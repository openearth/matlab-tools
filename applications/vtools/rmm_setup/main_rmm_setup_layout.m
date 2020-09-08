%This script updates the boundary conditions of the SOBEK 3 RMM model
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%200601
%
%add paths to OET tools:
%   https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab
%   run(setproperty)
%add paths to RIV tools:
%   https://repos.deltares.nl/repos/RIVmodels/rivtools/trunk/matlab
%   run(rivsettings)


%% PREAMBLE

fclose all;
clear
clc

%% INPUT

simdef.paths.bcmat='c:\Users\chavarri\temporal\200531_bc_rmm\data\rvw.mat'; %path to the matlab file containing the new boundary conditions (from RWS)
simdef.paths.loclabels='input_labels.m'; %path to the m-file containing the conversion names between data and SOBEK 3

simdef.paths.dimr_in='c:\Users\chavarri\temporal\200531_bc_rmm\models\DIMR\DIMR.xml'; %path to the dimr file defining the SOBEK 3 model 
simdef.paths.s3_out='c:\Users\chavarri\temporal\200531_bc_rmm\models_out\DIMR'; %path to the folder where to save the new SOBEK 3 model (it is created if it does not exist)

simdef.paths.sre_in='c:\Users\chavarri\temporal\200531_bc_rmm\models\16'; 
simdef.paths.sre_out='c:\Users\chavarri\temporal\200531_bc_rmm\models_out\16';

simdef.start_time=datetime(2019,01,07,01,59,00); %year,day,month,hour,minute,second
simdef.stop_time=datetime(2019,02,03,15,24,00); %year,day,month,hour,minute,second

%% CALC

update_boundary_conditions_rmm_s3(simdef)
update_boundary_conditions_rmm_sre(simdef)

