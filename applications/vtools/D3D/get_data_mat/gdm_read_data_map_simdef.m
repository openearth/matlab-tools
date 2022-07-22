%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18082 $
%$Date: 2022-05-27 16:38:11 +0200 (Fri, 27 May 2022) $
%$Author: chavarri $
%$Id: gdm_load_time_simdef.m 18082 2022-05-27 14:38:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_load_time_simdef.m $
%
%

function data_var=gdm_read_data_map_simdef(fdir_mat,simdef,varname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'sim_idx',[]);
addOptional(parin,'var_idx',[]);

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
sim_idx=parin.Results.sim_idx;
var_idx=parin.Results.var_idx;
        
%% 

fpath_map=gdm_fpathmap(simdef,sim_idx);

switch varname
    case 'clm2'
        data_var=gdm_read_data_map_sal_mass(fdir_mat,fpath_map,'tim',time_dnum); 
    case 'bl'
        switch simdef.D3D.structure
            case 1
                data_var=gdm_read_data_map(fdir_mat,fpath_map,'DPS','tim',time_dnum); 
            case {2,4}
                data_var=gdm_read_data_map(fdir_mat,fpath_map,varname,'tim',time_dnum); 
        end
    case {'T_max','T_da','T_surf'}         
        if isempty(var_idx)
            error('Provide the index of the constituent to analyze')
        end
        data_var=gdm_read_data_map_T_max(fdir_mat,fpath_map,varname,simdef.file.sub,'tim',time_dnum,'var_idx',var_idx); 
        
    otherwise %name directly available in output
        data_var=gdm_read_data_map(fdir_mat,fpath_map,varname,'tim',time_dnum); 
end

end %function