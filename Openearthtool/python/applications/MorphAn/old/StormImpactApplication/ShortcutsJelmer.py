#zoals Shortcuts.py, maar dan in de tab "Storm Impact" ipv "Shortcuts"

import clr
clr.AddReference('Fluent')
import os.path
from Fluent import RibbonTabItem as _RibbonTabItem
from Fluent import RibbonGroupBox as _RibbonGroupBox
from Fluent import Button as _Button

def AddShortcut(name,groupName,fun,image):
	group = _GetGroup(groupName)
	
	for item in group.Items :
		if (item.Header == name):
			# ITem already exists, What do we do?
			return item
	
	button = _Button()
	group.Items.Add(button)
	
	button.Header = name
	
	button.Click += lambda o,e,s=fun : _ButtonClicked(o,e,s)

	if (image != None and os.path.isfile(image)):
		button.LargeIcon = image
		button.Icon = image
	else:
		button.LargeIcon = None
		button.Icon = None

def RemoveShortcut(name,groupName):
	group = _GetGroup(groupName,False)
	
	if (group == None) :
		return
		
	for item in group.Items :
		if (item.Header == name):
			group.Items.Remove(item)
			break
			
	if (group.Items.Count == 0):
		_RemoveGroup(groupName)

#region Private functions
def _GetShortcutsTab(create = True):
	# Find Ribbon control
	ribbon = None
	for child in Gui.MainWindow.Content.Children :
		if (hasattr(child,'Name') and child.Name == "Ribbon"):
			ribbon = child
	
	if (ribbon == None) :
		print "Could not find Ribbon"
		return None
	
	# Search for existing Shortcuts tab
	for tab in ribbon.Tabs :
		if (tab.Header == "Storm Impact") :
			return tab
	
	if not(create):
		return None
		
	#Tab is not yet present, Add a new one
	tab = _RibbonTabItem()
	tab.Header = "Storm Impact"
	ribbon.Tabs.Add(tab)
	return tab

def _RemoveShortcutsTab():
	ribbon = None
	for child in Gui.MainWindow.Content.Children :
		if (hasattr(child,'Name') and child.Name == "Ribbon"):
			ribbon = child
	
	if (ribbon == None) :
		return
	
	for tab in ribbon.Tabs :
		if (tab.Header == "Storm Impact") :
			ribbon.Tabs.Remove(tab)
			break
	
def _GetGroup(name,create = True):
	tab = _GetShortcutsTab(create)
	if (tab == None):
		return None
	
	# Check existing groups
	for group in tab.Groups:
		if (group.Header == name):
			return group
	
	if not(create):
		return None
		
	# Create new one	
	newGroup = _RibbonGroupBox()
	newGroup.Header = name
	tab.Groups.Add(newGroup)
	return newGroup
	
def _RemoveGroup(groupName):
	tab = _GetShortcutsTab(False)
	if (tab == None):
		return
	
	for group in tab.Groups:
		if (group.Header == groupName):
			tab.Groups.Remove(group)
			break
		
	if (tab.Groups.Count == 0) :
		_RemoveShortcutsTab()

#endregion

#region Private Callbacks
def _ButtonClicked(object,eventArgs,func) :
	func()
	
#endregion