
//
//  dio_shm.h: DelftIO Shared Memory
//
//  include file DioShmClass
//
//  stef.hummel@wldelft.nl
//
//  (c) WL | Delft Hydraulics, Jan 2000
//


#if (!defined(DIOSHM_HANDLE_H))
#define DIOSHM_HANDLE_H

#if (defined(WIN32))
#include <windows.h>
#endif


class DioShmHandle {

public:
#if (defined(WIN32))
    HANDLE  mmfHandle;		// Windows Handle (Memory Mapped File)
#else
    void * mmfHandle;		// Unix Handle (ESM)
#endif

    void * shmBlock;		// Handle to data (MapView of file)

    DioShmHandle(int iSize, char * name);
    ~DioShmHandle();

};


#endif
