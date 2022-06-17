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
%get data from 1 time step in D3D, output name as in D3D

function out=NC_read_map(simdef,in)

% messageOut(NaN,'start reading map data')

%% RENAME in

file=simdef.file;
if isfield(simdef,'flg')
    flg=simdef.flg;
end

kt=in.kt; %times to plot
kf=in.kf; %fractions to plot
kF=in.kF; %faces to plot
kcs=in.kcs; %cross-sections to plot

if isfield(file,'partitions')==0
    file.partitions=1;
end
if isfield(flg,'get_cord')==0
    flg.get_cord=1;
end
if isfield(flg,'get_EHY')==0
    flg.get_EHY=0;
end
if file.partitions>1
    flg.get_EHY=1;
end

%overwritten by input variable
if flg.which_v==3
    mean_type=2;
elseif flg.which_v==26
    mean_type=1;
else
    mean_type=1;
end

if isfield(flg,'elliptic')==0
    flg.elliptic=0;
end

%is
[ismor,is1d,str_network]=D3D_is(file.map);

%whether data is at links or cell centre
islink=D3D_islink(flg.which_v);

%% CONSTANST

cnt.g=9.81; %readable from mdu

%% LOAD

%HELP
% file.map='c:\Users\chavarri\temporal\D3D\runs\P\035\DFM_OUTPUT_sim_P035\sim_P035_map.nc';
% ncinfo(file.map)

%% time, space, fractions
if flg.which_p~=-1
        
    switch simdef.D3D.structure
        case 2 %FM
            
            %time
            [time_r,time_mor_r,time_dnum,time_dtime]=D3D_results_time(file.map,ismor,kt);
            
            if is1d
                %take coordinates from curved domain (in case the domain is
                %straightened)
                if isfield(in,'rkm_curved')
                    x_node=ncread(in.rkm_curved,'mesh1d_node_x');
                    y_node=ncread(in.rkm_curved,'mesh1d_node_y');
                    
                    x_edge=ncread(in.rkm_curved,'mesh1d_edge_x');
                    y_edge=ncread(in.rkm_curved,'mesh1d_edge_y');
                    
                    offset_edge=ncread(in.rkm_curved,'mesh1d_edge_offset');
                    branch_edge=ncread(in.rkm_curved,'mesh1d_edge_branch');
                else
                    x_node=ncread(file.map,'mesh1d_node_x');
                    y_node=ncread(file.map,'mesh1d_node_y');
                    
                    x_edge=ncread(file.map,'mesh1d_edge_x');
                    y_edge=ncread(file.map,'mesh1d_edge_y');
                    
                    offset_edge=ncread(file.map,'mesh1d_edge_offset');
                    branch_edge=ncread(file.map,'mesh1d_edge_branch');
                end
                
                offset=ncread(file.map,'mesh1d_node_offset');
                branch=ncread(file.map,'mesh1d_node_branch');
                branch_length=ncread(file.map,sprintf('%s_edge_length',str_network));
                branch_id=ncread(file.map,sprintf('%s_branch_id',str_network))';
            else
                %preallocate for always passing to functions
                face_nodes_x=NaN;
                face_nodes_y=NaN;
                x_node=NaN;
                y_node=NaN;
                x_face=NaN;
                y_face=NaN;
                faces=NaN;
                edge_nodes_x=NaN;
                edge_nodes_y=NaN;
                if flg.get_cord
                    if file.partitions>1 || flg.get_EHY
                        gridInfo=EHY_getGridInfo(file.map,{'face_nodes_xy','XYcen','face_nodes','XYcor'});
                        face_nodes_x=gridInfo.face_nodes_x;
                        face_nodes_y=gridInfo.face_nodes_y;
                    else
                        x_node=ncread(file.map,'mesh2d_node_x');
                        y_node=ncread(file.map,'mesh2d_node_y');

                        x_face=ncread(file.map,'mesh2d_face_x',kF(1),kF(2));
                        y_face=ncread(file.map,'mesh2d_face_y',kF(1),kF(2));
                        faces=ncread(file.map,'mesh2d_face_nodes',[1,kF(1)],[Inf,kF(2)]);
                    end
                    if islink
                        if file.partitions>1 || flg.get_EHY
                            gridInfo=EHY_getGridInfo(file.map,{'face_nodes_xy','edge_nodes_xy'});
                            edge_nodes_x=gridInfo.edge_nodes_x;
                            edge_nodes_y=gridInfo.edge_nodes_y;
                        else
                            edge_nodes_x=ncread(file.map,'mesh2d_edge_x');
                            edge_nodes_y=ncread(file.map,'mesh2d_edge_y');
                        end
                    end
                end
            end
        case 3 %SOBEK3
%                     x_node_reach=ncread(file.reach,'x_coordinate');
%                     y_node_reach=ncread(file.reach,'y_coordinate');
% 
%                     offset_reach=ncread(file.reach,'chainage');
%                     branch_reach=ncread(file.reach,'branchid');
%                     branch_length_reach=branch_length_sobek3(offset_reach,branch_reach);
% 
%                     branch_id_reach=S3_get_branch_order(simdef);            
            file_read=S3_file_read(flg.which_v,file);
            
            x_node=ncread(file_read,'x_coordinate');
            y_node=ncread(file_read,'y_coordinate');

            offset=ncread(file_read,'chainage');
            branch=ncread(file_read,'branchid');
            branch_length=branch_length_sobek3(offset,branch);

            branch_id=S3_get_branch_order(simdef);

            [time_r,time_mor_r,time_dnum,time_dtime]=D3D_results_time(file_read,ismor,kt);
    end
    
    if in.nfl>1
        z_node=ncread(file.map,'mesh2d_node_z');
        layer_sigma=ncread(file.map,'mesh2d_layer_sigma');
    end
    
    % x_face_bnd=ncread(file.map,'mesh2d_face_x_bnd');
    % y_face_bnd=ncread(file.map,'mesh2d_face_y_bnd');
    % scatter(x_face_bnd(:),y_face_bnd(:))
    
    %sediment
    %delft3d_io_sed seems to be quite expensive. We only read it if necessary.
    if any(flg.which_p==[1,4]) || any(flg.which_v==[3,4])
        if isfield(file,'sed')
            dchar=D3D_read_sed(file.sed);
        end
    end
    
end %which_p
%% vars

