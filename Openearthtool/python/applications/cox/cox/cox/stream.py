from dll import *
from constants import *
from enums import *
from structs import *

def SaveIRImage(filename):

  # function
  fun           = DLL.SaveIRImage
  fun.argtypes  = [POINTER(HANDLE), c_char_p, POINTER(IRF_IR_FILE_HEADER_T)]

  # input
  cFilename     = c_char_p(filename)
  cHeader       = IRF_IR_FILE_HEADER_T()
  
  # output
  cHandle       = HANDLE(0)

  # call
  err = fun(byref(cHandle), cFilename, byref(cHeader))
  handle_error(err, 'SaveIRImage')
    
  return cHandle
  
def CloseIRStream(cHandle):

  # function
  fun           = DLL.CloseIRStream
  fun.argtypes  = [HANDLE]

  # call
  err = fun(cHandle)
  handle_error(err, 'CloseIRStream')
  
def SetIRImageToStream(cHandle, ir_image, millisecond=33, frameCnt=100):

  # function
  fun           = DLL.SetIRImageToStream
  fun.argtypes  = [HANDLE, c_void_p, c_long, c_int, POINTER(c_short)]
  
  # input
  cImageSize    = c_long(IRF_XSIZE * IRF_YSIZE)
  cMillisecond  = c_int(millisecond)
  cFrameCnt     = c_short(frameCnt)

  # call
  err = fun(cHandle, ir_image, cImageSize, cMillisecond, byref(cFrameCnt))
  handle_error(err, 'SetIRImageToStream')
  
def GetIRHeader(cHandle):
  
  # function
  fun           = DLL.GetIRHeader
  fun.argtypes  = [HANDLE, POINTER(IRF_IR_FILE_HEADER_T), POINTER(c_ulong)]

  # output
  cHeader       = IRF_IR_FILE_HEADER_T()
  cCurPos       = c_ulong(0)
  
  # call
  err = fun(cHandle, byref(cHeader), byref(cCurPos))
  handle_error(err, 'GetIRHeader')
  
  return (cHeader, cCurPos)