// CoxCamDll.h : CoxCamDll DLL의 기본 헤더 파일입니다.;
// Title : Description of the functions and structure
// 
// Date : 2010. 11. 24.
// Name : EunSeok Kim

#include <windows.h>
#include "mmsystem.h"
#include <stdint.h>

// 라이브러리 관련;
#pragma comment(lib, "CoxCamDll.lib")
#pragma comment(lib, "winmm.lib")
#pragma comment(lib, "Msimg32.lib")

#pragma region Define definition
/* define */
#define CONVERT565(r,g,b) (((r>>3)<<11) | ((g>>3)<<5) | (b>>3))
#define CONVERT555(r,g,b) (((r>>3)<<10) | ((g>>2)<<5) | (b>>3))
#define IRF_IMAGE_LEVEL			65536		// IR image level 16bits
#define IRF_GRAYSCALE			256
#define IRF_MAX_IR_BUFFER_SIZE	10
#define IRF_HEADER_BUFFER_SIZE	64			// header memory size : 128 bytes
#define IRF_PACKET_ID			0x434F5802
#define IRF_FILE_ID				0x499602D2
#define SAVEDATA_VERSION		0x0B		// cpu save version

#define IRF_BUFFER_SIZE		    8192	/* Receive/Transmission buffer size */
#define DEFAULT_TIMEOUT			100L

/* Message Code Definition */
#define ACK_CODE				0x06
#define NAK_CODE				0x15
#define ALIVE_CODE				0x20
#define STREAM_ON_CODE			0x21
#define STREAM_OFF_CODE			0x22
#define STREAM_DATA_CODE		0x23
#define REQ_CAM_DATA_CODE		0x24	// Request all camera setting value.
#define CAM_DATA_CODE			0x25	// Received all camera setting value.
#define SAVE_CAM_DATA_CODE		0x26	// Request to do save camera setting value.
#define SET_CAM_DATA_CODE		0x27	// Set camera unit function setting.
#define SET_USER_PALETTE_CODE	0x28	// User color palette update. (pc --> cam)
#define REQ_SYS_INFO_CODE		0x29	// Request System Information. (pc --> cam)
#define SYS_INFO_CODE			0x30	// Get System Information.	(cam --> pc)
#define FW_UPDATE_CODE			0x31	// Firmware update.	(pc --> cam)
#define MAC_UPDATE_CODE			0x32	// MAC Address Update
#define BROADCAST_CODE			0x50

/* Camera Setting Command Code */
#define CMD_AGC				0x0101		// (on/off)
#define CMD_LEVEL			0x0102		// (-20 ~ 100)
#define CMD_SPAN			0x0103		// (10 ~ 100)
#define CMD_SHARPNESS		0x0104		// (off/middle/high)
#define CMD_PALETTE			0x0105		// (0 ~ 7)
#define CMD_INVERT			0x0106		// (on/off)
#define CMD_MIRROR			0x0107		// (on/off)
#define CMD_FLIP			0x0108		// (on/off)
#define CMD_ZOOM			0x0109		// (off/2x/4x)				
#define CMD_NOISE_FILTER	0x010A		// (0:0ff, 1, 2, 3, 4, 5)
#define CMD_COLORBAR		0x0201		// (on/off)
#define CMD_TEMP_VIEW		0x0202		// (on/off)
#define CMD_TEMP_INDICATOR	0x0203		// (on/off)
#define CMD_TEMP_TYPE		0x0204		// (Celsius/Fahrenheit)
#define CMD_TRANSPARENCY	0x0205		// (0/20/40/60/80%) (0 ~ 4)
#define CMD_CENTER_CROSS	0x0206		// (on/off)
#define CMD_SPOT_INFO		0x0207		// (on/off)
#define CMD_SHOW_CORR		0x0208		// Show correction(on/off)
#define CMD_CAM_ID			0x0306		// Camera ID(1 ~ 255)
#define CMD_BAUDRATE		0x0307		// (2400/4800/9600/19200/38400)
#define CMD_ETHERNET		0x0301		// Use DHCP(on/off)
#define CMD_ALARM1_FUNC		0x0401		// Function(off/center/mean/max/min)
#define CMD_ALARM1_COND		0x0402		// Condition(above/below)
#define CMD_ALARM1_VAL		0x0403		// Value(-20 ~ 100)
#define CMD_ALARM2_FUNC		0x0404		// Function(off/center/mean/max/min)
#define CMD_ALARM2_COND		0x0405		// Condition(above/below)
#define CMD_ALARM2_VAL		0x0406		// Value(-20 ~ 100)
#define CMD_TV_MODE			0x0501		// (NTSC/PAL)
#define CMD_NUC				0x0502		// NUC
#define CMD_TEMP_MODE		0x0503		// Temperature range (normal, high)
#define CMD_NETWORK_FPS		0x0A01		// Network FPS (0:full, 1:(NTSC)60/(1+1)  (PAL)50/(1+1), ....(NTSC)59:1s  (PAL)49:1s
#define CMD_TEMP_CORRECT	0x0B01		// Entire emissivity correction
#define CMD_SPOT_CONF		0x0B02		// Spot configuration
#define CMD_ISOTHERM_CONF	0x0B03		// Isotherm configuration


