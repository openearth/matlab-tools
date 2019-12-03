from dll import *
from constants import *
from enums import *
from structs import *

def GetIRHistogram(ir_image):
  
  # function
  fun           = DLL.GetIRHistogram
  fun.argtypes  = [c_void_p, c_void_p, c_long]
  
  # input
  cIRImage      = ir_image #ir_image.ctypes.data_as(POINTER(c_ushort))
  cImageSize    = c_long(IRF_XSIZE * IRF_YSIZE)
  
  # output
  cHist         = (c_uint * 10)(0)
  
  # call
  #err = fun(byref(cHist), cIRImage, cImageSize)
  err = fun(byref(cHist), byref(cIRImage), cImageSize)
  handle_error(err, 'GetIRHistogram')

  return cHist