from DelftTools.Utils.NetCdf import NetCdfFile

def Transpose2DCharArrayToStringList(array, stringLength, numberOfItems):
    names = []
    for i in range(numberOfItems) :
        name = ""
        for j in range(stringLength) :
            name += array[j][i]
        names.append(name)
    return names

def GetArrayFromSecondDimention(twoDimArray, index, nrOfComponents):
    array = []
    for i in range(nrOfComponents):
        array.append(twoDimArray[i,index])
    return array