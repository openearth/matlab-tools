#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.
# $Revision: 2949 $

AC_PREREQ(2.59)
AC_INIT(bedcomposition_module, [v1], [bas.hoonhout@deltares.nl])

AC_CONFIG_SRCDIR([src])
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_HEADERS([config.h])

AC_ENABLE_SHARED
AC_DISABLE_STATIC
#AC_PROG_LIBTOOL(libtool)
LT_INIT

AM_INIT_AUTOMAKE

# prefer compilers we tested
AC_PROG_FC([gfortran ifort ifc g95 xlf95 f95 fort  efc pgf95 lf95 ftn xlf90 f90 pgf90 pghpf epcf90 g77 xlf f77 frt pgf77 cf77 fort77 fl32 af77])
AC_FC_FREEFORM
AC_FC_LINE_LENGTH([unlimited])
AC_PROG_INSTALL
# Checks for libraries.

PKG_PROG_PKG_CONFIG

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.


AC_CONFIG_FILES([Makefile
                 src/Makefile])
AC_OUTPUT
