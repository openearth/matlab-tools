/* config.h.  Generated from config.h.in by configure.  */
/* config.h.in.  Generated from configure.ac by autoheader.  */

/* default chunk cache nelems. */
#define CHUNK_CACHE_NELEMS 1000

/* default chunk cache preemption policy. */
#define CHUNK_CACHE_PREEMPTION 0.75

/* default chunk cache size in bytes. */
#define CHUNK_CACHE_SIZE 32000000

/* Define to one of `_getb67', `GETB67', `getb67' for Cray-2 and Cray-YMP
   systems. This function is required for `alloca.c' support on those systems.
   */
/* #undef CRAY_STACKSEG_END */

/* Define to 1 if using `alloca.c'. */
/* #undef C_ALLOCA */

/* set this only when building a DLL under MinGW */
/* #undef DLL_NETCDF */

/* if true, run extra tests which may not work with HDF5 beta release */
/* #undef EXTRA_TESTS */

/* use HDF5 1.6 API */
/* #undef H5_USE_16_API */

/* Define to 1 if you have `alloca', as a function or macro. */
#define HAVE_ALLOCA 1

/* Define to 1 if you have <alloca.h> and it should be used (not on Ultrix).
   */
#define HAVE_ALLOCA_H 1

/* Define to 1 if you have the <ctype.h> header file. */
#define HAVE_CTYPE_H 1

/* Define to 1 if you have the declaration of `isfinite', and to 0 if you
   don't. */
#define HAVE_DECL_ISFINITE 1

/* Define to 1 if you have the declaration of `isinf', and to 0 if you don't.
   */
#define HAVE_DECL_ISINF 1

/* Define to 1 if you have the declaration of `isnan', and to 0 if you don't.
   */
#define HAVE_DECL_ISNAN 1

/* Define to 1 if you have the declaration of `signbit', and to 0 if you
   don't. */
#define HAVE_DECL_SIGNBIT 1

/* Define to 1 if you have the <dirent.h> header file, and it defines `DIR'.
   */
#define HAVE_DIRENT_H 1

/* Define to 1 if you have the <dlfcn.h> header file. */
#define HAVE_DLFCN_H 1

/* Define to 1 if you don't have `vprintf' but do have `_doprnt.' */
/* #undef HAVE_DOPRNT */

/* Define to 1 if you have the <errno.h> header file. */
#define HAVE_ERRNO_H 1

/* Define to 1 if you have the <fcntl.h> header file. */
#define HAVE_FCNTL_H 1

/* Define to 1 if you have the <hdf5.h> header file. */
/* #undef HAVE_HDF5_H */

/* Define to 1 if you have the <inttypes.h> header file. */
#define HAVE_INTTYPES_H 1

/* Define to 1 if you have the `hdf5' library (-lhdf5). */
/* #undef HAVE_LIBHDF5 */

/* Define to 1 if you have the `hdf5_hl' library (-lhdf5_hl). */
/* #undef HAVE_LIBHDF5_HL */

/* Define to 1 if you have the <locale.h> header file. */
#define HAVE_LOCALE_H 1

/* Define to 1 if the system has the type `long long int'. */
/* #undef HAVE_LONG_LONG_INT */

/* Define to 1 if you have the <malloc.h> header file. */
#define HAVE_MALLOC_H 1

/* Define to 1 if you have the <memory.h> header file. */
#define HAVE_MEMORY_H 1

/* Define to 1 if you have the `mktemp' function. */
#define HAVE_MKTEMP 1

/* Define to 1 if you have the <ndir.h> header file, and it defines `DIR'. */
/* #undef HAVE_NDIR_H */

/* Define to 1 if the system has the type `ptrdiff_t'. */
#define HAVE_PTRDIFF_T 1

/* Define to 1 if you have the `snprintf' function. */
#define HAVE_SNPRINTF 1

/* Define to 1 if the system has the type `ssize_t'. */
#define HAVE_SSIZE_T 1

/* Define to 1 if you have the <stdarg.h> header file. */
#define HAVE_STDARG_H 1

