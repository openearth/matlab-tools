# Microsoft Developer Studio Generated NMAKE File, Based on waterbed.dsp
!IF "$(CFG)" == ""
CFG=test - Win32 Debug
!MESSAGE No configuration specified. Defaulting to test - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "test - Win32 Release" && "$(CFG)" != "test - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "waterbed.mak" CFG="test - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "test - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "test - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

!IF  "$(CFG)" == "test - Win32 Release"

OUTDIR=.\Release
INTDIR=.\Release
# Begin Custom Macros
OutDir=.\Release
# End Custom Macros

ALL : "$(OUTDIR)\waterbed.exe"


CLEAN :
	-@erase "$(INTDIR)\bed.obj"
	-@erase "$(INTDIR)\BED_MOD.MOD"
	-@erase "$(INTDIR)\flow.obj"
	-@erase "$(INTDIR)\FLOW_MOD.MOD"
	-@erase "$(INTDIR)\fluxes.obj"
	-@erase "$(INTDIR)\FLUXES_MOD.MOD"
	-@erase "$(INTDIR)\main.obj"
	-@erase "$(INTDIR)\MATLAB_IO.mod"
	-@erase "$(INTDIR)\MATLAB_READWRITE.obj"
	-@erase "$(INTDIR)\NAMELIST.mod"
	-@erase "$(INTDIR)\namelist.obj"
	-@erase "$(INTDIR)\post_process.obj"
	-@erase "$(INTDIR)\POST_PROCESS_MOD.mod"
	-@erase "$(INTDIR)\transport.obj"
	-@erase "$(INTDIR)\TRANSPORT_MOD.mod"
	-@erase "$(OUTDIR)\waterbed.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

F90=df.exe
F90_PROJ=/compile_only /nologo /warn:nofileopt /module:"Release/" /object:"Release/" 
F90_OBJS=.\Release/

.SUFFIXES: .fpp

.for{$(F90_OBJS)}.obj:
   $(F90) $(F90_PROJ) $<  

.f{$(F90_OBJS)}.obj:
   $(F90) $(F90_PROJ) $<  

.f90{$(F90_OBJS)}.obj:
   $(F90) $(F90_PROJ) $<  

.fpp{$(F90_OBJS)}.obj:
   $(F90) $(F90_PROJ) $<  

CPP=cl.exe
CPP_PROJ=/nologo /ML /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /Fp"$(INTDIR)\waterbed.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

RSC=rc.exe
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\waterbed.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib /nologo /subsystem:console /incremental:no /pdb:"$(OUTDIR)\waterbed.pdb" /machine:I386 /out:"$(OUTDIR)\waterbed.exe" 
LINK32_OBJS= \
	".\Debug\libut.lib" \
	".\Debug\libmat.lib" \
	".\Debug\libmx.lib" \
	"$(INTDIR)\bed.obj" \
	"$(INTDIR)\flow.obj" \
	"$(INTDIR)\fluxes.obj" \
	"$(INTDIR)\main.obj" \
	"$(INTDIR)\MATLAB_READWRITE.obj" \
	"$(INTDIR)\namelist.obj" \
	"$(INTDIR)\post_process.obj" \
	"$(INTDIR)\transport.obj"

"$(OUTDIR)\waterbed.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "test - Win32 Debug"

OUTDIR=.\Debug
INTDIR=.\Debug
# Begin Custom Macros
OutDir=.\Debug
# End Custom Macros

ALL : "$(OUTDIR)\waterbed.exe"


CLEAN :
	-@erase "$(INTDIR)\bed.obj"
	-@erase "$(INTDIR)\BED_MOD.MOD"
	-@erase "$(INTDIR)\DF60.PDB"
	-@erase "$(INTDIR)\flow.obj"
	-@erase "$(INTDIR)\FLOW_MOD.mod"
	-@erase "$(INTDIR)\fluxes.obj"
	-@erase "$(INTDIR)\FLUXES_MOD.mod"
	-@erase "$(INTDIR)\main.obj"
	-@erase "$(INTDIR)\MATLAB_IO.MOD"
	-@erase "$(INTDIR)\MATLAB_READWRITE.obj"
	-@erase "$(INTDIR)\NAMELIST.MOD"
	-@erase "$(INTDIR)\namelist.obj"
	-@erase "$(INTDIR)\post_process.obj"
	-@erase "$(INTDIR)\POST_PROCESS_MOD.MOD"
	-@erase "$(INTDIR)\transport.obj"
	-@erase "$(INTDIR)\TRANSPORT_MOD.MOD"
	-@erase "$(OUTDIR)\waterbed.exe"
	-@erase "$(OUTDIR)\waterbed.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

F90=df.exe
F90_PROJ=/check:bounds /compile_only /dbglibs /debug:full /free /integer_size:32 /nologo /real_size:32 /traceback /warn:argument_checking /warn:nofileopt /module:"Debug/" /object:"Debug/" /pdbfile:"Debug/DF60.PDB" 
F90_OBJS=.\Debug/