/* Error code */
#define IRF_NO_ERROR						1			/* OK, No error */
#define IRF_HANDLE_ERROR					-1			/* No handle */
#define IRF_FILE_OPEN_ERROR					-2			/* File open error. */
#define IRF_FILE_CLOSE_ERROR				-3			/* File close error. */
#define IRF_IR_IMAGE_READ_ERROR				-4			/* IR image read error. */
#define IRF_FILE_BUFFER_ALLOCATION_ERROR	-5			/* File Stream Buffer allocation error. */
#define IRF_END_OF_FILE						-6			/* End of IR image */
#define IRF_BEGIN_OF_FILE					-7			/* Start of IR image */
#define IRF_IR_IMAGE_WRITE_ERROR			-8			/* IR image write error. */
#define IRF_NOT_FOUND_WINSOCK_DLL			-9			/* Incorrect version of WS2_32.dll found */
#define IRF_CAMERA_CONNECTION_ERROR			-10			/* Connection error from a camera */
#define IRF_CAMERA_DISCONNECTION			-11			/* Disconnected from a camera */
#define IRF_PACKET_ID_ERROR					-12			/* Unknown packet ID */
#define IRF_MESSAGE_SEND_ERROR				-13			/* Message sending error */
#define IRF_FIRST_FRAME_POS_ERROR			-14			/* First frame position error */
#define IRF_FILTER_SIZE_ERROR				-15			/* Image filter size error. */
#define IRF_FILE_WRITE_COUNT_OVER			-16			/* Image frame count over */
#define IRF_PALETTE_FILE_OPEN_ERROR			-17			/* Palette File open error. */
#define IRF_NAK								-100		/* Received NAK message from a camera. */
#define IRF_BUFFER_ALLOCATION_ERROR			-1000		/* Buffer allocation error. */

#pragma endregion Define definition

#pragma region Enumeration Definition
/* Enumeration Temperature Mode */
typedef enum
{
	_IRF_CELSIUS,		/* Celsius */
	_IRF_FAHRENHEIT,	/* Fahrenheit */
	_IRF_KELVIN			/* Kelvin */
} IRF_TEMP_MODE_T;


/* Enumeration Action Status */
typedef enum
{
	_IRF_STATUS_OFF,
	_IRF_STATUS_ON
} IRF_ACTION_STATUS_T;


/* Enumeration Automatic Type */
typedef enum
{
	_IRF_AUTO,
	_IRF_MANUAL
} IRF_AUTOMATIC_TYPE_T;

/* Enumeration Dynamic range(Low/Middle/High Range) */
typedef enum
{
	_IRF_LOW_RANGE,		// -20 ~ 100	(미정);
	_IRF_MIDDLE_RANGE,	// 미정;
	_IRF_HIGH_RANGE		// 미정;
} IRF_DYNAMIC_RANGE_T;

/* Enumeration of Automatic Range Algorithms (Input Range Setting) */
typedef enum
{
	_IRF_MIN_MAX,			// MinMax Algorithm
	_IRF_BRIGHTNESS_RATE,	// Brightness Rate (%)
	_IRF_SD_RATE,			// Standard Deviation Rate (%)
	_IRF_AUTO_BRIGHT			// Auto Brightness
} IRF_AUTO_RANGE_INPUT_METHOD_T;

