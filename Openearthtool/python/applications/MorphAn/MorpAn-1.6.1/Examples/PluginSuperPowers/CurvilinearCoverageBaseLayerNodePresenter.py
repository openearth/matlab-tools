#region new node presenter  
from DeltaShell.Plugins.SharpMapGis.Gui.Forms.MapLegendView import MapLayerTreeViewNodePresenter as _MapLayerTreeViewNodePresenter
from System.Collections.Generic import List as _List
from SharpMap.Api import IThemeItem
from SharpMap.Layers import CurvilinearCoverageBaseLayer

class CurvilinearCoverageBaseLayerNodePresenter(_MapLayerTreeViewNodePresenter):
    def __new__(self,guiPlugin):
        return _MapLayerTreeViewNodePresenter.__new__(self,guiPlugin)

    def __init__(self,guiPlugin):
        pass
    
    def GetChildNodeObjects(self,mapLayer,node):
        theme = mapLayer.Theme
        if not(theme == None):
            items = _List[IThemeItem]()
            for themeItem in theme.ThemeItems:
                items.Add(themeItem)
            return items
            
    def get_NodeTagType(self):
        return CurvilinearCoverageBaseLayer
#endregion

#region Initialize node presenter (perform prior to opening the first map)
from DeltaShell.Plugins.SharpMapGis.Gui.Forms.MapLegendView import MapLegendView as _MapLegendView
from DeltaShell.Plugins.SharpMapGis.Gui import SharpMapGisGuiPlugin as _SharpMapGisGuiPlugin
from DelftTools.Utils.Reflection import TypeUtils as _TypeUtils

gisPlugin = None
for plugin in Gui.Plugins:
	if isinstance(plugin,_SharpMapGisGuiPlugin):
		gisPlugin = plugin
		break

if not(gisPlugin == None):
	treeView = _TypeUtils.GetField(gisPlugin.MapLegendView,"TreeView")
	treeView.NodePresenters.Add(CurvilinearCoverageBaseLayerNodePresenter(gisPlugin))
#endregion