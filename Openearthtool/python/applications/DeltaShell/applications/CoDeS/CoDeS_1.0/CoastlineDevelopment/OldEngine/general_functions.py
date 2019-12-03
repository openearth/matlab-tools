#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#
#       Freek Scheel
#
#       freek.scheel@deltares.nl
#
#       P.O. Box 177
#       2600 MH Delft
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
# Some variables to get from import later:

import numpy as np
from Libraries.StandardFunctions import *
from Libraries.MapFunctions import *
from SharpMap.Extensions.Layers import OpenStreetMapLayer as OSML

import Scripts.LinearWaveTheory as lwt

from System.Drawing.Drawing2D import LineCap, DashStyle
from NetTopologySuite.Extensions.Features import DictionaryFeatureAttributeCollection
from SharpMap.Api.Enums import HorizontalAlignmentEnum

import scipy as sp

import clr
clr.AddReference("System.Windows.Forms")
from System import *
from System.Collections.Generic import *
from DelftTools.Controls.Swf import CustomInputDialog
from System.Windows.Forms import DialogResult
from System.Windows.Forms import MessageBox

from System.Windows.Forms import PictureBox,DockStyle
from System.Drawing import Bitmap

import time

def plotting_transports(alongshore_transport,basepoints_compute,endpoints_compute,basepoints_plot,endpoints_plot,crossshore_orientation_cross_towards_land,CS_code_plot,CS_codes_compute,map):
	
	# Create map and add layers
	if map == None:
		map = Map()
		map.CoordinateSystem = CreateCoordinateSystem(3857) # EPSG code => WGS 84 / Pseudo-Mercator for plotting
		
		CoDeS_map = OpenView(map)
		
		OSML_layer = OSML()
		OSML_layer.Name = "OpenStreetMaps"
		map.Layers.Add(OSML_layer)
		
		map.Name = "CoDeS - " + alongshore_transport['function name'] + " formula"
		
		plot_cs_profiles = True
	else: # Map already present, check for old plots:
		map = map.Map
		ind_to_rem = []
		for layer_ind in range(0,len(map.Layers)):
			# Finds all layers to be removed:
			if map.Layers[layer_ind].Name == "Transport arrows and values":
				ind_to_rem.append(layer_ind)
			#elif map.Layers[layer_ind].Name == "Basepoints":
			#	ind_to_rem.append(layer_ind)
			#elif map.Layers[layer_ind].Name == "Cross-shore rays":
			#	ind_to_rem.append(layer_ind)
		ind_to_rem.reverse()
		for i in ind_to_rem:
			map.Layers.Remove(map.Layers[i])
		
		plot_cs_profiles = False
	
	cross_shore_features = []
	basepoint_features   = []
	
	# harbour_features.append(Feature(Geometry = CreateLineGeometry([start_point_of_coast,end_point_of_coast])))
	# harbour_features.append(Feature(Geometry = CreatePointGeometry(basepoint_of_harbour[0],basepoint_of_harbour[1])))
	
	pos_dir = crossshore_orientation_cross_towards_land - 90
	
	for ind in range(0,np.size(alongshore_transport['mass transport per set [kg/s]'],0)):
		
		basepoint_features.append(Feature(Geometry = CreatePointGeometry(basepoints_plot[ind][0],basepoints_plot[ind][1])))
		
		basepoint_features[-1].Attributes = DictionaryFeatureAttributeCollection()
		basepoint_features[-1].Attributes['title'] = "  Alongshore transports according to the " + alongshore_transport['function name'] + " formula  "
		
		cross_shore_features.append(Feature(Geometry = CreateLineGeometry([basepoints_plot[ind],endpoints_plot[ind]])))
		
		feature_length     = np.sqrt(((basepoints_compute[ind][0]-endpoints_compute[ind][0])**2) + ((basepoints_compute[ind][1]-endpoints_compute[ind][1])**2)).Value
		
		basepoints_arrows  = np.array([basepoints_compute[ind][0] + np.sin(np.pi*(crossshore_orientation_cross_towards_land[ind]-180)/180)*feature_length*np.array([0.25,0.50,0.75]),basepoints_compute[ind][1] + np.cos(np.pi*(crossshore_orientation_cross_towards_land[ind]-180)/180)*feature_length*np.array([0.25,0.50,0.75])])
		
		neg_pos_net        = np.array([alongshore_transport['gross neg/pos volume transport [m3/yr.]'][1,ind].Value,alongshore_transport['gross neg/pos volume transport [m3/yr.]'][0,ind].Value,alongshore_transport['net volume transport [m3/yr.]'][ind].Value])
		
		rel_max_dist_to_L  = feature_length*0.3
		
		endpoints_arrows   = np.array([basepoints_arrows[0]+np.sin(np.pi*pos_dir[ind]/180)*rel_max_dist_to_L*(neg_pos_net/(np.max(np.abs(neg_pos_net)).Value+(10**(-20)))),basepoints_arrows[1]+np.cos(np.pi*pos_dir[ind]/180)*rel_max_dist_to_L*(neg_pos_net/(np.max(np.abs(neg_pos_net)).Value+(10**(-20))))])
		
		current_transport_code = CS_codes_compute[ind]
		transport_features = []
		for i in np.array([0,1,2]):
			
			transport_features.append(Feature(Geometry = CreateLineGeometry([np.array([basepoints_arrows[0][i].Value,basepoints_arrows[1][i].Value]),np.array([endpoints_arrows[0][i].Value,endpoints_arrows[1][i].Value])])))
			
			transport_features[-1].Attributes = DictionaryFeatureAttributeCollection()
			
			transport_features[-1].Attributes['title'] = str(int(np.abs(neg_pos_net[i]).Value)) + " m3/yr."
		transport_features_layer = CreateLayerForFeatures("Transport arrows and values", transport_features, CreateCoordinateSystem(current_transport_code))
		map.Layers.Insert(0,transport_features_layer)
		
		style_var = transport_features_layer.Style
		
		transport_features_layer.Style.Line.Color    = Color.LightSeaGreen
		transport_features_layer.Style.Line.Width    = 10
		transport_features_layer.Style.Line.EndCap   = LineCap.ArrowAnchor
		
		ShowLayerLabels(transport_features_layer, "title")
	
	### Place everything in features:
	
	# Basepoint layer:
	
	if plot_cs_profiles:
		basepoint_layer = CreateLayerForFeatures("Basepoints", basepoint_features, CreateCoordinateSystem(CS_code_plot))
		map.Layers.Insert(0,basepoint_layer)
	
	#ShowLayerLabels(basepoint_layer, "title")
	#if np.mean(crossshore_orientation_cross_towards_land).Value < 180.0:
	#	basepoint_layer.LabelLayer.Style.HorizontalAlignment = HorizontalAlignmentEnum.Left
	#else:
	#	basepoint_layer.LabelLayer.Style.HorizontalAlignment = HorizontalAlignmentEnum.Right
	
	# Cross-shore layer
	if plot_cs_profiles:
		cross_shore_layer = CreateLayerForFeatures("Cross-shore rays", cross_shore_features, CreateCoordinateSystem(CS_code_plot))
		map.Layers.Insert(0,cross_shore_layer)
		
		cross_shore_layer.Style.Line.Color     = Color.Black
		cross_shore_layer.Style.Line.Width     = 5
		cross_shore_layer.Style.Line.DashStyle = DashStyle.Dot
	
	
	if plot_cs_profiles:
		# Only do this for a new plot
		ZoomToLayer(cross_shore_layer)

