from Libraries.Utils.Project import *
from DeltaShell.Plugins.SharpMapGis.Gui.Forms import MapView as _MapView
from SharpMap.Layers import GroupLayer as _GroupLayer
from DeltaShell.Plugins.MorphAn.MapLayers import ITransectLocationFeature as _ITransectLocationFeature
import time

def GetAllFeatures(layer, type):
	if (layer.DataSource != None and len(layer.DataSource.Features) > 0 and isinstance(layer.DataSource.Features[0],type)):
		return layer.DataSource.Features
	
	if (isinstance(layer,_GroupLayer)):
		for childLayer in layer.Layers:
			features = GetAllFeatures(childLayer,type)
			if (len(features) > 0):
				return features
	
	return []

def GetFirstMapView():
	mapView = None
	for view in Gui.DocumentViews:
		if (isinstance(view,_MapView)):
			mapView = view
			break;
		if (hasattr(view,'ChildViews')):
			for child in view.ChildViews:
				if (isinstance(child,_MapView)):
					mapView = child
					break
		
	return mapView

def SelectedFeaturesChanged(object,eventargs):
	PrintMessage("Test")
	global count
	messages = [
		"I'd rather have a bit of rest. Could you come back some other time to select something",
		"I just told you I'm not in the mood to select something else",
		"I've a headache! Please leave me alone!",
		"Stop touching me!!!",
		"Now I've had enough. I'll look for a quiet place next time.",
		"Bye Bye"]
	severeness = [2,2,1,1,0,0]
	
	if (count < len(messages)):
		PrintMessage(messages[count],severeness[count])
		count = count + 1
		SelectAllFeatures()
	else:
		mapView = GetFirstMapView()
		mapView.MapControl.SelectTool.SelectionChanged -= SelectedFeaturesChanged
		Gui.DocumentViews.ActiveView = None
		Gui.DocumentViews.Remove(mapView)

def SelectAllFeatures():
	global selecting
	
	if (selecting):
		return
		
	mapView = GetFirstMapView()
	for layer in mapView.Map.Layers:
		selection = GetAllFeatures(layer,_ITransectLocationFeature)
		if (len(selection) > 0):
			break
	
	selecting = True
	mapView.MapControl.SelectTool.SelectionChanged -= SelectedFeaturesChanged
	mapView.MapControl.SelectTool.Clear()
	mapView.MapControl.SelectTool.Select(selection)
	mapView.MapControl.SelectTool.SelectionChanged += SelectedFeaturesChanged
	selecting = False

count = 0
selecting = False
SelectAllFeatures()
mapView = GetFirstMapView()
mapView.MapControl.SelectTool.SelectionChanged += SelectedFeaturesChanged

