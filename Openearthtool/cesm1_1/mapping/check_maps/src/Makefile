#===============================================================================
# $Id: Makefile 40622 2012-09-28 17:07:34Z mlevy@ucar.edu $
# $URL: https://svn-ccsm-models.cgd.ucar.edu/tools/mapping/trunk_tags/mapping_121113b/check_maps/src/Makefile $
# 
# This is the makefile for the RegridWeightGen application in ESMF
# Altered for use with CESM's gen_atm_ocn_maps.sh tool
#===============================================================================

################################################################################
### Finding and including esmf.mk ##############################################
### NOTE: On Bluefire, ESMFMKFILE=/contrib/esmf-5.2.0r-64-O/lib/esmf.mk ########

ifneq ($(origin ESMFMKFILE), environment)
$(error Environment variable ESMFMKFILE was not set.)
endif

include $(ESMFMKFILE)
TARGET = ESMF_RegridWeightGenCheck

# To compile with verbose output, run
# $ gmake VERBOSE=TRUE
#
# To get back to concise output, run
# $ gmake VERBOSE=FALSE
# or touch the source file prior to running gmake again
#
ifneq ($(strip $(VERBOSE)),)
  ifneq ($(VERBOSE),FALSE)
    # Technically any string other than VERBOSE=FALSE will compile verbose
    ESMF_F90COMPILECPPFLAGS += -WF,-DVERBOSE=1
  endif
  $(shell rm -f $(TARGET).o) 
endif  


################################################################################
### Target / Linking ###########################################################

../ESMF_RegridWeightGenCheck: $(TARGET).o
	$(ESMF_F90LINKER) $(ESMF_F90LINKOPTS) $(ESMF_F90LINKPATHS) \
  $(ESMF_F90LINKRPATHS) -o $@ $(TARGET).o $(ESMF_F90ESMFLINKLIBS)        

.PHONY: verbose clean
verbose:
	$(MAKE) VERBOSE=TRUE

clean:
	rm -f ../ESMF_RegridWeightGenCheck ../PET*.Log ../hostfile *.o

###############################################################################
### Compiler rules using ESMF_ variables supplied by esmf.mk ##################

.SUFFIXES: .F90 .o

.F90.o:
	$(ESMF_F90COMPILER) -c $(ESMF_F90COMPILEOPTS) $(ESMF_F90COMPILEPATHS) \
  $(ESMF_F90COMPILEFREECPP) $(ESMF_F90COMPILECPPFLAGS) $<

