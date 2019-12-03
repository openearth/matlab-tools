import socket

from dll import *
from constants import *
from enums import *
from structs import *

def OpenConnect(destination='10.0.1.12', port=15001, protocol=socket.AF_INET, prototype=socket.SOCK_STREAM):

  # function
  fun           = DLL.OpenConnect
  fun.argtypes  = [POINTER(HANDLE), POINTER(UINT), c_char_p, c_char_p, c_int, c_int]
  
  # input
  cDestination  = c_char_p(destination)
  cPort         = c_char_p(str(port))
  cProtocol     = c_int(protocol)
  cPrototype    = c_int(prototype)
  
  # output
  cHandle       = HANDLE(0)
  cTimerID      = UINT(0)

  # call
  err = fun(byref(cHandle), byref(cTimerID), cDestination, cPort, cProtocol, cPrototype)
  handle_error(err, 'OpenConnect')
    
  return (cHandle, cTimerID)
  
def CloseConnect(cHandle, cTimerID):

  # function
  fun           = DLL.CloseConnect
  fun.argtypes  = [POINTER(HANDLE), POINTER(UINT)]

  # call
  err = fun(byref(cHandle), byref(cTimerID))
  handle_error(err, 'CloseConnect')
    
def SendCameraMessage(cHandle, cTimerID, messageID=None, messageType=0, rCode=0):

  if messageID == None:
    return
    
  # function
  fun           = DLL.SendCameraMessage
  fun.argtypes  = [HANDLE, POINTER(c_uint), c_uint, c_ushort, c_ushort]
  
  # input
  cMessageID    = messageID
  cMessageType  = c_ushort(messageType)
  cRCode        = c_ushort(rCode)
  
  # call
  err = fun(cHandle, byref(cTimerID), cMessageID, cMessageType, cRCode)
  handle_error(err, 'SendCameraMessage')

def SendMessageToCamera(cHandle, cTimerID, messageID=None, messageType=0, rCode=0, rCode2=0, rCode3=0, rCode4=0):

  if messageID == None:
    return
    
  # function
  fun           = DLL.SendMessageToCamera
  fun.argtypes  = [HANDLE, POINTER(c_uint), c_uint, c_ushort, c_ushort, DWORD, DWORD, DWORD]
  
  # input
  cMessageID    = messageID
  cMessageType  = c_ushort(messageType)
  cRCode        = c_ushort(rCode)
  cRCode2       = DWORD(rCode2)
  cRCode3       = DWORD(rCode3)
  cRCode4       = DWORD(rCode4)
  
  # call
  err = fun(cHandle, byref(cTimerID), cMessageID, cMessageType, cRCode, cRCode2, cRCode3, cRCode4)
  handle_error(err, 'SendMessageToCamera')
  
def GetIRBuffer(cHandle, cTimerID, cCamData=None):

  # function
  fun           = DLL.GetIRImages
  fun.argtypes  = [HANDLE, POINTER(c_uint), POINTER(IRF_IR_CAM_DATA_T)]

  # output
  if cCamData == None:
    cCamData                    = IRF_IR_CAM_DATA_T()
    cCamData.ir_image           = (c_ushort * (IRF_XSIZE * IRF_YSIZE))(0)
    cCamData.lpNextData         = (BYTE * IRF_BUFFER_SIZE)(0)
    cCamData.image_buffer_size  = c_uint(IRF_XSIZE * IRF_YSIZE)
    cCamData.dwSize             = c_uint(0)
    cCamData.dwPosition         = c_uint(0)
    cCamData.dwPosition         = c_uint(0)

  # call
  err = fun(cHandle, byref(cTimerID), byref(cCamData))
  handle_error(err, 'GetIRImages')
  
  return cCamData