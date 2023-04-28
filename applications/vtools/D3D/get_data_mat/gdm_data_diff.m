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

function [in_p,tag_ref]=gdm_data_diff(in_p,flg_loc,kdiff,kclim,data,data_ref,str_clims,str_clims_diff,var_str,varargin)

%%

if nargin>10
    data_0=varargin{1,1};
    data_ref_0=varargin{1,2};
    str_clims_diff_0=varargin{1,3};
    str_clims_perc=varargin{1,4};
else
    data_0=NaN;
    data_ref_0=NaN;
    str_clims_diff_0='dummy';
    str_clims_perc='dummy';
end

%% PARSE

if isfield(flg_loc,'clims_type')==0
    flg_loc.clims_type=1;
end

if isfield(flg_loc,str_clims)==0
    flg_loc.(str_clims)=[NaN,NaN];
end

if isfield(flg_loc,str_clims_diff)==0
    flg_loc.(str_clims_diff)=[NaN,NaN];
end

if isfield(flg_loc,str_clims_diff_0)==0
    flg_loc.(str_clims_diff_0)=[NaN,NaN];
end

if isfield(flg_loc,str_clims_perc)==0
    flg_loc.(str_clims_perc)=[NaN,NaN];
end

if isfield(flg_loc,'filter_lim')==0
    flg_loc.filter_lim.(str_clims_diff)=[inf,-inf];
    flg_loc.filter_lim.(str_clims)=[inf,-inf];
    flg_loc.filter_lim.(str_clims_diff_0)=[inf,-inf];
    flg_loc.filter_lim.(str_clims_perc)=[inf,-inf];
else
    if isfield(flg_loc.filter_lim,str_clims)==0
        flg_loc.filter_lim.(str_clims)=[inf,-inf];
    end
    if isfield(flg_loc.filter_lim,str_clims_diff)==0
        flg_loc.filter_lim.(str_clims_diff)=[inf,-inf];
    end
    if isfield(flg_loc.filter_lim,str_clims_diff_0)==0
        flg_loc.filter_lim.(str_clims_diff_0)=[inf,-inf];
    end
    if isfield(flg_loc.filter_lim,str_clims_perc)==0
        flg_loc.filter_lim.(str_clims_perc)=[inf,-inf];
    end
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
        in_p.is_percentage=0;
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
                in_p.is_percentage=0;
            otherwise
                in_p.is_diff=1;
                in_p.is_background=0;
                in_p.is_percentage=0;
        end
        in_p.filter_lim=flg_loc.filter_lim.(str_clims_diff);
    case 3
        bol_0=data_ref==0;
        val=(data-data_ref)./data_ref*100;
        val(bol_0)=NaN;
        in_p.val=val; 
        in_p.clims=flg_loc.(str_clims_perc)(kclim,:);
        tag_ref='perc';
        in_p.is_diff=0;
        in_p.is_background=0;
        in_p.is_percentage=1;
        in_p.filter_lim=flg_loc.filter_lim.(str_clims_perc);
    case 4
        bol_0=data_ref==0;
        val=(data-data_ref)-(data_0-data_ref_0);
        val(bol_0)=NaN;
        in_p.val=val; 
        in_p.clims=flg_loc.(str_clims_diff_0)(kclim,:);
        tag_ref='diff_0';
        in_p.is_diff=0;
        in_p.is_background=0;
        in_p.is_percentage=1;
        in_p.filter_lim=flg_loc.filter_lim.(str_clims_diff_0);
end

end %function