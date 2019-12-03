# Microsoft Developer Studio Project File - Name="swanmud" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=swanmud - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "swanmud.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "swanmud.mak" CFG="swanmud - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "swanmud - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "swanmud - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
F90=df.exe
RSC=rc.exe

!IF  "$(CFG)" == "swanmud - Win32 Release"

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
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib IMSL.LIB IMSLS_ERR.LIB IMSLMPISTUB.LIB /nologo /subsystem:console /machine:I386

!ELSEIF  "$(CFG)" == "swanmud - Win32 Debug"

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
# ADD BASE RSC /l 0x413 /d "_DEBUG"
# ADD RSC /l 0x413 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept
# ADD LINK32 user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib IMSL.LIB IMSLS_ERR.LIB IMSLMPISTUB.LIB /nologo /subsystem:console /incremental:no /debug /machine:I386 /pdbtype:sept

!ENDIF 

# Begin Target

# Name "swanmud - Win32 Release"
# Name "swanmud - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat;f90;for;f;fpp"
# Begin Source File

SOURCE=..\Progsrc\addlmean.for
NODEP_F90_ADDLM=\
	".\Release\SWCOMM3.mod"\
	
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\AuxHyperbolics.f90"
# End Source File
# Begin Source File

SOURCE=..\Progsrc\backupm.for
NODEP_F90_BACKU=\
	".\Release\M_PARALL.mod"\
	".\Release\OCPCOMM1.MOD"\
	".\Release\OCPCOMM2.mod"\
	".\Release\OCPCOMM3.MOD"\
	".\Release\OCPCOMM4.mod"\
	".\Release\SWCOMM1.mod"\
	".\Release\SWCOMM2.mod"\
	".\Release\SWCOMM3.mod"\
	".\Release\SWCOMM4.mod"\
	
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\Dispersion_Relations.f90"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\DVARDELFT.f90"
# End Source File
# Begin Source File

SOURCE="..\Progsrc\files DELFT\EnDissTerms.f90"
# End Source File
# Begin Source File

SOURCE=..\Progsrc\ocpcre.for
NODEP_F90_OCPCR=\
	".\Release\OCPCOMM1.MOD"\
	".\Release\OCPCOMM2.mod"\
	".\Release\OCPCOMM3.MOD"\
	".\Release\OCPCOMM4.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\Progsrc\ocpids.for
NODEP_F90_OCPID=\
	".\Release\M_PARALL.mod"\
	".\Release\OCPCOMM1.MOD"\
	".\Release\OCPCOMM2.mod"\
	".\Release\OCPCOMM3.MOD"\
	".\Release\OCPCOMM4.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\Progsrc\ocpmix.for
NODEP_F90_OCPMI=\
	".\Release\M_PARALL.mod"\
	".\Release\OCPCOMM1.MOD"\
	".\Release\OCPCOMM2.mod"\
	".\Release\OCPCOMM3.MOD"\
	".\Release\OCPCOMM4.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\Progsrc\restorem.for
NODEP_F90_RESTO=\
	".\Release\M_PARALL.mod"\
	".\Release\OCPCOMM1.MOD"\
	".\Release\OCPCOMM2.mod"\
	".\Release\OCPCOMM3.MOD"\
	".\Release\OCPCOMM4.mod"\
	".\Release\SWCOMM1.mod"\
	".\Release\SWCOMM2.mod"\
	".\Release\SWCOMM3.mod"\
	".\Release\SWCOMM4.mod"\
	".\Release\TIMECOMM.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\Progsrc\swancom1.for
NODEP_F90_SWANC=\
	".\Release\m_constants.mod"\
	".\Release\m_fileio.mod"\
	".\Release\M_GENARR.MOD"\
	".\Release\M_PARALL.mod"\
	".\Release\M_SNL4.MOD"\
	".\Release\M_WCAP.MOD"\
	".\Release\m_xnldata.mod"\
	".\Release\OCPCOMM1.MOD"\
	".\Release\OCPCOMM2.mod"\
	".\Release\OCPCOMM3.MOD"\
	".\Release\OCPCOMM4.mod"\
	".\Release\SWCOMM1.mod"\
	".\Release\SWCOMM2.mod"\
	".\Release\SWCOMM3.mod"\
	".\Release\SWCOMM4.mod"\
	".\Release\TIMECOMM.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\Progsrc\swancom2.for
NODEP_F90_SWANCO=\
	".\Release\M_WCAP.MOD"\
	".\Release\OCPCOMM4.mod"\
	".\Release\SWCOMM1.mod"\
	".\Release\SWCOMM2.mod"\
	".\Release\SWCOMM3.mod"\
	".\Release\SWCOMM4.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\Progsrc\swancom3.for
NODEP_F90_SWANCOM=\
	".\Release\OCPCOMM1.MOD"\
	".\Release\OCPCOMM2.mod"\
	".\Release\OCPCOMM3.MOD"\
	".\Release\OCPCOMM4.mod"\
	".\Release\SWCOMM1.mod"\
	".\Release\SWCOMM2.mod"\
	".\Release\SWCOMM3.mod"\
	".\Release\SWCOMM4.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\Progsrc\swancom4.for
NODEP_F90_SWANCOM4=\
	".\Release\M_PARALL.mod"\
	".\Release\M_SNL4.MOD"\
	".\Release\m_xnldata.mod"\
	".\Release\OCPCOMM4.mod"\
	".\Release\serv_xnl4v5.mod"\
	".\Release\SWCOMM3.mod"\
	".\Release\SWCOMM4.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\Progsrc\swancom5.for
