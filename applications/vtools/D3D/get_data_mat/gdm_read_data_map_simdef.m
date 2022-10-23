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
addOptional(parin,'layer',[]);
addOptional(parin,'do_load',1);
addOptional(parin,'tol',1.5e-7);
addOptional(parin,'idx_branch',[]);

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
sim_idx=parin.Results.sim_idx;
var_idx=parin.Results.var_idx;
layer=parin.Results.layer;
do_load=parin.Results.do_load;
tol=parin.Results.tol;
idx_branch=parin.Results.idx_branch;

%% 

fpath_map=gdm_fpathmap(simdef,sim_idx);

switch varname
    case 'clm2'
        data_var=gdm_read_data_map_sal_mass(fdir_mat,fpath_map,'tim',time_dnum); 
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
        data_var=gdm_read_data_map_T_max(fdir_mat,fpath_map,varname,simdef.file.sub,'tim',time_dnum,'var_idx',var_idx,'tol',tol); 
    case 'Ltot'
        data_var=gdm_read_data_map_Ltot(fdir_mat,fpath_map,'tim',time_dnum,'idx_branch',idx_branch);      
    case 'ba_mor'
        data_var=gdm_read_data_map_ba_mor(fdir_mat,fpath_map,'tim',time_dnum,'idx_branch',idx_branch);      
    case 'qsp'
        data_var=gdm_read_data_map_q(fdir_mat,fpath_map,'tim',time_dnum,'idx_branch',idx_branch);      
    case 'ba' %no time
        data_var=gdm_read_data_map(fdir_mat,fpath_map,varname,'layer',layer,'do_load',do_load,'idx_branch',idx_branch); 
    otherwise %name directly available in output
        data_var=gdm_read_data_map(fdir_mat,fpath_map,varname,'tim',time_dnum,'layer',layer,'do_load',do_load,'idx_branch',idx_branch); 
end

end %function
