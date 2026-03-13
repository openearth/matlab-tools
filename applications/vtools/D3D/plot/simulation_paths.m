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

function simdef=simulation_paths(fid_log,in_plot,ks)

%% PARSE

fdir_sim=in_plot.fdir_sim{ks};
%remove the last bar because we use it later to split the name and find <runid>
if fdir_sim(end)==filesep
    fdir_sim(end)='';
end
in_plot=isfield_default(in_plot,'simdef_overwrite',1);
in_plot=isfield_default(in_plot,'break_paths_smt',0);

%% paths

simdef.D3D.dire_sim=fdir_sim;

%`D3D_simpath` can be expensive if there are a large number of folders and
%subfolders with figures in an SMT simulation. This subrotuine is called
%repetitively inside the code. We want to read the `simdef` file if it
%already exists. At the same time, we want to control if we overwrite it 
%the first time, as it is dangerous in case a simulation is created by
%copy-pasting an existing simulation. For this reason, we here check and
%delete `simdef` if necessary, and then we do not overwrite the next times
%`D3D_simpath` is called, as the default value is to not overwrite.

fpath_simdef=fullfile(simdef.D3D.dire_sim,'simdef.mat');
if exist(fpath_simdef,'file')==2 && in_plot.simdef_overwrite
    messageOut(NaN,'`simdef` file exists. Deleting.')
    delete(fpath_simdef)
end

simdef=D3D_simpath(simdef,'break',1,'overwrite',0,'break_paths_smt',in_plot.break_paths_smt);

%the runid is not in the mdu name, but in the folder name
tok=regexp(fdir_sim,filesep,'split');
switch simdef.D3D.structure
    case 5
        simdef.file.runid=tok{1,end-1}; %<sim> is the last one
    otherwise
        simdef.file.runid=tok{1,end};
end

%% folders

in_plot=isfield_default(in_plot,'fdir_postprocess',in_plot.fdir_sim); %cell array of postprocess folders. 
npf=numel(in_plot.fdir_postprocess); 
if ks>npf
    %we have provide posprocess folder for some simulations, but not for all. 
    in_plot.fdir_postprocess{ks}=in_plot.fdir_sim{ks}; %if there is no postprocess folder for this simulation, we use the simulation folder.
end
if ~isfolder(in_plot.fdir_postprocess{ks})
    error('Postprocess folder does not exist: %s',in_plot.fdir_postprocess{ks})
end
fdirs={'fdir_mat','fdir_fig','fdir_csv','fdir_json','fdir_log'};
for kfdir=1:numel(fdirs)
    fdir_name=fdirs{kfdir};
    fdir_name_create=fdir_name(6:end);
    fdir=fullfile(in_plot.fdir_postprocess{ks},fdir_name_create);
    mkdir_check(fdir);
    simdef.file.(fdir_name)=fdir;
end

end %function