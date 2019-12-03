from dll import *
from constants import *
from enums import *
from structs import *

def GetImageLUT(paletteType=None, invert=False):
  
  # check input
  if paletteType == None:
    paletteType = IRF_PALETTE_TYPE_T.GREY_COLOR_MAP
  elif type(paletteType) == int:
    pass
  else:
    return paletteType
    
  # function
  fun           = DLL.GetImageLUT
  fun.argtypes  = [c_void_p, c_uint, c_bool]
  
  # input
  cPaletteType  = paletteType
  cInvert       = c_bool(invert)
  
  # output
  cPalette      = (c_byte * (IRF_GRAYSCALE * 3))(0)
  
  # call
  err = fun(byref(cPalette), cPaletteType, cInvert)
  handle_error(err, 'GetImageLUT')
    
  return cPalette

def GetTempMapTable(tempMode=None):

  # check input
  if tempMode == None:
    tempMode = IRF_DYNAMIC_RANGE_T._IRF_LOW_RANGE
  elif type(tempMode) == int:
    pass
  else:
    return tempMode
  
  # function
  fun           = DLL.GetTempMapTable
  fun.argtypes  = [c_void_p, c_uint]
  
  # input
  cTempMode     = tempMode

  # output
  cTempLUT      = (c_float * IRF_IMAGE_LEVEL)(0)

  # call
  err = fun(byref(cTempLUT), cTempMode)
  handle_error(err, 'GetTempMapTable')

  return cTempLUT
  
def GetTempRangeValue(tempMode=IRF_DYNAMIC_RANGE_T._IRF_LOW_RANGE):
    
  # function
  fun           = DLL.GetTempRangeValue
  fun.argtypes  = [c_uint, POINTER(c_short), POINTER(c_short)]

  # input
  cTempMode     = tempMode
  
  # output
  cMin          = c_short(0)
  cMax          = c_short(0)

  # call
  err = fun(cTempMode, byref(cMin), byref(cMax))
  handle_error(err, 'GetTempRangeValue')
  
  return (cMin, cMax)
  
def GetRawToTemp(ir_image, image_info=None, tempLUT=None, corrPara=None):

  # function
  fun           = DLL.GetRawToTemp
  fun.argtypes  = [c_void_p, IRF_IMAGE_INFO_T, c_void_p, IRF_TEMP_CORRECTION_PAR_T, c_void_p]

  # input
  cImageInfo    = IRF_IMAGE_INFO_T()
  cImageInfo.xSize = c_ushort(IRF_XSIZE)
  cImageInfo.ySize = c_ushort(IRF_YSIZE)
  
  cTempLUT      = GetTempMapTable(tempLUT) 
  
  cCorrPara     = IRF_TEMP_CORRECTION_PAR_T()
  cCorrPara.emissivity  = c_float(0.95)
  cCorrPara.atmTemp     = c_float(20)
  cCorrPara.atmTrans    = c_float(1)

  # output
  cTempImage    = (c_float * (IRF_XSIZE * IRF_YSIZE))(0)

  # call
  err = fun(ir_image, cImageInfo, byref(cTempLUT), cCorrPara, byref(cTempImage))
  handle_error(err, 'GetRawToTemp')
    
  return read_image_buffer(cTempImage, ctype=c_float)
  
# float __stdcall GetPointTemp(unsigned short *ir_image, IRF_IMAGE_INFO_T image_info, float *tempLUT, IRF_TEMP_CORRECTION_PAR_T corrPara, POINT pt);
# float __stdcall GetNeighborPointTemp(unsigned short *ir_image, IRF_IMAGE_INFO_T image_info, float *tempLUT, IRF_TEMP_CORRECTION_PAR_T corrPara, POINT pt);
# short __stdcall GetROITemp(unsigned short *ir_image, IRF_IMAGE_INFO_T image_info, float *tempLUT, IRF_TEMP_CORRECTION_PAR_T corrPara, RECT roi, IRF_NUMERIC_INFO_T *numInfo, POINT *min_pt, POINT *max_pt);
# short __stdcall GetRawToTemp(unsigned short *ir_image, IRF_IMAGE_INFO_T image_info, float *tempLUT, IRF_TEMP_CORRECTION_PAR_T corrPara, float* tempImage);
# float __stdcall GetCorrectedTemp(float *tempLUT, IRF_TEMP_CORRECTION_PAR_T corrPara, unsigned short engineOut);
# float __stdcall GetIRdataToTemp(unsigned short ir_data, float *tempLUT, IRF_TEMP_CORRECTION_PAR_T corrPara);