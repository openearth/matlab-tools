from dll import *
from constants import *
from enums import *
from structs import *

def _convert(fun, temp):

  # function
  fun.argtypes  = [c_float]
  fun.restype   = c_float

  # input
  cTemp         = c_float(temp)

  # call
  return fun(cTemp)

def ConvertFahToCels(temp):
  return _convert(DLL.ConvertFahToCels, temp)
  
def ConvertCelsToFah(temp):
  return _convert(DLL.ConvertCelsToFah, temp)
  
def ConvertKelvToCels(temp):
  return _convert(DLL.ConvertKelvToCels, temp)
  
def ConvertKelvToFah(temp):
  return _convert(DLL.ConvertKelvToFah, temp)
  
def ConvertCelToKel(temp):
  return _convert(DLL.ConvertCelToKel, temp)
  
def ConvertFahToKel(temp):
  return _convert(DLL.ConvertFahToKel, temp)

# float __stdcall ConvertFahToCels(float temp);
# float __stdcall ConvertCelsToFah(float temp);
# float __stdcall ConvertKelvToCels(float temp);
# float __stdcall ConvertKelvToFah(float temp);
# float __stdcall ConvertCelToKel(float temp);
# float __stdcall ConvertFahToKel(float temp);