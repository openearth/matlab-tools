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

%% PARSE

%remove the last bar because we use it later to split the name and find <runid>
if fdir_sim(end)==filesep
    fdir_sim(end)='';
end

%% paths

simdef.D3D.dire_sim=fdir_sim;
simdef=D3D_simpath(simdef,'break',1);

%the runid is not in the mdu name, but in the folder name
tok=regexp(fdir_sim,filesep,'split');
switch simdef.D3D.structure
    case 5
        simdef.file.runid=tok{1,end-1}; %<sim> is the last one
    otherwise
        simdef.file.runid=tok{1,end};
end

%% mat and fig

fdir_mat=fullfile(fdir_sim,'mat');
mkdir_check(fdir_mat);
simdef.file.mat.dir=fdir_mat;

fdir_fig=fullfile(fdir_sim,'figures');
simdef.file.fig.dir=fdir_fig;
mkdir_check(fdir_fig);

simdef.file.mat.grd=fullfile(fdir_mat,'grd.mat'); %moved to <gdm_load_grid>, should be erased here after updated everywhere

end %function