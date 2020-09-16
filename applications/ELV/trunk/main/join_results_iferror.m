%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 221 $
%$Date: 2018-11-26 06:30:49 +0100 (Mon, 26 Nov 2018) $
%$Author: v.chavarriasborras@tudelft.nl $
%$Id: join_results_iferror.m 221 2018-11-26 05:30:49Z v.chavarriasborras@tudelft.nl $
%$HeadURL: https://repos.deltares.nl/repos/ELV/branches/V0171/main/join_results_iferror.m $
%
%joint_results_iferror jpint the temporary results in the output file in case there has been an error.
%
%\texttt{joint_results_iferror(path_file_input,fid_log)}
%
%INPUT:
%   -\texttt{path_file_input} = path to the input.mat file [-]; [(nf-1)x(nx) double]
%   -\texttt{fid_log} = identificator of the log file
%
%OUTPUT:
%   -
%
%HISTORY:
%170531
%   -V. Created for the first time.
%


function join_results_iferror(path_file_input,fid_log)

%%
%% RENAME
%%

input=NaN; %V is stupid and has just realised that 'input' is also a function in MatLab. GEFELICITEERD!
load(path_file_input); %(input)

%%
%% CALL
%%

if isfield(input.mdv,'nx') 
%if there is wrong input an error is thrown before there are any results to be saved. This causes an error in join_results
%as if there is wrong input the variable 'input' is not saved, input.mdv.nx does not exist.
    
path_folder_TMP_output=input.mdv.path_folder_TMP_output;
bring_output_single_2_ws
input=get_nT(input,fid_log);    
output_creation(input,fid_log)
join_results(input,fid_log)
erase_directory(path_folder_TMP_output,fid_log)

end

end %function