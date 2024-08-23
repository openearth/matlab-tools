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

function data=gdm_read_data_map_ls_simdef(fdir_mat,simdef,varname,sim_idx,layer,varargin)
            
%% CALC

fpath_map=gdm_fpathmap(simdef,sim_idx);

if iscell(fpath_map) %SMTD3D4
    nf=numel(fpath_map);
    simdef_loc.D3D.structure=1;
    
    kf=1;
    simdef_loc.file.map=fpath_map{kf};
    if isfield(simdef.file,'sed')
        simdef_loc.file.sed=simdef.file.sed{kf};
    end
    branch=simdef.file.runids{kf};
    varin=cat(2,varargin,'branch',branch);
    val_loc=gdm_read_data_map_ls_simdef(fdir_mat,simdef_loc,varname,sim_idx,layer,varin{:});
    
    xy_cen=[val_loc.Xcen,val_loc.Ycen];
    val=val_loc.val;
    Zint=val_loc.gridInfo.Ycor;
    
    for kf=2:nf
        %kf=2
        simdef_loc.file.map=fpath_map{kf};
        branch=simdef.file.runids{kf};
        val_loc=gdm_read_data_map_ls_simdef(fdir_mat,simdef_loc,varname,sim_idx,layer,varargin{:},'branch',branch);
        
        xy_cen=cat(1,xy_cen,[val_loc.Xcen,val_loc.Ycen]);
        val=cat(2,val,val_loc.val);
        Zint=cat(2,Zint,val_loc.gridInfo.Ycor);
        
        [xy_cen,idx_o_cen]=order_polyline(xy_cen);
        
        val=val(:,idx_o_cen,:);
        Zint=Zint(:,idx_o_cen,:);
    end
    Scen=compute_distance_along_line(xy_cen);
    Scor=cen2cor(Scen);
    data.Xcen=xy_cen(:,1);
    data.Ycen=xy_cen(:,2);
    data.Xcor=cen2cor(data.Xcen)';
    data.Ycor=cen2cor(data.Ycen)';
    data.gridInfo.Xcor=Scor;
    data.gridInfo.Ycor=Zint;
    data.val=val;
    return
end

%% single run

ismor=D3D_is(fpath_map);

switch varname
    case {'d10','d50','d90','dm'}
        data=gdm_read_data_map_ls_grainsize(fdir_mat,fpath_map,varname,simdef,varargin{:});
    case {'h'}
        switch simdef.D3D.structure
            case {1,5}
                data_bl=gdm_read_data_map_ls(fdir_mat,fpath_map,'DPS',varargin{:});
                data_wl=gdm_read_data_map_ls(fdir_mat,fpath_map,'wl',varargin{:});

                data=data_bl;
                data.val=data_wl.val-data_bl.val;
            case {2,4}
                data=gdm_read_data_map_ls(fdir_mat,fpath_map,'wd',varargin{:});
        end
        
    case {'umag'}
        switch simdef.D3D.structure
            case {1,5}
                data=gdm_read_data_map_ls(fdir_mat,fpath_map,'U1',varargin{:});
                data.val=data.vel_mag;
            case {2,4}
                data=gdm_read_data_map_ls(fdir_mat,fpath_map,'mesh2d_ucmag',varargin{:});
%                 data=gdm_read_data_map_ls(fdir_mat,fpath_map,'uv',varargin{:});
%                 data.val=data.vel_mag;
        end
    case {'vpara'}
        switch simdef.D3D.structure
            case {1,5}
                error('do')
            case {2,4}
                data=gdm_read_data_map_ls(fdir_mat,fpath_map,'uv',varargin{:});
                data.val=data.vel_para;
        end
    case {'vperp'}
        switch simdef.D3D.structure
            case {1,5}
                error('do')
            case {2,4}
                data=gdm_read_data_map_ls(fdir_mat,fpath_map,'uv',varargin{:});
                data.val=data.vel_perp;
        end
    case {'bl'}
        switch simdef.D3D.structure
            case {1,5}
                data=gdm_read_data_map_ls(fdir_mat,fpath_map,'DPS',varargin{:});
            case {2,4}
                if ismor
                    data=gdm_read_data_map_ls(fdir_mat,fpath_map,'mesh2d_mor_bl',varargin{:});
                else
                    data=gdm_read_data_map_ls(fdir_mat,fpath_map,'bl',varargin{:});
                end
        end
    case {'sb'}
        switch simdef.D3D.structure
            case {1,5}
                data=gdm_read_data_map_ls(fdir_mat,fpath_map,'SBUU',varargin{:}); %<sbuu> already reads both
%                 data_v=gdm_read_data_map_ls(fdir_mat,fpath_map,'SBVV',varargin{:});
%                 data=data_u;
%                 data.val=hypot(data_u.val,data_v.val);
                data.val=data.vel_mag;
            case {2,4}
                data_x=gdm_read_data_map_ls(fdir_mat,fpath_map,'sbcx',varargin{:});
                data_y=gdm_read_data_map_ls(fdir_mat,fpath_map,'sbcy',varargin{:});
                data=data_x;
                data.val=hypot(data_x.val,data_y.val);
        end
    case {'lyrfrac'}
        switch simdef.D3D.structure
            case {1,5}
                error('do')
                data=gdm_read_data_map_ls(fdir_mat,fpath_map,'SBUU',varargin{:}); %<sbuu> already reads both
%                 data_v=gdm_read_data_map_ls(fdir_mat,fpath_map,'SBVV',varargin{:});
%                 data=data_u;
%                 data.val=hypot(data_u.val,data_v.val);
                data.val=data.vel_mag;
            case {2,4}
                error('check')
                data_x=gdm_read_data_map_ls(fdir_mat,fpath_map,'sxtot',varargin{:});
                data_y=gdm_read_data_map_ls(fdir_mat,fpath_map,'sytot',varargin{:});
        end
    case {'Fr','fr'}
        switch simdef.D3D.structure
            case {1,5}
                error('do')
                data=gdm_read_data_map_ls(fdir_mat,fpath_map,'SBUU',varargin{:}); %<sbuu> already reads both
%                 data_v=gdm_read_data_map_ls(fdir_mat,fpath_map,'SBVV',varargin{:});
%                 data=data_u;
%                 data.val=hypot(data_u.val,data_v.val);
%                 data.val=data.vel_mag;
            case {2,4}
                data=gdm_read_data_map_ls(fdir_mat,fpath_map,'mesh2d_ucmag',varargin{:});
                data_h=gdm_read_data_map_ls(fdir_mat,fpath_map,'wd',varargin{:});
                data.val=data.val./sqrt(9.81.*data_h.val); %ideally gravity is read from mdu.
        end
    case {'Q','qsp'}
        data=gdm_read_data_map_ls_Q(fdir_mat,fpath_map,varname,simdef,varargin{:});
    otherwise
        data=gdm_read_data_map_ls(fdir_mat,fpath_map,varname,varargin{:});
end

%% layer

if ~isempty(layer)
    if isinf(layer)
        np=size(data.val,2);
        val=NaN(1,np);
        Ycor=NaN(1,np);
        for kp=1:np
            layer_loc=find(~isnan(data.val(1,kp,:)),1,'first');
            val(1,kp)=data.val(1,kp,layer_loc);
            Ycor(1,kp)=data.gridInfo.Ycor(1,kp,layer_loc);
        end
        data.val=val;
        data.gridInfo.Ycor=Ycor;
    else
        data.val=data.val(:,:,layer);
    end
end

end %function