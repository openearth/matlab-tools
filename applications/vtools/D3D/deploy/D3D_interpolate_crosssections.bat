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
rem %Interpolates cross-sections at each computational node. 
rem %
rem %INPUT:
rem %   -path_mdu_ori: path to the mdu-file of the original (hydrodynamic) simulation; char
rem %   -path_sim_upd: path to the folder of the simulation to update the cross-section definitions and locations files; char

rem INPUT

set path_mdu_ori=c:\Users\chavarri\temporal\210409_webinar_1D\01_simulations\r005\dflowfm\FlowFM.mdu
set path_sim_upd=c:\Users\chavarri\temporal\210409_webinar_1D\01_simulations\r006\dflowfm\

rem CALL

@echo on

D3D_interpolate_crosssections %path_mdu_ori% %path_sim_upd%

@echo off
pause