#region imports
from BKL_plus.ProposedBkl import *
from Libraries.MorphAn.Models import *
from GisSharpBlog.NetTopologySuite.Geometries import LineString as _LineString
from System.Collections.Generic import List as _List
from GisSharpBlog.NetTopologySuite.Geometries import Coordinate as _Coordinate
from NetTopologySuite.Extensions.Features import Feature as _Feature
from SharpMap.Layers import VectorLayer as _VectorLayer
from SharpMap.Data.Providers import FeatureCollection as _FeatureCollection
from SharpMap.Styles import VectorStyle as _VectorStyle
from DeltaShell.Plugins.MorphAn.TRDA.Utils import TransectHelper as _TransectHelper
import clr
clr.AddReference('System.Drawing')
from System.Drawing import Color
from System.Drawing.Drawing2D import DashStyle
from System import Object as _object
from System.Collections.ObjectModel import Collection as _Collection
from SharpMap import Map as _Map
#endregion

def CreateBklMap(modelName, areaName , layerTitle = "Voorstel BKL"):
	#region Get model and corresponding map overview
	model = GetModel(modelName)
	if (model == None):
		PrintMessage("Please load and run a model first")
		
	mapView = None
	for view in Gui.DocumentViews:
		if (view.Data == model):
			mapView = view
	
	if (mapView == None):
		"""No view open yet, try to open a view for the model"""
		Gui.DocumentViewsResolver.OpenViewForData(model.ModelResults)
		mapView = Gui.DocumentViews.ActiveView

	map = mapView.Controls[0].Map
	#endregion
	
	#region Calculate proposed bkl coordinates in RD
	bklProposed = ProposedBkl(areaName)
	rdCoordinates = _List[_Coordinate]()
	
	if (len(bklProposed[0]) > 0):
		for idx,offset in enumerate(bklProposed[0]):
			location = None
			for tkl in model.ExpectedCoastLineModel.ExpectedCoastLineLocations.ResultList:
				if (tkl.Location.Offset == offset):
					location = tkl.Location
			
			if (location == None):
				continue
		
			tuple = _TransectHelper.CrossShore2Coordinate(bklProposed[1][idx],location)
			rdCoordinates.Add(_Coordinate(tuple.Item1,tuple.Item2))
	
		if (rdCoordinates.Count == 1):
			rdCoordinates.Add(_Coordinate(rdCoordinates[0].X,rdCoordinates[0].Y))
	#endregion
	
	#region Create new layer to add to the view
	if (rdCoordinates.Count > 0):
		features = _List[_Feature]()
		features.Add(_Feature(Geometry = _LineString(rdCoordinates.ToArray())))
	
		style = _VectorStyle()
		style.Line.Width = 3
		style.Line.Color = Color.DodgerBlue
		style.Line.DashStyle = DashStyle.Dash
		style.EnableOutline = False
	
		layer = None
		for l in map.Layers:
			if (l.Name == layerTitle):
				layer = l
				break

		if (layer == None):
			layer = _VectorLayer(layerTitle,
				DataSource = _FeatureCollection(features,_Feature),
				Style = style)
			layer.DataSource.CoordinateSystem = _Map.CoordinateSystemFactory.CreateFromEPSG(28992)
			map.Layers.Insert(0,layer)

	map.Layers[map.Layers.Count-1].Layers[0].Opacity = 0.5
	#endregion
	
	Gui.DocumentViews.ActiveView = mapView
