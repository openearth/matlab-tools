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
import csv
import datetime
from collections import OrderedDict

import clr
clr.AddReference("System.Windows.Forms")

import System.Windows.Forms as _swf

def read_csv(fileName, headerRow, Delimiter, dtFormat):

	data = []
	lineNr = 1
	with open(fileName) as csvfile:
		lines = csv.reader(csvfile,delimiter = Delimiter)
		for line in lines:
			if lineNr > headerRow:
				dt = datetime.datetime.strptime(line[0],dtFormat)
				Hs = float(line[1])
				Tp = float(line[2])
				dir = float(line[3])
				data.append([dt, Hs, Tp, dir])
			lineNr += 1
	
	return data
	
def PreviewFileInTextbox(filePath,textBox):
	textBox.Text = ""
	
	with open(filePath,'r') as datafile:
		regelIndex=1
		regel = datafile.readline()	
		while regel <> "" and regel <> None and regelIndex < 100:
			regel = datafile.readline()
			textBox.Text +=  regel 
			regelIndex += 1
			
def ReadColumnNamesAsDict(filePath,numDummyRows,sepCharacter):
	
	#	Errormessage (to show if correct sepCharacter has been used)

	errorMessage = ""
	
	#	Dictionary with sorted keys
	dataColumnsDict = OrderedDict()
	
	sepCharForPython = sepCharacter
	
	if sepCharacter == "tab":
		sepCharForPython = "\t"
	elif sepCharacter == "space":
		sepCharForPython = " "
	
	headerRowNr = numDummyRows +1
	# 	Open file
		
	ignoreChars = [ '#','%',"'"]
	
	with open(filePath,'r') as datafile:
		
		regelIndex = 1
		for x in range(0, headerRowNr):
			regel = datafile.readline()			
			regelIndex += 1
		
		#	First try splitting with selected character
		columnNames = regel.split(sepCharForPython)			
		
		#	If no result, split with space
		
		if len(columnNames) == 1:
			columnNames = regel.split(" ")
		
		#	If still no result, return errormessage
				
		k = 0
		for colIndex in range(0,len(columnNames)):
			if columnNames[colIndex] not in ignoreChars:
				dataColumnsDict[columnNames[colIndex]] = k
				k+=1
		
		numColumns = len(dataColumnsDict)

		#_swf.MessageBox.Show("Csvutils: check for length ({0})".format(str(numColumns)))
		if numColumns == 1:		
			errorMessage = "No columns found, please check if the correct field delimiter has been used."
	
	
	#_swf.MessageBox.Show("Csvutils:" + errorMessage)
	return [dataColumnsDict,errorMessage]
	
def ReadDataColumnsAsLists(filePath,numDummyRows,sepCharacter,columnIndices):
	
	ignoreValue = "NaN"
	errorMessage = ""	
	
	#	Create dictionary with column indices as keys and data columns as values
	
	dataDict = dict()
	
	for columnIndex in columnIndices:
		dataDict[columnIndex] = []
			
	
	sepCharForPython = sepCharacter
	
	if sepCharacter == "tab":
		sepCharForPython = "\t"
	elif sepCharacter == "space":
		sepCharForPython = " "
	
	headerRowNr = numDummyRows + 1
	
	firstEntry = True
	
	with open(filePath,'r') as datafile:
		
		#	Skip header
		for x in range(0, headerRowNr):
			regel = datafile.readline()
			
		#	Show some data
		while regel <> None and regel <> "":
			regel = datafile.readline()
			dataEntries = regel.split(sepCharForPython)
			
			#	If split has no effect - in case only 1 data entry is generated - try splitting with space
			
			if len(dataEntries) == 1:
				dataEntries = regel.split(" ")
			
			#	If still 1 data entry, return errorMessage
			
			if len(dataEntries) == 1:
				errorMessage = "Invalid field delimiter"
				return [dataDict,errorMessage]
			
			validRow = True
			
			for columnIndex in dataDict.keys():
				if dataEntries[columnIndex] == ignoreValue:
					validRow = False
			
			if validRow == True:
				for columnIndex in dataDict.keys():					
					dataDict[columnIndex].append(float(dataEntries[columnIndex]))
			
	
	return [dataDict,errorMessage]
	
	
"""dataPath = r"C:\Projecten\Coastal Design Toolbox\Develop\ToolboxContent\Scripts\WaveWindData\testdata\Sea2.dat"
numDummyRows = 5
sepCharacter = "\t"
columnIndices = [4,5,6] 

waveDataTimeSeries = ReadDataColumnsAsLists(dataPath,numDummyRows,sepCharacter,columnIndices)[0]

print waveDataTimeSeries

"""