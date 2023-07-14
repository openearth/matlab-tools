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

function D3D_create_simulation_all(flg,input_m,fdir_sim_runs,fcn_adapt)

%% get only all variations component

if isfield(input_m,'sim')
    input_m_s=input_m.sim;
else
    input_m_s=input_m;
end

%% save input matrix

mkdir_check(fdir_sim_runs);
fpath_input=fullfile(fdir_sim_runs,'readme.mat');
save(fpath_input,'input_m');
D3D_write_readme(input_m_s,'fpath_out',fullfile(fdir_sim_runs,'readme.txt'));

%% run files

[fid_lin,fid_win]=D3D_create_run_batch('open',fdir_sim_runs);

%% loop on simulations

nsim=numel(input_m_s);
for ksim=1:nsim
    
    if input_m_s(ksim).dorun==0; continue; end
    
    %% adapt input
    
    simdef=fcn_adapt(input_m_s(ksim));
    simdef=D3D_rework(simdef); %defaults

    %% create files
    
    if ~flg.only_run_script

        sta=mkdir_check(simdef.D3D.dire_sim);
        if sta==2
            fprintf('Simulation already exists %s \n',simdef.D3D.dire_sim)
            switch flg.overwrite
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
            D3D_dep(simdef,'check_existing',false)
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
        end

        %simdef
        fpath_simdef=fullfile(simdef.D3D.dire_sim,'simdef.mat');
        save(fpath_simdef,'simdef')
        
    end 
    
    %% run script

    [strsoft_lin,strsoft_win]=D3D_bat(simdef,simdef.file.software,'check_existing',false);    
    D3D_create_run_batch('add',fdir_sim_runs,fid_lin,fid_win,simdef.runid.name,strsoft_lin,strsoft_win);
    
    %% erase run in p and move new
%     fpath_c=input_m.sim(ksim).path_sim;
%     fpath_p=strrep(fpath_c,fdir_project,fdir_project_p);
%     fpath_p_old=strrep(fpath_p,'02_runs','02_runs\00_old');
% %     copyfile_check(fpath_p,fpath_p_old);
%     erase_directory(fpath_p);
%     copyfile_check(fpath_c,fpath_p);
    
end

D3D_create_run_batch('close',fdir_sim_runs,fid_lin,fid_win);

end %function