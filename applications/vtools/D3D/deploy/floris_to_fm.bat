@echo off

rem %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rem %%%                 VTOOLS                 %%%
rem %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rem % 
rem %Victor Chavarrias (victor.chavarrias@deltares.nl)
rem %
rem %$Revision: 20320 $
rem %$Date: 2025-09-15 08:29:13 +0200 (Mon, 15 Sep 2025) $
rem %$Author: chavarri $
rem %$Id: floris_to_fm.m 20320 2025-09-15 06:29:13Z chavarri $
rem %$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/floris_to_fm/floris_to_fm.m $
rem %
rem %Convert Floris to Delft3D FM model. 

rem INPUT

set fpath_cfg=c:\projects\ag\models\r015\floris.cfg

rem CALL

@echo on

floris_to_fm %fpath_cfg%

@echo off
pause