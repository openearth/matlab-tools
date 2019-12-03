#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 RoyalHaskoningDHV
#       Bart-Jan van der Spek
#
#       Bart-Jan.van.der.Spek@rhdhv.com
#
#       Laan 1914, nr 35
#       3818 EX Amersfoort
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
from Scripts.BreakwaterDesign.Main_function import Start_BW
from Scripts.UI_Examples.Shortcuts import *

#Start_BW()


#RemoveShortcut("Breakwater", "CoDeS")
AddShortcut("Breakwater", "CoDeS",Start_BW, r'c:\Users\905252\Documents\CoDeS\plugins\DeltaShell.Plugins.Toolbox\Scripts\Scripts\BreakwaterDesign\breakwater_icon.png')