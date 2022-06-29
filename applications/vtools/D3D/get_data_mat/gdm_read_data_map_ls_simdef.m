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
        switch simdef.D3D.structure
            case 1
                data_bl=gdm_read_data_map_ls(fdir_mat,fpath_map,'DPS',varargin{:});
                data_wl=gdm_read_data_map_ls(fdir_mat,fpath_map,'wl',varargin{:});

                data=data_bl;
                data.val=data_wl.val-data_bl.val;
            case {2,4}
                data=gdm_read_data_map_ls(fdir_mat,fpath_map,'wd',varargin{:});
        end
        
    case {'umag'}
        switch simdef.D3D.structure
            case 1
                data=gdm_read_data_map_ls(fdir_mat,fpath_map,'U1',varargin{:});
                data.val=data.vel_mag;
            case {2,4}
                data=gdm_read_data_map_ls(fdir_mat,fpath_map,'mesh2d_ucmag',varargin{:});
%                 data=gdm_read_data_map_ls(fdir_mat,fpath_map,'uv',varargin{:});
%                 data.val=data.vel_mag;
        end
    case {'bl'}
        switch simdef.D3D.structure
            case 1
                data=gdm_read_data_map_ls(fdir_mat,fpath_map,'DPS',varargin{:});
            case {2,4}
                data=gdm_read_data_map_ls(fdir_mat,fpath_map,'bl',varargin{:});
        end
    otherwise
        data=gdm_read_data_map_ls(fdir_mat,fpath_map,varname,varargin{:});
end



end %function