/* Enumeration of output range setting algorithms */
typedef enum
{
	_IRF_LINEAR,			// Linear method. (contrast + brightness)
	_IRF_NON_LINEAR,		// Non-Linear method. (Gamma function)
	_IRF_TPE,				// Tail-less Plateau Equalization.
	_IRF_APE,				// Adaptive Plateau Equalization.
	_IRF_SAPE				// Self-adaptive plateau equalization.
} IRF_AUTO_RANGE_OUTPUT_METHOD_T;

/* Enumeration of image filters */
typedef enum
{
	_IRF_FILTER_NONE,
	_IRF_MEDIAN,
	_IRF_SOFTEN_SLIGHTLY,
	_IRF_SOFTEN_STRONG,
	_IRF_SHARPENING_SLIGHTLY,
	_IRF_SHARPENING_STRONG,
	_IRF_BOXBLUR,
	_IRF_FAST_GAUSSIAN,
	_IRF_FAST_STACK_BLUR
} IRF_IMAGE_FILTER_T;

/* Enumeration of Message Type */
typedef enum
{
	_IRF_ACK,
	_IRF_NAK,
	_IRF_ALIVE,
	_IRF_STREAM_ON,
	_IRF_STREAM_OFF,
	_IRF_STREAM_DATA,
	_IRF_BROADCAST,
	_IRF_REQ_CAM_DATA,		// Request all camera setting value.
	_IRF_CAM_DATA,			// Received all camera setting value.
	_IRF_SAVE_CAM_DATA,		// Request to do save camera setting value.
	_IRF_SET_CAM_DATA,		// Set camera unit function setting.
	_IRF_SET_USER_PALETTE,	// User color palette update. (pc --> cam)
	_IRF_REQ_SYS_INFO,		// Request System Information. (pc --> cam)
	_IRF_SYS_INFO			// Get System Information.	(cam --> pc)
} IRF_MESSAGE_TYPE_T;

typedef enum
{
	YELLOW_COLOR_MAP,
	RAINBOW_COLOR_MAP,
	RAIN900_COLOR_MAP,
	RAIN10_COLOR_MAP,	
	MIDGREY_COLOR_MAP,
	MIDGREEN_COLOR_MAP,
	MEDICAL_COLOR_MAP,
	IRON10_COLOR_MAP,
	IRON_COLOR_MAP,
	GREYRED_COLOR_MAP,
	GREY10_COLOR_MAP,
	GREY_COLOR_MAP,
	GLOWBOW_COLOR_MAP
}IRF_PALETTE_TYPE_T;

typedef enum
{
	GREY,
	RAINBOW,
	IRON,
	GREYRED,
	GLOWBOW,
	YELLOW,
	MIDGREY,
	MIDGREEN
}IRF_CAM_PALETTE_TYPE_T;
#pragma endregion Enumeration Definition

#pragma region Structure Definition
#pragma pack(1)
/* The image data structure */
typedef struct
{	
	unsigned short xSize;		/* horizontal size of infrared data */
	unsigned short ySize;		/* vertical size of infrared data */
} IRF_IMAGE_INFO_T;


/* Structure of the temperature correction parameters */
typedef struct
{
	float emissivity;		/* 0.01 - 1.0 */		
	float atmTemp;			/* Atmospheric temperature in Celsius */
	float atmTrans;			/* Atmospheric Transmission in Celsius */
} IRF_TEMP_CORRECTION_PAR_T;

/* Structure of the file header */
typedef struct  
{
	BYTE ver;				/* file version <=16 : old */
	IRF_IMAGE_INFO_T image_info;
	IRF_TEMP_CORRECTION_PAR_T temp_correction;
} IRF_IR_FILE_HEADER_T;


typedef struct  
{
	BYTE dynamic_range;	// IRF_DYNAMIC_RANGE_T
	BYTE reserved[1000];
} IRF_IR_DATA_HEADER_T;



