@echo off

rem %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rem %%%                 VTOOLS                 %%%
rem %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rem % 
rem %Victor Chavarrias (victor.chavarrias@deltares.nl)
rem %
rem %$Revision$
rem %$Date$
rem %$Author$
rem %$Id$
rem %$HeadURL$
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