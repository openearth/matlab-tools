%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 157 $
%$Date: 2017-07-27 17:53:42 +0200 (Thu, 27 Jul 2017) $
%$Author: V $
%$Id: run_ELV_debug.m 157 2017-07-27 15:53:42Z V $
%$HeadURL: https://repos.deltares.nl/repos/ELV/trunk/main/run_ELV_debug.m $
%
%run_ELV_debug is the same as run_ELV without the try-catch loop for errors
%
%run_ELV_debug(path_file_input)
%
%INPUT:
%   -path_file_input = path to the file input.mat; [char];
%
%OUTPUT:
%   -
%
%HISTORY:
%160223
%   -V. Created for the first time.
%
%170123
%   -L. Added a seperate highway to compute equilibrium;

function run_ELV_debug(path_file_input)

% try 
%% 
%% INITIALIZATION
%% 

%% LOG FILE CREATION

fid_log=log_file_creation(path_file_input);
ELV_version(fid_log)

%% FOLDERS CREATION

folders_creation(path_file_input,fid_log);

%%
%% MAIN FUNCTION
%%

ELV(path_file_input,fid_log)

%log file
fprintf(fid_log,'%s %s\n',datestr(datetime('now')),'End of ELV');
sendemail_from_path(path_file_input,'SIMULATION FINISHED',sprintf('nice!'),fid_log) %send email

%%
%% POSTPROCESSING
%%

%% LOG FILE

fprintf(fid_log,'%s %s\n',datestr(datetime('now')),'End of the postprocessing');
fclose(fid_log);

% catch error_obj
%     
%     errorprint(error_obj,fid_log)
%     join_results_iferror(path_file_input,fid_log)
%     sendemail_from_path(path_file_input,'ERROR in ELV run',sprintf('!! ERROR !! %s in file: %s, at line %d \n',error_obj.message,error_obj.stack(1).file,error_obj.stack(1).line),fid_log) %send email
%     fclose(fid_log);
%     profile off
%     error('I am afraid to say that the simulation has crashed...') %throw error to main
%     
% end
    
