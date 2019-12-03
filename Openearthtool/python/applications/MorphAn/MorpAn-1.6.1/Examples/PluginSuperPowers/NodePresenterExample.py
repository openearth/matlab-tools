from Libraries.Plugin.AdditionalPlugin import *
from Examples.PluginSuperPowers.CurvilinearCoverageBaseLayerNodePresenter import CurvilinearCoverageBaseLayerNodePresenter
from DeltaShell.Plugins.SharpMapGis.Gui.Forms.MapLegendView import MapLegendView as _MapLegendView
from DeltaShell.Plugins.SharpMapGis.Gui import SharpMapGisGuiPlugin as _SharpMapGisGuiPlugin
from DelftTools.Utils.Reflection import TypeUtils as _TypeUtils

## Initialize the plugin
pl = AdditionalPlugin()


	
# Activate plugin (only works once, older versions will be deleted. Change the __name property if you would like to add two separate plugins
pl.Activate()

for plugin in Gui.Plugins:
	print plugin.Name

# pl.DeActivate()

#for plugin in Gui.Plugins:
#	print plugin.Name
