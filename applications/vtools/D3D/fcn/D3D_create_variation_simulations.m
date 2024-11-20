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
%creates a set of simulations based on a reference one 
%and the variations set in a structure
%
%INPUT
%   -path_ref: path to the reference simulations
%   -input_m: input structure with variations in the mdf/mdu-file. The fieldnames must be the keywords to be modified
%
%PAIR INPUT
%   -
%
%E.G.:
%
%     %% paths
% path_folder_sims='p:\11209261-004-groynes\06_simulations\04_runs_03\02_runs\';
% path_input_folder='p:\11209261-004-groynes\06_simulations\04_runs_03\01_input\';
% path_input_folder_refmdf='../../01_input';
% 
%     %% sims
% path_ref=fullfile(path_folder_sims,sprintf('r%03d',0));
% fcn_adapt=@(X)matrix_variation_01(X);
% 
% %% CALL
% 
% input_m=D3D_input_variation(path_folder_sims,path_input_folder,path_input_folder_refmdf,fcn_adapt);
% D3D_create_variation_simulations(path_ref,input_m);

function D3D_create_variation_simulations(path_ref,input_m,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'software','p:\d-hydro\dimrset\weekly\latest\');
addOptional(parin,'overwrite',0);

parse(parin,varargin{:});
 
fpath_software=parin.Results.software;
overwrite=parin.Results.overwrite;

%check reference exists
if ~isfolder(path_ref)
    error('Folder with reference simulation does not exist: %s',path_ref)
end

%check `dorun` exists
nsim=numel(input_m);
if isfield(input_m,'dorun')==0
    for ksim=1:nsim
        input_m(ksim).dorun=true;
    end
end

simdef.D3D.OMP_num=NaN;

%% CALC

%get path of simulations folder
simdef=D3D_modify_structure(simdef,input_m(1));
[fdir_sim_runs,~,~]=fileparts(simdef.D3D.dire_sim);

%save input matrix
mkdir_check(fdir_sim_runs);
fpath_input=fullfile(fdir_sim_runs,'readme.mat');
save(fpath_input,'input_m');
D3D_write_readme(input_m,'fpath_out',fullfile(fdir_sim_runs,'readme.txt'));

%ref
[path_file,mdf,~]=D3D_read_sim_folder(path_ref);

%structure
simdef.D3D.dire_sim=path_ref;
simdef=D3D_simpath(simdef);
simdef.mdf.dummy=NaN; %there may be no change in mdf. 
% runid=simdef.file.mdfid; %name of the mdf

%run file
[fid_lin,fid_win]=D3D_create_run_batch('open',fdir_sim_runs);

for ksim=1:nsim

%     simdef.mdf.dummy=NaN;
    simdef=D3D_modify_structure(simdef,input_m(ksim));

    if input_m(ksim).dorun==0
        continue
    end
    
    %% overwrite
    
    sta=mkdir_check(simdef.D3D.dire_sim);
    if sta==2
        fprintf('Simulation already exists %s \n',simdef.D3D.dire_sim)
        switch overwrite
            case 0
                fprintf('Skipping folder %s \n',simdef.D3D.dire_sim)
                continue
            case 1
                fprintf('Deleting folder %s \n',simdef.D3D.dire_sim)
                erase_directory(simdef.D3D.dire_sim,1)
            case 2
                fprintf('Not overwriting files if exist %s \n',simdef.D3D.dire_sim)
        end
    end

    %% copy

%     simdef.runid.name=runid; %used in `dimr_config.xml`

    mkdir_check(simdef.D3D.dire_sim);
    
    mdf_loc=mdf;
    mdf_loc=D3D_modify_input_structure(mdf_loc,simdef.mdf);
    mdf_loc=D3D_modify_mdf(mdf_loc); %adhoc changes

    %special case of grid change->copy to simulation folder
    if isfield(input_m,'NetFile')
        [~,fname_grd,fext_grd]=fileparts(input_m(ksim).NetFile);
        fnameext_grd=sprintf('%s%s',fname_grd,fext_grd);
        fpath_grd=fullfile(simdef.D3D.dire_sim,fnameext_grd);
        sts=copyfile_check(input_m(ksim).NetFile,fpath_grd);
        if ~sts
            error('I cannot find the grid to be copied: %s',input_m(ksim).NetFile)
        end
        mdf_loc.geometry.NetFile=fnameext_grd;
    end
    
    %copy files
    D3D_write_sim_folder(simdef.D3D.dire_sim,path_file,mdf_loc);
    
    %run file
    [strsoft_lin,strsoft_win]=D3D_bat(simdef,fpath_software,'check_existing',0);    
    D3D_create_run_batch('add',fdir_sim_runs,fid_lin,fid_win,simdef.runid.name,strsoft_lin,strsoft_win);

    %disp
    messageOut(NaN,sprintf('Simulation created: %4.1f %%',ksim/nsim*100))
    
end %ksim

D3D_create_run_batch('close',fdir_sim_runs,fid_lin,fid_win);

end %function

%%
%% FUNCTIONS
%%

function mdf=D3D_modify_mdf(mdf)

%!!! Attention with capitals. Better to non-capitalize everything. 

%% remove fxw file if scheme is 0
if isfield(mdf,'numerics')
    if isfield(mdf.numerics,'FixedWeirScheme')
        if mdf.numerics.FixedWeirScheme==0
            mdf.geometry.FixedWeirFile='';
        end
    end
end

end %function
