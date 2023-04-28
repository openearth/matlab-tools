%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18632 $
%$Date: 2022-12-20 06:26:16 +0100 (di, 20 dec 2022) $
%$Author: chavarri $
%$Id: plot_map_2DH_diff_01.m 18632 2022-12-20 05:26:16Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_map_2DH_diff_01.m $
%
%

function kdiff_v=gdm_kdiff_v(flg_loc)

%% PARSE

if isfield(flg_loc,'do_s')==0 %difference between runs
    flg_loc.do_s=1; %this is checked at the beginning of the run, but doesn't harm
end

if isfield(flg_loc,'do_s_diff')==0 %difference between runs and initial time
    flg_loc.do_s_diff=0;
end

if isfield(flg_loc,'do_s_perc')==0 %difference between runs in percentage terms
    flg_loc.do_s_perc=0;
end

%% CALC

%needs to match `gdm_data_diff`
kdiff_v=[];
if flg_loc.do_s
    kdiff_v=cat(2,kdiff_v,2);
end
if flg_loc.do_s_perc
    kdiff_v=cat(2,kdiff_v,3);
end
if flg_loc.do_s_diff
    kdiff_v=cat(2,kdiff_v,4);
end

end %function 