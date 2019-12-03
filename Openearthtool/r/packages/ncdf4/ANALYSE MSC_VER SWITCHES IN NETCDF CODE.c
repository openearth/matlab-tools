/* DEZE FILE BEVAT ALLE PLAATSEN IN DE C-CODE WAAR _MSC_VER WORDT GEBRUIKT ALS SWITCH
SOMMIGE VAN DIE AANPASSINGEN ZIJN COMPILER-SPECIFIEK, EN KUNNEN ZO BLIJVEN. ANDERE
HANGEN AF VAN HET OS OF VAN DE C RUNTIME, EN DAN MOET _MSC_VER VERVANGEN WORDEN DOOR _WIN32
IK HEB ZO VEEL MOGELIJK GEVALLEN GETEST (MAAR HET WAS NIET ALTIJD MOGELIJK). BEHALVE DE PATCHES
DIE REEDS ZIJN UITGEVOERD, IS ER MAAR ÉÉN GEVAL (cvt.c) WAAR EEN VERANDERING ZICH OPDRINGT
TOCH BEWAAR IK DEZE FILE ALS HERINNERING EN VOOR HET GEVAL ER ZICH TOCH PROBLEMEN ZOUDEN
VOORDOEN */


/* from dapcvt.c */
   int ok;
   char* s = (char*)nclistget(src,i);
   size_t slen = strlen(s);
   int nread = 0; /* # of chars read by sscanf */


   unsigned char* p = (unsigned char*)dstmem;
	    unsigned char* p = (unsigned char*)dstmem;
#ifdef _WIN32
	    unsigned int uval;
	    ok = sscanf(s,"%u%n",&uval,&nread);
#ifdef _MSC_VER
	    _ASSERTE(_CrtCheckMemory());
#endif
	    /* For back compatibility, we allow any value, but force conversion */
	    uval = (uval & 0xFF);
	    *p = (unsigned char)uval;
#else
	    ok = sscanf(s,"%hhu%n",p,&nread);
#endif


/* DIT IS OK */

   
	   

	   long long* p = (long long*)dstmem;
   
   #ifdef _WIN32
		ok = sscanf(s, "%I64d%n", p,&nread);
#else
		ok = sscanf(s,"%lld%n",p,&nread);
#endif

/* DIT WAS NIET NODIG (lld WERKT OOK) MAAR HET IS OOK NIET FOUT LATEN STAAN DUS */

/* from dauth.c */
#ifdef _MSC_VER
#include <windows.h>
#endif

#ifdef _MSC_VER
        DeleteFile(auth->curlflags.cookiejar);
#else
        remove(auth->curlflags.cookiejar);
#endif

/* THIS IS OK CAN REMAIN AS SUCH. remove IS RECOGNIZED BY GCC AND WORKS */


/* from dfile.c */
#ifdef _MSC_VER
        file->fp = fopen(file->path, "rb");
#else
        file->fp = fopen(file->path, "r");
#endif

#ifdef _MSC_VER
	int fd = fileno(file->fp);
	__int64 len64 = _filelengthi64(fd);
	if(len64 < 0)
            {status = errno; goto done;}
	file->filelen = (long long)len64;
#else
	long size;
	if((status = fseek(file->fp, 0L, SEEK_END)) < 0)
	    {status = errno; goto done;}
	size = ftell(file->fp);
	file->filelen = (long long)size;
#endif

/* KAN ZO BLIJVEN, LIJKT ALLEMAAL TE WERKEN OP WINDOWS */


/* from dutil.c */
#ifdef _MSC_VER
    stream = NCfopen(filename,"r");
#else
    stream = NCfopen(filename,"rb");
#endif

#ifdef _MSC_VER
        fd=NCopen3(tmp,O_RDWR|O_BINARY|O_CREAT, _S_IREAD|_S_IWRITE);
#else
        fd=NCopen3(tmp,O_RDWR|O_CREAT|O_EXCL, S_IRWXU);
#endif

/* KAN WAARSCHIJNLIJK ZO BLIJVEN, fopen LIJKT GOED TE WERKEN */


/* in dwinpath en elders */

#ifndef _MSC_VER
	p = outpath;
        /* Convert '\' back to '/' */
        for(;*p;p++) {
            if(*p == '\\') {*p = '/';}
	}
    }
#endif /*!_MSC_VER*/

/* DIT LIJKT NOOIT EEN PROBLEEM TE ZIJN */

/* from nc_initialize.c  - geen idee waar dit over gaat */
#ifdef _MSC_VER
    /* Force binary mode */
    _set_fmode(_O_BINARY);
#endif

/* WAARSCHIJNLIJK OOK GEEN PROBLEEM */


/* from nc4file.c */
static void
hdf5free(void* memory)
{
#ifndef JNA
   /* On Windows using the microsoft runtime, it is an error
      for one library to free memory allocated by a different library.*/
#ifdef HDF5_HAS_H5FREE
   if(memory != NULL) H5free_memory(memory);
#else
#ifndef _MSC_VER
   if(memory != NULL) free(memory);
#endif
#endif
#endif
}

/* DIT ZOU EEN PROBLEEM KUNNEN ZIJN, MAAR IK KAN HET NIET TESTEN. LAAT HET VOORLOPIG ZO. HET PROBLEEM LIJKT VOORAL VOOR TE KOMEN ALS
VERSCHILLENDE MODULES MET VERSCHILLENDE RUNTIMES SAMENWERKEN. DAT ZOU HIER MEE MOETEN VALLEN.*/

/* from cvt.c */

    Constvalue tmp;
    unsigned char* bytes = NULL;
    size_t bytelen;
#ifdef _MSC_VER
    int byteval;
#endif
    dst->lineno = src->lineno;
#ifdef _MSC_VER
case CASE(NC_STRING,NC_BYTE):
    sscanf(src->value.stringv.stringv,"%d",&byteval); tmp.int8v = (char)byteval; break;
case CASE(NC_STRING,NC_UBYTE):
    sscanf(src->value.stringv.stringv,"%d",&byteval); tmp.uint8v = (unsigned char)byteval; break;
#else
case CASE(NC_STRING,NC_BYTE):
    sscanf(src->value.stringv.stringv,"%hhd",&tmp.int8v); break;
case CASE(NC_STRING,NC_UBYTE):
    sscanf(src->value.stringv.stringv,"%hhu",&tmp.uint8v); break;
#endif

/* DEZE MOET AANGEPAST WORDEN, WANT SSCANF MET hhu OF hhd IS NIET BESCHIKBAAR */

/* from ocinternal.c */

static void
ocremovefile(const char* path)
{
#ifdef _MSC_VER
    DeleteFile(path);
#else
    remove(path);
#endif
}

/* GEEN PROBLEEM */