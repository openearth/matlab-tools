#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Witteveen+Bos
#
#       Jaap de Rue
#
#       jaap.de.rue@witteveenbos.com
#
#       Van Twickelostraat 2
#       7411 SC Deventer
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
import clr
clr.AddReference("System.Windows.Forms")
import System.Windows.Forms as _swf


## =============================================================
class frmDateTimeExample(_swf.Form):
	#Class for storing the table with all information about date time format
	
	def __init__(self):
		self.Width = 845
		self.Height = 470
		self.Text="Date-time format"
		#frmDateTime.FormBorderStyle = FormBorderStyle.FixedDialog
		
		rtbDateFormat = _swf.RichTextBox()
		rtbDateFormat.Top = 10
		rtbDateFormat.Left = 10
		rtbDateFormat.Width = 807
		rtbDateFormat.Height = 340
		
		defaultHeader = r"{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil\fcharset0 Calibri;}}"
		colorsUsed = r"{\colortbl ;\red0\green0\blue255;\red0\green255\blue0;}"
		text = (defaultHeader + colorsUsed +
			r"\trowd\trautofit1" + 
			r"\cellx1000 \cellx8000 \cellx12000" +
			r"\intbl  Format\cell  Explanation\cell  Example\cell" +
			r"\row"+
			r"\intbl  %a\cell  Weekday as abbreviated name.\cell  Sun, Mon, ..., Sat\cell" +
			r"\row" +
			r"\intbl  %A\cell  Weekday as full name.\cell  Sunday, Monday, ..., Saturday\cell" +
			r"\row" +
			r"\intbl  %w\cell  Weekday as a decimal number, where 0 is Sunday and 6 is Saturday.\cell  0, 1, ..., 6\cell" +
			r"\row" +
			r"\intbl  %d\cell  Day of the month as a zero-padded decimal number.\cell  01, 02, ..., 31\cell" +
			r"\row" +
			r"\intbl  %b\cell  Month as abbreviated name.\cell  Jan, Feb, ..., Dec\cell" +
			r"\row" +
			r"\intbl  %B\cell  Month as full name.\cell  January, February, ..., December\cell" +
			r"\row" +
			r"\intbl  %m\cell  Month as a zero-padded decimal number.\cell  01, 02, ..., 12\cell" +
			r"\row" +
			r"\intbl  %y\cell  Year without century as a zero-padded decimal number.\cell  00, 01, ..., 99\cell" +
			r"\row" +
			r"\intbl  %Y\cell  Year with century as a decimal number.\cell  1970, 1988, 2001, 2013\cell" +
			r"\row" +
			r"\intbl  %H\cell  Hour (24-hour clock) as a zero-padded decimal number.\cell  00, 01, ..., 23\cell" +
			r"\row" +
			r"\intbl  %I\cell  Hour (12-hour clock) as a zero-padded decimal number.\cell  01, 02, ..., 12\cell" +
			r"\row" +
			r"\intbl  %p\cell  Equivalent of either AM or PM.\cell  AM, PM\cell" +
			r"\row" +
			r"\intbl  %M\cell  Minute as a zero-padded decimal number.\cell  00, 01, ..., 59\cell" +
			r"\row" +
			r"\intbl  %S\cell  Second as a zero-padded decimal number.\cell  00, 01, ..., 59\cell" +
			r"\row" +
			r"}")
		
		rtbDateFormat.Rtf = text
		
		btnOK = _swf.Button()
		btnOK.Text = "Close"
		btnOK.Top = 380
		btnOK.Left = 730
		btnOK.Click += self.btnOK_Click
		
		self.Controls.Add(rtbDateFormat)
		self.Controls.Add(btnOK)
	
	
	def btnOK_Click(self, sender, e):
		#After clicking OK:
		self.Close()