def crossshore_to_orientation(basepoints,endpoints):
	
	coast_orientation = np.zeros((np.size(basepoints)/2,1))
	for i in range(0,(np.size(basepoints)/2)):
		end_point   = np.array(basepoints[i])
		start_point = np.array(endpoints[i])
		
		x_diff = np.diff([start_point[0],end_point[0]])
		y_diff = np.diff([start_point[1],end_point[1]])
		
		coast_orientation[i] = np.arctan2(x_diff,y_diff)/np.pi*180
		if float(coast_orientation[i]) < 0:
			coast_orientation[i] = coast_orientation[i]+360
		
	return coast_orientation
def get_wave_classes(wave_classes):
	
	H_s   = np.array([])
	T_p   = np.array([])
	dir   = np.array([])
	occ   = np.array([])
	names = np.array([])
	for ii in wave_classes:
		values = [float(i) for i in wave_classes[ii]]
		H_s = np.append(H_s,values[0])
		T_p = np.append(T_p,values[1])
		dir = np.append(dir,values[2])
		occ = np.append(occ,values[3])
		names = np.append(names,ii)
	return H_s,T_p,dir,occ,names
def compute_Kamphuis(H_s,T_p,dir,occ,names,crossshore_orientation_cross_towards_land,rho_s,rho_w,d50,porosity,beach_slope,translate_waves_data,gamma):
	
	# returns the sediment transport in m^3/s excluding pores
	
	diff_angles     = np.arccos(np.sin(crossshore_orientation_cross_towards_land  * np.pi / 180.0) * np.sin((dir-180.0) * np.pi / 180.0) + np.cos(crossshore_orientation_cross_towards_land  * np.pi / 180.0) * np.cos((dir-180.0) * np.pi / 180.0))*(180.0/np.pi)
	diff_angles_abs = np.arccos(np.sin(crossshore_orientation_cross_towards_land  * np.pi / 180.0) * np.sin((dir-180.0) * np.pi / 180.0) + np.cos(crossshore_orientation_cross_towards_land  * np.pi / 180.0) * np.cos((dir-180.0) * np.pi / 180.0))*(180.0/np.pi)
	diff_angles_rel = diff_angles_abs * (np.sin(2.0 * np.radians(crossshore_orientation_cross_towards_land-(dir-180.0))) / np.abs(np.sin(2.0 * np.radians(diff_angles_abs))))
	
	H_s_comp = []
	T_p_comp = []
	diff_angles_rel_comp = []
	diff_angles_abs_comp = []
	for ind in range(0,crossshore_orientation_cross_towards_land.shape[0]):
		if translate_waves_data == None:
			H_s_new = H_s
			T_p_new = T_p
			diff_angles_rel_new = diff_angles_rel[ind]
		else:
			H_s_new,T_p_new,diff_angles_rel_new = lwt.transWaveConditions(H_s,T_p,diff_angles_rel[ind],np.array([translate_waves_data['offshore_depth'],translate_waves_data['nearshore_depth']]),gamma)
		H_s_comp.append(list(H_s_new))
		T_p_comp.append(list(T_p_new))
		diff_angles_rel_comp.append(list(diff_angles_rel_new))
		diff_angles_abs_comp.append(list(np.abs(diff_angles_rel_new)))
	
	H_s_comp = np.array(H_s_comp)
	T_p_comp = np.array(T_p_comp)
	# make sure there are no nans in H_s and T_p:
	H_s_comp[np.isnan(H_s_comp)] = 0.0
	T_p_comp[np.isnan(T_p_comp)] = 0.0
	diff_angles_rel_comp = np.array(diff_angles_rel_comp)
	diff_angles_abs_comp = np.array(diff_angles_abs_comp)
	
	kamphuis_data = {}
	
	# see http://www.leovanrijn-sediment.com/papers/Longshoretransport2013.pdf
	kamphuis_data['mass transport per set [kg/s]']           = (diff_angles_abs_comp < 90.0) * 2.33 * H_s_comp**2.0 * T_p_comp**1.5 * beach_slope**0.75 * d50**-0.25 * (np.abs(np.sin(2.0 * np.radians(diff_angles_abs_comp)))**0.6) * (diff_angles_rel_comp/diff_angles_abs_comp)   # transport rate of immersed mass per unit time [kg(immersed)/s]
	
	kamphuis_data['weighted mass transport [kg/s]']          = ((kamphuis_data['mass transport per set [kg/s]'] * occ)/ np.sum(occ).Value)
	
	kamphuis_data['volume transport per set [m3/s]']         = kamphuis_data['mass transport per set [kg/s]'] / ((rho_s - rho_w) * (1.0 - porosity))
	kamphuis_data['weighted volume transport [m3/s]']        = ((kamphuis_data['volume transport per set [m3/s]'] * occ)/ np.sum(occ).Value)
	
	kamphuis_data['gross neg/pos mass transport [kg/s]']     = np.array([np.sum(np.clip(kamphuis_data['weighted mass transport [kg/s]'],0.0,np.inf),1.0),np.sum(np.clip(kamphuis_data['weighted mass transport [kg/s]'],-np.inf,0.0),1.0)])
	kamphuis_data['net mass transport [kg/s]']               = np.sum(kamphuis_data['gross neg/pos mass transport [kg/s]'],0.0)
	
	kamphuis_data['gross neg/pos volume transport [m3/s]']   = np.array([np.sum(np.clip(kamphuis_data['weighted volume transport [m3/s]'],0.0,np.inf),1.0),np.sum(np.clip(kamphuis_data['weighted volume transport [m3/s]'],-np.inf,0.0),1.0)])
	kamphuis_data['net volume transport [m3/s]']             = np.sum(kamphuis_data['gross neg/pos volume transport [m3/s]'],0.0)
	
	kamphuis_data['gross neg/pos mass transport [kg/yr.]']   = kamphuis_data['gross neg/pos mass transport [kg/s]']   * 60.0 * 60.0 * 24.0 * 365.0
	kamphuis_data['gross neg/pos volume transport [m3/yr.]'] = kamphuis_data['gross neg/pos volume transport [m3/s]'] * 60.0 * 60.0 * 24.0 * 365.0
	
	kamphuis_data['net mass transport [kg/yr.]']             = kamphuis_data['net mass transport [kg/s]']   * 60.0 * 60.0 * 24.0 * 365.0
	kamphuis_data['net volume transport [m3/yr.]']           = kamphuis_data['net volume transport [m3/s]'] * 60.0 * 60.0 * 24.0 * 365.0
	
	kamphuis_data['function name']                           = 'Kamphuis'
	
	return kamphuis_data
