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

function out=NC_read_his(simdef,in)

%% RENAME in

file=simdef.file;
if isfield(simdef,'flg')
    flg=simdef.flg;
end

kt=in.kt;    
if kt==0 %only give domain size as output
    error('do we get here?')
%     flg.which_v=-1;
    flg.which_p=-1;
else
%     ky=in.ky;
%     kx=in.kx; 
    if isfield(in,'kf')
        kf=in.kf;
    else
        kf=NaN;
    end
    
    nF=numel(kf);
    out.nF=nF;
    
end

if isfield(flg,'mean_type')==0
    mean_type=2; %log2
else
    mean_type=flg.mean_type; 
end

if isfield(flg,'elliptic')==0
    flg.elliptic=0;
end

if numel(kt)==2 && kt(2)==1
    warning('you want to plot one single time for a history file. that is weird')
end

%% LOAD

%HELP
% file.his='c:\Users\chavarri\temporal\D3D\runs\P\035\DFM_OUTPUT_sim_P035\sim_P035_map.nc';
% ncdisp(file.his)

    %% time, space, fractions
if flg.which_p~=-1
    %time
    ITMAPC=ncread(file.his,'time'); %results time vector
    time_r=ITMAPC; %results time vector [s]
%     TUNIT=vs_let(NFStruct,'map-const','TUNIT','quiet'); %dt unit
%     DT=vs_let(NFStruct,'map-const','DT','quiet'); %dt
%     time_r=ITMAPC*DT*TUNIT; %results time vector [s]
    
    %space
switch simdef.D3D.structure
    case 2 %FM
        
        %station or area
        switch flg.which_v
            case {1,11,12,18} %variables that are at stations
                where_is_var=1; %default is station
            case 22 %variables that are area
                where_is_var=2;
            case 24 %variables that are at cross sections
                where_is_var=3;
            otherwise
                error('specify where is this variable')
        end
        
        switch where_is_var
            case 1
                sdc_name=ncread(file.his,'station_name')';
            case 2
                sdc_name=ncread(file.his,'dump_area_name')';
            case 3
                sdc_name=ncread(file.his,'cross_section_name')';
        end

        if in.nfl~=1
            zcoordinate_c=ncread(file.his,'zcoordinate_c',[1,sdc_2p_idx,kt(1)],[Inf,1,numel(kt)]);
        end
        
    case 3 %SOBEK
        
        sdc_name=ncread(file.his,'observation_id')';
end
    
% switch where_is_var
%     case 1
        sdc_2p_idx=get_branch_idx(in.station,sdc_name);    
%     case 2
%         sdc_2p_idx=get_branch_idx(in.dump_area,sdc_name);
%     case 3
%         sdc_2p_idx=get_branch_idx(in.crs,sdc_name);
% end

if numel(sdc_2p_idx)>1
    error('You cannot read information from more than one station at the same time')
end

    %sediment
if isfield(file,'sed')
    dchar=D3D_read_sed(simdef.file.sed);
end

if isfield(file,'mor')
mor_in=delft3d_io_mor(file.mor);
end

%some interesting output...
if exist('mor_in','var')
if isfield(mor_in.Morphology0,'MorFac')
out.MorFac=mor_in.Morphology0.MorFac;
end
if isfield(mor_in.Morphology0,'MorStt')
out.MorStt=mor_in.Morphology0.MorStt;
end
end

end
    %% vars

%get coordinate of stations in case of SOBEK-3
tol_obs_sta=250; %tolerance for accepting station (in units od coordinates), very adhoc

