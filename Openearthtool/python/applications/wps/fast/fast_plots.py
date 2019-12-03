# -*- coding: utf-8 -*-
"""
Created on Fri Nov 25 13:57:43 2016

@author: sala
"""
from bokeh.plotting import figure, save, output_file, ColumnDataSource
from bokeh.models import Legend, tickers, Label, Arrow, VeeHead, NormalHead, LinearAxis, Range1d, BasicTicker
from bokeh.models.glyphs import ImageURL
from scipy.stats import linregress
import numpy as np
import logging
import re
import math

DEBUG = False # uncomment to debug

## Auxiliary function
def unicode_to_array(arraystr):
    arr = re.findall("[-+]?\d+[\.]?\d*[eE]?[-+]?\d*", arraystr)
    ret = []
    mn = 0.
    for a in arr:
       ret.append(float(a))
       mn+=float(a)
    
    if len(ret) > 0:    return (ret, float(mn/len(ret))) # array and mean
    else:               return (ret, None)

class bokeh_fast_plot:
    def __init__(self, expert_mode, slope, veget, waterlev, surge, output_html, output_html_summary, surge_noveg=None, wave_levee=None, wave_levee_veg=None, xaxis=None, plotX0=None, plotXN=None, begX=None, endX=None, imask=None):
        
        # SLOPE and shore (Expert vs Educational)        
        self.begX = begX
        self.endX = endX
        self.expert_mode = expert_mode
        if expert_mode:      
            (self.yslope,_) = unicode_to_array(slope)
            (self.xslope,_) = unicode_to_array(xaxis)
            self.imask = []
        else:                           
            (self.xslope, self.yslope) = zip(*slope)
            self.imask = imask
        
        # VEGETATION (Expert vs Educational) 
        if expert_mode:      
            (self.yveg,_) = unicode_to_array(veget)
            self.xveg = np.linspace(min(self.xslope), max(self.xslope), num=len(self.yveg))
        else:                           
            (self.xveg, self.yveg) = zip(*veget)

        # WATERLEVEL (Expert vs Educational) 
        if expert_mode:   
            (self.waterlev, self.mean_waterlevel) = unicode_to_array(waterlev)
        else:                           
            (self.waterlev, self.mean_waterlevel) = (None, float(waterlev))
        
        # SURGE (Expert vs Educational) 
        if expert_mode:   
            (self.surge, self.mean_surge) = unicode_to_array(surge)
            (self.surge_noveg, self.mean_surge_noveg) = unicode_to_array(surge_noveg)
            # Multiply by SQRT(2)
            self.surge = [s * math.sqrt(2) for s in self.surge]
            self.surge_noveg = [s * math.sqrt(2) for s in self.surge_noveg]
            self.begX = 0.0
            self.endX = self.xslope[0:len(self.surge)][-1]
        else:    
            self.surge = float(surge)         
            self.mean_surge = float(surge)
            self.wave_levee_veg = float(wave_levee_veg)
            self.wave_levee = float(wave_levee)
            
        # Plot settings
        self.xaxis = xaxis
        self.output_html = output_html
        self.output_html_summary = output_html_summary
        
        if expert_mode: 
            self.plotX0 = plotX0
            self.plotXN = plotXN
            # Plot zoom
            self.xslope[:] = [x - plotX0 for x in self.xslope]
            self.xveg[:] = [x - plotX0 for x in self.xveg]
            self.plotXN -= self.plotX0
            self.plotX0 = 0.0            
        else:                   
            self.plotX0 = self.xslope[0]
            self.plotXN = self.xslope[-1]

        # Plot colors
        self.color_water = "#ADD8E6" 
        self.color_surge = "#0994D5" 
        self.color_surge_noveg = '#0032AD'
        self.color_wave_levee = "#FF00FF" 
        self.color_wave_levee_veg = "#7700FF" 
        self.color_elevation = "#8B4513" 
        self.color_srtm = "#D2691E"
        self.color_intertidal = "#CD8B4E"
        self.color_vegetation = "#008000"
        self.color_highlighted = "#ffa500"
        self.color_linestr = "#f50076"
    
    # Intersect water/land
    def intersect_water_land(self, water_thr, x, y):
        # Get correlation
        linres=linregress(x, y)
        
        # Two possible coast directions
        if linres.slope < 0:   
            i=len(y)-2
            sign=-1
        else:
            i=1
            sign=1
            
        while i<len(y)-1 and i>0:
            if(y[i]>water_thr): break
            i+=sign
            
        return (int(x[i]), sign) # Return at what dist and sign
    
    def get_plot_bounds(self, arrX, arrY, plotX0, plotXN):
        
        (minX, maxX, minY, maxY, N, e) = (99999999, -99999999, 99999999, -99999999, 0, 0)
        
        while (e < len(arrX)):
            if arrX[e] != None and arrY[e] != None:
                if (arrX[e] <= plotXN and arrX[e] >= plotX0): # within limits           
                    N+=1
                    minX = min(minX, arrX[e])
                    minY = min(minY, arrY[e])
                    maxX = max(maxX, arrX[e])
                    maxY = max(maxY, arrY[e])
                e+=1        
        
        if DEBUG:
            logging.info('-----------------------------------------------------')
            logging.info(str((minX, maxX, minY, maxY)))
            logging.info('-----------------------------------------------------')

        return (minX, maxX, minY, maxY)

    # Summary tab plot [simplified]
    def plot_summary(self):
        # Figure settings
        p = figure(plot_width=730, plot_height=350, tools="", toolbar_location=None, x_range=(0,4), y_range=(0,110))
        
        # AXIS       
        p.xaxis.visible = False
        p.yaxis.axis_label = "Wave Height [%]"
        p.toolbar.logo = None 

        # PLOT [expert]
        if self.expert_mode:
            wl = 100
            wle = 100.0 * self.surge_noveg[-1]/self.surge_noveg[0]
            wlv = 100.0 * self.surge[-1]/self.surge[0]
        # PLOT [educational]
        else:      
            wl = 100
            wle = 100.0 * self.wave_levee/self.mean_surge
            wlv = 100.0 * self.wave_levee_veg/self.mean_surge
            
        # - Source data dict
        colors = [self.color_water, self.color_intertidal, self.color_vegetation]
        patchX = [[0,0,1,1], [2,2,3,3], [3,3,4,4]]
        patchY = [[0,wl,wl,0], [0,wle,wle,0], [0,wlv,wlv,0]]
        source = ColumnDataSource(data=dict(
            x=patchX,
            y=patchY,
            color=colors
        ))    

        logging.info('-----------------------------------------------------')
        logging.info('Summary Plot [wl = {}, wl_elev = {}, wl_veg = {}]'.format(wl,wle,wlv))
        logging.info('Summary Plot [wl = {}, wl_elev = {}, wl_veg = {}]'.format(wl,wle,wlv))
        logging.info('-----------------------------------------------------')

        # Plot data
        p.toolbar.logo = None 
        p.image_url(url=['http://fast.openearth.eu/site/img/waves.png'], x=0, y=wl, w=None, h=None, anchor='bottom_left', dilate=True)
        p.image_url(url=['http://fast.openearth.eu/site/img/sandrocks.png'], x=2, y=wle, w=None, h=None, anchor='bottom_left', dilate=True)
        p.image_url(url=['http://fast.openearth.eu/site/img/vegetation.png'], x=3, y=wlv, w=None, h=None, anchor='bottom_left', dilate=True)
        p.line([0, 1], [wl, wl], color='blue', line_width=3, line_dash="10 4")
        p.line([0, 3], [wle, wle], color='brown', line_width=3, line_dash="10 4")
        p.line([0, 4], [wlv, wlv], color='green', line_width=3, line_dash="10 4")

        p.patches('x', 'y', source=source, fill_color='color', fill_alpha=0.7, line_color="white", line_width=0.5)

        # Save plot
        output_file(self.output_html_summary, title="generated with bokeh_fast_plot.py")
        save(p)

    # Context tab plot
    def plot(self):

        # Calculate settings     
        (minX, maxX, floor, ceil) = self.get_plot_bounds(self.xslope, self.yslope, self.plotX0, self.plotXN)  
        Nslope = len(self.xslope)
        Nveg = len(self.xveg)
           
        # Figure settings
        p = figure(plot_width=730, plot_height=350, tools="", toolbar_location=None) 
     
        # YRANGE
        p.y_range.start = min([floor, self.mean_waterlevel, self.mean_surge])
        p.y_range.end = max([ceil, self.mean_waterlevel, self.mean_surge])
        yrange = abs(p.y_range.end - p.y_range.start)
        p.y_range.end += (0.25*yrange)
        p.y_range.start -= (0.25*yrange)
        totalheight = p.y_range.end-p.y_range.start

        # XRANGE
        p.x_range.start = float(self.plotX0)
        p.x_range.end = float(self.plotXN)
        totaldist = float(self.plotXN) - float(self.plotX0)

        # AXIS
        p.grid[0].ticker.desired_num_ticks = 10
        p.grid[1].ticker.desired_num_ticks = 6
        
        p.xaxis.axis_label = "Cross-shore distance [m]"
        p.yaxis.axis_label = "Surface elevation [m]"
        p.xaxis.axis_label_text_font_size = "9pt"
        p.yaxis.axis_label_text_font_size = "9pt"
        p.xgrid.grid_line_color = None
        p.ygrid.grid_line_color = None
        
        # Extra Y-Axis (right) - expert[array] vs educational[value]
        if self.expert_mode:	
            extra_y_max = 1.25*max(self.surge)
            p.extra_y_ranges = {"wave": Range1d(start=0, end=extra_y_max)}
            tick = BasicTicker(num_minor_ticks=2, desired_num_ticks=5)
            secondyaxis = LinearAxis(ticker=tick, y_range_name="wave", axis_label='wave [m]')        
            p.add_layout(secondyaxis, 'right')            

        # Sea and Land arrow
        if not(self.expert_mode):
            p.add_layout(Arrow(line_width=4, line_color=self.color_linestr, end=NormalHead(line_color=self.color_linestr,fill_color=self.color_linestr,size=20), x_start=self.plotX0, y_start=p.y_range.end-totalheight*0.1, x_end=self.plotXN, y_end=p.y_range.end-totalheight*0.1))
        
        # Calculation arrow
        p.add_layout(Arrow(line_width=4, line_color=self.color_highlighted, end=NormalHead(line_color=self.color_highlighted,fill_color=self.color_highlighted,size=10), x_start=self.begX, y_start=p.y_range.end-totalheight*0.1, x_end=self.endX, y_end=p.y_range.end-totalheight*0.1))
        p.add_layout(Arrow(line_width=4, line_color=self.color_highlighted, end=NormalHead(line_color=self.color_highlighted,fill_color=self.color_highlighted,size=10), x_start=self.endX, y_start=p.y_range.end-totalheight*0.1, x_end=self.begX, y_end=p.y_range.end-totalheight*0.1))
        p.add_layout(Arrow(line_width=2, line_dash="10 4", line_color=self.color_highlighted, end=NormalHead(line_color=self.color_highlighted,fill_color=self.color_highlighted,size=1), x_start=self.begX, y_start=p.y_range.start, x_end=self.begX, y_end=p.y_range.end-totalheight*0.1))
        p.add_layout(Arrow(line_width=2, line_dash="10 4", line_color=self.color_highlighted, end=NormalHead(line_color=self.color_highlighted,fill_color=self.color_highlighted,size=1), x_start=self.endX, y_start=p.y_range.start, x_end=self.endX, y_end=p.y_range.end-totalheight*0.1))

        if DEBUG:
            logging.info('-----------------------------------------------------')
            logging.info('Plot(xslope) = ' + str(self.xslope))
            logging.info('Plot(yslope) = ' + str(self.yslope))
            logging.info('Plot(xveg) = ' + str(self.xveg))
            logging.info('Plot(yveg) = ' + str(self.yveg))
            logging.info('Plot(begX) = ' + str(self.begX))
            logging.info('Plot(endX) = ' + str(self.endX))            
            logging.info('X - Plot(plotx0, plotxend) = ' + str(self.plotX0)+', '+str(self.plotXN))
            logging.info('Y - Plot(ceil, floor, yrange) = ' + str(ceil)+', '+str(floor)+', '+str(yrange))
            logging.info('Plot(minX, maxX, floor, ceil) = ' + str(minX)+', '+str(maxX)+', '+str(floor)+', '+str(ceil))
            logging.info('Plot(Nslope, Nveg) = ' + str(Nslope)+', '+str(Nveg))
            logging.info('-----------------------------------------------------')
                
        # Intersect land/water
        (wcoast, wsign) = self.intersect_water_land(self.mean_waterlevel, self.xslope, self.yslope)

        # Water (detect which side)
        minfloor=-9999
        if wcoast == maxX or wcoast == minX:
            p.patch([minX, minX, maxX, maxX, minX], [minfloor, self.mean_waterlevel, self.mean_waterlevel, minfloor, minfloor], color=self.color_water, line_width=2) # FULL
            if DEBUG: logging.info('FULL')
        else:
            if wsign < 0:
                p.patch([wcoast, wcoast, maxX, maxX, wcoast], [minfloor, self.mean_waterlevel, self.mean_waterlevel, minfloor, minfloor], color=self.color_water, line_width=2) # HALF-RIGHT
                if DEBUG: logging.info('HALF-RIGHT')
            else:
                p.patch([minX, minX, wcoast, wcoast, minX], [minfloor, self.mean_waterlevel, self.mean_waterlevel, minfloor, minfloor], color=self.color_water, line_width=2) # HALF-LEFT
                if DEBUG: logging.info('HALF-LEFT')
            
        # Topography
        lastx=0
        lasty=minfloor
        i=0
        xpatches = []
        ypatches = []
        colors = []

        while (i<Nslope):
            x1=self.xslope[i]
            y0=floor
            y1=self.yslope[i]
            # Shore color
            if (lastx in self.imask) or self.expert_mode:     
                colors.append(self.color_intertidal)  
            else:
                colors.append(self.color_srtm)

            xpatches.append([lastx,lastx,x1,x1,lastx])
            ypatches.append([minfloor,lasty,y1,minfloor,minfloor])            
            lastx=x1
            lasty=y1
            i+=1

        # plot at once
        p.patches(xs=xpatches, ys=ypatches, color=colors, line_width=2)
        p.line(self.xslope, self.yslope, color=self.color_elevation, line_width=3)

        # Vegetation - Educational versus expert
        yv = []
        i = 0
        while (i<Nveg):
            if self.yveg[i] == -999999 or self.yveg[i] == 0 or self.yveg[i] == None:
                yv.append(float('NaN'))
            else:
                if self.expert_mode:    yv.append(self.yslope[i])
                else:                   yv.append(self.yveg[i])
            i+=1
        p.line(self.xveg, yv, color=self.color_vegetation, line_width=4)
        #p.circle(self.xveg, yv, color='#93BD39', size=3)
                           
        # Surge - Educational versus expert - Intersect land/water    
        if self.expert_mode:
            p.line(self.xslope[0:len(self.surge)], self.surge, line_width=3, color=self.color_surge, y_range_name="wave") 
            p.line(self.xslope[0:len(self.surge_noveg)], self.surge_noveg, line_dash="6 4", line_width=3, color=self.color_surge_noveg, y_range_name="wave") 
        # No lines in educational // else:
            #(xs, ssign) = self.intersect_water_land(self.mean_surge, self.xslope, self.yslope) 
            #p.line([minX, xs], [self.mean_surge, self.mean_surge], line_dash="6 4", line_width=3, color=self.color_surge)
            #p.line([minX, maxX], [self.wave_levee_veg, self.wave_levee_veg], line_dash="6 4", line_width=3, color=self.color_wave_levee_veg, y_range_name="wave")
            #p.line([minX, maxX], [self.wave_levee, self.wave_levee], line_dash="4 6", line_width=3, color=self.color_wave_levee, y_range_name="wave")             

        # Save plot
        output_file(self.output_html, title="generated with bokeh_fast_plot.py")
        save(p)
