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

function data_var=gdm_read_data_map_simdef(fdir_mat,simdef,varname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'sim_idx',[]);
addOptional(parin,'var_idx',[]);
addOptional(parin,'sum_var_idx',1);
addOptional(parin,'layer',[]);
addOptional(parin,'do_load',1);
addOptional(parin,'tol',1.5e-7);
addOptional(parin,'idx_branch',[]);
addOptional(parin,'branch','');
addOptional(parin,'bed_layers',[]);
addOptional(parin,'sediment_transport',[]);

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
sim_idx=parin.Results.sim_idx;
var_idx=parin.Results.var_idx;
sum_var_idx=parin.Results.sum_var_idx;
layer=parin.Results.layer;
do_load=parin.Results.do_load;
tol=parin.Results.tol;
idx_branch=parin.Results.idx_branch;
branch=parin.Results.branch;
bed_layers=parin.Results.bed_layers;
sediment_transport=parin.Results.sediment_transport;

%% CALC

fpath_map=gdm_fpathmap(simdef,sim_idx);

if iscell(fpath_map) %SMTD3D4
    nf=numel(fpath_map);
    simdef_loc.D3D.structure=1;
    
    kf=1;
    simdef_loc.file.map=fpath_map{kf};
    branch=simdef.file.runids{kf};
    val_loc=gdm_read_data_map_simdef(fdir_mat,simdef_loc,varname,varargin{:},'branch',branch);
    val_loc_s=squeeze(val_loc.val); %I have to squeeze here to concatenate, which is not consistent with the rest and it is not doable if larger than 2D array output
    for kf=2:nf
        simdef_loc.file.map=fpath_map{kf};
        branch=simdef.file.runids{kf};
        val_loc=gdm_read_data_map_simdef(fdir_mat,simdef_loc,varname,varargin{:},'branch',branch);
        val_loc_s=D3D_SMTD3D4_concatenate(val_loc_s,squeeze(val_loc.val),1);
    end
    data_var.val=val_loc_s;
    return
end

switch varname
    case 'clm2'
        data_var=gdm_read_data_map_sal_mass(fdir_mat,fpath_map,'tim',time_dnum,'idx_branch',idx_branch,'branch',branch);
        %'bl' can be read fine in FM and the variable name is switched to 'DPS' for D3D4.
%     case 'bl'
%         switch simdef.D3D.structure
%             case 1
%                 error('change the name of the variable to read in <D3D_var_num2str>')
%                 data_var=gdm_read_data_map(fdir_mat,fpath_map,'DPS','tim',time_dnum); 
%             case {2,4}
%                 data_var=gdm_read_data_map(fdir_mat,fpath_map,varname,'tim',time_dnum,'idx_branch',idx_branch); 
%         end
    case {'T_max','T_da','T_surf'}         
        if isempty(var_idx)
            error('Provide the index of the constituent to analyze')
        end
        data_var=gdm_read_data_map_T_max(fdir_mat,fpath_map,varname,simdef.file.sub,'tim',time_dnum,'var_idx',var_idx,'tol',tol,'idx_branch',idx_branch,'branch',branch);
    case 'Ltot'
        switch simdef.D3D.structure
            case {2,4}
                data_var=gdm_read_data_map_Ltot(fdir_mat,fpath_map,'tim',time_dnum,'idx_branch',idx_branch,'branch',branch,'var_idx',var_idx);       
            case {1,5}
                data_var=gdm_read_data_map_Ltot_d3d4(fdir_mat,fpath_map,'tim',time_dnum,'idx_branch',idx_branch,'branch',branch,'var_idx',var_idx);       
        end
    case 'thlyr'
        switch simdef.D3D.structure
            case {2,4} %THLYR is available in output directly, call default case
                data_var=gdm_read_data_map(fdir_mat,fpath_map,varname,'tim',time_dnum,'layer',layer,'do_load',do_load,'idx_branch',idx_branch,'branch',branch,'var_idx',var_idx);%,'bed_layers',layer); 
            case {1,5}
                data_var=gdm_read_data_map_thlyr(fdir_mat,fpath_map,'tim',time_dnum,'layer',layer,'do_load',do_load,'idx_branch',idx_branch,'branch',branch,'var_idx',var_idx);%,'bed_layers',layer); 
        end
    case 'ba_mor'
        data_var=gdm_read_data_map_ba_mor(fdir_mat,fpath_map,'tim',time_dnum,'idx_branch',idx_branch,'branch',branch);       
    case 'qsp'
        data_var=gdm_read_data_map_q(fdir_mat,fpath_map,'tim',time_dnum,'idx_branch',idx_branch,'branch',branch);      
    case 'ba' %no time
        data_var=gdm_read_data_map(fdir_mat,fpath_map,varname,'layer',layer,'do_load',do_load,'idx_branch',idx_branch,'branch',branch); 
    case {'mesh1d_lyrfrac','mesh2d_lyrfrac','LYRFRAC'}
        data_var=gdm_read_data_map_Fak(fdir_mat,fpath_map,varname,'tim',time_dnum,'var_idx',var_idx,'idx_branch',idx_branch,'branch',branch,'layer',layer,'sum_var_idx',sum_var_idx); 
    case {'mesh2d_ucmag'} %different case for averaging in case there are several layers
        data_var=gdm_read_data_map_umag(fdir_mat,fpath_map,varname,'tim',time_dnum,'var_idx',var_idx,'idx_branch',idx_branch,'branch',branch,'layer',layer); 
    case 'stot'
        data_var=gdm_read_data_map_stot(fdir_mat,fpath_map,varname,'tim',time_dnum,'var_idx',var_idx,'idx_branch',idx_branch,'branch',branch,'layer',layer); 
    case 'stot_sum'
        data_var=gdm_read_data_map_stot_sum(fdir_mat,fpath_map,varname,'tim',time_dnum,'var_idx',var_idx,'idx_branch',idx_branch,'branch',branch,'layer',layer); 
    case {'Fr','fr'}
        data_var=gdm_read_data_map_Fr(fdir_mat,fpath_map,varname,'tim',time_dnum,'var_idx',var_idx,'idx_branch',idx_branch,'branch',branch,'layer',layer); 
    otherwise 
        %cases in which the variable name contains information on the analysis
        if ischar(varname) && contains(varname,'cel_morpho')
            data_var=gdm_read_data_map_cel_morpho(fdir_mat,fpath_map,varname,'tim',time_dnum,'var_idx',var_idx,'sediment_transport',sediment_transport); 
        else %name directly available in output
            data_var=gdm_read_data_map(fdir_mat,fpath_map,varname,'tim',time_dnum,'layer',layer,'do_load',do_load,'idx_branch',idx_branch,'branch',branch,'var_idx',var_idx);%,'bed_layers',layer); 
        end
end

end %function