def compute_CERC(H_s,T_p,dir,occ,names,crossshore_orientation_cross_towards_land,rho_s,rho_w,d50,porosity,beach_slope,translate_waves_data,gamma):
	K     = 0.77 # [-] Coefficient, Komar and Inman (1970) found 0.77, US Army corps of engineers uses 0.92 and Schoones and Theron (1993, 1996).
	             #     suggested a value much lower (about half). The shore protection manual (USACE, 1984) recommends a value of 0.39.
	# Variable from input: gamma = 0.70 # [-] Breaker coefficient
	n_br  = 1.00 # [-] n-coefficient at breaker line (approx. 1)
	g     = 9.81 # [m/s^2] gravitational acceleration
	c_br  = np.sqrt(g * (H_s / K )) # [m/s] wave celerity at the breaker line
	
	diff_angles     = np.arccos(np.sin(crossshore_orientation_cross_towards_land  * np.pi / 180.0) * np.sin((dir-180.0) * np.pi / 180.0) + np.cos(crossshore_orientation_cross_towards_land  * np.pi / 180.0) * np.cos((dir-180.0) * np.pi / 180.0))*(180.0/np.pi)
	diff_angles_abs = np.arccos(np.sin(crossshore_orientation_cross_towards_land  * np.pi / 180.0) * np.sin((dir-180.0) * np.pi / 180.0) + np.cos(crossshore_orientation_cross_towards_land  * np.pi / 180.0) * np.cos((dir-180.0) * np.pi / 180.0))*(180.0/np.pi)
	diff_angles_rel = diff_angles_abs * (np.sin(2.0 * np.radians(crossshore_orientation_cross_towards_land-(dir-180.0))) / np.abs(np.sin(2.0 * np.radians(diff_angles_abs))))
	
	H_s_comp = []
	T_p_comp = []
	diff_angles_rel_comp = []
	diff_angles_abs_comp = []
	for ind in range(0,crossshore_orientation_cross_towards_land.shape[0]):
		if translate_waves_data == None:
			H_s_new = H_s
			T_p_new = T_p
			diff_angles_rel_new = diff_angles_rel[ind]
		else:
			H_s_new,T_p_new,diff_angles_rel_new = lwt.transWaveConditions(H_s,T_p,diff_angles_rel[ind],np.array([translate_waves_data['offshore_depth'],translate_waves_data['nearshore_depth']]),gamma)
		H_s_comp.append(list(H_s_new))
		T_p_comp.append(list(T_p_new))
		diff_angles_rel_comp.append(list(diff_angles_rel_new))
		diff_angles_abs_comp.append(list(np.abs(diff_angles_rel_new)))
	
	H_s_comp = np.array(H_s_comp)
	T_p_comp = np.array(T_p_comp)
	# make sure there are no nans in H_s and T_p:
	H_s_comp[np.isnan(H_s_comp)] = 0.0
	T_p_comp[np.isnan(T_p_comp)] = 0.0
	diff_angles_rel_comp = np.array(diff_angles_rel_comp)
	diff_angles_abs_comp = np.array(diff_angles_abs_comp)
	
	CERC_data = {}
	
	# CHECK THE CERC FORMULA!
	
	# see http://www.leovanrijn-sediment.com/papers/Longshoretransport2013.pdf
	CERC_data['volume transport per set [m3/s]']         = (diff_angles_abs_comp < 90.0) * ((K * (1.0/8.0) * rho_w * g * H_s_comp**2.0 * n_br * c_br * np.abs(np.sin(2.0 * np.radians(diff_angles_abs_comp)))) / ((1.0-porosity) * (rho_s-rho_w) * g)) * (diff_angles_rel_comp/diff_angles_abs_comp)
	CERC_data['mass transport per set [kg/s]']           = (1-porosity) * rho_s * CERC_data['volume transport per set [m3/s]']
	
	CERC_data['weighted volume transport [m3/s]']        = ((CERC_data['volume transport per set [m3/s]'] * occ)/ np.sum(occ).Value)
	CERC_data['weighted mass transport [kg/s]']          = ((CERC_data['mass transport per set [kg/s]'] * occ)/ np.sum(occ).Value)
	
	CERC_data['gross neg/pos mass transport [kg/s]']     = np.array([np.sum(np.clip(CERC_data['weighted mass transport [kg/s]'],0.0,np.inf),1.0),np.sum(np.clip(CERC_data['weighted mass transport [kg/s]'],-np.inf,0.0),1.0)])
	CERC_data['net mass transport [kg/s]']               = np.sum(CERC_data['gross neg/pos mass transport [kg/s]'],0.0)
	
	CERC_data['gross neg/pos volume transport [m3/s]']   = np.array([np.sum(np.clip(CERC_data['weighted volume transport [m3/s]'],0.0,np.inf),1.0),np.sum(np.clip(CERC_data['weighted volume transport [m3/s]'],-np.inf,0.0),1.0)])
	CERC_data['net volume transport [m3/s]']             = np.sum(CERC_data['gross neg/pos volume transport [m3/s]'],0.0)
	
	CERC_data['gross neg/pos mass transport [kg/yr.]']   = CERC_data['gross neg/pos mass transport [kg/s]']   * 60.0 * 60.0 * 24.0 * 365.0
	CERC_data['gross neg/pos volume transport [m3/yr.]'] = CERC_data['gross neg/pos volume transport [m3/s]'] * 60.0 * 60.0 * 24.0 * 365.0
	
	CERC_data['net mass transport [kg/yr.]']             = CERC_data['net mass transport [kg/s]']   * 60.0 * 60.0 * 24.0 * 365.0
	CERC_data['net volume transport [m3/yr.]']           = CERC_data['net volume transport [m3/s]'] * 60.0 * 60.0 * 24.0 * 365.0
		
	CERC_data['function name']                           = 'CERC'
	
	return CERC_data
