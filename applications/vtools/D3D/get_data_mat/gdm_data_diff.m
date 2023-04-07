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

function [in_p,tag_ref]=gdm_data_diff(in_p,flg_loc,kdiff,kclim,data,data_ref,str_clims,str_clims_diff,var_str)

%% PARSE

if isfield(flg_loc,'clims_type')==0
    flg_loc.clims_type=1;
end

if isfield(flg_loc,str_clims)==0
    flg_loc.(str_clims)=[NaN,NaN];
    flg_loc.filter_lim.(str_clims)=[inf,-inf];
end

if isfield(flg_loc,str_clims_diff)==0
    flg_loc.(str_clims_diff)=[NaN,NaN];
    flg_loc.filter_lim.(str_clims_diff)=[inf,-inf];
end

%%
switch kdiff
    case 1
        in_p.val=data;
        switch flg_loc.clims_type
            case 1
                in_p.clims=flg_loc.(str_clims)(kclim,:);
            case 2
                tim_up=max(time_dnum(kt)-flg_loc.clims_type_var,0);
                in_p.clims=[0,tim_up];
        end
        tag_ref='val';
        in_p.is_diff=0;
        in_p.is_background=0;
        in_p.filter_lim=flg_loc.filter_lim.(str_clims);
    case 2
%         in_p.val=data-data_ref.data; %why is data in ref under <.data> ?
        in_p.val=data-data_ref; 
        in_p.clims=flg_loc.(str_clims_diff)(kclim,:);
        tag_ref='diff';
        switch var_str
            case 'clm2'
                in_p.is_diff=0;
                in_p.is_background=1;
            otherwise
                in_p.is_diff=1;
                in_p.is_background=0;
        end
        in_p.filter_lim=flg_loc.filter_lim.(str_clims_diff);
end

end %function