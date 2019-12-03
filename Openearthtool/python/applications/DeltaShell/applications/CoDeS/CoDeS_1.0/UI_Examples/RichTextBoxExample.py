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
from Scripts.UI_Examples.View import *

view = View()
view.Text = "RichTextBox Example"

textbox = RichTextBox()
textbox.Dock = DockStyle.Fill

defaultHeader = r"{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil\fcharset0 Calibri;}}"
colorsUsed = r"{\colortbl ;\red0\green0\blue255;\red0\green255\blue0;}"
text = (defaultHeader + colorsUsed +
    r"\fs44 Header text (font size 44) \plain \par" +
    r" \i Italic text \i0 \par" +
    r" \b Bold text \b0 \par" +
    r" \sub Subscript text \nosupersub \par" +
    r" \super Superscript text \nosupersub \par" +
    r" \strike Strikethrough text \strike0 \par" +
    r" \uld Dotted underline text \uld0 \par" +
    r" \ulwave Dotted underline text \ulwave0 \par" +    
    r" \cf1 Fore color blue \cf0 \par" +
    r" \highlight2 \cf0 Back color green \cf0 \highlight0 \par" +
    r"\par" +
    r"\trowd\trautofit1" + 
    r"\cellx2000 \cellx3000 \cellx4000" +
    r"\intbl cell 1\cell cell 2\cell cell 3\cell" +
    r"\row"+
    r"\intbl \highlight1 \cf2 Highlighted cell 4 \cf0 \cell \highlight0 cell 5\cell cell 6\cell" +
    r"\row" +
    r"}")

view.Controls.Add(textbox)
view.Show()

# set after the view is shown (otherwise the formatting is broken)
textbox.Rtf = text