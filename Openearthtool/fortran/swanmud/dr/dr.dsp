# Microsoft Developer Studio Project File - Name="dr" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=dr - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "dr.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "dr.mak" CFG="dr - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "dr - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "dr - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
F90=df.exe
RSC=rc.exe

!IF  "$(CFG)" == "dr - Win32 Release"

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

!ELSEIF  "$(CFG)" == "dr - Win32 Debug"

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
# ADD LINK32 kernel32.lib IMSL.LIB IMSLS_ERR.LIB IMSLMPISTUB.LIB /nologo /subsystem:console /incremental:no /debug /machine:I386 /pdbtype:sept

!ENDIF 

# Begin Target

# Name "dr - Win32 Release"
# Name "dr - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat;f90;for;f;fpp"
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\c1iarg.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\c1tci.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\c1tic.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\Dispersion_Relations.f90"
# End Source File
# Begin Source File

SOURCE=..\Progsrc\TEST_PORTAL\Dispersion_Relations_shell.f90
NODEP_F90_DISPE=\
	".\Debug\Dispersion_Relations.mod"\
	
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\dmach.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\dzanly.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\e1init.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\e1inpl.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\e1mes.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\e1pop.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\e1prt.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\e1psh.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\e1sti.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\e1stl.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\e1ucs.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\e1usr.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\i1cstr.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\i1dx.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\i1erif.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\i1krl.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\i1kst.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\i1x.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\iachar.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\icase.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\imach.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\iwkin.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\m1ve.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\m1vech.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\n1rgb.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\n1rty.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\s1anum.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\umach.for"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\dzanly\zcopy.for"
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl;fi;fd"
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# End Target
# End Project
