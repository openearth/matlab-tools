#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 RoyalHaskoningDHV
#       Bart-Jan van der Spek
#
#       Bart-Jan.van.der.Spek@rhdhv.com
#
#       Laan 1914, nr 35
#       3818 EX Amersfoort
#       The Netherlands
#
#   This library is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Lesser General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this library.  If not, see <http://www.gnu.org/licenses/>.
#   --------------------------------------------------------------------
from Libraries.MapFunctions import *
from Libraries.StandardFunctions import *
from Libraries.ChartFunctions import *
from Scripts.UI_Examples.View import *
import clr
clr.AddReference("System.Windows.Forms")
from System.Windows.Forms import Button, DockStyle
from SharpMap.Extensions.Layers import GdalRegularGridRasterLayer as _RegularGridRasterLayer
from System.Collections.Generic import *
from System import *
import numpy as np
import os
from Scripts.LinearWaveTheory.Utilities import plotLinWaveTheory as lw

#from Scripts.BathymetryData.Bathy_UI_functions import *


def Plot_Crossection(ip,op):
	
	lineouter=CreateAreaSeries(op.alignment[op.cross_ind]['dims']['xyouter'])
	lineouter.Color = Color.LightGray
	lineouter.LineColor = Color.Black
	lineouter.LineWidth = 2
	lineouter.PointerVisible = False
	lineouter.PointerLineVisible = False
	lineouter.Transparency = 20
	#lineouter.Title="Crestheight: %.1f m+MSL Crestwidth: %.1f m " % (ip.crestheight,ip.crestwidth)
	
	
	linearmour=CreateAreaSeries(op.alignment[op.cross_ind]['dims']['xyarmour'])
	linearmour.Color = Color.DarkGray
	linearmour.LineVisible = False
	linearmour.PointerVisible = False
	linearmour.PointerLineVisible = False
	#linearmour.LineColor = Color.Black
	linearmour.Transparency = 20
	#linearmour.Title="Armour: Grading "+str(gradmin)+" - "+str(gradmax)+" kg"
	
	linefilter=CreateAreaSeries(op.alignment[op.cross_ind]['dims']['xyfilter'])
	linefilter.Color = Color.DimGray
	linefilter.LineVisible = False
	#linefilter.LineColor = Color.Black
	linefilter.PointerVisible = False
	linefilter.PointerLineVisible = False
	linefilter.Transparency = 20
	#linefilter.Title = "Filter: Grading "+str(gradmin_filter)+" - "+str(gradmax_filter)+" kg"
	
	"""xyMSL=np.vstack((xouter,[0,0,0,0])).T
	lineMSL=CreateLineSeries(xyMSL)
	lineMSL.Color = Color.Blue
	lineMSL.Width = 1.5
	lineMSL.PointerVisible = False
	lineMSL.Transparency = 0
	lineMSL.Title="MSL"""
	
	xySWL=np.vstack(([op.alignment[op.cross_ind]['dims']['xouter'][0],op.alignment[op.cross_ind]['dims']['xouter'][-1]],[ip.SWL,ip.SWL])).T
	lineSWL=CreateAreaSeries(xySWL)
	lineSWL.Color = Color.RoyalBlue
	lineSWL.LineVisible = False
	#lineSWL.LineColor = Color.MediumBlue
	lineSWL.PointerVisible = False
	lineSWL.PointerLineVisible = False
	lineSWL.Transparency = 75
	lineSWL.Title="SWL"
	
	chart = CreateChart([lineouter,linearmour,linefilter,lineSWL])
	chart.LeftAxis.Automatic = False
	if ip.is2D:
		chart.LeftAxis.Minimum = -op.profile['mean_z'][op.cross_ind]
	else:
		chart.LeftAxis.Minimum = -op.z
	
	chart.LeftAxis.Maximum = op.crestheight+2
	chart.LeftAxis.Title = "level w.r.t. MSL (m)"
	chart.BottomAxis.Title = "Distance (m)"
	chart.BackGroundColor = Color.White
	chart.Legend.Visible=False
	chart.Legend.Alignment=LegendAlignment.Right
	if ip.is2D:
		chart.Title="Breakwater section %d at %.1f m from coastline" %(op.cross_ind+1,op.profile['mean_dist'][op.cross_ind])
	else:
		chart.Title="Breakwater cross-section"
	
	chart.TitleVisible=True
	chart.Name="Breakwater design"
	
	plot1 = ChartView()
	plot1.Text = "Plot1"
	plot1.Chart = chart
	plot1.Dock = DockStyle.Fill
	
	return plot1
	
