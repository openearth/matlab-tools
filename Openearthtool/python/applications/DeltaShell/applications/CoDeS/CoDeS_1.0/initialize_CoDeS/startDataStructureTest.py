#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 RoyalHaskoningDHV
#
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
#Import only the bathymetry-file although it NOT in the init-file
from Scripts.GeneralData import Bathymetry

#Import based on the contents of the init-file. 
#For example, scenario is direct available as class, without referencing
from Scripts.GeneralData import *


#Similar import (__init__-based), so (for example) class Scenario is available.
#Calling the class should be with 'Scripts.GeneralData.Scenario'
import Scripts.GeneralData

#Similar import (__init__-based), so (for example) class Scenario is available in variable 'gd'.
#Calling the class should be with 'gd.Scenario' (aliassing)
import Scripts.GeneralData as gd


#Similar import (__init__-based), but now the variable (with the module-content) is only available 
#for this file. 
import Scripts.GeneralData as _gd


newScenario = Scenario()


