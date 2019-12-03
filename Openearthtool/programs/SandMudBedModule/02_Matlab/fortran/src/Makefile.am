lib_LTLIBRARIES=libbedcomposition_module.la

libbedcomposition_module_la_SOURCES= \
	precision_basics.F90 \
	precision.F90 \
	message_module.f90 \
	string_module.f90 \
	bedcomposition_module.f90 \
	bdc_module.f90 \
	bedcomposition_interface.f90

include_HEADERS=bedcomposition_interface.macosx.h

AM_FCFLAGS=-I$(top_builddir)/include -fno-underscoring

CLEANFILES=*.mod *.MOD