switch flg.which_p
    case -1 %nothing
        
    case 1 %3D bed elevation and gsd
        %%
        bl=ncread(file.map,'mesh2d_mor_bl',[kF(1),kt(1)],[kF(2),kt(2)]);
        LYRFRAC=ncread(file.map,'mesh2d_lyrfrac',[1,1,1,kt(1)],[Inf,Inf,Inf,kt(2)]);
        
        %mean grain size
        dm=mean_grain_size(LYRFRAC,dchar,mean_type);
        
        %output
        out.x_node=x_node;
        out.y_node=y_node;
        out.x_face=x_face;
        out.y_face=y_face;
        out.faces=faces;
        
        out.cvar=dm;
        out.bl=bl;
        
        
    case {2,3,5,6,8,9} %2DH & 1D
        %%
        switch flg.which_v
            case 0 %nothing
                
            case 1 %etab
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            if ismor
                                out=get_fm1d_data('mesh1d_mor_bl',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                            else
                                out=get_fm1d_data('mesh1d_flowelem_bl',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                            end
                        else
                            if flg.get_EHY
                                if ismor==0
                                    z=get_EHY(file.map,'mesh2d_flowelem_bl',time_dnum);
                                else
                                    z=get_EHY(file.map,'mesh2d_mor_bl',time_dnum);
                                end
                                out=v2struct(z,face_nodes_x,face_nodes_y);
                            else
                                if ismor==0
                                    z=ncread(file.map,'mesh2d_flowelem_bl',kF(1),kF(2));
                                else
                                    z=ncread(file.map,'mesh2d_mor_bl',[kF(1),kt(1)],[kF(2),kt(2)]);
                                end
                                out=v2struct(z,x_node,y_node,x_face,y_face,faces);
                            end
                        end
                    case 3 %SOBEK3
                        out_wl=get_sobek3_data('water_level',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                        out_h=get_sobek3_data('water_depth',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                        
                        out=out_wl;
                        out.z=out_wl.z-out_h.z;
                end
                out.zlabel='bed elevation [m]';
            case 2 %h
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            out=get_fm1d_data('mesh1d_waterdepth',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                        else %FM2D
                            if flg.which_p==3 %1D
                                %% d3d interpolation
                                %                         warning('Interpolation does not work well')
                                %                             %%
                                %                     D = dflowfm.readMap(file.map,kt);
                                %                     G = dflowfm.readNet(file.grd);
                                %
                                %                     pol.x=in.pol.x;
                                %                     pol.y=in.pol.y;
                                %
                                %                     %begin debug
                                %     %                 pol.x=x_v;
                                %     %                 pol.y=y_v;
                                %                     %end debug
                                %
                                %                     polout=dflowfm.interpolate_on_polygon(G,D,pol);
                                %
                                
                                %% my interplation
                                if ismor==0
                                    h=ncread(file.map,'mesh2d_waterdepth',[1,kt(1)],[Inf,kt(2)]);
                                else
                                    bl=ncread(file.map,'mesh2d_mor_bl',[kF(1),kt(1)],[kF(2),kt(2)]);
                                    wl=ncread(file.map,'mesh2d_s1',[kF(1),kt(1)],[kF(2),kt(2)]);
                                    h=wl-bl;
                                end
                                
                                %integrate corss section
                                s=[0,cumsum(sqrt(diff(in.pol.x).^2+diff(in.pol.y).^2))];
                                
                                if any(diff(y_face))==0 && any(diff(x_face))==0 %pseudo 2D (2D simulation but only one cell wide)
                                    warning('ad hoc')
                                    s_r=fliplr([0;cumsum(sqrt(diff(x_face).^2+diff(y_face).^2))]');
                                    hs=interp1(s_r,h,s);
                                else
                                    Fh=scatteredInterpolant(x_face,y_face,h);
                                    hs=Fh(in.pol.x,in.pol.y);
                                end
                                
                                %output
                                out.z=hs;
                                out.XZ=in.pol.x;
                                out.YZ=in.pol.y;
                                out.SZ=s;
                                
                                %                 switch flg.which_p
                                %                     case 2
                                %                         out.z (1,:)=NaN;
                                %                         out.z (end,:)=NaN;
                            end
                            if flg.which_p==2
                                if flg.get_EHY
                                    if ismor==0
                                        z=get_EHY(file.map,'mesh2d_waterdepth',time_dnum);
                                    else
                                        bl=get_EHY(file.map,'mesh2d_mor_bl',time_dnum);
                                        wl=get_EHY(file.map,'mesh2d_s1',time_dnum);
                                        z=wl-bl;
                                    end
                                    out=v2struct(z,face_nodes_x,face_nodes_y);
                                else
                                    if ismor==0
                                        z=ncread(file.map,'mesh2d_waterdepth',[1,kt(1)],[Inf,kt(2)]);
                                    else
                                        bl=ncread(file.map,'mesh2d_mor_bl',[kF(1),kt(1)],[kF(2),kt(2)]);
                                        wl=ncread(file.map,'mesh2d_s1',[kF(1),kt(1)],[kF(2),kt(2)]);
                                        z=wl-bl;
                                    end
                                    out=v2struct(z,x_node,y_node,x_face,y_face,faces);
                                end
                            end
                        end
                    case 3 %SOBEK3
                        out=get_sobek3_data('water_depth',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                end
                out.zlabel='flow depth [m]';
                %%
            case 3 %dm
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            out=get_fm1d_data('mesh1d_dm',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                        else
                            nci=ncinfo(file.map);
                            if isnan(find_str_in_cell({nci.Variables.Name},{'mesh2d_dm'}))
                                warning('dm not available in output, constructing from mass and thickness. Check if this is true')
                                if flg.get_EHY
                                    error('do')
%                                     M=get_EHY(file.map,'mesh2d_msed',time_dnum);
%                                     L=get_EHY(file.map,'mesh2d_thlyr',time_dnum);
                                    out=v2struct(z,face_nodes_x,face_nodes_y);
                                else
                                    F=ncread(file.map,'mesh2d_lyrfrac',[kF(1),1,1,kt(1)],[kF(2),Inf,Inf,kt(2)]); %faces, layer, fraction, time
                                    z=mean_grain_size(F,dchar,mean_type);
                                    z=z(:,1); %active layer
                                    out=v2struct(z,x_node,y_node,x_face,y_face,faces);
                                end
                            else
                                error('do')
                            end
                        end
                    case 3 %SOBEK3
                        error('check')
                        out=get_sobek3_data('water_level',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                end
                out.zlabel='arithmetic mean grain size [m]';
                %%
            case 4 %dm fIk
                LYRFRAC=vs_let(NFStruct,'map-sed-series',{kt},'LYRFRAC',{ky,kx,1:nl,1:nf},'quiet'); %fractions at layers [-] (t,y,x,l,f)
                DP_BEDLYR=vs_let(NFStruct,'map-sed-series',{kt},'DP_BEDLYR',{ky,kx,1:nl+1},'quiet'); %fractions at layers [-] (t,y,x,l)
                
                fIk=find_substrate(LYRFRAC,DP_BEDLYR);
                dm=mean_grain_size(fIk,dchar,mean_type);
                
                %output
                switch flg.which_p
                    case 2
                        %output
                        out.z=reshape(dm,ny,nx);
                        out.XZ=reshape(XZ,ny,nx);
                        out.YZ=reshape(YZ,ny,nx);
                        
                    case 5
                        out.z=reshape(fIk(:,:,1:end-2,kf),kt(2),nx-2);
                        out.XZ=reshape(XZ(:,:,1:end-2),ny,nx-2);
                        out.YZ=time_r;
                end
                %%
            case 5 %fIk
                LYRFRAC=vs_let(NFStruct,'map-sed-series',{kt},'LYRFRAC',{ky,kx,1:nl,1:nf},'quiet'); %fractions at layers [-] (t,y,x,l,f)
                DP_BEDLYR=vs_let(NFStruct,'map-sed-series',{kt},'DP_BEDLYR',{ky,kx,1:nl+1},'quiet'); %fractions at layers [-] (t,y,x,l)
                
                fIk=find_substrate(LYRFRAC,DP_BEDLYR);
                
                %output
                switch flg.which_p
                    case 5
                        out.z=reshape(fIk(:,:,1:end-2,kf),kt(2),nx-2);
                        out.XZ=reshape(XZ(:,:,1:end-2),ny,nx-2);
                        out.YZ=time_r;
                end
                %%
            case 6 %I
                I=ncread(file.map,'mesh2d_spirint',[1,kt],[Inf,kt(2)]);
                
                out.z=I;
                out.x_node=x_node;
                out.y_node=y_node;
                out.x_face=x_face;
                out.y_face=y_face;
                out.faces=faces;
                
                out.zlabel='secondary flow intensity [m/s]';
                %%
            case 7 %elliptic
                z=ncread(file.map,'mesh2d_hirano_illposed',[1,kt],[Inf,kt(2)]);
                
                out.z=z;
                out.x_node=x_node;
                out.y_node=y_node;
                out.x_face=x_face;
                out.y_face=y_face;
                out.faces=faces;
                
                out.zlabel='ill-posed [-]';
                
                %                 HIRCHK=vs_let(NFStruct,'map-sed-series',{kt},'HIRCHK',{ky,kx},'quiet'); %Hyperbolic/Elliptic Hirano model [-]
                %                 HIRCHK(HIRCHK==-999)=NaN;
                %
                %                 if flg.which_p==8
                %                     HIRCHK=cumulative_elliptic(HIRCHK); %make it cumulative
                %                 end
                %
                %                 %output
                %                 out.z=reshape(HIRCHK,ny,nx);
                %                 out.XZ=reshape(XZ,ny,nx);
                %                 out.YZ=reshape(YZ,ny,nx);
                %
                %                 switch flg.which_p
                %                     case {2,8}
                %                         out.z (1,:)=NaN;
                %                         out.z (end,:)=NaN;
                %                 end
                %%
            case 8 %Fak
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            out=get_fm1d_data('mesh1d_lyrfrac',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                            out.z=squeeze(out.z(:,1,kf,:)); %get first layer and fractions we ask for
                        else
                            if flg.get_EHY
                                OPT.bed_layers=1;
                                z=get_EHY(file.map,'mesh2d_lyrfrac',time_dnum,OPT);
                                
                                out=v2struct(z,face_nodes_x,face_nodes_y);
                            else
                                z=ncread(file.map,'mesh2d_lyrfrac',[kF(1),kl(1),kf(1),kt(1)],[kF(2),kl(2),kf(2),kt(2)]);  %!! I am not sure the dimension we take are correct in case we take more than one fraction or at more than one time
                                
                                out=v2struct(z,x_node,y_node,x_face,y_face,faces);
                            end
                        end
                    case 3 %SOBEK3
                        error('No fractions in SOBEK 3')
                        %                         out=get_sobek3_data('water_level',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                end
                if numel(kf)==1
                    out.zlabel=sprintf('volume fraction content of size fraction %d in the active layer [-]',kf);
                else
                    out.zlabel='volume fraction content in the active layer [-]';
                end
                %%
            case 9 %detrended etab based on etab_0
                DPS_0=vs_let(NFStruct,'map-sed-series',{1} ,'DPS',{ky,kx},'quiet'); %depth at z point [m]
                DPS  =vs_let(NFStruct,'map-sed-series',{kt},'DPS',{ky,kx},'quiet'); %depth at z point [m]
                
                %output
                switch flg.which_p
                    case 2
                        out.z=reshape(-DPS-(-DPS_0),ny,nx);
                        out.XZ=reshape(XZ,ny,nx);
                        out.YZ=reshape(YZ,ny,nx);
                        
                        out.z (1,:)=NaN;
                        out.z (end,:)=NaN;
                    case 3
                        out.z=reshape(-DPS-(-DPS_0),ny,nx);
                        out.XZ=reshape(XZ,ny,nx);
                        out.YZ=reshape(YZ,ny,nx);
                        
                        %                         out.z (1,:)=NaN;
                        %                         out.z (end,:)=NaN;
                    case 6
                        ndim=max(nx,ny);
                        out.z=reshape(-DPS-(-DPS_0),kt(2),ndim);
                        out.XZ=reshape(XZ,ny,nx);
                        out.YZ=reshape(YZ,ny,nx);
                        
                end
                out.zlabel='relative bed elevation [m]';
                %%
            case 10 %depth-averaged velocity
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            out=get_fm1d_data('mesh1d_ucmag',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                        else
                            if in.nfl>1
                                z=ncread(file.map,'mesh2d_ucmaga',[kF(1),kt(1)],[kF(2),1]);
                                out=v2struct(z,x_node,y_node,x_face,y_face,faces);
                            else
                                z=get_EHY(file.map,'mesh2d_ucmag',time_dnum);
%                                 out=v2struct(z,x_node,y_node,x_face,y_face,faces);
%                                 out=v2struct(z,face_nodes_x,face_nodes_y);
                                out=v2struct(z,x_node,y_node,x_face,y_face,faces);
                            end                            
                        end
                    case 3 %SOBEK3
                        out=get_sobek3_data('water_velocity',file_read,in,branch,offset,x_node,y_node,branch_length,branch_id);
                end
                out.zlabel='depth-averaged velocity [m/s]';
            case 11 %velocity
                switch simdef.D3D.structure
                    case 2
                ucx=ncread(file.map,'mesh2d_ucx',[1,1,kt(1)],[Inf,Inf,kt(2)]);
                ucy=ncread(file.map,'mesh2d_ucy',[1,1,kt(1)],[Inf,Inf,kt(2)]);
                ucz=ncread(file.map,'mesh2d_ucz',[1,1,kt(1)],[Inf,Inf,kt(2)]);
                
                wl=ncread(file.map,'mesh2d_s1',[1,kt(1)],[Inf,kt(2)]);
                
                try
                    bl=ncread(file.map,'mesh2d_mor_bl',[1,kt],[Inf,kt(2)]);
                catch
                    bl=ncread(file.map,'mesh2d_flowelem_bl',[1],[Inf]);
                end
                
                
                %%
                %     data = qpread(file.map,1,'velocity','data',kt);
                %% exact mn points
                %                 h=wl-bl;
                %                 h_diff=h*(layer_sigma)';
                %                 z_face=wl+h_diff;
                % %                 mn=[806; 817; 828; 839; 850; 861; 872; 883; 894; 905];
                %                 mn=in.mn;
                % %                 np=numel(mn);
                %                 ucx_s=ucx(:,mn);
                %                 ucy_s=ucy(:,mn);
                %                 ucz_s=ucz(:,mn);
                %
                %                 uc_norm=NaN(size(ucx_s));
                %                 for kl=1:out.nfl
                %                     uc_norm(kl,:)=sqrt(ucx_s(kl,:).^2+ucy_s(kl,:).^2+ucz_s(kl,:).^2);
                %                 end
                %
                %                 x_face_s=x_face(mn);
                %                 y_face_s=y_face(mn);
                %                 z_face_s=z_face(mn,:);
                
                %% interpolate 2D
                %                 Fwl=scatteredInterpolant(x_face,y_face,wl);
                %                 Fbl=scatteredInterpolant(x_face,y_face,bl);
                %
                %                 wl_cs=Fwl(in.pol.x,in.pol.y);
                %                 bl_cs=Fbl(in.pol.x,in.pol.y);
                %                 h_cs=wl_cs-bl_cs;
                %                 h_diff=h_cs.*layer_sigma;
                %                 z_face_s=wl_cs+h_diff;
                %
                %                 npcs=numel(in.pol.y);
                %
                %                 uc_norm=NaN(out.nfl,npcs);
                %                 ucx_s=NaN(out.nfl,npcs);
                %                 ucy_s=NaN(out.nfl,npcs);
                %                 ucz_s=NaN(out.nfl,npcs);
                %
                %
                %                 for kl=1:out.nfl
                %                     %Attention with velocity signs!
                %                     FU1=scatteredInterpolant(x_face,y_face,ucx(kl,:)');
                %                     FV1=scatteredInterpolant(x_face,y_face,ucy(kl,:)');
                %                     FW =scatteredInterpolant(x_face,y_face,ucz(kl,:)');
                %
                %                     ucx_s(kl,:)=FU1(in.pol.x,in.pol.y);
                %                     ucy_s(kl,:)=FV1(in.pol.x,in.pol.y);
                %                     ucz_s(kl,:)=FW (in.pol.x,in.pol.y);
                %
                %                     uc_norm(kl,:)=sqrt(ucx_s(kl,:).^2+ucy_s(kl,:).^2+ucz_s(kl,:).^2);
                %                 end
                %
                %                 out.ucx_s=ucx_s;
                %                 out.ucy_s=ucy_s;
                %                 out.ucz_s=ucz_s;
                %                 out.uc_norm=uc_norm;
                % %                 out.x_face_s=x_face_s;
                %                 out.x_face_s=in.pol.x;
                % %                 out.y_face_s=y_face_s;
                %                 out.y_face_s=in.pol.y;
                %                 out.z_face_s=z_face_s;
                %
                %
                %                 out.zlabel='velocity [m/s]';
                %% interpolate 3D
                
                xmin=min(in.pol.x);
                xmax=max(in.pol.x);
                ymin=min(in.pol.y);
                ymax=max(in.pol.y);
                
                epsilon=0.25; %we should use something like 2dx. Compute dx base on area of cells or similar
                
                idx_take=x_face<xmax+epsilon & x_face>xmin-epsilon & y_face<ymax+epsilon & y_face>ymin-epsilon;
                wl=wl(idx_take);
                bl=bl(idx_take);
                x_face=x_face(idx_take);
                y_face=y_face(idx_take);
                ucx=ucx(:,idx_take);
                ucy=ucy(:,idx_take);
                ucz=ucz(:,idx_take);
                
                h=wl-bl;
                h_diff=h.*layer_sigma';
                z_face_k=(wl+h_diff)';
                
                x_face_k=repmat(x_face,1,out.nfl)';
                y_face_k=repmat(y_face,1,out.nfl)';
                
                
                FU1=scatteredInterpolant(x_face_k(:),y_face_k(:),z_face_k(:),ucx(:),'linear','nearest');
                FV1=scatteredInterpolant(x_face_k(:),y_face_k(:),z_face_k(:),ucy(:),'linear','nearest');
                FW =scatteredInterpolant(x_face_k(:),y_face_k(:),z_face_k(:),ucz(:),'linear','nearest');
                
                npcs=numel(in.pol.y);
                npiz=3*out.nfl;
                
                x_face_s=repmat(in.pol.x,npiz,1);
                y_face_s=repmat(in.pol.y,npiz,1);
                
                Fwl=scatteredInterpolant(x_face,y_face,wl);
                Fbl=scatteredInterpolant(x_face,y_face,bl);
                
                wl_cs=Fwl(in.pol.x,in.pol.y);
                bl_cs=Fbl(in.pol.x,in.pol.y);
                for kpcs=1:npcs
                    z_face_s(:,kpcs)=linspace(wl_cs(kpcs),bl_cs(kpcs),npiz);
                end
                
                ucx_i=FU1(x_face_s(:),y_face_s(:),z_face_s(:));
                ucy_i=FV1(x_face_s(:),y_face_s(:),z_face_s(:));
                ucz_i=FW (x_face_s(:),y_face_s(:),z_face_s(:));
                
                ucx_s=reshape(ucx_i,npiz,npcs);
                ucy_s=reshape(ucy_i,npiz,npcs);
                ucz_s=reshape(ucz_i,npiz,npcs);
                
                uc_norm=sqrt(ucx_s.^2+ucy_s.^2+ucz_s.^2);
                
                out.ucx_s=ucx_s;
                out.ucy_s=ucy_s;
                out.ucz_s=ucz_s;
                out.uc_norm=uc_norm;
                %                 out.x_face_s=x_face_s;
                out.x_face_s=in.pol.x;
                %                 out.y_face_s=y_face_s;
                out.y_face_s=in.pol.y;
                out.z_face_s=z_face_s;
                
                    case 3
                        error('use variable 10 rather than 11')
%                         out=get_sobek3_data('water_velocity',file_read,in,branch_reach,offset_reach,x_node_reach,y_node_reach,branch_length_reach,branch_id_reach);
                end
                out.zlabel='velocity [m/s]';
                %%
            case 12 %water level
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            out=get_fm1d_data('mesh1d_s1',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                        else
                            if flg.get_EHY
                                z=get_EHY(file.map,'mesh2d_s1',time_dnum);
                                out=v2struct(z,face_nodes_x,face_nodes_y);
                            else
                                wl=ncread(file.map,'mesh2d_s1',[kF(1),kt(1)],[kF(2),1]);

                                %output
                                out.z=wl;
                                out.x_node=x_node;
                                out.y_node=y_node;
                                out.x_face=x_face;
                                out.y_face=y_face;
                                out.faces=faces;
                            end                            
                        end
                    case 3 %SOBEK3
                        out=get_sobek3_data('water_level',file_read,in,branch,offset,x_node,y_node,branch_length,branch_id);
                end
                out.zlabel='water level [m]';
                %%
            case 13 %face index
                %                 wl=ncread(file.map,'mesh2d_s1',[1,kt(1)],[Inf,kt(2)]);
                
                %output
                out.z=[1:1:size(faces,2)]';
                out.x_node=x_node;
                out.y_node=y_node;
                out.x_face=x_face;
                out.y_face=y_face;
                out.faces=faces;
                
                out.zlabel='face indices [-]';
                %%
            case 15 %bed shear stress
                if is1d
                    out=get_fm1d_data('mesh1d_taus',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                else
                    taus=ncread(file.map,'mesh2d_taus',[1,kt(1)],[Inf,kt(2)]);
                    
                    %output
                    out.z=taus;
                    out.x_node=x_node;
                    out.y_node=y_node;
                    out.x_face=x_face;
                    out.y_face=y_face;
                    out.faces=faces;
                end
                out.zlabel='bed shear stress [Pa]';
                %%
            case 17
                bl_0=ncread(file.map,'mesh2d_mor_bl',[1,kt(1)],[Inf,1]);
                bl  =ncread(file.map,'mesh2d_mor_bl',[1,kt(2)],[Inf,1]);
                
                bl_change=bl-bl_0;
                
                %output
                out.x_node=x_node;
                out.y_node=y_node;
                out.x_face=x_face;
                out.y_face=y_face;
                %                 out.x_node_edge=x_node_edge;
                %                 out.y_node_edge=y_node_edge;
                out.faces=faces;
                
                out.z=bl_change;
                
                out.zlabel='bed elevation change [m]';
                %%
            case 18 %discharge m^3/s
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            out=get_fm1d_data('mesh1d_q1',file.map,in,branch_edge,offset_edge,x_edge,y_edge,branch_length,branch_id);
                        else
                            error('check')
                            wl=ncread(file.map,'mesh2d_s1',[kF(1),kt(1)],[kF(2),1]);
                            
                            %output
                            out.z=wl;
                            out.x_node=x_node;
                            out.y_node=y_node;
                            out.x_face=x_face;
                            out.y_face=y_face;
                            out.faces=faces;
                            
                        end
                    case 3 %SOBEK3
                        error('check')
                        out=get_sobek3_data('water_level',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                end
                out.zlabel='discharge [m^3/s]';
                %%
            case {19,44} %bed load transport magnitude [m^2/s]
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            %                             outx=get_fm1d_data('mesh1d_sbcx',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                            %                             outy=get_fm1d_data('mesh1d_sbcy',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                            outx=get_fm1d_data('mesh1d_sbcx_reconstructed',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                            outy=get_fm1d_data('mesh1d_sbcy_reconstructed',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                            out=outx;
                            %                             out.z=sqrt(outx.z.^2+outy.z.^2);
                            switch flg.which_v
                                case 19
                                    out.z=sqrt(outx.z(:,kf).^2+outy.z(:,kf).^2);
                                case 44
                                    out.z=sqrt(sum(outx.z,2).^2+sum(outy.z,2).^2);
                            end
                        else
                            if flg.get_EHY
                               sx=get_EHY(file.map,'mesh2d_sbcx',time_dnum);
                               sy=get_EHY(file.map,'mesh2d_sbcy',time_dnum);
                                
                                sx=squeeze(sx)';
                                sy=squeeze(sy)';
                            else
                                sx=ncread(file.map,'mesh2d_sbcx',[kF(1),1,kt(1)],[kF(2),Inf,kt(2)]);
                                sy=ncread(file.map,'mesh2d_sbcy',[kF(1),1,kt(1)],[kF(2),Inf,kt(2)]);
                            end
                            switch flg.which_v
                                case 19
                                    z=sqrt(sx(:,kf).^2+sy(:,kf).^2);
                                case 44
                                    z=sqrt(sum(sx,2).^2+sum(sy,2).^2);
                            end
                            if flg.get_EHY
                               out=v2struct(z,face_nodes_x,face_nodes_y);
                            else
                               out=v2struct(z,x_node,y_node,x_face,y_face,faces);
                            end
                        end
                    case 3 %SOBEK3
                        error('check')
                        out=get_sobek3_data('water_level',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                end
                out.zlabel='bed load transport magnitude [m^2/s]';
                %%
            case 20 %flow velocity at the main channel [m/s]
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            %activate with .mor; [Output]; VelocMagAtZeta=true
                            out=get_fm1d_data('mesh1d_umod',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                        else
                            error('check')
                            wl=ncread(file.map,'mesh2d_s1',[kF(1),kt(1)],[kF(2),1]);
                            
                            %output
                            out.z=wl;
                            out.x_node=x_node;
                            out.y_node=y_node;
                            out.x_face=x_face;
                            out.y_face=y_face;
                            out.faces=faces;
                            
                        end
                    case 3 %SOBEK3
                        error('check')
                        out=get_sobek3_data('water_level',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                end
                out.zlabel='flow velocity at the main channel [m/s]';
                %%
            case 21 %discharge at the main channel [m/s]
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            out=get_fm1d_data('mesh1d_q1_main',file.map,in,branch_edge,offset_edge,x_edge,y_edge,branch_length,branch_id);
                        else
                            error('check')
                            wl=ncread(file.map,'mesh2d_s1',[kF(1),kt(1)],[kF(2),1]);
                            
                            %output
                            out.z=wl;
                            out.x_node=x_node;
                            out.y_node=y_node;
                            out.x_face=x_face;
                            out.y_face=y_face;
                            out.faces=faces;
                            
                        end
                    case 3 %SOBEK3
                        error('check')
                        out=get_sobek3_data('water_level',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                end
                out.zlabel='flow discharge at the main channel [m^3/s]';
                %%
            case 23 %suspended transport magnitude [m^2/s]
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            %                             outx=get_fm1d_data('mesh1d_sbcx',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                            %                             outy=get_fm1d_data('mesh1d_sbcy',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                            outx=get_fm1d_data('mesh1d_sscx_reconstructed',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                            outy=get_fm1d_data('mesh1d_sscy_reconstructed',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                            out=outx;
                            %                             out.z=sqrt(outx.z.^2+outy.z.^2);
                            out.z=sqrt(outx.z(:,kf,:).^2+outy.z(:,kf,:).^2);
                        else
                            error('check')
                            wl=ncread(file.map,'mesh2d_s1',[kF(1),kt(1)],[kF(2),1]);
                            
                            %output
                            out.z=wl;
                            out.x_node=x_node;
                            out.y_node=y_node;
                            out.x_face=x_face;
                            out.y_face=y_face;
                            out.faces=faces;
                            
                        end
                    case 3 %SOBEK3
                        error('check')
                        out=get_sobek3_data('water_level',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                end
                out.zlabel='suspended transport magnitude [m^2/s]';
                %%
            case 25 %total mass
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            out_area=get_fm1d_data('mesh1d_flowelem_ba',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                            out_mass=get_fm1d_data('mesh1d_msed',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                            
                            tot_mass_m2=squeeze(sum(out_mass.z(kf,:,:),2)); %total mass in all substrate
                            
                            tot_mass=tot_mass_m2.*out_area.z';
                            warning('area is length!')
                            tot_mass=tot_mass_m2;
                            
                            out=out_area;
                            out.z=tot_mass;
                            
                            %                             figure
                            %                             plot(tot_mass_m2')
                            %                             figure
                            %                             plot(out_area.z)
                        else
                            error('check')
                            wl=ncread(file.map,'mesh2d_s1',[kF(1),kt(1)],[kF(2),1]);
                            
                            %output
                            out.z=wl;
                            out.x_node=x_node;
                            out.y_node=y_node;
                            out.x_face=x_face;
                            out.y_face=y_face;
                            out.faces=faces;
                            
                        end
                    case 3 %SOBEK3
                        error('check')
                        out=get_sobek3_data('water_level',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                end
                out.zlabel='sediment mass [kg]';
                %%
            case 26 %dg
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            out=get_fm1d_data('mesh1d_dg',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                        else
                            error('check')
                            wl=ncread(file.map,'mesh2d_s1',[kF(1),kt(1)],[kF(2),1]);
                            
                            %output
                            out.z=wl;
                            out.x_node=x_node;
                            out.y_node=y_node;
                            out.x_face=x_face;
                            out.y_face=y_face;
                            out.faces=faces;
                            
                        end
                    case 3 %SOBEK3
                        error('check')
                        out=get_sobek3_data('water_level',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                end
                out.zlabel='geometric mean grain size [m]';
                %%
                %             case 27 %sediment thickness
                %                 switch simdef.D3D.structure
                %                     case 2 %FM
                %                         if is1d
                %                             out=get_fm1d_data('mesh1d_thlyr',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                %                             out.z=sum(out.z,1)';
                %                         else
                %                             if flg.get_EHY
                %                                z=get_EHY(file.map,'mesh2d_thlyr',time_dnum);
                %                                z=sum(z,2);
                %                                out=v2struct(z,face_nodes_x,face_nodes_y);
                %                             else
                %                                z=ncread(file.map,'mesh2d_thlyr',[kl(1),kF(1),kt(1)],[kl(2),kF(2),kt(2)]);
                %
                %                                out=v2struct(z,x_node,y_node,x_face,y_face,faces);
                %                             end
                %                         end
                %                     case 3 %SOBEK3
                %                         error('check')
                %                         out=get_sobek3_data('water_level',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                %                 end
                %                 out.zlabel='total sediment thickness [m]';
                %%
            case 28 %Main channel averaged bed level
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            out=get_fm1d_data('mesh1d_bl_ave',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                        else
                            error('check')
                            wl=ncread(file.map,'mesh2d_s1',[kF(1),kt(1)],[kF(2),1]);
                            
                            %output
                            out.z=wl;
                            out.x_node=x_node;
                            out.y_node=y_node;
                            out.x_face=x_face;
                            out.y_face=y_face;
                            out.faces=faces;
                        end
                    case 3 %SOBEK3
                        error('check')
                        out=get_sobek3_data('water_level',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                end
                out.zlabel='main channel averaged bed level [m]';
                %%
            case 29 %sediment transport magnitude at edges [m^2/s]
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            outx=get_fm1d_data('mesh1d_sbn',file.map,in,branch_edge,offset_edge,x_edge,y_edge,branch_length,branch_id);
                            outy=get_fm1d_data('mesh1d_sbt',file.map,in,branch_edge,offset_edge,x_edge,y_edge,branch_length,branch_id);
                            
                            out=outx;
                            out.z=sqrt(outx.z.^2+outy.z.^2);
                            
                        else
                            error('check')
                            wl=ncread(file.map,'mesh2d_s1',[kF(1),kt(1)],[kF(2),1]);
                            
                            %output
                            out.z=wl;
                            out.x_node=x_node;
                            out.y_node=y_node;
                            out.x_face=x_face;
                            out.y_face=y_face;
                            out.faces=faces;
                            
                        end
                    case 3 %SOBEK3
                        error('check')
                        out=get_sobek3_data('water_level',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                end
                out.zlabel='sediment transport magnitude at edges [m^2/s]';
                %%
            case 30 %sediment transport magnitude at edges [m^3/s]
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            outx=get_fm1d_data('mesh1d_sbn',file.map,in,branch_edge,offset_edge,x_edge,y_edge,branch_length,branch_id);
                            outy=get_fm1d_data('mesh1d_sbt',file.map,in,branch_edge,offset_edge,x_edge,y_edge,branch_length,branch_id);
                            outw=get_fm1d_data('mesh1d_mor_width_u',file.map,in,branch_edge,offset_edge,x_edge,y_edge,branch_length,branch_id);
                            
                            out=outx;
                            out.z=sqrt(outx.z(:,kf,:).^2+outy.z(:,kf,:).^2).*repmat(outw.z,1,numel(kf),size(outx.z,3));
                            
                        else
                            error('check')
                            wl=ncread(file.map,'mesh2d_s1',[kF(1),kt(1)],[kF(2),1]);
                            
                            %output
                            out.z=wl;
                            out.x_node=x_node;
                            out.y_node=y_node;
                            out.x_face=x_face;
                            out.y_face=y_face;
                            out.faces=faces;
                            
                        end
                    case 3 %SOBEK3
                        error('check')
                        out=get_sobek3_data('water_level',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                end
                out.zlabel='sediment transport magnitude at edges [m^3/s]';
                %%
            case 31 %morphodynamic width
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            out=get_fm1d_data('mesh1d_mor_width_u',file.map,in,branch_edge,offset_edge,x_edge,y_edge,branch_length,branch_id);
                        else
                            error('check')
                            wl=ncread(file.map,'mesh2d_s1',[kF(1),kt(1)],[kF(2),1]);
                            
                            %output
                            out.z=wl;
                            out.x_node=x_node;
                            out.y_node=y_node;
                            out.x_face=x_face;
                            out.y_face=y_face;
                            out.faces=faces;
                            
                        end
                    case 3 %SOBEK3
                        error('check')
                        out=get_sobek3_data('water_level',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                end
                out.zlabel='morphodynamic width [m]';
                %%
            case 32 %Chezy
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            out=get_fm1d_data('mesh1d_czs',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                        else
                            if flg.get_EHY
                                z=get_EHY(file.map,'mesh2d_czs',time_dnum);
                                out=v2struct(z,face_nodes_x,face_nodes_y);
                            else
                                z=ncread(file.map,'mesh2d_czs',[kF(1),kt(1)],[kF(2),kt(2)]);
                                out=v2struct(z,x_node,y_node,x_face,y_face,faces);
                            end
                        end
                    case 3 %SOBEK3
                        error('check')
                        out=get_sobek3_data('water_level',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                end
                out.zlabel='Chezy friction coefficient [m^{1/2}/s]';
                %%
            case 33 %cell area
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            out=get_fm1d_data('mesh1d_flowelem_ba',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                        else
                            wl=ncread(file.map,'mesh2d_flowelem_ba',[kF(1)],[kF(2)]);
                            
                            %output
                            out.z=wl;
                            out.x_node=x_node;
                            out.y_node=y_node;
                            out.x_face=x_face;
                            out.y_face=y_face;
                            out.faces=faces;
                            
                        end
                    case 3 %SOBEK3
                        error('check')
                        out=get_sobek3_data('water_level',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                end
                out.zlabel='cell area [m^2]';
                %%
            case 34 %dx
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            nb=numel(in.branch);
                            branch_aux=in.branch;
                            dx=[];
                            SZ=[];
                            XZ=[];
                            YZ=[];
                            for kb=1:nb
                                in.branch=branch_aux(1,kb);
                                out=get_fm1d_data('mesh1d_node_offset',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                                dx_aux=diff(out.z);
                                if ~isempty(dx_aux)
                                    dx=cat(1,dx,dx_aux);
                                    %                                     XZ=cat(1,XZ,out.XZ(1:end-1));
                                    %                                     YZ=cat(1,YZ,out.YZ(1:end-1));
                                    %                                     SZ=cat(1,SZ,out.SZ(1:end-1));
                                end
                            end
                            out.z=dx;
                            out.SZ=1:1:numel(dx);
                            %                             out.XZ=XZ;
                            %                             out.YZ=YZ;
                            
                        else
                            ba=ncread(file.map,'mesh2d_flowelem_ba',kF(1),kF(2));
                            
                            %output
                            out.z=sqrt(ba);
                            out.x_node=x_node;
                            out.y_node=y_node;
                            out.x_face=x_face;
                            out.y_face=y_face;
                            out.faces=faces;
                            
                        end
                    case 3 %SOBEK3
                        error('check')
                        out=get_sobek3_data('water_level',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                end
                out.zlabel='space step [m]';
            case 36 %Froude
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            out=get_fm1d_data('mesh1d_ucmag',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                            out_h=get_fm1d_data('mesh1d_waterdepth',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                            out.z=out.z./sqrt(cnt.g.*out_h.z);
                        else
                            if in.nfl>1
                                umag=ncread(file.map,'mesh2d_ucmaga',[kF(1),kt(1)],[kF(2),1]);
                            else
                                umag=ncread(file.map,'mesh2d_ucmag',[kF(1),kt(1)],[kF(2),1]);
                            end
                            if ismor==0
                                h=ncread(file.map,'mesh2d_waterdepth',[1,kt(1)],[Inf,kt(2)]);
                            else
                                bl=ncread(file.map,'mesh2d_mor_bl',[kF(1),kt(1)],[kF(2),kt(2)]);
                                wl=ncread(file.map,'mesh2d_s1',[kF(1),kt(1)],[kF(2),kt(2)]);
                                h=wl-bl;
                            end
                            out.z=umag./sqrt(cnt.g.*h);
                            out.x_node=x_node;
                            out.y_node=y_node;
                            out.x_face=x_face;
                            out.y_face=y_face;
                            out.faces=faces;
                        end
                    case 3 %SOBEK3
                        error('do')
                        out=get_sobek3_data('water_velocity',file.reach,in,branch_reach,offset_reach,x_node_reach,y_node_reach,branch_length_reach,branch_id_reach);
                end
                out.zlabel='Froude number [-]';
                %%
            case 37 %CFL
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            error('do')
                            out=get_fm1d_data('mesh1d_ucmag',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                            out_h=get_fm1d_data('mesh1d_waterdepth',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                            out.z=out.z./sqrt(cnt.g.*out_h.z);
                        else
                            if in.nfl>1
                                umag=ncread(file.map,'mesh2d_ucmaga',[kF(1),kt(1)],[kF(2),1]);
                            else
                                umag=ncread(file.map,'mesh2d_ucmag',[kF(1),kt(1)],[kF(2),1]);
                            end
                            if ismor==0
                                h=ncread(file.map,'mesh2d_waterdepth',[1,kt(1)],[Inf,kt(2)]);
                            else
                                bl=ncread(file.map,'mesh2d_mor_bl',[kF(1),kt(1)],[kF(2),kt(2)]);
                                wl=ncread(file.map,'mesh2d_s1',[kF(1),kt(1)],[kF(2),kt(2)]);
                                h=wl-bl;
                            end
                            ba=ncread(file.map,'mesh2d_flowelem_ba',kF(1),kF(2));
                            dt=ncread(file.map,'timestep',kt(1),kt(2));
                            
                            c=umag+sqrt(cnt.g.*h);
                            dx=sqrt(ba);
                            
                            out.z=c.*dt./dx;
                            out.x_node=x_node;
                            out.y_node=y_node;
                            out.x_face=x_face;
                            out.y_face=y_face;
                            out.faces=faces;
                        end
                    case 3 %SOBEK3
                        error('do')
                        out=get_sobek3_data('water_velocity',file.reach,in,branch_reach,offset_reach,x_node_reach,y_node_reach,branch_length_reach,branch_id_reach);
                end
                out.zlabel='CFL [-]';
                %%
            case 38 %time step
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            error('do')
                            out=get_fm1d_data('mesh1d_ucmag',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                            out_h=get_fm1d_data('mesh1d_waterdepth',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                            out.z=out.z./sqrt(cnt.g.*out_h.z);
                        else
                            dt=ncread(file.map,'timestep',kt(1),kt(2));
                            
                            out.z=dt.*ones(size(x_face));
                            out.x_node=x_node;
                            out.y_node=y_node;
                            out.x_face=x_face;
                            out.y_face=y_face;
                            out.faces=faces;
                        end
                    case 3 %SOBEK3
                        error('do')
                        out=get_sobek3_data('water_velocity',file.reach,in,branch_reach,offset_reach,x_node_reach,y_node_reach,branch_length_reach,branch_id_reach);
                end
                out.zlabel='time step [s]';
                %%
            case {14,27,39} %sediment thickness
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            out=get_fm1d_data('mesh1d_thlyr',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                            if flg.which_v==27
                                out.z=sum(out.z,1)';
                            elseif flg.which_v==14
                                out.z=squeeze(out.z(1,:,:));
                            end
                        else
                            if flg.get_EHY
                                z=get_EHY(file.map,'mesh2d_thlyr',time_dnum,'bed_layers',1:1:in.nl);
                                if flg.which_v==27
                                    z=sum(z,3)';
                                elseif flg.which_v==14
                                    z=squeeze(z(:,:,1));
                                end
                                out=v2struct(z,face_nodes_x,face_nodes_y);
                            else
                                z=ncread(file.map,'mesh2d_thlyr',[1,kF(1),kt(1)],[Inf,kF(2),kt(2)]);
                                if flg.which_v==27
                                    z=sum(z,1)';
                                elseif flg.which_v==14
                                    z=z(1,:)';
                                end
                                out=v2struct(z,x_node,y_node,x_face,y_face,faces);
                            end
                        end
                    case 3 %SOBEK3
                        error('check')
                        out=get_sobek3_data('water_level',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                end
                if flg.which_v==27
                    out.zlabel='total sediment thickness [m]';
                elseif flg.which_v==39
                    out.zlabel='sediment thickness [m]';
                elseif flg.which_v==14
                    out.zlabel='active layer thickness [m]';
                end
                %%
            case 40 %volume fraction content
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            error('check')
                            out=get_fm1d_data('mesh1d_thlyr',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                            out.z=sum(out.z,1)';
                        else
                            if flg.get_EHY
                                z=get_EHY(file.map,'mesh2d_lyrfrac',time_dnum);
                                
                                out=v2struct(z,face_nodes_x,face_nodes_y);
                            else
                                z=ncread(file.map,'mesh2d_lyrfrac',[kF(1),1,kf(1),kt(1)],[kF(2),Inf,kf(2),kt(2)]);
                                
                                out=v2struct(z,x_node,y_node,x_face,y_face,faces);
                            end
                        end
                    case 3 %SOBEK3
                        error('check')
                        out=get_sobek3_data('water_level',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                end
                out.zlabel='total sediment thickness [m]';
                %%    
            case 41 %wave height
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            error('not available')
                        else
                            if flg.get_EHY
                                z=get_EHY(file.map,'mesh2d_hwav',time_dnum);
                                out=v2struct(z,face_nodes_x,face_nodes_y);
                            else
                                z=ncread(file.map,'mesh2d_hwav',[kF(1),1,kf(1),kt(1)],[kF(2),Inf,kf(2),kt(2)]);                                
                                out=v2struct(z,x_node,y_node,x_face,y_face,faces);
                            end
                        end
                    case 3 %SOBEK3
                        error('not available')
                end
                out.zlabel='wave height [m]';
                %%
            case 42 %wave forces
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            error('not available')
                        else
                            if flg.get_EHY
                                fx=get_EHY(file.map,'mesh2d_Fx',time_dnum);
                                fy=get_EHY(file.map,'mesh2d_Fy',time_dnum);
                                z=hypot(fx,fy);
                                out=v2struct(z,face_nodes_x,face_nodes_y);
                            else
                                fx=ncread(file.map,'mesh2d_Fx',[kF(1),1,kf(1),kt(1)],[kF(2),Inf,kf(2),kt(2)]); 
                                fy=ncread(file.map,'mesh2d_Fx',[kF(1),1,kf(1),kt(1)],[kF(2),Inf,kf(2),kt(2)]); 
                                z=hypot(fx,fy);
                                out=v2struct(z,x_node,y_node,x_face,y_face,faces);
                            end
                        end
                    case 3 %SOBEK3
                        error('not available')
                end
                out.zlabel='wave forces [N]';         
                %%
            case 43 %horizontal eddy-viscosity
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            error('not available')
                        else
                            if flg.get_EHY
                                zn=get_EHY(file.map,'mesh2d_viu',time_dnum);
                                F=scatteredInterpolant(edge_nodes_x,edge_nodes_y,zn);
                                z=F(face_nodes_x,face_nodes_y);
                                out=v2struct(z,face_nodes_x,face_nodes_y);
                            else
                                zn=ncread(file.map,'mesh2d_viu',[1,kt(1)],[Inf,kt(2)]); 
                                %dealing with nan in zn
                                bol_nan=isnan(zn);
                                F=scatteredInterpolant(edge_nodes_x(~bol_nan),edge_nodes_y(~bol_nan),zn(~bol_nan),'linear','linear');
%                                 F=scatteredInterpolant(edge_nodes_x,edge_nodes_y,zn,'linear','linear');
                                z=F(x_face,y_face);
                                out=v2struct(z,x_node,y_node,x_face,y_face,faces);
                            end
                        end
                    case 3 %SOBEK3
                        error('not available')
                end
                out.zlabel='horizontal eddy viscosity [m^2/s]';    
                %%
            case 45
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            out=get_fm1d_data('mesh2d_hice',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                        else
                            if flg.get_EHY
                                zn=get_EHY(file.map,'mesh2d_hice',time_dnum);
                                F=scatteredInterpolant(edge_nodes_x,edge_nodes_y,zn);
                                z=F(face_nodes_x,face_nodes_y);
                                out=v2struct(z,face_nodes_x,face_nodes_y);
                            else
                                z=ncread(file.map,'mesh2d_hice',[1,kt(1)],[Inf,kt(2)]); 
                                out=v2struct(z,x_node,y_node,x_face,y_face,faces);
                            end
                        end
                    case 3 %SOBEK3
                        error('not available')
                end
                out.zlabel='thickness of the floating ice cover [m]';   
                %%
            case 46
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            out=get_fm1d_data('mesh2d_pice',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                        else
                            if flg.get_EHY
                                zn=get_EHY(file.map,'mesh2d_pice',time_dnum);
                                F=scatteredInterpolant(edge_nodes_x,edge_nodes_y,zn);
                                z=F(face_nodes_x,face_nodes_y);
                                out=v2struct(z,face_nodes_x,face_nodes_y);
                            else
                                z=ncread(file.map,'mesh2d_pice',[1,kt(1)],[Inf,kt(2)]); 
                                out=v2struct(z,x_node,y_node,x_face,y_face,faces);
                            end
                        end
                    case 3 %SOBEK3
                        error('not available')
                end
                out.zlabel='pressure exerted by the floating ice cover [m]';   
                %%
            case 47
                switch simdef.D3D.structure
                    case 2 %FM
                        if is1d
                            error('do')
                            out=get_fm1d_data('mesh1d_thlyr',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                            if flg.which_v==27
                                out.z=sum(out.z,1)';
                            elseif flg.which_v==14
                                out.z=squeeze(out.z(1,:,:));
                            end
                        else
                            if flg.get_EHY
                                z=get_EHY(file.map,'mesh2d_thlyr',time_dnum,'bed_layers',1:1:in.nl);
                                Ltot=sum(z,3)';
                                ba=get_EHY(file.map,'mesh2d_flowelem_ba',[]);
                                z=ba;
                                z(Ltot<1e-3)=0;
                                out=v2struct(z,face_nodes_x,face_nodes_y);
                            else
                                error('do')
                                z=ncread(file.map,'mesh2d_thlyr',[1,kF(1),kt(1)],[Inf,kF(2),kt(2)]);
                                if flg.which_v==27
                                    z=sum(z,1)';
                                elseif flg.which_v==14
                                    z=z(1,:)';
                                end
                                out=v2struct(z,x_node,y_node,x_face,y_face,faces);
                            end
                        end
                    case 3 %SOBEK3
                        error('check')
                        out=get_sobek3_data('water_level',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
                end
                if flg.which_v==27
                    out.zlabel='total sediment thickness [m]';
                elseif flg.which_v==39
                    out.zlabel='sediment thickness [m]';
                elseif flg.which_v==14
                    out.zlabel='active layer thickness [m]';
                end
            otherwise
                error('ups...')
                
        end %flg.which_v
        
        %%
        %% PATCH
        %%
    case 4 %patch
        %%
        switch simdef.D3D.structure
            case 2 %FM
                if is1d
                    %layer fractions
                    out_lyrfrac=get_fm1d_data('mesh1d_lyrfrac',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id); %mesh1d_nNodes,nBedLayers,nSedTot,time
                    
                    %take out mud fractions
                    %                     idx_bedload=strcmp(sedtype,'bedload');
                    lyrfrac=out_lyrfrac.z;
                    %                     lyrfrac_nomud=out_lyrfrac.z(:,:,idx_bedload);
                    lyrfrac_nomud=out_lyrfrac.z;
                    %                     warning('solve this')
                    
                    %layer thickness
                    out_thlyr=get_fm1d_data('mesh1d_thlyr',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id); %nBedLayers,mesh1d_nNodes,time
                    
                    %reorder
                    nnb=size(out_thlyr.z,2); %number of nNodes in branches to plot
                    thlyr=out_thlyr.z';
                    
                    %bed level
                    out_bl=get_fm1d_data('mesh1d_mor_bl',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id); %{s,t}
                    bl=out_bl.z;
                else
                    error('check')
                    wl=ncread(file.map,'mesh2d_s1',[kF(1),kt(1)],[kF(2),1]);
                    
                    %output
                    out.z=wl;
                    out.x_node=x_node;
                    out.y_node=y_node;
                    out.x_face=x_face;
                    out.y_face=y_face;
                    out.faces=faces;
                    
                end
            case 3 %SOBEK3
                error('check')
                out=get_sobek3_data('water_level',file.map,in,branch,offset,x_node,y_node,branch_length,branch_id);
        end
        out.zlabel='elevation [m]';
        
        eta_subs=cumsum(thlyr,2);
        sub=repmat(bl,1,in.nl+1)-cat(2,zeros(nnb,1),eta_subs);
        
        %mean grain size
        dm=mean_grain_size(lyrfrac_nomud,dchar,mean_type);
        
        %output
        sz=out_lyrfrac.SZ;
        sz_diff=diff(sz);
        %         sz_edges=[sz(1)-sz_diff(1)/2;sz(1)-sz_diff(1)/2+sz(1:end-1)+sz_diff;sz(end)+sz_diff(end)/2];
        sz_edges=[sz(1)-sz_diff(1)/2;sz(1:end-1)-sz_diff(1)/2+sz_diff;sz(end)+sz_diff(end)/2];
        out.XZ=sz_edges';
        out.sub=sub';
        switch flg.which_v
            case 8
                if numel(kf)>1
                    error('you want to plot the volume fraction content of more than one fraction at the same time')
                end
                out.cvar=lyrfrac(:,:,kf)';
            case {3,26}
                out.cvar=dm';
            otherwise
                error('3, 8, or 26')
        end
        out.kf=kf;
        
        
    case 7 % 0D
        LYRFRAC=vs_let(NFStruct,'map-sed-series',{kt},'LYRFRAC',{ky,kx,1:nl,1:nf},'quiet'); %fractions at layers [-] (t,y,x,l,f)
        DP_BEDLYR=vs_let(NFStruct,'map-sed-series',{kt},'DP_BEDLYR',{ky,kx,1:nl+1},'quiet'); %fractions at layers [-] (t,y,x,l)
        DPS=vs_let(NFStruct,'map-sed-series',{kt},'DPS',{ky,kx},'quiet'); %depth at z point [m]
        S1=vs_let(NFStruct,'map-series',{kt},'S1',{ky,kx},'quiet'); %water level at z point [m]
        U1=vs_let(NFStruct,'map-series',{kt},'U1',{ky,kx,1},'quiet'); %velocity in x direction at u point [m/s]
        V1=vs_let(NFStruct,'map-series',{kt},'V1',{ky,kx,1},'quiet'); %velocity in y direction at v point [m/s]
        SBUU=vs_get(NFStruct,'map-sed-series',{kt},'SBUU',{ky,kx,1:nf},'quiet'); %bed load transport excluding pores per fraction in x direction at u point [m3/s]
        SBVV=vs_get(NFStruct,'map-sed-series',{kt},'SBVV',{ky,kx,1:nf},'quiet'); %bed load transport excluding pores per fraction in y direction at v point [m3/s]
        
        dp=S1+DPS; %flow depth
        fIk=find_substrate(LYRFRAC,DP_BEDLYR); %interface
        thklyr=layer_thickness(DP_BEDLYR);
        
        %output
        out.Fak=reshape(LYRFRAC(:,:,:,1,:),1,nf);
        out.La =reshape(thklyr (:,:,:,1,:),1, 1);
        out.fIk=reshape(fIk,1,nf);
        out.SBUU=reshape(SBUU,1,nf);
        out.SBVV=reshape(SBVV,1,nf);
        out.dp=reshape(dp,1,1);
        out.U1=reshape(U1,1,1);
        out.V1=reshape(V1,1,1);
        %%
        %% cross-sections
        %%
    case 10
        mesh1d_mor_crs_z=ncread(file.map,'mesh1d_mor_crs_z',[1,kcs(1),kt(1)],[Inf,kcs(2),kt(2)]); %'time-varying cross-section points level' [m]
        mesh1d_mor_crs_n=ncread(file.map,'mesh1d_mor_crs_n',[1,kcs(1),kt(1)],[Inf,kcs(2),kt(2)]); %'time-varying cross-section points half width' [m]
        mesh1d_mor_crs_name=ncread(file.map,'mesh1d_mor_crs_name',[1,kcs(1)],[Inf,kcs(2)])'; %'name of cross-section'
        
        out.z=mesh1d_mor_crs_z;
        out.n=mesh1d_mor_crs_n;
        out.name=mesh1d_mor_crs_name;
        
        
    otherwise
        %%
        error('ups...')
end

%elliptic output
if flg.which_p~=-1 && flg.elliptic==2
    HIRCHK=ncread(file.map,'mesh2d_hirano_illposed',[kF(1),kt],[kF(2),1]);
    %     switch flg.which_p
    %         case 1
    %             HIRCHK=reshape(HIRCHK,ny,nx);
    %             HIRCHK(1,:)=NaN;
    %             HIRCHK(end,:)=NaN;
    %         case 5
    %             HIRCHK=reshape(HIRCHK(:,:,1:end-2),kt(2),nx-2);
    %             HIRCHK(1,:)=NaN;
    %         case 7 %0D
    %             HIRJCU=vs_let(NFStruct,'map-sed-series',{kt},'HIRJCU',{ky,kx,1:(nf+3+secflow)^2},'quiet'); %Jacobian in u-direction (no sec flow in the indeces!)
    %             HIRJCV=vs_let(NFStruct,'map-sed-series',{kt},'HIRJCV',{ky,kx,1:(nf+3+secflow)^2},'quiet'); %Jacobian in v-direction (no sec flow in the indeces!)
    %
    %             HIRCHK=reshape(HIRCHK,1,1);
    %             out.HIRJCU=reshape(HIRJCU,nf+3+secflow,nf+3+secflow);
    %             out.HIRJCV=reshape(HIRJCV,nf+3+secflow,nf+3+secflow);
    %     end
    out.HIRCHK=HIRCHK;
end

%% OUTPUT FOR ALL

if exist('time_dnum','var')
    out.time_dnum=time_dnum;
end
if exist('time_mor_r','var')
    out.time_mor=time_mor_r;
end
if exist('time_dtime','var')
    out.time_dtime=time_dtime;
end
out.time_r=time_r;

out.kf=kf;

end %main function

%%
%% FUNCTIONS
%%

%%
function dm=mean_grain_size(LYRFRAC,dchar,mean_type)

lyr_s=size(LYRFRAC);
nfaces=lyr_s(1);
nl=lyr_s(2);
nf=lyr_s(3);
try
    nt=lyr_s(4);
catch
    nt=1;
end

aux.m=NaN(nfaces,nl,nf,nt);
for kf=1:nf
    aux.m(:,:,kf,:)=dchar(kf).*ones(nfaces,nl,1,nt);
end

switch mean_type
    case 1
        dm=2.^(sum(LYRFRAC.*log2(aux.m),3));
    case 2
        dm=sum(LYRFRAC.*aux.m,3);
end

%remove values in which all fractions are 0
lyrfrac_s=sum(LYRFRAC,3);
dm(lyrfrac_s==0)=NaN;

end %function mean_grain_size

%%

function fIk=find_substrate(LYRFRAC,DP_BEDLYR)

lyr_s=size(LYRFRAC);
nT=lyr_s(1);
ny=lyr_s(2);
nx=lyr_s(3);
% nl=lyr_s(4);
nf=lyr_s(5);

thklyr=layer_thickness(DP_BEDLYR);
fIk=NaN(nT,ny,nx,1,nf);
for kkt=1:nT
    for kky=1:ny
        for kkx=1:nx
            kks=find(thklyr(kkt,kky,kkx,2:end),1,'first')+1;
            if isempty(kks)
                fIk(kkt,kky,kkx,1,:)=NaN;
            else
                fIk(kkt,kky,kkx,1,:)=LYRFRAC(kkt,kky,kkx,kks,:);
            end
        end
    end
end

end

%%

function thklyr=layer_thickness(DP_BEDLYR)

thklyr=diff(DP_BEDLYR,1,4);

end

%%

function HIRCHK_cumulative=cumulative_elliptic(HIRCHK)

HIRCHK_cumulative=squeeze(nansum(HIRCHK,1));
HIRCHK_cumulative(HIRCHK_cumulative>1)=1;

end

%%

function [z_br,o_br,cord_br]=get_data_from_branches(z,in,branch,offset,x_node,y_node,branch_length,branch_id)

branch_2p_idx=get_branch_idx(in.branch,branch_id);

%in FM1D, the branch id start at 0, while is starts at 1 in SOBEK3
% cte_br=1;
% if isempty(find(branch==0,1)) %sobek3;
%     cte_br=0;
% end

%in FM1D, the branch id start at 0, while is starts at 1 in SOBEK3
cte_br=0;
if ~isempty(find(branch==0,1)) %fm;
    branch_2p_idx=branch_2p_idx-1;
    cte_br=1;
end

nb=numel(branch_2p_idx);

z_br=[];
cord_br=[];
o_br=[];
last_dx_bm1=0;
o_br_end_bm1=0;

zsize=size(z);
ndim=numel(zsize);
dim_s=zsize==numel(branch);
idx_dim_s=find(dim_s);

for kb=1:nb
    idx_br=branch==branch_2p_idx(kb); %logical indexes of intraloop branch
    br_length=branch_length(branch_2p_idx(kb)+cte_br); %total branch length. As the branches start counting on 0, in position n+1 we find the length of branch n.
    
    %this is really ugly and there must be a simple way to do it. sorry, I
    %am in a rush :)
    switch ndim
        case 1
            z_a1=z(idx_br);
        case 2
            switch idx_dim_s
                case 1
                    z_a1=z(idx_br,:);
                case 2
                    z_a1=z(:,idx_br);
                otherwise
                    error('ups... check where are the dimensions of the streamwise coordinate')
            end
        case 3
            switch idx_dim_s
                case 1
                    z_a1=z(idx_br,:,:);
                case 2
                    z_a1=z(:,idx_br,:);
                case 3
                    z_a1=z(:,:,idx_br);
                otherwise
                    error('ups... check where are the dimensions of the streamwise coordinate')
            end
        case 4
            switch idx_dim_s
                case 1
                    z_a1=z(idx_br,:,:,:);
                case 2
                    z_a1=z(:,idx_br,:,:);
                case 3
                    z_a1=z(:,:,idx_br,:);
                case 4
                    z_a1=z(:,:,:,idx_br);
                otherwise
                    error('ups... check where are the dimensions of the streamwise coordinate')
            end
        otherwise
            error('ups... more dimensions than I thought')
    end
    
    if isempty(z_a1)
        error('Branch %s has no computational nodes',branch_id(branch_2p_idx(kb)+cte_br,:))
        %
        %        figure
        %        plot(branch,'-*')
    end
    
    o_a1=offset(idx_br);
    last_dx=br_length-o_a1(end);
    
    %     switch idx_dim_s
    %         case 1
    %             z_ba=cat(1,z_br,z_a1);
    %         case 2
    %             z_ba=cat(1,z_br,z_a1);
    %         otherwise
    %             error('ups... check where are the dimensions of the streamwise coordinate')
    %     end
    
    z_ba=cat(idx_dim_s,z_br,z_a1);
    z_br=z_ba;
    %     z_br=[z_br;z_a1];
    o_br=[o_br;o_a1+o_br_end_bm1+last_dx_bm1];
    
    last_dx_bm1=last_dx;
    o_br_end_bm1=o_br(end);
    
    x_node_a1=x_node(idx_br);
    y_node_a1=y_node(idx_br);
    cord_br=[cord_br;[x_node_a1,y_node_a1]];
    
end

% o_br=o_br(2:end);

% np=size(cord_br,1);
% o_br=zeros(np,1);
% for kp=2:np
%     o_br(kp)=o_br(kp-1)+sqrt((cord_br(kp,1)-cord_br(kp-1,1)).^2+(cord_br(kp,2)-cord_br(kp-1,2))^2);
% end

%test uniqueness
% o_u=unique(o_br);
% ndiff=numel(o_u)-numel(o_br);
% if ndiff~=0
%     error('offset has repeated values')
% end

end

%%

function branch_length=branch_length_sobek3(offset,branch)

branch_2p_idx=unique(branch);
nb=numel(branch_2p_idx);

branch_length=NaN(nb,1);

for kb=1:nb
    idx_br=branch==branch_2p_idx(kb); %logical indexes of intraloop branch
    off_br=offset(idx_br);
    branch_length(kb,1)=off_br(end);
end

end %function

%%

function out=get_fm1d_data(tag_read,file_map,in,branch,offset,x_node,y_node,branch_length,branch_id)

kf=in.kf;
kt=in.kt;

%it does not matter whether it is nodes or edges
switch tag_read
    case {'mesh1d_flowelem_bl','mesh1d_flowelem_ba','mesh1d_mor_width_u','mesh1d_node_offset'} %{s}
        wl=ncread(file_map,tag_read,1,Inf);
    case {'mesh1d_sbcx','mesh1d_sbcy','mesh1d_sbcx_reconstructed','mesh1d_sbcy_reconstructed','mesh1d_sscx_reconstructed','mesh1d_sscy_reconstructed','mesh1d_sbn','mesh1d_sbt'} %{s,f,t}
        wl=ncread(file_map,tag_read,[1,1,kt(1)],[Inf,Inf,kt(2)]);
    case {'mesh1d_waterdepth','mesh1d_s1','mesh1d_umod','mesh1d_mor_bl','mesh1d_q1_main','mesh1d_q1','mesh1d_dm','mesh1d_ucmag','mesh1d_dg','mesh1d_bl_ave','mesh1d_czs','mesh1d_taus'} %mesh1d_nNodes,time
        wl=ncread(file_map,tag_read,[1,kt(1)],[Inf,kt(2)]);
    case {'mesh1d_lyrfrac'} %mesh1d_nNodes,nBedLayers,nSedTot,time
        wl=ncread(file_map,tag_read,[1,1,1,kt(1)],[Inf,Inf,Inf,kt(2)]);
    case {'mesh1d_thlyr'} %nBedLayers,mesh1d_nNodes,time
        wl=ncread(file_map,tag_read,[1,1,kt(1)],[Inf,Inf,kt(2)]);
    case {'mesh1d_msed'} %nSedTot,nBedLayers,mesh1d_nNodes,time
        wl=ncread(file_map,tag_read,[1,1,1,kt(1)],[Inf,Inf,Inf,kt(2)]);
    otherwise
        error('indicate for %s variable what the size is',tag_read)
end

[wl_br,o_br,cord_br]=get_data_from_branches(wl,in,branch,offset,x_node,y_node,branch_length,branch_id);

%output
out.z=wl_br;
out.XZ=cord_br(:,1);
out.YZ=cord_br(:,2);
out.SZ=o_br;

%convert to river km
if isfield(in,'path_rkm')
    rkm_br=convert2rkm(in.path_rkm,cord_br,'TolMinDist',in.rkm_TolMinDist);
    out.SZ=rkm_br;
end

end %function

%%

function out=get_sobek3_data(tag_read,file_map,in,branch,offset,x_node,y_node,branch_length,branch_id)

kt=in.kt;

% wl=ncread(file_map,tag_read,[1,kt(1)],[Inf,1]);
wl=ncread(file_map,tag_read,[1,kt(1)],[Inf,kt(2)]);

[wl_br,o_br]=get_data_from_branches(wl,in,branch,offset,x_node,y_node,branch_length,branch_id);
[~,u_idx,~]=unique(o_br);
wl_o=wl_br(u_idx,:);
o_o=o_br(u_idx);

%output
out.z=wl_o;
out.XZ=x_node(u_idx);
out.YZ=y_node(u_idx);
out.SZ=o_o;

end %function

%%

function val=get_EHY(file_map,vartok,time_dnum,varargin)

OPT.varName=vartok;
if ~isempty(time_dnum)
    OPT.t0=time_dnum(1);
    OPT.tend=time_dnum(end);
end
OPT.disp=0;
OPT.bed_layers=0;

OPT=setproperty(OPT,varargin{:});

map_data=EHY_getMapModelData(file_map,OPT);
if numel(size(map_data.val))==2
    val=map_data.val';
else
    val=map_data.val;
end

end