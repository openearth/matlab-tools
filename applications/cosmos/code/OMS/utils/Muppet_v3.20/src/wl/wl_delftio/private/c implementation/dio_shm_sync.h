//
//  dio_shm_sync.h: DelftIO Shared Memory synchronisation functions
//
//  stef.hummel@wldelft.nl
//
//  (c) WL | Delft Hydraulics, Jan 2000
//


#if (!defined(DIOSHM_SYNC_H))
#define DIOSHM_SYNC_H


//
// Enumeration for Dataset part to synchronize
//

typedef enum {
    DioShmHeaderPart, // dataset's header data
    DioShmDataPart,   // dataset's 'timestep' data
    DIO_NUM_PARTS
} DioShmPart;


//
// Dataset Synchronisation information
//

typedef struct _DioShmSync_STR {

    int infoAvailable;                // is info complete
    int dataAvailable[DIO_NUM_PARTS]; // has header/data been provided?
    int putterDone;                   // Putter cleans up

}DioShmSync_STR;
typedef DioShmSync_STR * DioShmSync;


//
// Enumeration for DataStored/DataConsumed functions
//

typedef enum {
    DsConfirm,       // Confirm Storage/Consumation of header or data part
    DsCheck,         // Check if header or data part has been stored/consumed
    NR_STORE_TYPES
} DsStoreFlag;


///
/// PUBLIC Functions
///

//
// Set sleep time / Sleep
//
void DioSetSyncSleepTime(int sleepTime);
void DioSleep(int sleepTime);

//
// Confirm/Check Storage/Consumation of header or data part
// In case of Check flag, function synchronizes.
//

int DioShmDataConsumed(DioShmSync sync, DioShmPart part, DsStoreFlag flag);
int DioShmDataStored(DioShmSync sync, DioShmPart part, DsStoreFlag flag);

//
// Wait until dataset info is available
//
int DioShmInfoAvailable(DioShmSync sync);

#endif

