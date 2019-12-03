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
from Scripts.GeneralData.Views.BaseView import BaseView 
from System.Windows.Forms import AnchorStyles as _AnchorStyles
from System.Windows.Forms import Label as _Label, TextBox as _TextBox, Button as _Button
from System.Drawing import Point as _Point, Size as _Size

baseView = BaseView()

print "w : " + str(baseView.leftPanel.Width) + " - h : " + str(baseView.leftPanel.Height)

lineHeigth = 30
offset = 5

labelText = _Label()
baseView.leftPanel.Controls.Add(labelText)
labelText.Text = "Parameter"
labelText.Location = _Point(offset,lineHeigth) 
labelText.AutoSize = True

labelUnit = _Label()
baseView.leftPanel.Controls.Add(labelUnit)
labelUnit.Text = "m"
labelUnit.AutoSize = True
labelUnit.Location = _Point(baseView.leftPanel.Width - labelUnit.Width - offset, lineHeigth)
labelUnit.Anchor = _AnchorStyles.Top | _AnchorStyles.Right

textbox = _TextBox()
baseView.leftPanel.Controls.Add(textbox)
textbox.Location = _Point(offset + labelText.Width + offset  ,lineHeigth)
textbox.Width = baseView.leftPanel.Width - textbox.Left - labelUnit.Width - (offset * 2); 
textbox.Anchor = _AnchorStyles.Left | _AnchorStyles.Top | _AnchorStyles.Right

button = _Button()
baseView.leftPanel.Controls.Add(button)
button.Text = "Button1"

button.Width = baseView.leftPanel.Width - 20
button.Location = _Point(10,0)
button.Anchor = _AnchorStyles.Left | _AnchorStyles.Top | _AnchorStyles.Right

baseView.leftPanel.AutoScroll = True
baseView.leftPanel.AutoScrollMinSize = _Size(200,600)

baseView.Show()
