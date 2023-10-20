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

%In case there is <flg_loc.ylims> and it is a cell, this is the one you want to use
str_no_var=strrep(str_check,'_var','');
if isfield(flg_loc,str_no_var) && iscell(flg_loc.(str_no_var))
    flg_loc.(str_check)=flg_loc.(str_no_var);
end

nvar_tmp=numel(flg_loc.var);
if isfield(flg_loc,str_check)==0
    flg_loc.(str_check)=cell(nvar_tmp,1);
    for kvar=1:nvar_tmp
        if isfield(flg_loc,str_no_var) 
            flg_loc.(str_check){kvar,1}=flg_loc.(str_no_var);
        else
            flg_loc.(str_check){kvar,1}=[NaN,NaN];
        end
    end
end

if numel(flg_loc.(str_check))~=nvar_tmp
    messageOut(fid_log,sprintf('The number of variables (%d) is different than the number of limits (%d). Everything to automatic.',nvar_tmp,numel(flg_loc.(str_check))));
    for kvar=1:nvar_tmp
        flg_loc.(str_check){kvar,1}=[NaN,NaN];
    end
end

end %function