%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 137 $
%$Date: 2017-07-20 09:50:06 +0200 (Thu, 20 Jul 2017) $
%$Author: V $
%$Id: run_spacemarching.m 137 2017-07-20 07:50:06Z V $
%$HeadURL: https://repos.deltares.nl/repos/ELV/branches/V0171/main/run_spacemarching.m $
%
%run_ELV is a function that creates the folders for the output, calls the main function and then the postprocessing functions
%
%run_spacemarching(path_file_input)
%
%INPUT:
%   -path_file_input = path to the file input.mat; [char];
%
%OUTPUT:
%   -
%
%HISTORY:
%170130
%   -L. First created;

function run_spacemarching(path_file_input)
version='1';

%% 
%% INITIALIZATION
%% 

%% LOG FILE CREATION

fid_log=log_file_creation_sp(path_file_input);
fprintf(fid_log,'run_spacemarching version: %s\n',version); %stamp run_ELV version in log

%%
%% MAIN FUNCTION
%%

ELV_sp(path_file_input,fid_log)


%log file
fprintf(fid_log,'%s %s\n',datestr(datetime('now')),'End of space marching algorithm');

%%
%% POSTPROCESSING
%%



%% LOG FILE

fprintf(fid_log,'%s %s\n',datestr(datetime('now')),'End of the postprocessing');
fclose(fid_log);

