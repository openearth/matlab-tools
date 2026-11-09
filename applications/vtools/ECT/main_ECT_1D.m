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

%Check out SVN repository:
%https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/
%into a folder (e.g., <dir_checkout>).
%`fpath_add_oet` points to <dir_checkout\applications\vtools\general\addOET.m>
fpath_add_oet='c:\checkouts\oet_matlab\applications\vtools\general\addOET.m';
% fpath_add_oet='p:\studenten-riv\05_OpenEarthTools\01_matlab\applications\vtools\general\addOET.m';

if isunix %we assume that if Linux we are in the p-drive. 
    fpath_add_oet=strrep(strrep(strcat('/',strrep(fpath_add_oet,'P:','p:')),':',''),'\','/');
end
run(fpath_add_oet);

%Path to folder with project paths. See `paths_project_layout`.
fpath_project=pwd;

input_ECT_2D

[ECT_matrices,sed_trans]=call_ECT(ECT_input);

[c_anl,eig_i_morpho]=ECT_celerity_growth(ECT_matrices,'kwx',2*pi/100,'kwy',0);

fprintf('Celerity: %f\n', c_anl);