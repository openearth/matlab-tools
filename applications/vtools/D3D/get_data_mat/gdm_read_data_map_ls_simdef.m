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

function data=gdm_read_data_map_ls_simdef(fdir_mat,simdef,varname,sim_idx,varargin)
            
fpath_map=gdm_fpathmap(simdef,sim_idx);

switch varname
    case {'d10','d50','d90','dm'}
        data=gdm_read_data_map_ls_grainsize(fdir_mat,fpath_map,simdef,varargin);
    case {'h'}
        data_bl=gdm_read_data_map_ls(fdir_mat,fpath_map,'DPS',varargin{:});
        data_wl=gdm_read_data_map_ls(fdir_mat,fpath_map,'wl',varargin{:});
        
        data=data_bl;
        data.val=data_wl.val-data_bl.val;
    otherwise
        data=gdm_read_data_map_ls(fdir_mat,fpath_map,varname,varargin{:});
end



end %function