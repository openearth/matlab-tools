# Microsoft Developer Studio Project File - Name="test" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=test - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "waterbed.mak".
!MESSAGE 
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

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
F90=df.exe
RSC=rc.exe

!IF  "$(CFG)" == "test - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
# ADD BASE F90 /compile_only /nologo /warn:nofileopt
# ADD F90 /compile_only /nologo /warn:nofileopt
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD BASE RSC /l 0x413 /d "NDEBUG"
# ADD RSC /l 0x413 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib /nologo /subsystem:console /machine:I386

!ELSEIF  "$(CFG)" == "test - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE F90 /check:bounds /compile_only /dbglibs /debug:full /nologo /traceback /warn:argument_checking /warn:nofileopt
# ADD F90 /check:bounds /compile_only /dbglibs /debug:full /free /nologo /traceback /warn:argument_checking /warn:nofileopt
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /GZ /c
# ADD CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /GZ /c
# ADD BASE RSC /l 0x413 /d "_DEBUG"
# ADD RSC /l 0x413 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib /nologo /subsystem:console /incremental:no /debug /machine:I386 /pdbtype:sept

!ENDIF 

# Begin Target

# Name "test - Win32 Release"
# Name "test - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat;f90;for;f;fpp"
# Begin Source File

SOURCE=..\source\bed.f90
DEP_F90_BED_F=\
	".\Debug\MATLAB_IO.MOD"\
	".\Debug\parameters_sed_mod.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\source\flow.f90
DEP_F90_FLOW_=\
	".\Debug\MATLAB_IO.MOD"\
	".\Debug\NAMELIST.MOD"\
	
# End Source File
# Begin Source File

SOURCE=..\source\fluxes.f90
DEP_F90_FLUXE=\
	".\Debug\parameters_sed_mod.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\source\main.f90
DEP_F90_MAIN_=\
	".\Debug\BED_MOD.MOD"\
	".\Debug\FLOW_MOD.mod"\
	".\Debug\NAMELIST.MOD"\
	".\Debug\parameters_sed_mod.mod"\
	".\Debug\plug_mod.mod"\
	".\Debug\POST_PROCESS_MOD.MOD"\
	".\Debug\TRANSPORT_MOD.MOD"\
	".\Debug\waterbed_fluxes_mod.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\source\MATLAB_READWRITE.f90
# End Source File
# Begin Source File

SOURCE=..\source\namelist.f90
# End Source File
# Begin Source File

SOURCE=..\source\plug.f90
DEP_F90_PLUG_=\
	".\Debug\NAMELIST.MOD"\
	".\Debug\parameters_sed_mod.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\source\post_process.f90
DEP_F90_POST_=\
	".\Debug\MATLAB_IO.MOD"\
	".\Debug\parameters_sed_mod.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\source\set_parameters_sed.f90
# End Source File
# Begin Source File

SOURCE=..\source\transport.f90
DEP_F90_TRANS=\
	".\Debug\FLOW_MOD.mod"\
	".\Debug\MATLAB_IO.MOD"\
	".\Debug\parameters_sed_mod.mod"\
	
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl;fi;fd"
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# Begin Source File

SOURCE=.\Debug\libmat.dll
# End Source File
# Begin Source File

SOURCE=.\Debug\libmex.dll
# End Source File
# Begin Source File

SOURCE=.\Debug\libmx.dll
# End Source File
# Begin Source File

SOURCE=.\Debug\libut.dll
# End Source File
# Begin Source File

SOURCE=.\Debug\libut.lib
# End Source File
# Begin Source File

SOURCE=.\Debug\libmat.lib
# End Source File
# Begin Source File

SOURCE=.\Debug\libmx.lib
# End Source File
# End Group
# End Target
# End Project
