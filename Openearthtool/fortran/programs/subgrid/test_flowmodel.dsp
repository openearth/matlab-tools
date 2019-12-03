# Microsoft Developer Studio Project File - Name="test_flowmodel" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=test_flowmodel - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "test_flowmodel.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "test_flowmodel.mak" CFG="test_flowmodel - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "test_flowmodel - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "test_flowmodel - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
F90=df.exe
RSC=rc.exe

!IF  "$(CFG)" == "test_flowmodel - Win32 Release"

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
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib /nologo /subsystem:console /machine:I386

!ELSEIF  "$(CFG)" == "test_flowmodel - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
# ADD BASE F90 /check:bounds /compile_only /dbglibs /debug:full /nologo /traceback /warn:argument_checking /warn:nofileopt
# ADD F90 /check:bounds /compile_only /dbglibs /debug:full /nologo /traceback /warn:argument_checking /warn:nofileopt
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /GZ /c
# ADD CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /GZ /c
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept

!ENDIF 

# Begin Target

# Name "test_flowmodel - Win32 Release"
# Name "test_flowmodel - Win32 Debug"
# Begin Group "matlab_libs"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Release\libmat.dll
# End Source File
# Begin Source File

SOURCE=.\Release\libmex.dll
# End Source File
# Begin Source File

SOURCE=.\Release\libmx.dll
# End Source File
# Begin Source File

SOURCE=.\Release\libut.dll
# End Source File
# Begin Source File

SOURCE=.\Release\libz.dll
# End Source File
# Begin Source File

SOURCE=.\Release\libmat.lib
# End Source File
# Begin Source File

SOURCE=.\Release\libmx.lib
# End Source File
# Begin Source File

SOURCE=.\Release\libut.lib
# End Source File
# End Group
# Begin Group "sr timestep flow"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\comp_hu_au.f90
DEP_F90_COMP_=\
	".\Release\dataspace.mod"\
	
# End Source File
# Begin Source File

SOURCE=.\curu.f90
DEP_F90_CURU_=\
	".\Release\dataspace.mod"\
	
# End Source File
# Begin Source File

SOURCE=.\s1uexpvimp.f90
DEP_F90_S1UEX=\
	".\Release\dataspace.mod"\
	
# End Source File
# Begin Source File

SOURCE=.\s1uimpvexp.f90
DEP_F90_S1UIM=\
	".\Release\dataspace.mod"\
	
# End Source File
# End Group
# Begin Group "sr inititalise"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\dataspace.f90
# End Source File
# Begin Source File

SOURCE=.\initialise.f90
DEP_F90_INITI=\
	".\Release\dataspace.mod"\
	
# End Source File
# Begin Source File

SOURCE=.\readgrid.f90
DEP_F90_READG=\
	".\Release\dataspace.mod"\
	
# End Source File
# End Group
# Begin Group "sr postprocess"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\hisout.f90
DEP_F90_HISOU=\
	".\Release\dataspace.mod"\
	
# End Source File
# End Group
# Begin Group "sr general"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\MATLAB_READWRITE.f90
# End Source File
# Begin Source File

SOURCE=.\SWEEP.FOR
# End Source File
# End Group
# Begin Group "mother"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\test_flowmodel.f90
DEP_F90_TEST_=\
	".\Release\dataspace.mod"\
	".\Release\matlab_io.mod"\
	
# End Source File
# Begin Source File

SOURCE=.\timestep.f90
DEP_F90_TIMES=\
	".\Release\dataspace.mod"\
	
# End Source File
# End Group
# End Target
# End Project
