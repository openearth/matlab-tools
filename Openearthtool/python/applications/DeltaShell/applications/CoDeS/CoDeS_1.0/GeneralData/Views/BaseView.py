#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#
#       Hidde Elzinga
#
#       hidde.elzinga@deltares.nl
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
import os
import time
from Scripts.GeneralData.Views.View import *
import System.Windows.Forms as _swf
from System.Drawing import Font as _font
from System.Drawing import FontStyle as _fontStyle
from System.Windows.Forms import Padding as _Padding
from System.Drawing import Point as _Point, Size as _Size

class BaseView(View):
	"""General view containing two panels: one for input data on the left (40% screenwidth)
	and one for output data on the right (60% screenwidth)."""   

	def __init__(self):
		View.__init__(self) 

		self.Width = 1000
		panels = self.MakePanels(40)
		
		#Add Panels to the class, to access them outside.
		self.lblMessage = panels[0]
		self.leftPanel = panels[1]
		self.rightPanel = panels[2]
	
	def MakePanels(self, percentageLeft):
		tlpBase = _swf.TableLayoutPanel()
		tlpBase.ColumnCount = 2
		#tlpBase.RowCount = 2
		tlpBase.RowCount = 1
		tlpBase.CellBorderStyle = _swf.TableLayoutPanelCellBorderStyle.Single
		csLeft = _swf.ColumnStyle(_swf.SizeType.Percent,percentageLeft)
		csRight = _swf.ColumnStyle(_swf.SizeType.Percent,100 - percentageLeft)
		#csTop = _swf.RowStyle(_swf.SizeType.AutoSize)
		#csBottom = _swf.RowStyle(_swf.SizeType.Percent,100)
		tlpBase.ColumnStyles.Add(csLeft)
		tlpBase.ColumnStyles.Add(csRight)
		#tlpBase.ColumnStyles.Add(csTop)
		#tlpBase.ColumnStyles.Add(csBottom)
		tlpBase.Dock = _swf.DockStyle.Fill
				
		
		#Left side of the view: it is a message-box in the upper left corner,
		#and an (empty) panel which can be adjust in all views (so: two rows) 
		pnlLeft = _swf.TableLayoutPanel()
		pnlLeft.ColumnCount = 1
		pnlLeft.RowCount = 2
		pnlLeft.CellBorderStyle = _swf.TableLayoutPanelCellBorderStyle.Single
		csTop = _swf.RowStyle(_swf.SizeType.Absolute, 25)
		csBottom = _swf.RowStyle(_swf.SizeType.Percent,100)
		pnlLeft.RowStyles.Add(csTop)
		pnlLeft.RowStyles.Add(csBottom)
		pnlLeft.Dock = _swf.DockStyle.Fill
		
		#For the message (always one line)
		pnlMessage = _swf.Label()
		pnlMessage.Font = _font(pnlMessage.Font.FontFamily, 12, _fontStyle.Bold)
		pnlMessage.Dock = _swf.DockStyle.Bottom
		
		#For the input panel
		pnlInput = _swf.Panel()
		pnlInput.Dock = _swf.DockStyle.Fill
		
		#Combining the left side
		pnlLeft.Controls.Add(pnlMessage, 0, 0)
		pnlLeft.Controls.Add(pnlInput, 1, 0)


		#Right side of the view: simple
		pnlRight = _swf.Panel()
		pnlRight.Dock = _swf.DockStyle.Fill
		pnlRight.Margin = _Padding(0)
		tlpBase.Controls.Add(pnlLeft, 0, 0)
		tlpBase.Controls.Add(pnlRight, 1, 0)
		self.Controls.Add(tlpBase)
		
		return pnlMessage, pnlInput, pnlRight
	

	'''Set minimum size; scrollbars appear when the size of the leftPanel is below this size'''
	def SetScrollBarsLeftPanel(self,margin):
		
		#	Absolute minimum size of the leftPanel
		maxRight = 100
		maxBottom = 100
		
		#settingsPath = r"C:\Projecten\Coastal Design Toolbox\Temp" + os.sep + "Controls_" + self.Text + str(time.time()) + ".txt"
		#_swf.MessageBox.Show("Writing to file " + settingsPath)
		#settingsFile = open(settingsPath,'w')
		
		for control in self.leftPanel.Controls:	
			#	Get all child controls
			
			allControls = self.GetControlsRecursive(control)
							
			for subcontrol in allControls:
				#if (type(subcontrol) is _swf.TextBox) or (type(subcontrol) is _swf.ComboBox) or (type(subcontrol) is _swf.Label) or (type(subcontrol) is _swf.RichTextBox) or (type(subcontrol) is _swf.Button):				
				#	settingsFile.write(subcontrol.Text + "," + str(subcontrol.Left) + "," + str(subcontrol.Top) + "\n")
				#	settingsFile.write(subcontrol.Text + "," + str(subcontrol.Right) + "," + str(subcontrol.Bottom) + "\n") 
				
				if subcontrol.Right > maxRight or (subcontrol.Left + subcontrol.Width) > maxRight:
					maxRight = subcontrol.Right				
				if subcontrol.Bottom > maxBottom or (subcontrol.Top + subcontrol.Height) > maxBottom:
					maxBottom = subcontrol.Bottom
	
			
		
		#_swf.MessageBox.Show("max right " + str(maxRight))
		#_swf.MessageBox.Show("max bottom: " + str(maxBottom))
		
		#maxBottom += self.lblMessage.Height
		
		if self.leftPanel.AutoScroll == False:
			self.leftPanel.AutoScrollMargin = _Size(margin,margin)
			
		self.leftPanel.AutoScroll = True
		
		#settingsFile.write("Max right is " + str(maxRight) + "\n")
		#settingsFile.write("Max bottom is " + str(maxBottom) + "\n")
		
		self.leftPanel.AutoScrollMinSize = _Size(maxRight,maxBottom)
		
		
		#settingsFile.close()

	def GetControlsRecursive(self,control):
		controls = [control]
		
		if (control.HasChildren):
			for childControl in control.Controls:
				childControls = self.GetControlsRecursive(childControl)
				controls.extend(childControls)
	
		return controls
	
	