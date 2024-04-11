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
%Write boundary condition per cell. Based on a map-file and 
%a cross-section (for links) and observation station (for cell centre)
%files, it finds the location in the map from which to extract the 
%information and write the boundary conditions files. 
%
%Wout and Willem made a first version. 
%
%INPUT:
%   -obs-file upstream and downstream station from each cell.
%   -crs-file at each cell.
%   -map-file
%
%OUTPUT:
%   -BC files
%

function write_subdomain_bc(fpath_map,fpath_crs,fpath_obs,fpath_ext,fdir_out,fpathrel_bc,fpathrel_pli,fname_h,fname_q,time_start,is_upstream,varargin)

%% PARSE

%Option select either upstream or downstream water level. 
%Future: read information from obs-file

% parin=inputParser;
% 
% addOptional(parin,'xlsx_range','');
% 
% parse(parin,varargin{:});
% 
% xlsx_range=parin.Results.xlsx_range;

if isempty(fpath_map) || ~isfile(fpath_map)
    error('Please input map file.')
end

%% CALC

messageOut(NaN,'Start getting indices.')
[obs,crs]=get_idx_grid_pli(fpath_map,fpath_crs,fpath_obs,varargin{:});

messageOut(NaN,'Start getting data.')
[obs,crs,time_v]=extract_map_info(fpath_map,obs,crs);

messageOut(NaN,'Start writing water level boundary.')
bc_h=write_h_bc(obs,fdir_out,time_start,time_v,is_upstream,fname_h);

messageOut(NaN,'Start writing discharge boundary.')
bc_q=write_q_bc(crs,fdir_out,time_start,time_v,fname_q);

messageOut(NaN,'Start writing polylines.')
write_pli(crs,fdir_out)

messageOut(NaN,'Start writing external file.')
write_ext(fpath_ext,bc_h,bc_q,fdir_out,fpathrel_bc,fpathrel_pli,fname_h,fname_q)

messageOut(NaN,'Done.')

end %function

%%
%% FUNCTIONS
%%

%%  

function [obs,crs]=get_idx_grid_pli(fpath_map,fpath_crs,fpath_obs,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'delimiter','\t');

parse(parin,varargin{:});

delimiter=parin.Results.delimiter;

%% CALC

%read grid
gridInfo=EHY_getGridInfo(fpath_map,{'XYcen','XYuv'}); 
xcen_ehy=gridInfo.Xcen;
ycen_ehy=gridInfo.Ycen;
xedg_ehy=gridInfo.Xu;
yedg_ehy=gridInfo.Yu;

%`edge_faces` from EHY cannot be used because it is a local of every partitioned grid and there is an inconsistency. 
[edge_face,xcen_raw,ycen_raw,xedg_raw,yedg_raw,~,faces_local]=D3D_edge_faces(fpath_map);

%% obs
obs=D3D_io_input('read',fpath_obs,'delimiter',delimiter,'v',2);
nobs=numel(obs);
for kobs=1:nobs
    x=obs(kobs).xy(1);
    y=obs(kobs).xy(2);
    dist=hypot(xcen_ehy-x,ycen_ehy-y);
    [idx,~]=absmintol(dist,0,'do_disp_list',0,'tol',12,'do_break',1);
    obs(kobs).idx=idx; %EHY index of cell centre
end %kobs
xy_obs_all=reshape([obs.xy],2,[])';

