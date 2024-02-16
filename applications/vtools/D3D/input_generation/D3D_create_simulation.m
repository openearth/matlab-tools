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

function simdef=D3D_create_simulation(simdef,varargin) 

%% PARSE

parin=inputParser;

addOptional(parin,'only_run_script',false);
addOptional(parin,'overwrite',0);

parse(parin,varargin{:});

only_run_script=parin.Results.only_run_script;
overwrite=parin.Results.overwrite;

%% create files

simdef=D3D_rework(simdef);

if ~only_run_script

    %% overwrite
    
    sta=mkdir_check(simdef.D3D.dire_sim);
    if sta==2
        fprintf('Simulation already exists %s \n',simdef.D3D.dire_sim)
        switch overwrite
            case 0  
                fprintf('Skipping folder %s \n',simdef.D3D.dire_sim)
                return
            case 1
                fprintf('Deleting folder %s \n',simdef.D3D.dire_sim)
                erase_directory(simdef.D3D.dire_sim,1)
            case 2
                fprintf('Not overwriting files if exist %s \n',simdef.D3D.dire_sim)
        end
    end

    %% files

    %grid
    [dirloc]=fileparts(simdef.file.grd);
    mkdir_check(dirloc);
    if exist(simdef.file.grd,'file')~=2 
        D3D_grid(simdef)
    end
    copyfile_check(simdef.file.grd,simdef.D3D.dire_sim); %copy to run location

    %morphological boundary conditions
%     [dirloc]=fileparts(simdef.file.bcm);
%     mkdir_check(dirloc)
%     if exist(simdef.file.bcm,'file')~=2
%         D3D_bcm(simdef)
%     end

    %hydrodynamic boundary conditions 
    [dirloc]=fileparts(simdef.file.bct);
    mkdir_check(dirloc);
    if exist(simdef.file.bct,'file')~=2
        D3D_bct(simdef,'check_existing',false)
    end

    %initial bathymetry
    [dirloc]=fileparts(simdef.file.dep);
    mkdir_check(dirloc);
    if exist(simdef.file.dep,'file')~=2
        D3D_dep(simdef)
    end

    %initial bed grain size distribution
    if exist(simdef.file.mini,'file')~=2 
        D3D_mini(simdef)
    end

    %initial flow conditions
    if simdef.D3D.structure==1
        if exist(simdef.file.fini,'file')~=2 
            D3D_fini(simdef,'check_existing',false)
        end
    else 
        simdef_c=simdef; %make a copy because filenames are changed for misusing the function
        simdef_c.file.dep=simdef_c.file.etaw;
        [dirloc]=fileparts(simdef_c.file.dep);
        mkdir_check(dirloc);
        if exist(simdef_c.file.dep,'file')~=2
            simdef_c.ini.etab=simdef_c.ini.etab+simdef_c.ini.h; %changed here to missuse the creation of dep file for water level
            simdef_c.ini.noise_amp=-simdef_c.ini.noise_amp;
            simdef_c.ini.etab_noise=simdef_c.ini.etaw_noise;
            D3D_dep(simdef_c)
        end
        if exist(simdef.file.ini_vx,'file')~=2
            D3D_fini_u(simdef)
        end
    end

    %boundary definition    
    [dirloc]=fileparts(simdef.file.bnd);
    mkdir_check(dirloc);
    mkdir_check(simdef.file.fdir_pli);
    if exist(simdef.file.bnd,'file')~=2
        D3D_bnd(simdef)
    end

    %morphology parameters
    [dirloc]=fileparts(simdef.file.mor);
    mkdir_check(dirloc);
    if exist(simdef.file.mor,'file')~=2
        D3D_mor(simdef,'check_existing',false)
    end

    %morphodynamic boundary condition
    [dirloc]=fileparts(simdef.file.bcm);
    mkdir_check(dirloc);
    if exist(simdef.file.bcm,'file')~=2
        D3D_bcm(simdef,'check_existing',false)
    end
    
    %sediment parameters
    [dirloc]=fileparts(simdef.file.sed);
    mkdir_check(dirloc);
    if exist(simdef.file.sed,'file')~=2
        D3D_sed(simdef,'check_existing',false)
    end

    %sediment transport parameters
%         if simdef.D3D.structure==1
%             [dirloc]=fileparts(simdef.file.tra);
%             mkdir_check(dirloc);
%             if exist(simdef.file.tra,'file')~=2
%                 D3D_tra(simdef,'check_existing',false)
%             end
%         end

    %concentrations BC
    if simdef.D3D.structure==1
        [dirloc]=fileparts(simdef.file.bcc);
        mkdir_check(dirloc);
        if exist(simdef.file.bcc,'file')~=2 && ~isempty(simdef.file.bcc)
            D3D_bcc(simdef,'check_existing',false)
        end
    end

    %mdf/mdu    
    if exist(simdef.file.mdf,'file')~=2
        D3D_md(simdef,'check_existing',false)
    end

    %runid
    if simdef.D3D.structure==1
        if exist(simdef.file.runid,'file')~=2
            D3D_runid(simdef)
        end
    end

    %observation points
    if simdef.mdf.Flhis_dt>0
        if exist(simdef.file.obs,'file')~=2
            D3D_obs(simdef,'check_existing',false);
        end
        if exist(simdef.file.crs,'file')~=2
            D3D_crs(simdef,'check_existing',false);
        end
    end

    %simdef
    fpath_simdef=fullfile(simdef.D3D.dire_sim,'simdef.mat');
    save(fpath_simdef,'simdef')
    
    %run script
    D3D_bat(simdef,simdef.file.software,'check_existing',false);   
    
end 

end %function