/* Define to 1 if stdbool.h conforms to C99. */
#define HAVE_STDBOOL_H 1

/* Define to 1 if you have the <stdint.h> header file. */
#define HAVE_STDINT_H 1

/* Define to 1 if you have the <stdio.h> header file. */
#define HAVE_STDIO_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#define HAVE_STDLIB_H 1

/* Define to 1 if you have the `strcat' function. */
#define HAVE_STRCAT 1

/* Define to 1 if you have the `strchr' function. */
#define HAVE_STRCHR 1

/* Define to 1 if you have the `strcpy' function. */
#define HAVE_STRCPY 1

/* Define to 1 if you have the `strerror' function. */
#define HAVE_STRERROR 1

/* Define to 1 if you have the <strings.h> header file. */
#define HAVE_STRINGS_H 1

/* Define to 1 if you have the <string.h> header file. */
#define HAVE_STRING_H 1

/* Define to 1 if you have the `strlcat' function. */
#define HAVE_STRLCAT 1

/* Define to 1 if you have the `strrchr' function. */
#define HAVE_STRRCHR 1

/* Define to 1 if `st_blksize' is member of `struct stat'. */
#define HAVE_STRUCT_STAT_ST_BLKSIZE 1

/* Define to 1 if your `struct stat' has `st_blksize'. Deprecated, use
   `HAVE_STRUCT_STAT_ST_BLKSIZE' instead. */
#define HAVE_ST_BLKSIZE 1

/* Define to 1 if you have the <sys/dir.h> header file, and it defines `DIR'.
   */
/* #undef HAVE_SYS_DIR_H */

/* Define to 1 if you have the <sys/ndir.h> header file, and it defines `DIR'.
   */
/* #undef HAVE_SYS_NDIR_H */

/* Define to 1 if you have the <sys/stat.h> header file. */
#define HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/types.h> header file. */
#define HAVE_SYS_TYPES_H 1

/* Define to 1 if you have <sys/wait.h> that is POSIX.1 compatible. */
#define HAVE_SYS_WAIT_H 1

/* Define to 1 if the system has the type `uchar'. */
/* #undef HAVE_UCHAR */

/* Define to 1 if you have the <unistd.h> header file. */
#define HAVE_UNISTD_H 1

/* Define to 1 if the system has the type `unsigned long long int'. */
/* #undef HAVE_UNSIGNED_LONG_LONG_INT */

/* Define to 1 if you have the `vprintf' function. */
#define HAVE_VPRINTF 1

/* Define to 1 if the system has the type `_Bool'. */
#define HAVE__BOOL 1

/* if true, use HDF5 data conversions */
/* #undef HDF5_CONVERT */

/* do large file tests */
/* #undef LARGE_FILE_TESTS */

/* if true, turn on netCDF-4 logging */
/* #undef LOGGING */

/* Define to the sub-directory in which libtool stores uninstalled libraries.
   */
#define LT_OBJDIR ".libs/"

/* type definition */
#define NCBYTE_T byte

/* min blocksize for posixio. */
#define NCIO_MINBLOCKSIZE 256

/* type definition */
#define NCSHORT_T integer*2

/* default */
#define NF_DOUBLEPRECISION_IS_C_DOUBLE 1

/* default */
#define NF_INT1_IS_C_SIGNED_CHAR 1

/* type thing */
#define NF_INT1_T byte

/* default */
#define NF_INT2_IS_C_SHORT 1

/* type thing */
#define NF_INT2_T integer*2

/* default */
#define NF_INT_IS_C_INT 1

/* default */
#define NF_REAL_IS_C_FLOAT 1

/* no IEEE float on this platform */
/* #undef NO_IEEE_FLOAT */

/* Define to 1 if your C compiler doesn't accept -c and -o together. */
/* #undef NO_MINUS_C_MINUS_O */

/* do not build the netCDF version 2 API */
/* #undef NO_NETCDF_2 */

/* no stdlib.h */
/* #undef NO_STDLIB_H */

/* no sys_types.h */
/* #undef NO_SYS_TYPES_H */

/* Name of package */
#define PACKAGE "netcdf"

