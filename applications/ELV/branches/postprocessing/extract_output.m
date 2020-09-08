%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%function_name does this and that


%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%170719
%   -V. Created for the first time.
%

function output_m=extract_output(path_fold_main,fig_input)

%% 
%% READ
%% 

%paths
path_file_input=fullfile(path_fold_main,'input.mat');
% path_file_output=fullfile(path_fold_main,'output.mat');

%input (input)
input=struct();
load(path_file_input); 

%output.mat or separate files
path_folder_TMP_output=fullfile(path_fold_main,'TMP_output');
path_file_output=fullfile(path_fold_main,'output.mat');
dir_temp_output=dir(path_folder_TMP_output);
nto=numel(dir_temp_output)-2;
if nto~=-2 %temporal folder exist
    fig_input.mdv.wh=2; 
else %temporal folder does not exist
    fig_input.mdv.wh=1; 
end

%variables to extract
if isfield(fig_input.mdv,'output_var')==1
    input.mdv.output_var=fig_input.mdv.output_var;
    input.mdv.output_var_bra=fig_input.mdv.output_var; %_bra needs to be added
    input.mdv.no=numel(input.mdv.output_var);
    for ko=1:input.mdv.no
        switch input.mdv.output_var{1,ko}
            case {'time_loop','celerities','time_l'} %history variable

            otherwise %map variable
                input.mdv.output_var_bra{1,ko}=strcat(input.mdv.output_var{1,ko},'_bra');
        end
    end    
else
%     output_var=input.mdv.output_var;
%     output_var_bra=input.mdv.output_var_bra;
    input.mdv.no=numel(input.mdv.output_var);
end

switch fig_input.mdv.wh %
    case 1
%         output_m=matfile(fullfile(path_fold_main,'output.mat')); %matfile io object creation
    case 2
        %load the empty results (output.mat should always exist if you do not run in debug mode, unless a simulation is unfinished!)
        
        %if output.mat and path_folder_TMP_output exists, it means that the simulation: 
        %(1) has not crashed and (2) it is not finished and (3) you are trying to see the resulsts for at least the second time. 
        %In this case, erase output.mat to preasllocate it again.
        if exist(path_file_output,'file')==2
            erase_file(path_file_output,NaN);
        end

        bring_output_single_2_ws
        input=get_nT(input,NaN);        
        output_creation(input,NaN)
        join_results(input,NaN);
end

output_m=matfile(fullfile(path_fold_main,'output.mat')); %matfile io object creation

end




