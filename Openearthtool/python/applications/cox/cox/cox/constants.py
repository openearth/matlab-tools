IRF_XSIZE             = 384
IRF_YSIZE             = 288

IRF_IMAGE_LEVEL         = 65536       # IR image level 16bits
IRF_GRAYSCALE           = 256
IRF_MAX_IR_BUFFER_SIZE  = 10
IRF_HEADER_BUFFER_SIZE  = 64          # header memory size : 128 bytes
IRF_PACKET_ID           = 0x434F5802
IRF_FILE_ID             = 0x499602D2
SAVEDATA_VERSION        = 0x0B        # cpu save version

IRF_BUFFER_SIZE         = 8192        # Receive/Transmission buffer size
DEFAULT_TIMEOUT         = 100

# Message Code Definition
ACK_CODE              = 0x06
NAK_CODE              = 0x15
ALIVE_CODE            = 0x20
STREAM_ON_CODE        = 0x21
STREAM_OFF_CODE       = 0x22
STREAM_DATA_CODE      = 0x23
REQ_CAM_DATA_CODE     = 0x24 # Request all camera setting value.
CAM_DATA_CODE         = 0x25 # Received all camera setting value.
SAVE_CAM_DATA_CODE    = 0x26 # Request to do save camera setting value.
SET_CAM_DATA_CODE     = 0x27 # Set camera unit function setting.
SET_USER_PALETTE_CODE = 0x28 # User color palette update. (pc== --> cam)
REQ_SYS_INFO_CODE     = 0x29 # Request System Information. (pc== --> cam)
SYS_INFO_CODE         = 0x30 # Get System Information. (cam== --> pc)
FW_UPDATE_CODE        = 0x31 # Firmware update. (pc== --> cam)
MAC_UPDATE_CODE       = 0x32 # MAC Address Update
BROADCAST_CODE        = 0x50

# Camera Setting Command Code
CMD_AGC             = 0x0101  # (on/off)
CMD_LEVEL           = 0x0102  # (-20 ~ 100)
CMD_SPAN            = 0x0103  # (10 ~ 100)
CMD_SHARPNESS       = 0x0104  # (off/middle/high)
CMD_PALETTE         = 0x0105  # (0 ~ 7)
CMD_INVERT          = 0x0106  # (on/off)
CMD_MIRROR          = 0x0107  # (on/off)
CMD_FLIP            = 0x0108  # (on/off)
CMD_ZOOM            = 0x0109  # (off/2x/4x)    
CMD_NOISE_FILTER    = 0x010A  # (0:0ff, 1, 2, 3, 4, 5)
CMD_COLORBAR        = 0x0201  # (on/off)
CMD_TEMP_VIEW       = 0x0202  # (on/off)
CMD_TEMP_INDICATOR  = 0x0203  # (on/off)
CMD_TEMP_TYPE       = 0x0204  # (Celsius/Fahrenheit)
CMD_TRANSPARENCY    = 0x0205  # (0/20/40/60/80%) (0 ~ 4)
CMD_CENTER_CROSS    = 0x0206  # (on/off)
CMD_SPOT_INFO       = 0x0207  # (on/off)
CMD_SHOW_CORR       = 0x0208  # Show correction(on/off)
CMD_CAM_ID          = 0x0306  # Camera ID(1 ~ 255)
CMD_BAUDRATE        = 0x0307  # (2400/4800/9600/19200/38400)
CMD_ETHERNET        = 0x0301  # Use DHCP(on/off)
CMD_ALARM1_FUNC     = 0x0401  # Function(off/center/mean/max/min)
CMD_ALARM1_COND     = 0x0402  # Condition(above/below)
CMD_ALARM1_VAL      = 0x0403  # Value(-20 ~ 100)
CMD_ALARM2_FUNC     = 0x0404  # Function(off/center/mean/max/min)
CMD_ALARM2_COND     = 0x0405  # Condition(above/below)
CMD_ALARM2_VAL      = 0x0406  # Value(-20 ~ 100)
CMD_TV_MODE         = 0x0501  # (NTSC/PAL)
CMD_NUC             = 0x0502  # NUC
CMD_TEMP_MODE       = 0x0503  # Temperature range (normal, high)
CMD_NETWORK_FPS     = 0x0A01  # Network FPS (0:full, 1:(NTSC)60/(1+1)  (PAL)50/(1+1), ....(NTSC)59:1s  (PAL)49:1s
CMD_TEMP_CORRECT    = 0x0B01  # Entire emissivity correction
CMD_SPOT_CONF       = 0x0B02  # Spot configuration
CMD_ISOTHERM_CONF   = 0x0B03  # Isotherm configuration

# Error code
IRF_NO_ERROR                      = 1     # OK, No error
IRF_HANDLE_ERROR                  = -1    # No handle
IRF_FILE_OPEN_ERROR               = -2    # File open error.
IRF_FILE_CLOSE_ERROR              = -3    # File close error.
IRF_IR_IMAGE_READ_ERROR           = -4    # IR image read error.
IRF_FILE_BUFFER_ALLOCATION_ERROR  = -5    # File Stream Buffer allocation error.
IRF_END_OF_FILE                   = -6    # End of IR image
IRF_BEGIN_OF_FILE                 = -7    # Start of IR image
IRF_IR_IMAGE_WRITE_ERROR          = -8    # IR image write error.
IRF_NOT_FOUND_WINSOCK_DLL         = -9    # Incorrect version of WS2_32.dll found
IRF_CAMERA_CONNECTION_ERROR       = -10   # Connection error from a camera
IRF_CAMERA_DISCONNECTION          = -11   # Disconnected from a camera
IRF_PACKET_ID_ERROR               = -12   # Unknown packet ID
IRF_MESSAGE_SEND_ERROR            = -13   # Message sending error
IRF_FIRST_FRAME_POS_ERROR         = -14   # First frame position error
IRF_FILTER_SIZE_ERROR             = -15   # Image filter size error.
IRF_FILE_WRITE_COUNT_OVER         = -16   # Image frame count over
IRF_PALETTE_FILE_OPEN_ERROR       = -17   # Palette File open error.
IRF_NAK                           = -100  # Received NAK message from a camera.
IRF_BUFFER_ALLOCATION_ERROR       = -1000 # Buffer allocation error.