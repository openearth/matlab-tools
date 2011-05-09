//
//  dio_shm_datablock.h: DelftIO Shared Memory Datablocks
//
//  stef.hummel@wldelft.nl
//
//  (c) WL | Delft Hydraulics, May 2002
//


#if (!defined(DIOSHM_DATASET_H))
#define DIOSHM_DATASET_H

//
// Put/Get bytes to/from a Named Datablock
//

void DioShmPutDataBlock(char * name, int dSize, char * data);
int DioShmGetDataBlock(char * name, int dSize, char * data);

//
// Cleanup the Named Datablock administration
//

void DioShmDataBlockCleanup(void);


#endif
