from DelftTools.Utils import ItemContainerExtensions as _ItemContainerExtensions
from DelftTools.Shell.Core import Folder as _Folder
from DelftTools.Shell.Core.Workflow import IModel as _IModel
import clr
clr.AddReference('log4net')
from log4net import LogManager as _LogManager
from DeltaShell.Plugins.Scripting import ScriptingApplicationPlugin as _ScriptingApplicationPlugin
from DeltaShell.Plugins.Toolbox import ToolboxApplicationPlugin as _ToolboxApplicationPlugin

def GetToolboxDir():
	for plugin in Application.Plugins:
		if (isinstance(plugin,_ToolboxApplicationPlugin)):
			return plugin.Toolbox.ScriptingRootDirectory
			
	return None

def FindFolder(name) :
	for item in _ItemContainerExtensions.GetAllItemsRecursive(Application.Project) :
		if (isinstance(item,_Folder) and item.Name == name) :
			return item
	
	print "Could not find folder '%s'" % (name)
	return None	

def FindModel(name) :
	for item in _ItemContainerExtensions.GetAllItemsRecursive(Application.Project) :
		if (isinstance(item,_IModel) and item.Name == name) :
			return item
	
	print "Could not find folder '%s'" % (name)
	return None	

def AddFolder(name):
	folder = _Folder(name)
	Gui.CommandHandler.AddItemToProject(folder)
	return folder
	
def GetUniqueName(name, level=0):
	uniqueName = name
	if (level > 0) :
		uniqueName = name + " (%d)" % (level)
	
	for item in _ItemContainerExtensions.GetAllItemsRecursive(Application.Project) :
		if (hasattr(item,'Name') and item.Name == uniqueName) :
			return GetUniqueName(name,level + 1)
		
	return uniqueName

def PrintMessage(message,level=2):
	log = _LogManager.GetLogger(clr.GetClrType(_ScriptingApplicationPlugin))
	if (level == 2):
		log.Info(message)
	elif (level == 1):
		log.Warn(message)
	elif (level == 0):
		log.Error(message)
	elif (level == 3):
		log.Debug(message)