/* Define to the address where bug reports for this package should be sent. */
#define PACKAGE_BUGREPORT "support@unidata.ucar.edu"

/* Define to the full name of this package. */
#define PACKAGE_NAME "netCDF"

/* Define to the full name and version of this package. */
#define PACKAGE_STRING "netCDF 4.0.1"

/* Define to the one symbol short name of this package. */
#define PACKAGE_TARNAME "netcdf"

/* Define to the version of this package. */
#define PACKAGE_VERSION "4.0.1"

/* The size of `double', as computed by sizeof. */
#define SIZEOF_DOUBLE 8

/* The size of `float', as computed by sizeof. */
#define SIZEOF_FLOAT 4

/* The size of `int', as computed by sizeof. */
#define SIZEOF_INT 4

/* The size of `long', as computed by sizeof. */
#define SIZEOF_LONG 4

/* The size of `off_t', as computed by sizeof. */
#define SIZEOF_OFF_T 8

/* The size of `short', as computed by sizeof. */
#define SIZEOF_SHORT 2

/* The size of `size_t', as computed by sizeof. */
#define SIZEOF_SIZE_T 4

/* If using the C implementation of alloca, define if you know the
   direction of stack growth for your system; otherwise it will be
   automatically deduced at runtime.
	STACK_DIRECTION > 0 => grows toward higher addresses
	STACK_DIRECTION < 0 => grows toward lower addresses
	STACK_DIRECTION = 0 => direction of growth unknown */
/* #undef STACK_DIRECTION */

/* Define to 1 if you have the ANSI C header files. */
#define STDC_HEADERS 1

/* Place to put very large netCDF test files. */
#define TEMP_LARGE "."

/* Define to 1 if you can safely include both <sys/time.h> and <time.h>. */
#define TIME_WITH_SYS_TIME 1

/* if true, build DAP Client */
/* #undef USE_DAP */

/* Experimental; please do not set */
#define USE_DAP4 1

/* set this to use extreme numbers in tests */
#define USE_EXTREME_NUMBERS 1

/* if true, build netCDF-4 */
/* #undef USE_NETCDF4 */

/* if true, parallel netCDF-4 is in use */
/* #undef USE_PARALLEL */

/* if true, compile in parallel netCDF-4 based on MPI/IO */
/* #undef USE_PARALLEL_MPIO */

/* if true, compile in parallel netCDF-4 based on MPI/POSIX */
/* #undef USE_PARALLEL_POSIX */

/* if true, build libsrc code with renamed API functions */
/* #undef USE_RENAMEV3 */

/* if true, compile in zlib compression in netCDF-4 variables */
/* #undef USE_ZLIB */

/* Version number of package */
#define VERSION "4.0.1"

/* Define WORDS_BIGENDIAN to 1 if your processor stores words with the most
   significant byte first (like Motorola and SPARC, unlike Intel and VAX). */
#if defined __BIG_ENDIAN__
# define WORDS_BIGENDIAN 1
#elif ! defined __LITTLE_ENDIAN__
/* # undef WORDS_BIGENDIAN */
#endif

/* Number of bits in a file offset, on hosts where this is settable. */
/* #undef _FILE_OFFSET_BITS */

/* Needed by HPUX with c89 compiler. */
/* #undef _HPUX_SOURCE */

/* Define for large files, on AIX-style hosts. */
/* #undef _LARGE_FILES */

/* Define to 1 if type `char' is unsigned and you are not using gcc.  */
#ifndef __CHAR_UNSIGNED__
/* # undef __CHAR_UNSIGNED__ */
#endif

/* Define to empty if `const' does not conform to ANSI C. */
/* #undef const */

/* Turned on by netCDF configure. */
/* #undef f2cFortran */

/* Turned on by netCDF configure. */
/* #undef gFortran */

/* Define to `long int' if <sys/types.h> does not define. */
/* #undef off_t */

/* Turned on by netCDF configure. */
#define pgiFortran 1

/* Define to `unsigned int' if <sys/types.h> does not define. */
/* #undef size_t */
