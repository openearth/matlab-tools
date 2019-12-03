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
import numpy as np
import math as math
import scipy as scipy
from Libraries.StandardFunctions import *
from Libraries.ChartFunctions import *
from Libraries.MapFunctions import *

from SharpMap.Editors.Interactors import Feature2DEditor
from SharpMap.UI.Tools import NewLineTool


from Scripts.BreakwaterDesign.Engine_functions import *
from Scripts.BreakwaterDesign.Input_dialog import *
from System import *
from System.Windows.Forms import MessageBox,BorderStyle,TableLayoutPanel, TableLayoutPanelGrowStyle, RowStyle,ColumnStyle, SizeType
from Scripts.UI_Examples.View import *
import clr
clr.AddReference("System.Windows.Forms")

#def Start_BW():



#region Define input parameters
class inputparam_BW():
	def __init__(self):
		self.Hs = 3
		self.Tp = 12
		self.SWL = 1
		self.cota = 3
		self.z = 10
		self.angleinc = 0
		self.Armour_Type = None
		self.rhos=2650
		self.rhow = 1000
		self.P = 0.4
		self.S = 2
		self.stormdur = 6
		self.autocrest = None
		self.crestheight = 0
		self.crestwidth = 5
		self.situation = None
		self.gammab = 1
		self.gammaf = 0.4
		self.kt = 1
		self.g = 9.81
		self.cpl = 6.2
		self.cs = 1.0
		self.qthres = 10
		self.length = 1000
		self.cross_ind = 4
ip=inputparam_BW()
#endregion

# Get UI input, overrides default values
[ip,Critical_type,armour_types] = get_UI_Input(ip)



#region Pre calculation of additional input variables
[tana,alfa]=get_varangle(ip.cota) 			# Variations of slope angle
Tm=calcMeanWavePeriod(ip.Tp) 				# Mean wave period
stp=steepness(ip.Hs,Tm,ip.g) 				# Wave steepness  
irri=irribarren(stp,tana) 					# Irribarren number
delta=calcRelativedensity(ip.rhos,ip.rhow) 	# Relative density
N=calcNumberofWaves(ip.stormdur,Tm) 		# Number of waves
ip.qthres = get_Qthres(ip,Critical_type) 	# Get qthreshold

#endregion

# Calculate Dn50 for Rock
[Dn50,irricrit,isPlunging]=vanderMeer_stability_rock(ip.Hs,delta,irri,ip.S,N,ip.P,ip.cpl,ip.cs,ip.cota)

# Get grading from table
[gradmin,gradmax,Dn50_grad,isTooLarge]=get_grading(Dn50)

#print "Armour: Grading "+str(gradmin)+" - "+str(gradmax)+" kg"

# Correction for oblique waves
gammabeta=calcGammabeta(ip.angleinc)

# Calculate overtopping
gamma_crest=calcGamma_crest(ip.crestwidth,ip.Hs)

if ip.autocrest: # If user want to auto determine required crest height
	Rc_required=calcRequired_crestheight(ip.qthres,ip.Hs,irri,ip.gammab,ip.gammaf,gammabeta,gamma_crest,tana,ip.g)
	crestheight_required=np.max([Rc_required,0])+ip.SWL
	#print "Required crest elevation = %.2f m with allowable overtopping of %.1f l/s/m" % (crestheight_required,ip.qthres)
	if crestheight_required>ip.crestheight:
		ip.crestheight=np.ceil(crestheight_required*4).Value/4
	
	#print "Crestheight adjusted to required crest height ( %.1f m)" % ip.crestheight

Rc=ip.crestheight-ip.SWL # Crestheight above SWL

qovertopping=calcOvertopping_TAW(ip.Hs,Rc,irri,ip.gammab,ip.gammaf,gammabeta,tana,ip.g)
qovertopping_crest=calcOvertopping_crest(qovertopping,gamma_crest)

M50=get_M50(Dn50,ip.rhos)
M50_grad=get_M50(Dn50_grad,ip.rhos)

[M50_filter,Dn50_filter]=getFilter_rock(M50_grad,ip.rhos)

