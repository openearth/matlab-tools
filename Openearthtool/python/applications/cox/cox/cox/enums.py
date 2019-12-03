def enum(*sequential, **named):
    enums = dict(zip(sequential, range(len(sequential))), **named)
    return type('enum', (), enums)

IRF_TEMP_MODE_T = enum(
  '_IRF_CELSIUS',     # Celsius  
  '_IRF_FAHRENHEIT',  # Fahrenheit  
  '_IRF_KELVIN'       # Kelvin  
)

# Enumeration Action Status  
IRF_ACTION_STATUS_T = enum(
  '_IRF_STATUS_OFF',
  '_IRF_STATUS_ON'
) 

# Enumeration Automatic Type  
IRF_AUTOMATIC_TYPE_T = enum(
  '_IRF_AUTO',
  '_IRF_MANUAL'
) 

# Enumeration Dynamic range(Low/Middle/High Range)  
IRF_DYNAMIC_RANGE_T = enum(
  '_IRF_LOW_RANGE',     # -20 ~ 100
  '_IRF_MIDDLE_RANGE',
  '_IRF_HIGH_RANGE'
) 

# Enumeration of Automatic Range Algorithms (Input Range Setting)  
IRF_AUTO_RANGE_INPUT_METHOD_T = enum(
  '_IRF_MIN_MAX',         # MinMax Algorithm
  '_IRF_BRIGHTNESS_RATE', # Brightness Rate (%)
  '_IRF_SD_RATE',         # Standard Deviation Rate (%)
  '_IRF_AUTO_BRIGHT'      # Auto Brightness
) 

# Enumeration of output range setting algorithms  
IRF_AUTO_RANGE_OUTPUT_METHOD_T = enum(
  '_IRF_LINEAR',      # Linear method. (contrast + brightness)
  '_IRF_NON_LINEAR',  # Non-Linear method. (Gamma function)
  '_IRF_TPE',         # Tail-less Plateau Equalization.
  '_IRF_APE',         # Adaptive Plateau Equalization.
  '_IRF_SAPE'         # Self-adaptive plateau equalization.
) 

# Enumeration of image filters  
IRF_IMAGE_FILTER_T = enum(
  '_IRF_FILTER_NONE',
  '_IRF_MEDIAN',
  '_IRF_SOFTEN_SLIGHTLY',
  '_IRF_SOFTEN_STRONG',
  '_IRF_SHARPENING_SLIGHTLY',
  '_IRF_SHARPENING_STRONG',
  '_IRF_BOXBLUR',
  '_IRF_FAST_GAUSSIAN',
  '_IRF_FAST_STACK_BLUR'
) 

# Enumeration of Message Type  
IRF_MESSAGE_TYPE_T = enum(
  '_IRF_ACK',
  '_IRF_NAK',
  '_IRF_ALIVE',
  '_IRF_STREAM_ON',
  '_IRF_STREAM_OFF',
  '_IRF_STREAM_DATA',
  '_IRF_BROADCAST',
  '_IRF_REQ_CAM_DATA',      # Request all camera setting value.
  '_IRF_CAM_DATA',          # Received all camera setting value.
  '_IRF_SAVE_CAM_DATA',     # Request to do save camera setting value.
  '_IRF_SET_CAM_DATA',      # Set camera unit function setting.
  '_IRF_SET_USER_PALETTE',  # User color palette update. (pc --> cam)
  '_IRF_REQ_SYS_INFO',      # Request System Information. (pc --> cam)
  '_IRF_SYS_INFO'           # Get System Information.  (cam --> pc)
)

IRF_PALETTE_TYPE_T = enum(
  'YELLOW_COLOR_MAP',
  'RAINBOW_COLOR_MAP',
  'RAIN900_COLOR_MAP',
  'RAIN10_COLOR_MAP',  
  'MIDGREY_COLOR_MAP',
  'MIDGREEN_COLOR_MAP',
  'MEDICAL_COLOR_MAP',
  'IRON10_COLOR_MAP',
  'IRON_COLOR_MAP',
  'GREYRED_COLOR_MAP',
  'GREY10_COLOR_MAP',
  'GREY_COLOR_MAP',
  'GLOWBOW_COLOR_MAP'
)

IRF_CAM_PALETTE_TYPE_T = enum(
  'GREY',
  'RAINBOW',
  'IRON',
  'GREYRED',
  'GLOWBOW',
  'YELLOW',
  'MIDGREY',
  'MIDGREEN'
)