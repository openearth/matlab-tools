from bokeh.plotting import figure, save, output_file, ColumnDataSource
from bokeh.models import HoverTool, Label, LinearColorMapper
import colorcet as cc
import numpy as np

# Author: Joan Sala Calero
# CLASS to generate bokeh plots for Fiber optics data
class rectangles_Plot:

    def __init__(self, alldata, allexp, allt0t1):
        self.alldata = alldata
        self.allexp = allexp
        self.allt0t1 = allt0t1

    def generate_plot(self, outfile, type, xsize=1800, ysize=800, minT=10, maxT=25, minD=0, maxD=10, axis=0):
        # Gather data
        colors = []
        patchX = []
        patchY = []
        meantemps = []
        mintemps = []
        maxtemps = []
        diftempst0t1 = []
        diftempsminmax = []
        expnumb = []
        y0=0
        y1=1

        for exp in self.alldata:
            # Every experiment [y-axis]
            x0=0
            x1=1
            metadata = self.allexp[y0]
            x, y, tdata = self.allt0t1[y0]

            # Get the temperature data matrix cutXY determined by columns=[t0,t1] rows=[x0,x1]
            #tdata = exp.tempmatrix[exp.idx0:exp.idx1, t0:t1]

            # Get number of rows
            dims = tdata.shape

            # For every distance[rows] or time[cols], append values
            for i in range(dims[axis]-1):
                # Slice distance
                if axis == 0:
                    vals = tdata[i, :]
                else:
                    vals = tdata[:, i]

                # Tooltips and so on
                expnumb.append(metadata.Number)
                meantemps.append(vals.mean())
                mintemps.append(vals.min())
                maxtemps.append(vals.max())
                difft0t1 = vals[-1] - vals[0]
                diffminmax = vals.max() - vals.min()
                diftempst0t1.append(difft0t1)
                diftempsminmax.append(diffminmax)

                if type == 'mean':
                    colors.append(cc.rainbow[int(max(0, min(1, (vals.mean()-minT) / (maxT-minT))) * 255)])
                elif type == 'min':
                    colors.append(cc.rainbow[int(max(0, min(1, (vals.min()-minT)/ (maxT-minT))) * 255)])
                elif type == 'max':
                    colors.append(cc.rainbow[int(max(0, min(1, (vals.max()-minT) / (maxT-minT))) * 255)])
                elif type == 'difft0t1':
                    colors.append(cc.rainbow[int(max(0, min(1, (difft0t1 - minD) / (maxD - minD))) * 255)])
                elif type == 'diffminmax':
                    colors.append(cc.rainbow[int(max(0, min(1, (diffminmax - minD) / (maxD - minD))) * 255)])

                # Axis [Distance or Time sample]
                if axis == 0:
                    patchX.append([y[x0], y[x0], y[x1], y[x1]])
                else:
                    patchX.append([x0, x0, x1, x1])
                patchY.append([y0, y1, y1, y0])
                x0+=1
                x1+=1

            # New experiment
            y0+=1
            y1+=1

        # - Source data dict
        source = ColumnDataSource(data=dict(
            x=patchX,
            y=patchY,
            color=colors,
            meantemp=meantemps,
            expnumb=expnumb,
            mintemp=mintemps,
            maxtemp=maxtemps,
            diftempst0t1=diftempst0t1,
            diftempsminmax=diftempsminmax
        ))

        # Title
        tit = 'Undefined plot'
        if type == 'mean':  tit = 'Mean Temperature [deg]'
        if type == 'min':  tit = 'Min Temperature [deg]'
        if type == 'max':  tit = 'Max Temperature [deg]'
        if type == 'difft0t1':  tit = 'Temperature Difference on/off [deg]'
        if type == 'diffminmax':  tit = 'Absolute Temperature Difference [deg]'

        # - Plot (patches)
        TOOLS="pan,wheel_zoom,box_zoom,reset,hover,save"
        p = figure(plot_width=xsize, plot_height=ysize, title=tit, tools=TOOLS)
        p.toolbar.logo = None
        p.grid.grid_line_color = None
        p.patches('x', 'y', source=source, fill_color='color', fill_alpha=0.7, line_color="black", line_width=0.5)

        # - Axis definition
        if axis == 0:
            p.xaxis.axis_label = "Distance [m]"
        else:
            p.xaxis.axis_label = "Time samples"

        p.yaxis.axis_label = "Experiment number"

        # - Mouse hover
        hover = p.select_one(HoverTool)
        hover.point_policy = "follow_mouse"
        hover.tooltips = """
        <div>
            <div>
                <span style="font-size: 12px;font-weight: bold;">Experiment nb:</span>
                <span style="font-size: 12px; color: #777777;">@expnumb</span>
            </div>        
            <div>
                <span style="font-size: 12px;font-weight: bold;">Mean Temperature:</span>
                <span style="font-size: 12px; color: #777777;">@meantemp</span>
            </div>
            <div>
                <span style="font-size: 12px;font-weight: bold;">Max Temperature:</span>
                <span style="font-size: 12px; color: #777777;">@maxtemp</span>
            </div>
            <div>
                <span style="font-size: 12px;font-weight: bold;">Min Temperature:</span>
                <span style="font-size: 12px; color: #777777;">@mintemp</span>
            </div>   
            <div>
                <span style="font-size: 12px;font-weight: bold;">Temperature difference [t1-t0]:</span>
                <span style="font-size: 12px; color: #777777;">@diftempst0t1</span>
            </div>   
            <div>
                <span style="font-size: 12px;font-weight: bold;">Temperature difference [max-min]:</span>
                <span style="font-size: 12px; color: #777777;">@diftempsminmax</span>
            </div>                                
        </div>
        """

        # - Output HTML
        output_file(outfile, title="Summary plot")
        print 'Saving {}'.format(outfile)
        save(p)