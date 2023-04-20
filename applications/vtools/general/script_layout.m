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
fdir_d3d='c:\checkouts\delft3d\';

% fpath_project='d:\temporal\220517_improve_exner\';
fpath_project='p:\11209261-rivierkunde-2023-morerijn';

%% ADD OET

run(fpath_add_oet);

%% PATHS

fpaths=paths_project(fpath_project);

%% INPUT