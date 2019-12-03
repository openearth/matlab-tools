from ctypes import *
from ctypes.wintypes import *

class IRF_IMAGE_INFO_T(Structure):
  _fields_ = [("xSize", c_ushort),  # horizontal size of infrared data
              ("ySize", c_ushort)]  # vertical size of infrared data

# Structure of the temperature correction parameters
class IRF_TEMP_CORRECTION_PAR_T(Structure):
  _fields_ = [("emissivity", c_float),  # 0.01 - 1.0    
              ("atmTemp", c_float),     # Atmospheric temperature in Celsius
              ("atmTrans", c_float)]    # Atmospheric Transmission in Celsius

# Structure of the file header
class IRF_IR_FILE_HEADER_T(Structure):  
  _fields_ = [("ver", BYTE),                                  # file version <=16 : old
              ("image_info", IRF_IMAGE_INFO_T),
              ("temp_correction", IRF_TEMP_CORRECTION_PAR_T)]

class IRF_IR_DATA_HEADER_T(Structure):  
  _fields_ = [("dynamic_range", BYTE),    # IRF_DYNAMIC_RANGE_T
              ("reserved", BYTE * 1000)]

# Setting of Input and output range method
class IRF_AUTO_RANGE_METHOD_T(Structure): 
  _fields_ = [("autoScale", c_uint),      # Automatic scale. (IRF_AUTOMATIC_TYPE_T)
              ("inputMethod", c_uint),    # Input range setting method. (IRF_AUTO_RANGE_INPUT_METHOD_T)
              ("outputMethod", c_uint),   # output range setting method. (IRF_AUTO_RANGE_OUTPUT_METHOD_T)
              ("B_Rate", c_float),        # Parameter of input range method. (Brightness method) (0 <= B_Rate <= 1.0)
              ("SD_Rate", c_float),       # Parameter of input range method. (SD method) (1.0 <= SD_Rate <= 6.0)
              ("intercept", c_ubyte),     # intercept of linear method (0 <= intercept <= 254)
              ("gamma", c_float),         # Gamma of non-linear method.  (0.1 <= gamma <= 25)
              ("plateau", c_uint),        # plateau value for tail-less plateau equalization.
              ("epsilon", c_float),       # The epsilon that is threshold value is a scalar arbitrary set to a value between zero and one. (Adaptive Plateau Algorithm)
              ("psi", c_float),           # The psi is a scalar arbitrary set to a value between zero and one. (Adaptive Plateau Algorithm)
              ("prevPalteau", c_float)]   # previous plateau value for using Adaptive Plateau Algorithm.

# Interface Message Structure (TCP/IP header message) : in the SDK
class IRF_MESSAGE_HEADER_T(Structure):
  _fields_ = [("ID", c_uint),
              ("Length", c_uint),
              ("Type", c_ushort),
              ("Reserved", BYTE * 6)]

# Structure of numeric information in ROI
class IRF_NUMERIC_INFO_T(Structure):
  _fields_ = [("min", c_float),
              ("max", c_float),
              ("avg", c_float),
              ("std", c_float)]

class IRF_SET_CAM_DATA_T(Structure):
  _fields_ = [("CMD", c_ushort),    # AGC, Level, Span, etc.
              ("Value", c_ushort),  # on/off, color palette, osd transparency, baud rate, zoom, nuc
              ("Value2", DWORD),    # ip address
              ("Value3", DWORD),    # netmask
              ("Value4", DWORD),    # gateway
              ("Reserved", BYTE * 16)]

# Message Body (User palette)
class IRF_SET_USER_PALETTE(Structure):
  _fields_ = [("Info", BYTE * 7),       # Reserved
              ("Index", BYTE),          # Data Index(0:userPalette1, 1:userPalette2)
              ("Data", BYTE * 1024),    # RGBA (4bytes * 256 level)
              ("pngLength", c_uint),    # PNG File length
              ("pngData", BYTE * 8192)] # PNG File data;

# camera information structure
class IRF_SAVEDATA_SPOT(Structure):
  _fields_ = [("enable", c_uint8),
              ("x", c_uint16),
              ("y", c_uint16),
              ("local", c_uint8),
              ("em", c_uint8),
              ("tr", c_uint8),
              ("at", c_int16),
              ("reserved", c_uint8 * 6)]

class IRF_SAVEDATA_ISO(Structure):
  _fields_ = [("enable", c_uint8),
              ("seed_color", c_uint32),
              ("top", c_int16),
              ("bottom", c_int16),
              ("reserved", c_uint8 * 3)]

class IRF_SAVEDATA_S(Structure):
  _fields_ = [("crc", c_uint32),
              ("ver", c_uint8),
              ("id", c_uint8),
              ("baudrate", c_uint8),
              ("level", c_int16),
              ("span", c_uint16),
              ("tv", c_uint8),
              ("agc", c_uint8),
              ("invert", c_uint8),
              ("mirror", c_uint8),
              ("flip", c_uint8),
              ("colorbar", c_uint8),
              ("showinfo", c_uint8),
              ("indicator", c_uint8),
              ("unit", c_uint8),
              ("dhcp", c_uint8),
              ("color", c_uint8),
              ("alpha", c_uint8),
              ("zoom", c_uint8),
              ("sharp", c_uint8),
              ("noise", c_uint8),
              ("nuc", c_uint16),
              ("ipaddr", c_uint32),
              ("netmask", c_uint32),
              ("gateway", c_uint32),
              ("dns", c_uint32),
              ("alarm1_func", c_uint8),
              ("alarm1_cond", c_uint8),
              ("alarm1_value", c_uint16),
              ("alarm2_func", c_uint8),
              ("alarm2_cond", c_uint8),
              ("alarm2_value", c_uint16),
              ("temp_mode", c_uint8),
              ("down_filter", c_uint8),
              ("show_center", c_uint8),
              ("show_spot", c_uint8),
              ("show_correction", c_uint8),
              ("show_isotherm", c_uint8),
              ("reserved1", c_uint8 * 70),
              ("limit9", c_uint8),
              ("enable_high", c_uint8),
              ("correction", c_uint8),
              ("emissivity", c_uint8),
              ("transmission", c_uint8),
              ("atmosphere", c_int16),
              ("spot", IRF_SAVEDATA_SPOT * 10),
              ("iso", IRF_SAVEDATA_ISO * 3)]
    
class IRF_SAVEDATA_T(Union):
  _fields_ = [("s", IRF_SAVEDATA_S),
              ("padding", c_char * 512)]

# Structurer of received data processing from TCP/IP
class IRF_IR_CAM_DATA_T(Structure): 
  _fields_ = [("ir_image", POINTER(c_ushort)),  # 16bits raw image data
              ("image_buffer_size", DWORD),     # raw image size.
              ("lpNextData", POINTER(BYTE)),    # This variable is remainder data make next raw image after make a raw image data from communication buffer.
              ("dwSize", DWORD),                # This variable is size of reminder data.
              ("dwPosition", DWORD),            # This variable is current position in the reminder data.
              ("msg_type", c_uint),             # IRF_MESSAGE_TYPE_T
              ("save_data", IRF_SAVEDATA_S),    # cam data in CAM_DATA
              ("fw_ver", c_uint),               # firmware version in SYS_INFO
              ("PMSGTYPE", c_ushort),           # Primary Message Type Code
              ("RCODE", c_ushort)]              # Response Code