/* Setting of Input and output range method */
typedef struct 
{
	IRF_AUTOMATIC_TYPE_T autoScale;					// Automatic scale.
	IRF_AUTO_RANGE_INPUT_METHOD_T inputMethod;		// Input range setting method.
	IRF_AUTO_RANGE_OUTPUT_METHOD_T outputMethod;	// output range setting method.
	float B_Rate;			 // Parameter of input range method. (Brightness method)	(0 <= B_Rate <= 1.0)
	float SD_Rate;			 // Parameter of input range method. (SD method)	(1.0 <= SD_Rate <= 6.0)
	unsigned char intercept; // intercept of linear method (0 <= intercept <= 254)
	float gamma;			 // Gamma of non-linear method.	(0.1 <= gamma <= 25)
	unsigned int plateau;	 // plateau value for tail-less plateau equalization.
	float epsilon;			 // The epsilon that is threshold value is a scalar arbitrary set to a value between zero and one. (Adaptive Plateau Algorithm)
	float psi;				 // The psi is a scalar arbitrary set to a value between zero and one. (Adaptive Plateau Algorithm)
	float prevPalteau;		 // previous plateau value for using Adaptive Plateau Algorithm.
} IRF_AUTO_RANGE_METHOD_T;

/* Interface Message Structure (TCP/IP header message) : in the SDK */
typedef struct
{
	unsigned int ID;
	unsigned int Length;
	unsigned short Type;
	BYTE Reserved[6];
} IRF_MESSAGE_HEADER_T;

/* Structure of numeric information in ROI */
typedef struct
{
	float min;
	float max;
	float avg;
	float std;
} IRF_NUMERIC_INFO_T;

typedef struct {
	unsigned short CMD;		// AGC, Level, Span, etc.
	unsigned short Value;	// on/off, color palette, osd transparency, baud rate, zoom, nuc
	DWORD Value2;			// ip address
	DWORD Value3;			// netmask
	DWORD Value4;			// gateway
	BYTE Reserved[16];
} IRF_SET_CAM_DATA_T;


/* Message Body (User palette) */
typedef struct {
	BYTE Info[7];				// Reserved
	BYTE Index;					// Data Index(0:userPalette1, 1:userPalette2)
	BYTE Data[1024];			// RGBA (4bytes * 256 level)
	unsigned int pngLength;		// PNG File length
	BYTE pngData[8192];			// PNG File data;
} IRF_SET_USER_PALETTE;


/* camera information structure */
typedef union strSAVEDATA
{
	struct
	{
		uint32_t	crc;
		uint8_t		ver;
		uint8_t		id;
		uint8_t		baudrate;
		int16_t		level;
		uint16_t	span;
		uint8_t		tv;
		uint8_t		agc;
		uint8_t		invert;
		uint8_t		mirror;
		uint8_t		flip;
		uint8_t		colorbar;
		uint8_t		showinfo;
		uint8_t		indicator;
		uint8_t		unit;
		uint8_t		dhcp;
		uint8_t		color;
		uint8_t		alpha;
		uint8_t		zoom;
		uint8_t		sharp;
		uint8_t		noise;			// new
		uint16_t	nuc;
		uint32_t	ipaddr;
		uint32_t	netmask;
		uint32_t	gateway;
		uint32_t	dns;
		uint8_t		alarm1_func;	// new
		uint8_t 	alarm1_cond;	// new
		uint16_t	alarm1_value;	// new
		uint8_t		alarm2_func;	// new
		uint8_t		alarm2_cond;	// new
		uint16_t	alarm2_value;	// new
		uint8_t		temp_mode;		// reserved
		uint8_t		down_filter;	// reserved
		uint8_t		show_center;
		uint8_t		show_spot;
		uint8_t		show_correction;
		uint8_t		show_isotherm;
		uint8_t		reserved1[70];	    // 128th
		uint8_t		limit9;
		uint8_t		enable_high;	// device 고온모드 엔진=1, only 상온모드 엔진 = 0
		uint8_t		correction;
		uint8_t		emissivity;
		uint8_t		transmission;
		int16_t	atmosphere;
		struct {
			uint8_t		enable;
			uint16_t	x;
			uint16_t	y;
			uint8_t		local;
			uint8_t		em;
			uint8_t		tr;
			int16_t	at;
			uint8_t		reserved[6];
		} spot[10];
		struct {
			uint8_t		enable;
			uint32_t	seed_color;
			int16_t		top;
			int16_t		bottom;
			uint8_t		reserved[3];
		} iso[3];
	};

	char padding[512];
} IRF_SAVEDATA_T;


