%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Description

%% PREAMBLE

% dbclear all;
clear
clc
fclose all;

%% PATHS

fpath_add_oet='c:\checkouts\oet_matlab\applications\vtools\general\addOET.m';
fdir_d3d='c:\checkouts\qp\';

% fpath_project='c:\02_projects\231005_redolfi';
fpath_project='p:\dflowfm\users\chavarri\231005_redolfi\';

%% ADD OET

if isunix %we assume that if Linux we are in the p-drive. 
    fpath_add_oet=strrep(strrep(strcat('/',strrep(fpath_add_oet,'P:','p:')),':',''),'\','/');
end
run(fpath_add_oet);

%% PATHS

fpaths=paths_project(fpath_project);

%% INPUT

simdef.runid.name='r001';
simdef.D3D.dire_sim=fullfile(fpaths.fdir_sim_runs,simdef.runid.name);

%% CALC

simdef=input_D3D_01(simdef);
simdef=D3D_create_simulation(simdef);