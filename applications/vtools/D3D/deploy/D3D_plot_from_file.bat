@echo off

rem %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rem %%%                 VTOOLS                 %%%
rem %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rem % 
rem %Victor Chavarrias (victor.chavarrias@deltares.nl)
rem %
rem %$Revision: 17190 $
rem %$Date: 2021-04-15 10:24:15 +0200 (Thu, 15 Apr 2021) $
rem %$Author: chavarri $
rem %$Id: D3D_plot.m 17190 2021-04-15 08:24:15Z chavarri $
rem %$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_plot.m $
rem %
rem %Runs the plotting routine reading the input from a matlab script
rem %
rem %INPUT:
rem %   -path_input: path to the matlab script (char)

rem INPUT

set path_input_fig="c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\210409_webinar_1D\main_1D_plot_from_file.m"

rem CALL

@echo on

D3D_plot_from_file %path_input_fig%

@echo off
pause