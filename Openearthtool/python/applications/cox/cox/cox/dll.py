from ctypes import *
from ctypes.wintypes import *

from constants import *

import os
import struct
import numpy as np

DLLPath = r"c:\cox\dll\CoxCamDll.dll"

#DLLPath = r"CoxCamDll.dll"
#DLLPath = r"d:\COX\CoxDLLSample\CoxCamDllSample\CoxCamDll.dll"
#DLLPath = r"c:\Program Files (x86)\CX\ThermalTools\Dll&Bin\CoxCamDll.dll"

if os.path.exists(DLLPath):
    DLL = WinDLL(DLLPath)
else:
    DLL = None

def handle_error(err, fcn):
  
  if err < 1:
    raise StandardError('%s [%d]' % (fcn, err))
    
def read_image_buffer(img, width=IRF_XSIZE, height=IRF_YSIZE, ndims=1, ctype=c_ushort, normalize=False):
  
  fmt, dtype = convert_ctype(ctype)

  buffer_size = width * height * ndims * sizeof(ctype)
  img_buffer  = create_string_buffer(buffer_size) 

  memmove(img_buffer, img, buffer_size)
  
  # OPTIMIZE
  fmt = fmt * (width * height * ndims)
  M   = np.array(struct.unpack_from(fmt, img_buffer), dtype=dtype)
  M   = M.reshape([height,width,ndims])
  M   = np.squeeze(M)
  
  # normalize
  if normalize:
    M = (M.astype(np.float) - M.min())/(M.max() - M.min())
  
  return M
  
def convert_ctype(ctype):

  v = ctype()

  if type(v) is c_ubyte:
    fmt   = 'B'
    dtype = np.uint8
  elif type(v) is c_ushort:
    fmt   = 'H'
    dtype = np.uint16
  elif type(v) is c_uint:
    fmt   = 'I'
    dtype = np.uint32
  elif type(v) is c_float:
    fmt   = 'f'
    dtype = np.float16
  else:
    raise ValueError('Unsupported C-type [%s]' % type(v))
    
  return (fmt, dtype)