# Microsoft Developer Studio Project File - Name="netcdf_unidata_only" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=netcdf_unidata_only - Win32 Release
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "netcdf_unidata_only.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "netcdf_unidata_only.mak" CFG="netcdf_unidata_only - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "netcdf_unidata_only - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE "netcdf_unidata_only - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
F90=df.exe
RSC=rc.exe

!IF  "$(CFG)" == "netcdf_unidata_only - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "netcdf_unidata_only___Win32_Release"
# PROP BASE Intermediate_Dir "netcdf_unidata_only___Win32_Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "netcdf_unidata_only___Win32_Release"
# PROP Intermediate_Dir "netcdf_unidata_only___Win32_Release"
# PROP Target_Dir ""
# ADD BASE F90 /compile_only /nologo /warn:nofileopt /fpp
# ADD F90 /compile_only /nologo /traceback /warn:nofileopt /assume:underscore /iface:nomixed_str_len_arg /names:lowercase /fpp /define:"DLL_NETCDF" /define:"USENETCDF"
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD BASE RSC /l 0x413 /d "NDEBUG"
# ADD RSC /l 0x413 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib netcdf.lib /nologo /subsystem:console /machine:I386 /libpath:"lib\win32\vs\pg"

# Begin Special Build Tool
OutDir=.\netcdf_unidata_only___Win32_Release
SOURCE="$(InputPath)"
PostBuild_Cmds=copy lib\win32\vs\pg\*.dll $(OutDir)	copy lib\win32\all\hdf5\dll\*.dll $(OutDir)	copy lib\win32\all\szip\dll\*.dll $(OutDir)
# End Special Build Tool

!ELSEIF  "$(CFG)" == "netcdf_unidata_only - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "netcdf_unidata_only___Win32_Debug"
# PROP BASE Intermediate_Dir "netcdf_unidata_only___Win32_Debug"
# PROP BASE Ignore_Export_Lib 0
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "netcdf_unidata_only___Win32_Debug"
# PROP Intermediate_Dir "netcdf_unidata_only___Win32_Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE F90 /browser /check:bounds /check:power /check:overflow /compile_only /dbglibs /debug:full /fltconsistency /fpconstant /fpe:0 /fpp /nologo /traceback /warn:argument_checking /warn:declarations /warn:nofileopt
# SUBTRACT BASE F90 /check:underflow
# ADD F90 /assume:underscore /browser /check:bounds /check:power /check:overflow /compile_only /dbglibs /debug:full /define:"DLL_NETCDF" /define:"USENETCDF" /fltconsistency /fpconstant /fpe:0 /fpp /iface:nomixed_str_len_arg /names:lowercase /nologo /traceback /warn:argument_checking /warn:declarations /warn:nofileopt
# SUBTRACT F90 /check:underflow
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /GZ /c
# ADD CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /GZ /c
# ADD BASE RSC /l 0x413 /d "_DEBUG"
# ADD RSC /l 0x413 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /stack:0x3d0900 /subsystem:console /debug /machine:I386 /pdbtype:sept
# SUBTRACT BASE LINK32 /pdb:none
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib netcdf.lib /nologo /stack:0x3d0900 /subsystem:console /debug /machine:I386 /pdbtype:sept /libpath:"lib\win32\vs\pg"
# SUBTRACT LINK32 /pdb:none

# Begin Special Build Tool
OutDir=.\netcdf_unidata_only___Win32_Debug
SOURCE="$(InputPath)"
PostBuild_Cmds=copy lib\win32\vs\pg\*.dll $(OutDir)	copy lib\win32\all\hdf5\dll\*.dll $(OutDir)	copy lib\win32\all\szip\dll\*.dll $(OutDir)
# End Special Build Tool

!ENDIF 

# Begin Target

# Name "netcdf_unidata_only - Win32 Release"
# Name "netcdf_unidata_only - Win32 Debug"
# Begin Group "netcdff90"

# PROP Default_Filter "f90"

# Begin Source File
SOURCE=.\lib\win32\netcdff90\typeSizes.f90
# End Source File

# Begin Source File
SOURCE=.\lib\win32\netcdff90\netcdf.f90
DEP_F90_NETCD=\
	".\lib\win32\netcdff90\netcdf_attributes.f90"\
	".\lib\win32\netcdff90\netcdf_constants.f90"\
	".\lib\win32\netcdff90\netcdf_dims.f90"\
	".\lib\win32\netcdff90\netcdf_expanded.f90"\
	".\lib\win32\netcdff90\netcdf_externals.f90"\
	".\lib\win32\netcdff90\netcdf_file.f90"\
	".\lib\win32\netcdff90\netcdf_overloads.f90"\
	".\lib\win32\netcdff90\netcdf_text_variables.f90"\
	".\lib\win32\netcdff90\netcdf_variables.f90"\
	".\lib\win32\netcdff90\netcdf_visibility.f90"\
	".\netcdf_unidata_only___Win32_Debug\typeSizes.mod"\
# End Source File

# Begin Source File
SOURCE=.\netcdf_unidata_only.f90
DEP_F90_NETCDF=\
	".\netcdf_unidata_only___Win32_Release\netcdf.mod"\
# End Source File

# End Group
# End Target
# End Project
