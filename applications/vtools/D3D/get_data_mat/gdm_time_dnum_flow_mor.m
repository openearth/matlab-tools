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

function tim_search_in_mea=gdm_time_dnum_flow_mor(flg_loc,time_dnum,time_mor_dnum)

%% PARSE

if isfield(flg_loc,'tim_type')==0
    flg_loc.tim_type=1;
end

%% CALC

if flg_loc.tim_type==1
    tim_search_in_mea=time_dnum;
elseif flg_loc.tim_type==2
    tim_search_in_mea=time_mor_dnum;
end

end %function