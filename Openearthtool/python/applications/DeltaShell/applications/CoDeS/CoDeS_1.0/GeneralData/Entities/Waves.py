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
class Waves:
    """Class for determine all information about waves"""
    
    def __init__(self):
        #To store the absolute path of the source-file where the data comes from
        self.SourcePath = ''
        
        #Spatial Location of the dataset
        self.Location = None
        self.Z = 0

        #A float with returnperiod
        self.ReturnPeriodExtremeValue = None
        
        #Two types of WaveClimates
        self.WaveClimates = []
        self.ExtremeValueClimate = None
        self.Type = None
        
        #Offshore or Nearshore
        self.IsOffshore = True
        
    def Transform(self):
        """Function to transform a offshore-waveclass towards an near-shore wave-class"""
        #Implemented in LinearWaveTheory, conversion TBD