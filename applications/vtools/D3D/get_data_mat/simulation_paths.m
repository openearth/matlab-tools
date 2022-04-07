%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17944 $
%$Date: 2022-04-07 14:24:09 +0200 (Thu, 07 Apr 2022) $
%$Author: chavarri $
%$Id: plot_map_sal_mass_01.m 17944 2022-04-07 12:24:09Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_map_sal_mass_01.m $
%
%

function simdef=simulation_paths(fdir_sim,in_plot)

%% paths

simdef.D3D.dire_sim=fdir_sim;
simdef=D3D_simpath(simdef,'break',1);

tok=regexp(fdir_sim,'\','split');
simdef.file.runid=tok{1,end};

%% mat and fig

fdir_mat=fullfile(fdir_sim,'mat');
mkdir_check(fdir_mat);
simdef.file.mat.dir=fdir_mat;

fdir_fig=fullfile(fdir_sim,'figures');
simdef.file.fig.dir=fdir_fig;
mkdir_check(fdir_fig);

% if in_plot.map
    simdef.file.mat.grd=fullfile(fdir_mat,'grd.mat');
% end

%% map_sal_01

if in_plot.fig_map_sal_01.do
    simdef.file.mat.map_sal_01=fullfile(fdir_mat,'map_sal_01.mat');
    simdef.file.mat.map_sal_01_tim=fullfile(fdir_mat,'map_sal_01_tim.mat');
    
    simdef.file.fig.map_sal_01=fullfile(fdir_fig,'map_sal_01');
    mkdir_check(simdef.file.fig.map_sal_01);
end

%% map_ls_01

if in_plot.fig_map_ls_01.do
    simdef.file.mat.map_ls_01=fullfile(fdir_mat,'map_ls_01.mat');
    simdef.file.mat.map_ls_01_tim=fullfile(fdir_mat,'map_ls_01_tim.mat');
    
    simdef.file.fig.map_ls_01=fullfile(fdir_fig,'map_ls_01');
    mkdir_check(simdef.file.fig.map_ls_01);
end

end %function