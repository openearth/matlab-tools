import time
import numpy as np

import temperature
import connection
from progressbar import progressbar

from dll import *
from constants import *
from enums import *
from structs import *

def GetIRImages(cHandle, cTimerID, cCamData=None):

  cCamData = connection.GetIRBuffer(cHandle, cTimerID, cCamData)
  
  # convert to image
  return read_image_buffer(cCamData.ir_image, ctype=c_ushort)
  
def GetIRImageStream(cHandle, cTimerID, duration=10*60, frequency=2, schemes=['snap','timex','min','max','var'], cCamData=None):

  connection.SendCameraMessage(cHandle, cTimerID, messageID=IRF_MESSAGE_TYPE_T._IRF_STREAM_ON)

  t0 = time.time()
  
  t  = {}
  
  if 'timex' in schemes:
    t['timex'] = np.zeros((IRF_YSIZE,IRF_XSIZE))
  if 'min' in schemes:
    t['min'] = np.inf * np.ones((IRF_YSIZE,IRF_XSIZE))
  if 'max' in schemes:
    t['max'] = -np.inf * np.ones((IRF_YSIZE,IRF_XSIZE))
  if 'var' in schemes:
    t['var'] = np.zeros((IRF_YSIZE,IRF_XSIZE))
    schemes.append('timex')
    
  n = 0

  while time.time() < t0 + duration:

    progressbar((time.time() - t0) / duration)
  
    try:

      cCamData = connection.GetIRBuffer(cHandle, cTimerID, cCamData)
    
      T = temperature.GetRawToTemp(cCamData.ir_image)
      #T = T.copy().reshape((1,IRF_YSIZE,IRF_XSIZE))
    
      if 'timex' in schemes:
        t['timex'] = t['timex'] + T
      if 'min' in schemes:  
        t['min'] = np.minimum(t['min'], T)
      if 'max' in schemes:  
        t['max'] = np.maximum(t['max'], T)
      if 'var' in schemes:
        t['var'] = t['var'] + np.power(T,2)
    
      n = n + 1    
    
      time.sleep(1.0/frequency)

    except Exception as e:
      print 'skipping frame...'

  print ''
    
  if 'snap' in schemes:
    t['snap']  = T
  if 'var' in schemes:
    t['var'] = (t['var'] - t['timex']*t['timex']/n) / (n - 1)
  if 'timex' in schemes:
    t['timex'] = t['timex'] / n
   
  return (t, n)
  
def GetImage(ir_image, tempLUT=None, level=30, span=20, cMethod=None, autoScale=None):

  # function
  fun           = DLL.GetImage
  fun.argtypes  = [c_void_p, c_void_p, c_long, c_void_p, POINTER(c_float), POINTER(c_float), POINTER(IRF_AUTO_RANGE_METHOD_T)]
  
  # input
  cTempLUT      = temperature.GetTempMapTable(tempLUT)
  cIRImage      = ir_image.ctypes.data_as(POINTER(c_ushort))
  cImageSize    = c_long(IRF_XSIZE * IRF_YSIZE)
  cLevel        = c_float(level)
  cSpan         = c_float(span)
  
  if cMethod == None:
  
    # autoScale shortcut
    if type(autoScale) == str:
      if autoScale == 'auto':
        autoScale = IRF_AUTOMATIC_TYPE_T._IRF_AUTO
      elif autoScale == 'manual':
        autoScale = IRF_AUTOMATIC_TYPE_T._IRF_MANUAL
      else:
        raise ValueError('Unknown autoScale value [%s]' % cMethod)
    else:
      autoScale = IRF_AUTOMATIC_TYPE_T._IRF_AUTO
      
    cMethod              = IRF_AUTO_RANGE_METHOD_T()
    cMethod.autoScale    = autoScale
    cMethod.inputMethod  = IRF_AUTO_RANGE_INPUT_METHOD_T._IRF_SD_RATE
    cMethod.outputMethod = IRF_AUTO_RANGE_OUTPUT_METHOD_T._IRF_LINEAR
    cMethod.B_Rate       = c_float(0.01)
    cMethod.SD_Rate      = c_float(5)
    cMethod.intercept    = c_ubyte(0)
    cMethod.gamma        = c_float(1)
    cMethod.plateau      = c_uint(100)
    cMethod.epsilon      = c_float(0.5)
    cMethod.psi          = c_float(0.3)
    cMethod.prevPlateau  = c_float(0)

  # output
  cImage        = (c_ubyte * (IRF_XSIZE * IRF_YSIZE))(0)
  
  # call
  err = fun(byref(cImage), cIRImage, cImageSize, byref(cTempLUT), byref(cLevel), byref(cSpan), byref(cMethod))
  handle_error(err, 'GetImage')
  
  # convert to image
  return read_image_buffer(cImage, ctype=c_ubyte)
  
def GetCorrectedImage():
  # similar to GetImage(), but with extra correction structure
  pass

def GetGrayToPaletteImage(from_image, palette=None, bitPixel=32, mirror=False, flip=False):
  
  # function
  fun           = DLL.GetGrayToPaletteImage
  fun.argtypes  = [c_void_p, c_void_p, c_ushort, c_ushort, c_void_p, c_int, c_bool, c_bool]

  # input
  cFromImage    = from_image.ctypes.data_as(POINTER(c_ubyte))
  cPalette      = temperature.GetImageLUT(palette)
  cWidth        = c_ushort(IRF_XSIZE)
  cHeight       = c_ushort(IRF_YSIZE)
  cBitPixel     = c_int(bitPixel)
  cMirror       = c_bool(mirror)
  cFlip         = c_bool(flip)

  # output
  if bitPixel == 32:
    cToImage    = (c_uint32 * (IRF_XSIZE * IRF_YSIZE))(0)
  elif bitPixel == 16:
    cToImage    = (c_ushort * (IRF_XSIZE * IRF_YSIZE))(0)
  elif bitPixel == 24:
    cToImage    = (c_ubyte * (3 * xIRF_XSIZE * IRF_YSIZE))(0)
  else:
    raise ValueError('Unsupported bitmap [%d]' % bitPixel)
    
  # call
  err = fun(cFromImage, byref(cToImage), cWidth, cHeight, byref(cPalette), cBitPixel, cMirror, cFlip)
  handle_error(err, 'GetGrayToPaletteImage')

  # convert to image
  return read_image_buffer(cToImage, ctype=c_ubyte, ndims=bitPixel/8, normalize=True)