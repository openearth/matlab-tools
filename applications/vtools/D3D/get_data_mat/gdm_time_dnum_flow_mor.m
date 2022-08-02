%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18187 $
%$Date: 2022-06-21 16:12:26 +0200 (di, 21 jun 2022) $
%$Author: chavarri $
%$Id: plot_1D_01.m 18187 2022-06-21 14:12:26Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_1D_01.m $
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