.SUFFIXES: .fpp

.for{$(F90_OBJS)}.obj:
   $(F90) $(F90_PROJ) $<  

.f{$(F90_OBJS)}.obj:
   $(F90) $(F90_PROJ) $<  

.f90{$(F90_OBJS)}.obj:
   $(F90) $(F90_PROJ) $<  

.fpp{$(F90_OBJS)}.obj:
   $(F90) $(F90_PROJ) $<  

CPP=cl.exe
CPP_PROJ=/nologo /MLd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /Fp"$(INTDIR)\waterbed.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /GZ /c 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

RSC=rc.exe
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\waterbed.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib /nologo /subsystem:console /incremental:no /pdb:"$(OUTDIR)\waterbed.pdb" /debug /machine:I386 /out:"$(OUTDIR)\waterbed.exe" /pdbtype:sept 
LINK32_OBJS= \
	".\Debug\libut.lib" \
	".\Debug\libmat.lib" \
	".\Debug\libmx.lib" \
	"$(INTDIR)\bed.obj" \
	"$(INTDIR)\flow.obj" \
	"$(INTDIR)\fluxes.obj" \
	"$(INTDIR)\main.obj" \
	"$(INTDIR)\MATLAB_READWRITE.obj" \
	"$(INTDIR)\namelist.obj" \
	"$(INTDIR)\post_process.obj" \
	"$(INTDIR)\transport.obj"

"$(OUTDIR)\waterbed.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 


!IF "$(NO_EXTERNAL_DEPS)" != "1"
!IF EXISTS("waterbed.dep")
!INCLUDE "waterbed.dep"
!ELSE 
!MESSAGE Warning: cannot find "waterbed.dep"
!ENDIF 
!ENDIF 


!IF "$(CFG)" == "test - Win32 Release" || "$(CFG)" == "test - Win32 Debug"
SOURCE=..\source\bed.f90
F90_MODOUT=\
	"BED_MOD"


"$(INTDIR)\bed.obj"	"$(INTDIR)\BED_MOD.MOD" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\MATLAB_IO.mod" "$(INTDIR)\NAMELIST.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


SOURCE=..\source\flow.f90
F90_MODOUT=\
	"FLOW_MOD"


"$(INTDIR)\flow.obj"	"$(INTDIR)\FLOW_MOD.MOD" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\MATLAB_IO.mod" "$(INTDIR)\NAMELIST.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


SOURCE=..\source\fluxes.f90
F90_MODOUT=\
	"FLUXES_MOD"


"$(INTDIR)\fluxes.obj"	"$(INTDIR)\FLUXES_MOD.MOD" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\BED_MOD.MOD" "$(INTDIR)\NAMELIST.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


SOURCE=..\source\main.f90

"$(INTDIR)\main.obj" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\FLOW_MOD.MOD" "$(INTDIR)\FLUXES_MOD.MOD" "$(INTDIR)\BED_MOD.MOD" "$(INTDIR)\NAMELIST.mod" "$(INTDIR)\POST_PROCESS_MOD.mod" "$(INTDIR)\TRANSPORT_MOD.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


SOURCE=..\source\MATLAB_READWRITE.f90
F90_MODOUT=\
	"MATLAB_IO"


"$(INTDIR)\MATLAB_READWRITE.obj"	"$(INTDIR)\MATLAB_IO.mod" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


SOURCE=..\source\namelist.f90
F90_MODOUT=\
	"NAMELIST"


"$(INTDIR)\namelist.obj"	"$(INTDIR)\NAMELIST.mod" : $(SOURCE) "$(INTDIR)"
	$(F90) $(F90_PROJ) $(SOURCE)


SOURCE=..\source\post_process.f90
F90_MODOUT=\
	"POST_PROCESS_MOD"


"$(INTDIR)\post_process.obj"	"$(INTDIR)\POST_PROCESS_MOD.mod" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\NAMELIST.mod" "$(INTDIR)\BED_MOD.MOD" "$(INTDIR)\FLOW_MOD.MOD" "$(INTDIR)\MATLAB_IO.mod" "$(INTDIR)\TRANSPORT_MOD.mod"
	$(F90) $(F90_PROJ) $(SOURCE)


SOURCE=..\source\transport.f90
F90_MODOUT=\
	"TRANSPORT_MOD"


"$(INTDIR)\transport.obj"	"$(INTDIR)\TRANSPORT_MOD.mod" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\NAMELIST.mod" "$(INTDIR)\MATLAB_IO.mod" "$(INTDIR)\FLOW_MOD.MOD" "$(INTDIR)\FLUXES_MOD.MOD"
	$(F90) $(F90_PROJ) $(SOURCE)



!ENDIF 