if simdef.D3D.structure
    x_cord=ncread(file.map,'x_coordinate');    
    y_cord=ncread(file.map,'y_coordinate');    
    branchid=ncread(file.map,'branchid');
    chainage=ncread(file.map,'chainage');
    
    branchid_obs=ncread(file.his,'branchid',sdc_2p_idx,1);
    chainage_obs=ncread(file.his,'chainage',sdc_2p_idx,1);
    
    idx_br=find(branchid==branchid_obs);
    [min_va,min_idx]=min((abs(chainage(idx_br)-chainage_obs)));
    if min_va>tol_obs_sta
        warning('The station %s is at %f m from the coordinate given as output',sdc_name(sdc_2p_idx,:),min_va)
    end
    out.X=x_cord(idx_br(min_idx));
    out.Y=y_cord(idx_br(min_idx));
end

switch flg.which_p
    case {'a','b'}
        %common output
        out.time_r=time_r(kt(1):kt(2)); 
        switch flg.which_v
                            
            case 1 %bed level
                switch simdef.D3D.structure
                    case 2
                        z=ncread(file.his,'bedlevel',[sdc_2p_idx,kt(1)],[1,kt(2)]);
                    case 3
                        error('')
%                         wl=ncread(file.his,'water_discharge',[sdc_2p_idx,kt(1)],[1,kt(2)]);
                end
                %output
                out.z=z;
                out.zlabel='bed level [m]';
                out.station=sdc_name(sdc_2p_idx,:);
            case 11 %velocity
                vx=ncread(file.his,'x_velocity',[1,sdc_2p_idx,kt(1)],[Inf,1,kt(2)]);
                vy=ncread(file.his,'y_velocity',[1,sdc_2p_idx,kt(1)],[Inf,1,kt(2)]);
                vz=ncread(file.his,'z_velocity',[1,sdc_2p_idx,kt(1)],[Inf,1,kt(2)]);
                
                out.z=[vx,vy,vz];
                out.zcoordinate_c=zcoordinate_c;
%                 out.time_r=time_r(kt(1):kt(2)); 
                out.zlabel='velocity [m/s]';                
            case 12 %water level
                switch simdef.D3D.structure
                    case 2
                        wl=ncread(file.his,'waterlevel',[sdc_2p_idx,kt(1)],[1,kt(2)]);
                    case 3
                        wl=ncread(file.his,'water_level',[sdc_2p_idx,kt(1)],[1,kt(2)]);
                end
                %output
                out.z=wl;
%                 out.time_r=time_r(kt(1):kt(2)); 
                out.zlabel='water level [m]';
                out.station=sdc_name(sdc_2p_idx,:);
            case 18 %water discharge
                switch simdef.D3D.structure
                    case 2
                        wl=ncread(file.his,'cross_section_discharge',[sdc_2p_idx,kt(1)],[1,kt(2)]);
                    case 3
                        wl=ncread(file.his,'water_discharge',[sdc_2p_idx,kt(1)],[1,kt(2)]);
                end
                
                %output
                out.z=wl;
%                 out.time_r=time_r(kt(1):kt(2)); 
                out.zlabel='water discharge [m^3/s]';
                out.station=sdc_name(sdc_2p_idx,:);
            case 22 %dredged volume
                wl=ncread(file.his,'dump_discharge',[1,kt(1)],[ndump,kt(2)]);
                wl=wl(sdc_2p_idx,:);

                %output
                out.z=wl;
%                 out.time_r=time_r(kt(1):kt(2)); 
                out.dump_area=in.dump_area;
                out.zlabel='nourished volume [m^3]';
            case 24 %cumulative bedload
                switch simdef.D3D.structure
                    case 2
                        wl=ncread(file.his,'cross_section_bedload_sediment_transport',[sdc_2p_idx,kt(1)],[1,kt(2)]);
                    case 3
                        error('')
                        wl=ncread(file.his,'water_discharge',[sdc_2p_idx,kt(1)],[1,kt(2)]);
                end
                
                %output
                out.z=wl;
%                 out.time_r=time_r(kt(1):kt(2)); 
                out.zlabel='cumulative bed load sediment transport [kg]';
                out.station=sdc_name(sdc_2p_idx,:);                
            otherwise
                error('This variable has no his data')
        end

end