[gradmin_filter,gradmax_filter,Dn50_grad_filter,isTooLarge_filter]=get_grading(Dn50_filter)

#print "Filter: Grading "+str(gradmin_filter)+" - "+str(gradmax_filter)+" kg"

layer_armour=getLayerthickness_rock(Dn50_grad,ip.kt)
layer_filter=getLayerthickness_rock(Dn50_grad_filter,ip.kt)


#region Profile dimensions
#Input profile, arbitrary
profile = {}
profile['dist'] = np.linspace(0,2000,11)
profile['z'] = np.linspace(30,5,11)

# Get profile spacing and mean at 'centre' points
profile = get_profile_mean(profile)
alignment = {}
volumes = {}

for ii in range(len(profile['mean_z'])):
	alignment[ii] = {}
	alignment[ii]['dims']=get_Breakwater_dimensions(ip.crestheight,ip.crestwidth,ip.cota,profile['mean_z'][ii],layer_armour,layer_filter)
	alignment[ii]['area']=get_Breakwater_areas(alignment[ii]['dims'])
	alignment[ii]['depth']=profile['mean_z'][ii]
	alignment[ii]['ds'] = profile['ds'][ii]
	alignment[ii]['volume'] = get_Breakwater_volumes(alignment[ii]['area'],profile['ds'][ii])
	
	for k,v in alignment[ii]['volume'].items():
		volumes[k] = np.zeros(len(profile['mean_z']))
	for k,v in alignment[ii]['volume'].items():
		volumes[k][ii] = v
		

totalvolumes = {}
for k,v in volumes.items():
	totalvolumes[k] = np.sum(v)
#endregion



#region Plotting
lineouter=CreateLineSeries(alignment[ip.cross_ind]['dims']['xyouter'])
lineouter.Color = Color.Black
lineouter.Width = 3
lineouter.PointerVisible = False
lineouter.Transparency = 0
lineouter.Title="Crestheight: %.1f m+MSL Crestwidth: %.1f m " % (ip.crestheight,ip.crestwidth)


linearmour=CreateLineSeries(alignment[ip.cross_ind]['dims']['xyarmour'])
linearmour.Color = Color.Black
linearmour.Width = 2
linearmour.PointerVisible = False
linearmour.Transparency = 0
linearmour.Title="Armour: Grading "+str(gradmin)+" - "+str(gradmax)+" kg"


linefilter=CreateLineSeries(alignment[ip.cross_ind]['dims']['xyfilter'])
linefilter.Color = Color.Black
linefilter.Width = 1
linefilter.PointerVisible = False
linefilter.Transparency = 0
linefilter.Title = "Filter: Grading "+str(gradmin_filter)+" - "+str(gradmax_filter)+" kg"

"""xyMSL=np.vstack((xouter,[0,0,0,0])).T
lineMSL=CreateLineSeries(xyMSL)
lineMSL.Color = Color.Blue
lineMSL.Width = 1.5
lineMSL.PointerVisible = False
lineMSL.Transparency = 0
lineMSL.Title="MSL"""

xySWL=np.vstack((alignment[ip.cross_ind]['dims']['xouter'],[ip.SWL,ip.SWL,ip.SWL,ip.SWL])).T
lineSWL=CreateLineSeries(xySWL)
lineSWL.Color = Color.Blue
lineSWL.Width = 1.5
lineSWL.PointerVisible = False
lineSWL.Transparency = 0
lineSWL.Title="SWL"

chart = CreateChart([lineouter,linearmour,linefilter,lineSWL])
chart.LeftAxis.Automatic = False
chart.LeftAxis.Minimum = -profile['mean_z'][ip.cross_ind]
chart.LeftAxis.Maximum = ip.crestheight+2
chart.LeftAxis.Title = "level w.r.t. MSL (m)"
chart.BottomAxis.Title = "Distance (m)"
chart.BackGroundColor = Color.White
chart.Legend.Visible=False
chart.Legend.Alignment=LegendAlignment.Right
chart.Title="Breakwater section %d at %.1f m offshore" %(ip.cross_ind+1,np.max(profile['dist']).Value - profile['dist'][ip.cross_ind])
chart.TitleVisible=True
chart.Name="Breakwater design"

