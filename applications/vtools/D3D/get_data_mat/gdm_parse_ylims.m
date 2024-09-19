%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%

function flg_loc=gdm_parse_ylims(fid_log,flg_loc,str_check)

%In case there is `flg_loc.ylims` and it is a cell, this is the one you want to use
str_no_var=strrep(str_check,'_var','');
if isfield(flg_loc,str_no_var) && iscell(flg_loc.(str_no_var))
    flg_loc.(str_check)=flg_loc.(str_no_var);
end

%If there is no `flg_loc.ylims_var`, create it. 
%If `flg_loc.ylims`, copy it to all variables. 
%If it does not exist, make is automatic.
nvar_tmp=numel(flg_loc.var);
if isfield(flg_loc,str_check)==0
    flg_loc.(str_check)=cell(nvar_tmp,1);
    for kvar=1:nvar_tmp
        if isfield(flg_loc,str_no_var) 
            flg_loc.(str_check){kvar,1}=flg_loc.(str_no_var);
        else
            %if we are in `ylims_diff_var`, `ylims_var` already exists and it is not empty.
            %We make the default of the former with the same size as the latter.
            if isfield(flg_loc,str_check) && ~isempty(flg_loc.(str_check){kvar})
                nylim=size(flg_loc.(str_check){kvar},1);
            else
                nylim=1;
            end
            flg_loc.(str_check){kvar,1}=NaN(nylim,2);
        end
    end
end

%If there is `flg_loc.ylims_var` but does not match the number of variables, all automatic.
if numel(flg_loc.(str_check))~=nvar_tmp
    messageOut(fid_log,sprintf('The number of variables (%d) is different than the number of limits (%d). Everything to automatic.',nvar_tmp,numel(flg_loc.(str_check))));
    for kvar=1:nvar_tmp
        flg_loc.(str_check){kvar,1}=[NaN,NaN];
    end
end

end %function