%% crs
crs=D3D_io_input('read',fpath_crs);
ncrs=numel(crs);
for kcrs=1:ncrs
    x=mean(crs(kcrs).xy(:,1));
    y=mean(crs(kcrs).xy(:,2));
    dist=hypot(xedg_ehy-x,yedg_ehy-y);
    [idx_edg,~]=absmintol(dist,0,'do_disp_list',0,'tol',12,'do_break',1);
    crs(kcrs).idx=idx_edg; %EHY index of link

    %direction
    dist=hypot(xedg_raw-x,yedg_raw-y);
    [idx_edg_raw,~]=absmintol(dist,0,'do_disp_list',0,'tol',12,'do_break',1); %index of the link closest in raw coordinates

    idx_faces=edge_face(idx_edg_raw,:); %index of faces connected by the link in raw coordinates. Because it is a local variable, there are as many possible faces as partitions. 

    idx_faces_possible=find(faces_local==idx_faces(1)); %global index of possible origin faces connected by the link

    x_possible=xcen_raw(idx_faces_possible);
    y_possible=ycen_raw(idx_faces_possible);

    dist=hypot(x_possible-x,y_possible-y); 
    [idx_obs_1_loc,~]=absmintol(dist,0,'do_disp_list',0,'tol',40,'do_break',1); %index of origin face from the possible ones that is closest to the link in raw coordinates.

    x_obs=x_possible(idx_obs_1_loc); %x coordinate of the observation station that is origin of the link.
    y_obs=y_possible(idx_obs_1_loc); %y coordinate of the observation station that is origin of the link.

    dist=hypot(xy_obs_all(:,1)-x_obs,xy_obs_all(:,2)-y_obs); 
    idx_obs=absmintol(dist,0,'do_disp_list',0,'tol',40,'do_break',1); %index of the observation station list associated to the observation station that is origin of the link.

    obs_name=obs(idx_obs).name;
    bol=str2double(obs_name(3))==1; %true => the observation station has a 1. Hence, the origin face is upstream.
    dir=1; %link goes from upstream to downstream
    if ~bol
        dir=-1; %link goes from downstream to upstream
    end
    crs(kcrs).direction=dir;

    crs(kcrs).name=strrep(crs(kcrs).name,'C_','');

    %% DEBUG

%     figure
%     hold on
%     scatter(xcen_v,ycen_v)
%     x=xy_obs_all(idx_obs,1);
%     y=xy_obs_all(idx_obs,2);
%     scatter(x,y,'r','s')
%     plot(crs(kcrs).xy(:,1),crs(kcrs).xy(:,2),'LineWidth',2,'color','g')
%     axis equal
%     xlim([x-100,x+100])
%     ylim([y-100,y+100])
%     title(sprintf('%d',crs(kcrs).direction))
%     pause(0.5)
%     close all

end

end %function

%%

function [obs,crs,time_v]=extract_map_info(fpath_map,obs,crs)

data_q=EHY_getMapModelData(fpath_map,'varName','mesh2d_q1');
ncrs=numel(crs);
for kcrs=1:ncrs
    crs(kcrs).q=data_q.val(:,crs(kcrs).idx);
end

data_s1=EHY_getMapModelData(fpath_map,'varName','mesh2d_s1');
data_bl=EHY_getMapModelData(fpath_map,'varName','bl');
nobs=numel(obs);
for kobs=1:nobs
    obs(kobs).s1=data_s1.val(:,obs(kobs).idx);
    obs(kobs).bl=data_bl.val(obs(kobs).idx);
end

time_v=data_q.times;

end %function

%%

function bc=write_h_bc(obs,fdir_out,time_start,time_v,is_upstream,fname_h)

nobs=numel(obs);
ks=0;
for kobs=1:nobs
    name=deblank(obs(kobs).name);
    if (strcmp(name(3),'1') && is_upstream) || (strcmp(name(3),'2') && ~is_upstream)
        continue
    end
    ks=ks+1;
    name(1:4)='';
    bc(ks).name=name;
    bc(ks).function='time_series';
    bc(ks).time_interpolation='linear';
    bc(ks).quantity{1}='time';
    bc(ks).unit{1}=sprintf('seconds since %s %s',string(time_start,'yyyy-MM-dd HH:mm:ss'),time_start.TimeZone);
    bc(ks).quantity{2}='waterlevelbnd';
    bc(ks).unit{2}='m';

    %replace NaN values with bed level values
    val=obs(kobs).s1;
    bol_nan=isnan(val);
    val(bol_nan)=obs(kobs).bl;

    bc(ks).val=[time_v,val];
end

fpath=fullfile(fdir_out,sprintf('%s.bc',fname_h));
D3D_write_bc(fpath,bc)

end %function

%%

function bc=write_q_bc(crs,fdir_out,time_start,time_v,fname_q)