"""for view in Gui.DocumentViews:
	if (view.Text == chart.Name):
		viewToRemove = view
		break
print "Remove" + viewToRemove.Text
Gui.DocumentViews.Remove(viewToRemove)
"""
#OpenView(chart)
#endregion


#region Create Outputtext

Outputtext_rock = "Rubble mound:\n" +\
"Minimum Dn50:\t\t%.2f m\n" % Dn50 + \
"Set Dn50:\t\t%.2f m\n" % Dn50_grad + \
"Armour:\t\t\t%.0f - %.0f kg\n" %(gradmin,gradmax) + \
"Filter:\t\t\t%.0f - %.0f kg\n" % (gradmin_filter,gradmax_filter) +\
"Armour thickness:\t%0.2f m\n" % layer_armour +\
"Filter thickness:\t\t%0.2f m\n\n" % layer_filter

if isTooLarge:
	Outputtext_rock += "Required Stone size is larger than available in grading table!!\n\n"
	
if ip.autocrest:
	Outputtext_overtopping = \
	"Allowable overtopping:\t%0.3f l/s/m " % ip.qthres + "(" + ip.situation + ")\n" +\
	"Current overtopping:\t%0.3f l/s/m\n" % qovertopping_crest +\
	"Required crestheight:\t%0.3f m+MSL\n" %  crestheight_required +\
	"Set crestheight:\t\t%0.3f m+MSL\n\n" % ip.crestheight 
else:
	Outputtext_overtopping = \
	"Overtopping: %0.3f l/s/m\n\n" % qovertopping_crest 

Outputtext_dimensions = \
"Cross-sectional area at section %d :\n" % (ip.cross_ind+1) +\
"Armour:\t%.0f m3/m\n" % alignment[ip.cross_ind]['area']['armour'] +\
"Filter:\t%.0f m3/m\n" % alignment[ip.cross_ind]['area']['filter'] +\
"Core:\t%.0f m3/m\n" % alignment[ip.cross_ind]['area']['core'] +\
"Total:\t%.0f m3/m\n\n" % alignment[ip.cross_ind]['area']['outer'] +\
"Total volume:\n"+\
"Armour:\t%.0f m3\n" % totalvolumes['armour'] +\
"Filter:\t%.0f m3\n" % totalvolumes['filter'] +\
"Core:\t%.0f m3\n" % totalvolumes['core'] +\
"Total:\t%.0f m3\n\n" % totalvolumes['outer'] 

Outputtext = Outputtext_rock + Outputtext_overtopping + Outputtext_dimensions

#endregion


#region Input text
Inputtext_wavecon= \
"Hs:\t%0.1f m\n" % ip.Hs +\
"Tp:\t%0.1f s\n" % ip.Tp +\
"SWL:\t%0.1f m+MSL\n" % ip.SWL +\
"Angle of incidence: %0.0f deg\n" % ip.angleinc +\
"Stormduration: %0.1f h\n\n" % ip.stormdur 

Inputtext_funcpar= \
"Permeability (P): %.1f\n" % ip.P +\
"Damage number (S): %.0f\n" % ip.S +\
"Rock density: %.0f kg/m3\n\n" % ip.rhos

Inputtext_gammas= \
"Reduction factors: \n" +\
"Berm:\t\t%.1f\n" % ip.gammab +\
"Roughness:\t%.1f\n" % ip.gammaf +\
"Oblique waves:\t%.1f\n" % gammabeta +\
"Crestwidth:\t%.1f" % gamma_crest 

Inputtext_left = Inputtext_wavecon + Inputtext_funcpar + Inputtext_gammas


if ip.autocrest:
	crestheight_text="%0.2f m (Auto)" % ip.crestheight
else:
	crestheight_text="%0.2f m" % ip.crestheight

