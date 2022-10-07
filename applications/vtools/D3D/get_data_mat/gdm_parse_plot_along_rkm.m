%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18390 $
%$Date: 2022-09-27 12:07:53 +0200 (Tue, 27 Sep 2022) $
%$Author: chavarri $
%$Id: plot_map_2DH_01.m 18390 2022-09-27 10:07:53Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_map_2DH_01.m $
%
%

function flg_loc=gdm_parse_plot_along_rkm(flg_loc)

if isfield(flg_loc,'do_plot_along_rkm')==0
    flg_loc.do_plot_along_rkm=0;
end
if flg_loc.do_plot_along_rkm
    if ~isfield(flg_loc,'fpath_rkm_plot_along')
        error('Provide rkm file')
    else
        if ~exist(flg_loc.fpath_rkm_plot_along,'file')
            error('File with rkm does not exist')
        end
    end
end

if isfield(flg_loc,'do_rkm_disp')==0
    flg_loc.do_rkm_disp=0;
end
if flg_loc.do_rkm_disp
    if ~isfield(flg_loc,'fpath_rkm_disp') 
        error('Provide rkm file')
    else
        if ~exist(flg_loc.fpath_rkm_disp,'file')
            error('File with rkm does not exist')
        end
    end
end

if isfield(flg_loc,'rkm_tol_x')==0
    flg_loc.rkm_tol_x=1000;
end

if isfield(flg_loc,'rkm_tol_y')==0
    flg_loc.rkm_tol_y=1000;
end

end %function