# def compute_van_Rijn(H_s,T_p,dir,occ,names,crossshore_orientation_cross_towards_land,rho_s,rho_w,d50,porosity,beach_slope):
	# TBD
	# see http://www.leovanrijn-sediment.com/papers/Longshoretransport2013.pdf
def points_to_utm(x_y,CS_code_ori,CS_code_to_utm = None):
	
	from Libraries.StandardFunctions import *
	from Libraries.MapFunctions import *
	
	CS_code_WGS84 = 4326
	
	x_y_new = np.zeros((np.size(x_y)/2,2))
	for i in range(0,(np.size(x_y)/2)):
		conversion_feature = Feature(Geometry = CreatePointGeometry(x_y[i][0],x_y[i][1]))
		conversion_feature = TransformGeometry(conversion_feature.Geometry, CS_code_ori,CS_code_WGS84)
		if i == 0:
			if CS_code_to_utm == None:
				CS_code_UTM = int(32600 + int(np.ceil((conversion_feature.X + 180)/6).Value) + (100*np.abs(((conversion_feature.Y/np.abs(conversion_feature.Y).Value)*0.5)-0.5).Value))
			else:
				CS_code_UTM = int(CS_code_to_utm)
		conversion_feature = TransformGeometry(conversion_feature, CS_code_WGS84, CS_code_UTM)
		x_y_new[i] = np.array([conversion_feature.X,conversion_feature.Y])
			
	return CS_code_UTM, x_y_new