NODEP_F90_SWANCOM5=\
	".\Release\M_DIFFR.mod"\
	".\Release\M_PARALL.mod"\
	".\Release\OCPCOMM4.mod"\
	".\Release\SWCOMM1.mod"\
	".\Release\SWCOMM2.mod"\
	".\Release\SWCOMM3.mod"\
	".\Release\SWCOMM4.mod"\
	".\Release\TIMECOMM.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\Progsrc\swanmain.for
NODEP_F90_SWANM=\
	".\Release\M_BNDSPEC.MOD"\
	".\Release\M_DIFFR.mod"\
	".\Release\M_GENARR.MOD"\
	".\Release\M_PARALL.mod"\
	".\Release\M_SNL4.MOD"\
	".\Release\M_WCAP.MOD"\
	".\Release\OCPCOMM1.MOD"\
	".\Release\OCPCOMM2.mod"\
	".\Release\OCPCOMM3.MOD"\
	".\Release\OCPCOMM4.mod"\
	".\Release\OUTP_DATA.MOD"\
	".\Release\SWCOMM1.mod"\
	".\Release\SWCOMM2.mod"\
	".\Release\SWCOMM3.mod"\
	".\Release\SWCOMM4.mod"\
	".\Release\TIMECOMM.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\Progsrc\swanout1.for
NODEP_F90_SWANO=\
	".\Release\M_DIFFR.mod"\
	".\Release\M_PARALL.mod"\
	".\Release\OCPCOMM3.MOD"\
	".\Release\OCPCOMM4.mod"\
	".\Release\OUTP_DATA.MOD"\
	".\Release\SWCOMM1.mod"\
	".\Release\SWCOMM2.mod"\
	".\Release\SWCOMM3.mod"\
	".\Release\SWCOMM4.mod"\
	".\Release\TIMECOMM.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\Progsrc\swanout2.for
NODEP_F90_SWANOU=\
	".\Release\M_PARALL.mod"\
	".\Release\OCPCOMM2.mod"\
	".\Release\OCPCOMM4.mod"\
	".\Release\OUTP_DATA.MOD"\
	".\Release\SWCOMM1.mod"\
	".\Release\SWCOMM2.mod"\
	".\Release\SWCOMM3.mod"\
	".\Release\SWCOMM4.mod"\
	".\Release\TIMECOMM.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\Progsrc\swanparll.for
NODEP_F90_SWANP=\
	".\Release\M_GENARR.MOD"\
	".\Release\M_PARALL.mod"\
	".\Release\OCPCOMM4.mod"\
	".\Release\OUTP_DATA.MOD"\
	".\Release\SWCOMM1.mod"\
	".\Release\SWCOMM2.mod"\
	".\Release\SWCOMM3.mod"\
	".\Release\SWCOMM4.mod"\
	".\Release\TIMECOMM.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\Progsrc\swanpre1.for
NODEP_F90_SWANPR=\
	".\Release\M_GENARR.MOD"\
	".\Release\M_OBSTA.MOD"\
	".\Release\M_PARALL.mod"\
	".\Release\M_SNL4.MOD"\
	".\Release\M_WCAP.MOD"\
	".\Release\OCPCOMM1.MOD"\
	".\Release\OCPCOMM2.mod"\
	".\Release\OCPCOMM3.MOD"\
	".\Release\OCPCOMM4.mod"\
	".\Release\OUTP_DATA.MOD"\
	".\Release\SWCOMM1.mod"\
	".\Release\SWCOMM2.mod"\
	".\Release\SWCOMM3.mod"\
	".\Release\SWCOMM4.mod"\
	".\Release\TIMECOMM.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\Progsrc\swanpre2.for
NODEP_F90_SWANPRE=\
	".\Release\M_BNDSPEC.MOD"\
	".\Release\M_PARALL.mod"\
	".\Release\OCPCOMM1.MOD"\
	".\Release\OCPCOMM2.mod"\
	".\Release\OCPCOMM3.MOD"\
	".\Release\OCPCOMM4.mod"\
	".\Release\OUTP_DATA.MOD"\
	".\Release\SWCOMM1.mod"\
	".\Release\SWCOMM2.mod"\
	".\Release\SWCOMM3.mod"\
	".\Release\SWCOMM4.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\Progsrc\swanser.for
NODEP_F90_SWANS=\
	".\Release\M_OBSTA.MOD"\
	".\Release\M_PARALL.mod"\
	".\Release\OCPCOMM1.MOD"\
	".\Release\OCPCOMM4.mod"\
	".\Release\OUTP_DATA.MOD"\
	".\Release\SWCOMM1.mod"\
	".\Release\SWCOMM2.mod"\
	".\Release\SWCOMM3.mod"\
	".\Release\SWCOMM4.mod"\
	".\Release\TIMECOMM.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\Progsrc\swmod1.for
# End Source File
# Begin Source File

SOURCE=..\Progsrc\swmod2.for
NODEP_F90_SWMOD=\
	".\Release\OCPCOMM2.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\Progsrc\swmod3.for
NODEP_F90_SWMOD3=\
	".\Release\M_PARALL.mod"\
	".\Release\SWCOMM3.mod"\
	
# End Source File
# Begin Source File

SOURCE=..\Progsrc\SWMUD.for
NODEP_F90_SWMUD=\
	".\Release\Dispersion_Relations.mod"\
	".\Release\EnDissTerms.mod"\
	".\Release\M_DIFFR.mod"\
	".\Release\M_PARALL.mod"\
	".\Release\OCPCOMM4.mod"\
	".\Release\SWCOMM1.mod"\
	".\Release\SWCOMM2.mod"\
	".\Release\SWCOMM3.mod"\
	".\Release\SWCOMM4.mod"\
	".\Release\TIMECOMM.mod"\
	
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