def Create_DimensionsText(ip,op):
	
	Sizes_rock = "\nRubble mound:\n" +\
	"Minimum Dn50:\t\t%.2f m\n" % op.Dn50['armour'] + \
	"Set Dn50:\t\t%.2f m\n" % op.Dn50['armour_grad'] + \
	"Armour:\t\t\t%.0f - %.0f kg\n" % (op.grad['min_armour'],op.grad['max_armour']) + \
	"Filter:\t\t\t%.0f - %.0f kg\n" % (op.grad['min_filter'],op.grad['max_filter']) +\
	"Armour thickness:\t%0.2f m\n" % op.layer['armour'] +\
	"Filter thickness:\t\t%0.2f m\n\n" % op.layer['filter']
	
	if op.isTooLarge['armour']:
		Sizes_rock += "Required Stone size is larger than available in grading table!!\n\n"
		
	if ip.autocrest:
		crestheight_text="%0.2f m (Auto)" % float(op.crestheight)
	else:
		crestheight_text="%0.2f m" % float(op.crestheight)
	
	if ip.is2D:
		localdepth = op.profile['mean_z'][op.cross_ind]
		breakwatlength = np.max(op.profile['dist']).Value
	else:
		localdepth = ip.z
		breakwatlength = 1.0
	
	Dimensions2_Text= \
	"Slope:\t\t\t1:%.0f \n" % ip.cota +\
	"Crestheight:\t\t"+crestheight_text+"\n" +\
	"Crestwidth:\t\t%0.2f m\n" % ip.crestwidth +\
	"Breakwater length:\t%.d m\n\n" % breakwatlength
	
	
	DimensionsText = Sizes_rock + Dimensions2_Text #+ Dimensions2_Text
	return DimensionsText
	
	
def Create_ConditionsText(ip,op):
	
	#defaultHeader = r"{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil\fcharset0 Calibri;}}"
	#colorsUsed = r"{\colortbl ;\red0\green0\blue255;\red0\green255\blue0;}"
	
	WaveOFF = \
	"\nOffshore:\n" +\
	"Hs:\t\t%.2f m \n"  % ip.Hs0 +\
	"Tp:\t\t%.1f s \n" % ip.Tp0 +\
	"Dir:\t\t%0.0f deg North \n" % ip.theta0 +\
	"Depth:\t\t%.2f m \n\n" % ip.z0 
	
	WaveNEAR = \
	"Nearshore: \n" +\
	"Hs:\t\t%.2f m \n"  % op.Hs +\
	"Tp:\t\t%.1f s \n" % op.Tp +\
	"Dir:\t\t%0.0f deg North \n" % op.theta +\
	"Depth:\t\t%.2f m \n\n" % op.z 
	
	if op.isPlunging:
		BreakerType="Plunging"
	else:
		BreakerType="Surging"
	
	Conditions_extra= \
	"Irribarren:\t\t%.2f\n" % op.irri +\
	"Breakertype:\t\t"+BreakerType+ "\n" +\
	"Wave steepness:\t%.2f\n" % op.stp +\
	"Number of waves:\t%.0f \n" % op.N +\
	"Rel. density:\t\t%.2f" % op.delta
	
	Conditions_Text = WaveOFF + WaveNEAR + Conditions_extra
	return Conditions_Text
	