def create_diaglog_transport(transport_formulas):
	
	dialog = CustomInputDialog()
	
	box = PictureBox()
	box.Width = 0
	box.Height = 0
	box.BringToFront()
	box.Dock = DockStyle.Right
	dialog.Controls.Add(box)
	layout = dialog.Controls[0]
	
	dialog.AddChoice('Longshore transport formulation:', List[String](transport_formulas))
	dialog.Text = 'Choose a longshore transport formulation'
	
	def ShowDialog():
		# show dialog and wait for the user to click OK
		if dialog.ShowDialog() == DialogResult.OK:
		
			# retrieve values as filled in by user (using label name)
			type_of_formula = dialog['Longshore transport formulation:']
			
			# # show in message box for confirmation
			# MessageBox.Show('User supplied ' + type_of_formula)
			
			return type_of_formula
	
	type_of_formula = ShowDialog()
	
	dialog.Dispose()
	
	return type_of_formula

def main_function(map = None,cs_variables = None,new_window_switch = None,transform_switch = None):
	
	transport_formulas = ['Kamphuis','CERC','van Rijn (not yet implemented)']
	
	if cs_variables == None:
		# TEST MODE, everything hard codes for the dutch coast:
		
		beach_slope = 1.0/100
		
		rho_s = 2650.0
		rho_w = 1000.0
		
		d50  = 0.000200 # in m
		
		porosity = 0.4
		
		gamma = 0.70
		
		CS_code_input    = 4326 # WGS84
		CS_code_plot     = 3857 # Mercator
		
		# start_point_of_coast  = [4.605214,52.556649]
		# end_point_of_coast    = [4.523728,52.374311]
		
		# basepoint_of_harbour  = [0.5,0.5]
		# basepoint_of_harbour  = np.mean([start_point_of_coast,end_point_of_coast],0)
		
		basepoints            = [[4.526195, 52.380949], [4.557388, 52.462713], [4.603254, 52.548726]]
		endpoints             = [[4.476227, 52.390793], [4.503806, 52.470960], [4.546973, 52.554834]]
		
		CS_code_compute, basepoints   = points_to_utm(basepoints,CS_code_input)
		CS_code_compute_2, endpoints  = points_to_utm(endpoints,CS_code_input)
		
		if CS_code_compute != CS_code_compute_2:
			raise Exception("Your start and end points of cross-shore lines lie in different UTM zones!")
		
		# coastline_feature          = Feature(Geometry = CreateLineGeometry([start_point_of_coast,end_point_of_coast]))
		# coastline_feature.Geometry = TransformGeometry(coastline_feature.Geometry, CS_code_input, CS_code_compute)
		
		# start_point_of_coast  = [coastline_feature.Geometry.Coordinates[0].X,coastline_feature.Geometry.Coordinates[0].Y]
		# end_point_of_coast    = [coastline_feature.Geometry.Coordinates[1].X,coastline_feature.Geometry.Coordinates[1].Y]
		
		#input_type = 'timeseries' # either 'wave_classes' or 'timeseries'
		
		#if input_type == 'wave_classes':
		#	wave_classes = {'class1': [1.8,8,274.02611,20], 'class2': [1.0,8,294.02611,20]}
		#	# Or load wave classes, and convert to separate arrays:
		#	H_s,T_p,dir,occ,names = get_wave_classes(wave_classes)
		#elif input_type == 'timeseries':
		H_s = np.array([1,1.02,1.05,0.99])
		T_p = np.array([8.1,7.95,8.2,7.78])
		dir = np.array([270,280,290,300])
		# Or load timeseries, and add an occ array:
		occ   = np.ones(np.alen(H_s))
		names=[]
		for i in range(int(np.alen(H_s))): names.append("t" + str(i+1))
		
		formula_name       = create_diaglog_transport(transport_formulas)
		
		translate_waves_data = None
		
		# If you wish to include the wave translation as a test:
		#translate_waves_data = {}
		#translate_waves_data['offshore_depth']  = 10.0
		#translate_waves_data['nearshore_depth'] = 5.0
		
	else: # Defined via GUI
		
		#Check if data is available to perform calculations.
		#If not, then return main-function prematurely
		if (cs_variables.Profiles.shape[0] < 2) & (cs_variables.Wave_data == None):
			MessageBox.Show("Not enough data available: \n * Please enter at least one cross-shore transect \n * Please enter wave data","Not enough data")
			return
		if (cs_variables.Profiles.shape[0] < 2):
			MessageBox.Show("Please enter at least one cross-shore transect","No cross-shore transect")
			return
		if (cs_variables.Wave_data == None):
			MessageBox.Show("Please enter wave data","No wave data") #alert the user
			return
		
		beach_slope   = cs_variables.beach_slope
		rho_s         = cs_variables.rho_s
		rho_w         = cs_variables.rho_w
		d50           = cs_variables.d50
		porosity      = cs_variables.porosity
		gamma         = cs_variables.gamma
		
		formula_name = cs_variables.formula_name
		
		CS_codes_compute = cs_variables.Profiles_utm_codes # Mercator
		CS_code_plot     = 3857 # Mercator
		
		basepoints_compute = []
		endpoints_compute  = []
		basepoints_plot    = []
		endpoints_plot     = []
		for ind in range(1,np.size(cs_variables.Profiles,0),3):
			basepoints_compute.append(list(cs_variables.Profiles_utm[ind,:]))
			endpoints_compute.append(list(cs_variables.Profiles_utm[ind+1,:]))
			basepoints_plot.append(list(cs_variables.Profiles[ind,:]))
			endpoints_plot.append(list(cs_variables.Profiles[ind+1,:]))
		
		if cs_variables.input_type == 'class':
			cs_variables.Wave_data = np.array(cs_variables.Wave_data)
			H_s = np.array([])
			T_p = np.array([])
			dir = np.array([])
			occ = np.array([])
			for i in range(0,cs_variables.Wave_data.shape[0]):
				H_s = np.append(H_s,cs_variables.Wave_data[i,0].Value)
				T_p = np.append(T_p,cs_variables.Wave_data[i,1].Value)
				dir = np.append(dir,cs_variables.Wave_data[i,2].Value)
				occ = np.append(occ,cs_variables.Wave_data[i,3].Value)
			names=[]
			for i in range(int(np.alen(H_s))): names.append("t" + str(i+1))
		elif cs_variables.input_type == 'time series':
			cs_variables.Wave_data = np.array(cs_variables.Wave_data)
			H_s = np.array([])
			T_p = np.array([])
			dir = np.array([])
			for i in range(0,cs_variables.Wave_data.shape[0]):
				H_s = np.append(H_s,cs_variables.Wave_data[i,1])
				T_p = np.append(T_p,cs_variables.Wave_data[i,2])
				dir = np.append(dir,cs_variables.Wave_data[i,3])
			occ   = np.ones(np.alen(H_s))
			names=[]
			for i in range(int(np.alen(H_s))): names.append("t" + str(i+1))
		
		if transform_switch.Checked:
			# Translate from offshore to nearshore
			translate_waves_data = {}
			translate_waves_data['offshore_depth']  = -cs_variables.wave_loc_xyz[2].Value
			translate_waves_data['nearshore_depth'] = cs_variables.doc
			if translate_waves_data['offshore_depth'] < translate_waves_data['nearshore_depth']:
				MessageBox.Show("The specified offshore depth (wave data) is shallower than the computed depth of closure (start of the breaker zone), therefore wave translating to the nearshore is skipped!","No wave transformation")
				translate_waves_data = None
		else:
			# No translation
			translate_waves_data = None
		
		if new_window_switch.Checked:
			map = None
	
	if formula_name == transport_formulas[0]:
		formula_function = 'Kamphuis'
	elif formula_name == transport_formulas[1]:
		formula_function = 'CERC'
	elif formula_name == transport_formulas[2]:
		formula_function = 'van_Rijn'
	
	# End of input
	crossshore_orientation_cross_towards_land = crossshore_to_orientation(basepoints_compute,endpoints_compute) # this is also the positive direction
	
	# Now let's compute all the alongshore transports
	
	alongshore_transports = {}
	
	exec("alongshore_transports['" + formula_function + "'] = compute_" + formula_function + "(H_s,T_p,dir,occ,names,crossshore_orientation_cross_towards_land,rho_s,rho_w,d50,porosity,beach_slope,translate_waves_data,gamma)")
	
	plotting_transports(alongshore_transports[formula_function],basepoints_compute,endpoints_compute,basepoints_plot,endpoints_plot,crossshore_orientation_cross_towards_land,CS_code_plot,CS_codes_compute,map)
	
	# For debugging the plot function purposes:
	# alongshore_transport = alongshore_transports[formula_function]

def not_available():
	print "Not available yet"

def test_alongshore_transport():
	main_function()