ncrs=numel(crs);
for kcrs=1:ncrs    
    bc(kcrs).name=deblank(crs(kcrs).name);
    bc(kcrs).function='time_series';
    bc(kcrs).time_interpolation='linear';
    bc(kcrs).quantity{1}='time';
    bc(kcrs).unit{1}=sprintf('seconds since %s %s',string(time_start,'yyyy-MM-dd HH:mm:ss'),time_start.TimeZone);
    bc(kcrs).quantity{2}='dischargebnd';
    bc(kcrs).unit{2}='m3/s';

    val=crs(kcrs).direction.*crs(kcrs).q; %if the link goes from downstream to upstream, a negative discharge must be positive.

    bc(kcrs).val=[time_v,val];
end

fpath=fullfile(fdir_out,sprintf('%s.bc',fname_q));
D3D_write_bc(fpath,bc)

end %function

%%

function write_pli(crs,fdir_out)

ncrs=numel(crs);
for kcrs=1:ncrs
    name=crs(kcrs).name;
    pli(kcrs).name=name;
    pli(kcrs).xy=crs(kcrs).xy;

    %write in individual files
    fpath=fullfile(fdir_out,sprintf('%s.pli',name));
    D3D_io_input('write',fpath,pli(kcrs))
end %kcrs

end %function

%%

function write_ext(fpath_ext,bc_h,bc_q,fdir_out,fpathrel_bc,fpathrel_pli,fname_h_bc,fname_q_bc)

if ~strcmp(fpathrel_bc(end),'\') && ~strcmp(fpathrel_bc(end),'/')
    fpathrel_bc(end)='/';
end

ext=D3D_io_input('read',fpath_ext);
fn=fieldnames(ext);
kboundary=sum(contains(fn,'boundary'));

ext=add_ext(ext,kboundary,bc_h,'waterlevelbnd',fpathrel_pli,fpathrel_bc,fname_h_bc); %h
ext=add_ext(ext,kboundary,bc_q,'dischargebnd',fpathrel_pli,fpathrel_bc,fname_q_bc); %q

fpath=fullfile(fdir_out,'ext.ext');
D3D_io_input('write',fpath,ext);

end %function

%% 

function [edge_face_all,face_x_all,face_y_all,edge_x_all,edge_y_all,domain_all,faces_local]=D3D_edge_faces(fpath_map)

edge_face_all=[];
edge_x_all=[];
edge_y_all=[];
face_x_all=[];
face_y_all=[];
domain_all=[];

ncFiles=EHY_getListOfPartitionedNcFiles(fpath_map);
npart=numel(ncFiles);

for k=1:npart
    if npart>1
        fpath_map_loc=strrep(fpath_map,'_0000_map.nc',sprintf('_%04d_map.nc',k-1));
    else
        fpath_map_loc=fpath_map;
    end
    edge_face=ncread(fpath_map_loc,'mesh2d_edge_faces');
    edge_x=ncread(fpath_map_loc,'mesh2d_edge_x');
    edge_y=ncread(fpath_map_loc,'mesh2d_edge_y');
    face_x=ncread(fpath_map_loc,'mesh2d_face_x');
    face_y=ncread(fpath_map_loc,'mesh2d_face_y');

    edge_face_all=cat(1,edge_face_all,edge_face');
    edge_x_all=cat(1,edge_x_all,edge_x);
    edge_y_all=cat(1,edge_y_all,edge_y);
    face_x_all=cat(1,face_x_all,face_x);
    face_y_all=cat(1,face_y_all,face_y);
    domain_all=cat(1,domain_all,(k-1).*ones(size(face_x)));
end

ndom=max(domain_all)+1; %number of domains
faces_local=NaN(size(domain_all));
for kdom=1:ndom
    bol_dom=domain_all==kdom-1;
    faces_local(bol_dom)=1:1:sum(bol_dom);
end

end

%%

function ext=add_ext(ext,kboundary,bc_h,str,fpathrel_pli,fpathrel_bc,fname_h_bc)

nbch=numel(bc_h);
for kbch=1:nbch
    kboundary=kboundary+1;

    fnloc=sprintf('boundary%i',kboundary);
    ext.(fnloc).quantity=str;
    ext.(fnloc).locationfile=sprintf('%s%s.pli',fpathrel_pli,bc_h(kbch).name);
    ext.(fnloc).forcingfile=sprintf('%s%s.bc',fpathrel_bc,fname_h_bc);
end %kbch

end %function