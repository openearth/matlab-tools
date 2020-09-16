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
%write_results does this and that
%
%write_results(input,fid_log,kts)
%
%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%160223
%   -V. Created for the first time.

function write_results(input,fid_log,kts)

%bring ~_bra variables in (and time_loop)
for ko=1:input.mdv.no
    %call to the workspace of the function the variables that we want to save
    aux_varname=input.mdv.output_var_bra{1,ko}; %variable name to update in output.mat
    aux_var=evalin('caller',aux_varname); %variable value in the main function corresponding to the variable name
    feval(@()assignin('caller',aux_varname,aux_var)) %rename such that the variable name goes with its variable value
end

path_file_output_sng=fullfile(input.mdv.path_folder_TMP_output,sprintf('%06d.mat',kts));

%% all in one file direclty
if input.mdv.savemethod==1
    error('needs to be debugged')
output_mat=matfile(input.mdv.path_file_output,'writable',true); %matfile io object creation

for ko=1:input.mdv.no
    
    %call to the workspace of the function the variables that we want to save
    aux_varname=input.mdv.output_var{1,ko}; %variable name to update in output.mat
    aux_var=evalin('caller',aux_varname); %variable value in the main function corresponding to the variable name
    feval(@()assignin('caller',aux_varname,aux_var)) %rename such that the variable name goes with its variable value
    
    %update value
    nel=size(output_mat.(aux_varname)); %size of the variable in the .mat file
    if strcmp(aux_varname,'time_loop')
%         time_loop_tmp=eval(aux_varname);
        output_mat.(aux_varname)((kts-2)*input.mdv.Flmap_dt/input.mdv.dt+1:(kts-1)*input.mdv.Flmap_dt/input.mdv.dt,1)=time_loop;
    else
        output_mat.(aux_varname)(1:nel(1),1:nel(2),1:nel(3),kts)=eval(aux_varname); %add the value of the current time
    end
    
    %if problems with dimensions check this:
%     eval(sprintf('%s(%i,%i)',aux_varname,1,2)); %add the value of the current time
    
end

%% separate files
else %input.mdv.savemethod~=1

if input.mdv.nb==1 %one branch
    %get arrays from cells
    for ko=1:input.mdv.no
        switch input.mdv.output_var_bra{1,ko}
            case {'time_loop','celerities','time_l'}
                %the name of this variables does not have '_bra', so it does not need to be changed
            otherwise
                feval(@()evalin('caller',sprintf('%s=%s{1,1};',input.mdv.output_var{1,ko},input.mdv.output_var_bra{1,ko})))
        end
    end %ko
    save(path_file_output_sng,input.mdv.output_var{1,:},'-v6') %v6 is faster than v7.3
else %input.mdv.nb~=1
    save(path_file_output_sng,input.mdv.output_var_bra{1,:},'-v6') %v6 is faster than v7.3
end %input.mdv.nb

end %input.mdv.savemethod
