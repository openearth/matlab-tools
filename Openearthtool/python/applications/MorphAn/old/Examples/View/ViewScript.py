from Libraries.Utils.View import *

v = View()
v.Text = "Test tool"

#region Map
mapView = MapView(Dock = DockStyle.Fill)
""" Add MapView to childviews to allow default backgroundlayers and manipulation in the "Map" toolwindow """
v.ChildViews.Add(mapView) 
#endregion

#region Options
jrkChoice = ComboBox(
	Dock = DockStyle.Top,
	DropDownStyle = ComboBoxStyle.DropDownList)

optionsBox = GroupBox(
	Dock = DockStyle.Top,
	Text = "Options",
	Height = 200)
optionsBox.Controls.Add(jrkChoice)
#endregion

#region Report box
reportBox = GroupBox(
	Dock = DockStyle.Fill,
	Text = "Report")
#endregion

#region Add controls to view
splitPanel = SplitContainer(
	Orientation = Orientation.Vertical, 
	FixedPanel = FixedPanel.Panel2,
	Dock = DockStyle.Fill,
	Width = 700,
	SplitterDistance = 200,
	Panel1MinSize = 200,
	Panel2MinSize = 400)

splitPanel.Panel1.Controls.Add(mapView)
splitPanel.Panel2.Controls.Add(reportBox)
splitPanel.Panel2.Controls.Add(optionsBox)

v.Controls.Add(splitPanel)
#endregion

v.Show()

