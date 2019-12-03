from DelftTools.Shell.Gui import GuiPlugin as _GuiPlugin
from DelftTools.Utils.Reflection import TypeUtils as _TypeUtils
from DelftTools.Controls import ITreeNodePresenter as _ITreeNodePresenter
from DelftTools.Shell.Gui import PropertyInfo as _PropertyInfo
from DelftTools.Controls import ViewInfo as _ViewInfo
from System.Collections.Generic import List as _List

""" Trick to add Linq functionality in IronPython:
import clr, System
clr.AddReference("System.Core")
clr.ImportExtensions(System.Linq)
"""

class AdditionalPlugin(_GuiPlugin):
    NodePresenters = _List[_ITreeNodePresenter]()
    PropertyInfos = _List[_PropertyInfo]()
    ViewInfos = _List[_ViewInfo]()
    
    __name = "AdditionalScriptedPlugin"
    __description = """This plugins allows adding functionality during runtime by means of python code"""
    __displayname = "fun"
    __version =  "1.0.0"
    __fileformatversion = "1.0.0"
    
    def __new__(self): #TODO: Optionally pass name and version numbers etc.
        return _GuiPlugin.__new__(self)

    def __init__(self):
        pass

    def get_Name(self):
        return self.__name
    
    def get_DisplayName(self):
        return self.__displayname
    
    def get_Description(self):
        return self.__description
    
    def get_Version(self):
        return self.__version
        
    def get_FileFormatVersion(self):
        return self.__fileformatversion
        
    def Activate(self):
    	pluginsToRemove = list()
    	for p in Gui.Plugins:
            if (p.Name == self.Name):
                pluginsToRemove.append(p)
        for p in pluginsToRemove:
        	Gui.Plugins.Remove(p)
        	
        Gui.Plugins.Add(self)
        self.Gui = Gui
        
        self.UpdateMainRibbonControl()

        self.IsActive = True
        
    def DeActivate(self):
    	for p in Gui.Plugins:
    		if (p.Name == self.Name):
    			Gui.Plugins.Remove(p)
    			break
    	
    	self.IsActive = False
    	
    def GetProjectTreeViewNodePresenters(self):
        return self.NodePresenters
        
    def GetPropertyInfos(self):
        return self.PropertyInfos
        
    def GetViewInfoObjects(self):
        return self.ViewInfos
        
    def UpdateMainRibbonControl(self):
        
        if self.RibbonCommandHandler == None:
            return
        
        # Still need to add a RibbonCommandHandler to handle ValidateItems and IsContextualTabVisible
        # Manually add the ribbon items here to the mainwindow
        
        # Add Contextual group if it does not exist yet
        """
        for group in ribbonControl.ContextualGroups:
            if (Gui.MainWindow.Ribbon.ContextualGroups.Any(lambda g: g.Name.Equals(group.Name))):
                continue

            Gui.MainWindow.Ribbon.ContextualGroups.Add(group);
        """
        
        # Add tab, or find tab
        """
        for tab in Gui.MainWindow.Ribbon.Tabs:
            if (this is the tab):
                # Store tab for later use
            else:
                # Add your own tab here
        """
        # Find group (maybe as part of the previous loop)
        """
        for group in tab.Groups:
            if (this is the group):
                
            else:
                # CReate a new group
        """
        
        # Add elements to the group
        """
        """
        
        # Connect contextual group bindings
        """
        // update contextual tab bindings
                    if (existingTab.Group != null)
                    {
                        var newGroup = Ribbon.ContextualGroups.First(g => g.Name == existingTab.Group.Name);
                        existingTab.Group = newGroup;
                    }
        """