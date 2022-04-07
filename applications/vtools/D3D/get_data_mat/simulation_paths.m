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