/* Structurer of received data processing from TCP/IP */
typedef struct 
{
	unsigned short* ir_image;	// 16bits raw image data * 10
	DWORD image_buffer_size;	// raw image size.
	LPBYTE lpNextData;			// This variable is remainder data make next raw image after make a raw image data from communication buffer.
	DWORD dwSize;				// This variable is size of reminder data.
	DWORD dwPosition;			// This variable is current position in the reminder data.

	IRF_MESSAGE_TYPE_T		msg_type;
	IRF_SAVEDATA_T			save_data;		// cam data in CAM_DATA
	unsigned int			fw_ver;			// firmware version in SYS_INFO

	unsigned short PMSGTYPE;	// Primary Message Type Code
	unsigned short RCODE;		// Response Code
} IRF_IR_CAM_DATA_T;


#pragma pack()
#pragma endregion Structure Definition


#pragma region Function definition
extern "C" __declspec(dllimport) short PASCAL GetIRHeader(HANDLE handle, IRF_IR_FILE_HEADER_T* header, unsigned long *curPos);
extern "C" __declspec(dllimport) short PASCAL GetIRHeaders(HANDLE handle, IRF_IR_FILE_HEADER_T* header, IRF_IR_DATA_HEADER_T* addedInfo, unsigned long *curPos);
extern "C" __declspec(dllimport) short PASCAL GetImageLUT(unsigned char *palette, IRF_PALETTE_TYPE_T paletteType, bool bInvert);
extern "C" __declspec(dllimport) short PASCAL GetImage(unsigned char *image, unsigned short *ir_image, long image_size, float *tempLUT, float *level, float *span, IRF_AUTO_RANGE_METHOD_T *method);
extern "C" __declspec(dllimport) short PASCAL GetCorrectedImage(unsigned char *image, unsigned short *ir_image, long image_size, float* tempLUT, IRF_TEMP_CORRECTION_PAR_T corrPara, float *level, float *span, IRF_AUTO_RANGE_METHOD_T *method);
extern "C" __declspec(dllimport) short PASCAL GetIRHistogram(unsigned int *hist, unsigned short *ir_image, long image_size);
extern "C" __declspec(dllimport) short PASCAL GetGrayToPaletteImage(unsigned char *from_image, void* to_image, unsigned short width, unsigned short height, unsigned char *palette, int BitsPixel, bool bMirror, bool bFlip);
extern "C" __declspec(dllimport) short PASCAL GetTempRangeValue(IRF_DYNAMIC_RANGE_T tempMode, short *min, short *max);
extern "C" __declspec(dllimport) float PASCAL ConvertFahToCels(float temp);
extern "C" __declspec(dllimport) float PASCAL ConvertCelsToFah(float temp);
extern "C" __declspec(dllimport) float PASCAL ConvertKelvToCels(float temp);
extern "C" __declspec(dllimport) float PASCAL ConvertKelvToFah(float temp);
extern "C" __declspec(dllimport) float PASCAL ConvertCelToKel(float temp);
extern "C" __declspec(dllimport) float PASCAL ConvertFahToKel(float temp);
extern "C" __declspec(dllimport) void PASCAL BilateralFilter(unsigned char *image, unsigned short width, unsigned short height, float sigD, float sigR, int w);
extern "C" __declspec(dllimport) void PASCAL GetGaussianKernel(int *kernel, int *mult, int sz);
extern "C" __declspec(dllimport) short PASCAL FastGaussianBlur(BYTE *img, int iw, int ih, int *Gkernel, int *Gmult, int radius);
extern "C" __declspec(dllimport) short PASCAL FastStackBlur(BYTE* img, int w, int h, int radius);
extern "C" __declspec(dllimport) short PASCAL BoxBlur(BYTE *src, int src_w, int src_h, int sz);
extern "C" __declspec(dllimport) short PASCAL ApplyImageFilter(unsigned char *image, unsigned short width, unsigned short height, IRF_IMAGE_FILTER_T filter);
extern "C" __declspec(dllimport) short PASCAL LoadIRImage(HANDLE *handle, char *FileName, unsigned long *totSize);
extern "C" __declspec(dllimport) short PASCAL GetIRImageFromStream(HANDLE handle, unsigned short* ir_image, long image_size, unsigned long totStreamSize, unsigned long *curPos, int* gap_time, bool bLoop);
extern "C" __declspec(dllimport) short PASCAL GetIRImageFromStream_n(HANDLE handle, unsigned short* ir_image, long image_size, unsigned long totStreamSize, unsigned long *curPos, int* gap_time, bool bLoop, bool new_ver);
extern "C" __declspec(dllimport) short PASCAL GetRevIRImageFromStream(HANDLE handle, unsigned short* ir_image, long image_size, unsigned long *curPos, int* gap_time);
extern "C" __declspec(dllimport) short PASCAL GetRevIRImageFromStream_n(HANDLE handle, unsigned short* ir_image, long image_size, unsigned long *curPos, int* gap_time, bool new_ver);
extern "C" __declspec(dllimport) short PASCAL CloseIRStream(HANDLE handle);
extern "C" __declspec(dllimport) short PASCAL SaveIRImage(HANDLE *handle, char* filename, IRF_IR_FILE_HEADER_T *pHeader);
extern "C" __declspec(dllimport) short PASCAL SaveIRHeader(HANDLE *handle, char* filename, IRF_IR_FILE_HEADER_T *pHeader, IRF_IR_DATA_HEADER_T *pAddedData);
extern "C" __declspec(dllimport) short PASCAL SetIRImageToStream(HANDLE handle, unsigned short* ir_image, long image_size, int millisecond, short *frameCnt);
extern "C" __declspec(dllimport) void PASCAL DrawColorBar(HWND hWnd, HDC hDC, unsigned char* palette, float level, float span, IRF_TEMP_MODE_T tempUnit, bool bUpdateOnlyTickArea);
extern "C" __declspec(dllimport) short PASCAL GetIRImages(HANDLE handle, UINT *pTimerID, IRF_IR_CAM_DATA_T* cam_data);
extern "C" __declspec(dllimport) short PASCAL OpenConnect(HANDLE *pHandle, UINT *pTimerID, LPCTSTR strDestination, LPCTSTR strServiceName, int nProtocol, int nType);
extern "C" __declspec(dllimport) short PASCAL CloseConnect(HANDLE *handle, UINT timerID);
extern "C" __declspec(dllimport) short PASCAL SendCameraMessage(HANDLE handle, UINT *pTimerID, IRF_MESSAGE_TYPE_T type, unsigned short PMSGTYPE, unsigned short RCODE);
extern "C" __declspec(dllimport) short PASCAL GetTempMapTable(float* tempLUT, IRF_DYNAMIC_RANGE_T tempMode);
extern "C" __declspec(dllimport) float PASCAL GetCorrectedTemp(float *tempLUT, IRF_TEMP_CORRECTION_PAR_T corrPara, unsigned short engineOut);
extern "C" __declspec(dllimport) float PASCAL GetPointTemp(unsigned short *ir_image, IRF_IMAGE_INFO_T image_info, float *tempLUT, IRF_TEMP_CORRECTION_PAR_T corrPara, POINT pt);
extern "C" __declspec(dllimport) float PASCAL GetNeighborPointTemp(unsigned short *ir_image, IRF_IMAGE_INFO_T image_info, float *tempLUT, IRF_TEMP_CORRECTION_PAR_T corrPara, POINT pt);
extern "C" __declspec(dllimport) short PASCAL GetROITemp(unsigned short *ir_image, IRF_IMAGE_INFO_T image_info, float *tempLUT, IRF_TEMP_CORRECTION_PAR_T corrPara, RECT roi, IRF_NUMERIC_INFO_T *numInfo, POINT *min_pt, POINT *max_pt);
extern "C" __declspec(dllimport) void PASCAL DrawMinMaxPos(HDC hDC, POINT minP, POINT maxP, int size);
extern "C" __declspec(dllimport) short PASCAL ApplyColorImageFilter(void* image, unsigned short width, unsigned short height, IRF_IMAGE_FILTER_T filter, int bitPixel);
extern "C" __declspec(dllimport) short PASCAL GetError(short code, LPCTSTR msg);
extern "C" __declspec(dllimport) short PASCAL SendMessageToCamera(HANDLE handle, UINT *pTimerID, IRF_MESSAGE_TYPE_T type, unsigned short PMSGTYPE, unsigned short RCODE, DWORD RCODE2, DWORD RCODE3, DWORD RCODE4);
extern "C" __declspec(dllimport) short PASCAL SendPaletteMessage(HANDLE handle, UINT *pTimerID, IRF_SET_USER_PALETTE struct_palette);

#pragma endregion Function definition
