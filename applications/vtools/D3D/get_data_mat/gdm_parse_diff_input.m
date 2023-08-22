%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18565 $
%$Date: 2022-11-24 09:19:58 +0100 (do, 24 nov 2022) $
%$Author: chavarri $
%$Id: plot_differences_between_runs_one_figure.m 18565 2022-11-24 08:19:58Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_differences_between_runs_one_figure.m $
%
%Based on the reference simulation, it removes input such as colormap and
%linestyle for plotting. 
%

function flg_loc=gdm_parse_diff_input(flg_loc)

%matrix
if isfield(flg_loc,'cmap')
    flg_loc.cmap(flg_loc.sim_ref,:)=[];
end

%cell array
if isfield(flg_loc,'ls')
    flg_loc.ls(flg_loc.sim_ref)=[];
end

end %function