def Create_VolumesText(ip,op):
	
	if ip.is2D:
		VolumesText1 = \
		"\nCross-sectional area at section %d :\n" % (op.cross_ind+1) +\
		"Armour:\t\t%.0f m3/m\n" % op.alignment[op.cross_ind]['area']['armour'] +\
		"Filter:\t\t%.0f m3/m\n" % op.alignment[op.cross_ind]['area']['filter'] +\
		"Core:\t\t%.0f m3/m\n" % op.alignment[op.cross_ind]['area']['core'] +\
		"Total:\t\t%.0f m3/m\n\n" % op.alignment[op.cross_ind]['area']['outer']+\
		"Costs:\n" +\
		"Armour:\t\t" + "{:,.0f}".format(float(op.costs_perm['armour'][op.cross_ind])) + " EUR/m\n"  +\
		"Filter:\t\t" + "{:,.0f}".format(float(op.costs_perm['filter'][op.cross_ind])) + " EUR/m\n" +\
		"Core:\t\t" + "{:,.0f}".format(float(op.costs_perm['core'][op.cross_ind])) + " EUR/m\n" +\
		"Total:\t\t" + "{:,.0f}".format(float(op.costs_perm['outer'][op.cross_ind])) + " EUR/m\n\n" 
	else:
		VolumesText1 = \
		"\nCross-sectional area at section %d :\n" % (op.cross_ind+1) +\
		"Armour:\t\t%.0f m3/m\n" % op.alignment[op.cross_ind]['area']['armour'] +\
		"Filter:\t\t%.0f m3/m\n" % op.alignment[op.cross_ind]['area']['filter'] +\
		"Core:\t\t%.0f m3/m\n" % op.alignment[op.cross_ind]['area']['core'] +\
		"Total:\t\t%.0f m3/m\n\n" % op.alignment[op.cross_ind]['area']['outer']+\
		"Costs:\n" +\
		"Armour:\t\t" + "{:,.0f}".format(float(op.costs_perm['armour'])) + " EUR/m\n"  +\
		"Filter:\t\t" + "{:,.0f}".format(float(op.costs_perm['filter'])) + " EUR/m\n" +\
		"Core:\t\t" + "{:,.0f}".format(float(op.costs_perm['core'])) + " EUR/m\n" +\
		"Total:\t\t" + "{:,.0f}".format(float(op.costs_perm['outer'])) + " EUR/m\n\n" 
	
	VolumesText2 = \
	"\nTotal volumes:\n" +\
	"Armour:\t\t" + "{:,.0f}".format(float(op.totalvolumes['armour'])) + " m3\n"  +\
	"Filter:\t\t" + "{:,.0f}".format(float(op.totalvolumes['filter'])) + " m3\n" +\
	"Core:\t\t" + "{:,.0f}".format(float(op.totalvolumes['core'])) + " m3\n" +\
	"Total:\t\t" + "{:,.0f}".format(float(op.totalvolumes['outer'])) + " m3\n\n" +\
	"Costs:\n" +\
	"Armour:\t\t" + "{:,.0f}".format(float(op.totalcosts['armour'])) + " EUR\n"  +\
	"Filter:\t\t" + "{:,.0f}".format(float(op.totalcosts['filter'])) + " EUR\n" +\
	"Core:\t\t" + "{:,.0f}".format(float(op.totalcosts['core'])) + " EUR\n" +\
	"Total:\t\t" + "{:,.0f}".format(float(op.totalcosts['outer'])) + " EUR\n\n" 
	
	
	
	if ip.is2D:
		VolumesText = VolumesText1 + VolumesText2
	else:
		VolumesText = VolumesText1
		
	
	return VolumesText


def Create_OvertoppingText(ip,op):
	
	if ip.autocrest:
		OvertoppingText = \
		"\nSafety level:\t\t " + ip.situation + "\n" +\
		"Allowable overtopping:\t%0.3f l/s/m\n" % ip.qthres +\
		"Current overtopping:\t%0.3f l/s/m\n" % op.qovertopping_crest +\
		"Required crestheight:\t%0.2f m+MSL\n" %  op.crestheight_required +\
		"Set crestheight:\t\t%0.2f m+MSL\n\n" % float(op.crestheight) 
	else:
		OvertoppingText = \
		"\nOvertopping: %0.3f l/s/m\n\n" % float(op.qovertopping_crest) 
		
	return OvertoppingText