Inputtext_dim= \
"Slope 1:%.0f \n" % ip.cota +\
"Crestheight: "+crestheight_text+"\n" +\
"Crestwidth: %0.2f m\n" % ip.crestwidth +\
"Local depth: %.1f m\n" % profile['mean_z'][ip.cross_ind] +\
"Breakwater length: %.d m\n\n" % np.max(profile['dist']).Value

if isPlunging:
	BreakerType="Plunging"
else:
	BreakerType="Surging"

Inputtext_extra= \
"Irribarren: %.2f\n" % irri +\
"Breakertype: "+BreakerType+ "\n" +\
"Wave steepness: %.2f\n" % stp +\
"Number of waves: %.0f \n" % N +\
"Rel. density: %.2f" % delta

Inputtext_right = Inputtext_dim + Inputtext_extra

#endregion

#region Viewer

view = View()
view.Text = "Breakwater design"

Inputlabel1 = RichTextBox()
Inputlabel1.Dock = DockStyle.Fill
Inputlabel1.BackColor = Color.FromArgb(249,249,249)
Inputlabel1.BorderStyle = BorderStyle.None
Inputlabel1.ReadOnly = True
Inputlabel1.Text = Inputtext_left

Inputlabel2 = RichTextBox()
Inputlabel2.Dock = DockStyle.Fill
Inputlabel2.BackColor = Color.FromArgb(249,249,249)
Inputlabel2.BorderStyle = BorderStyle.None
Inputlabel2.ReadOnly = True
Inputlabel2.Text = Inputtext_right

# create table layout
Inputtable = TableLayoutPanel()
Inputtable.Dock = DockStyle.Fill

# define 2 column
Inputtable.ColumnCount = 2
Inputtable.ColumnStyles.Add(ColumnStyle(SizeType.Percent, 50))
Inputtable.ColumnStyles.Add(ColumnStyle(SizeType.Percent, 50))


# define 1 rows
Inputtable.RowCount = 1
Inputtable.RowStyles.Add(RowStyle(SizeType.Percent, 100))

Inputtable.Controls.Add(Inputlabel1,0,0)
Inputtable.Controls.Add(Inputlabel2,1,0)


InputPanel1 = GroupBox()
InputPanel1.Text = "Input parameters"
InputPanel1.Controls.Add(Inputtable)
InputPanel1.Dock = DockStyle.Fill

mapview = MapView()
mapview.Dock = DockStyle.Fill
mapview.Map.Layers.Add(CreateSatelliteImageLayer())
mapview.Height = 100

splitPlot1 = SplitContainer()
splitPlot1.Dock = DockStyle.Fill
splitPlot1.Orientation = Orientation.Vertical
splitPlot1.Panel1.Controls.Add(InputPanel1)
splitPlot1.Panel2.Controls.Add(mapview)

plot1 = ChartView()
plot1.Chart = chart
plot1.Dock = DockStyle.Fill
#view.Controls.Add(plot1)


Outputlabel1 = RichTextBox()
#Outputlabel1.Text = Outputtext
Outputlabel1.Dock = DockStyle.Fill
Outputlabel1.BackColor = Color.FromArgb(249,249,249)
Outputlabel1.BorderStyle = BorderStyle.None
Outputlabel1.ReadOnly = True
Outputlabel1.Text = Outputtext

OutputPanel1 = GroupBox()
OutputPanel1.Controls.Add(Outputlabel1)
OutputPanel1.Dock = DockStyle.Fill
OutputPanel1.Text = "Output parameters" 

splitPlot2 = SplitContainer()
splitPlot2.Dock = DockStyle.Fill
splitPlot2.Orientation = Orientation.Vertical
splitPlot2.Panel1.Controls.Add(plot1)
splitPlot2.Panel2.Controls.Add(OutputPanel1)

totalsplit = SplitContainer()
totalsplit.Dock = DockStyle.Fill
totalsplit.Orientation = Orientation.Horizontal
totalsplit.Panel1.Controls.Add(splitPlot1)
totalsplit.Panel2.Controls.Add(splitPlot2)

view.Controls.Add(totalsplit)
#view.Controls.Add(splitPlot2)
#view.Controls.Add(splitPlot1)


view.Show()
#endregion
	
#Start_BW()
