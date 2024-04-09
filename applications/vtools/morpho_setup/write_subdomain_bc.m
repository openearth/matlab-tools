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
% function write_subdomain_bc(Upstream, Downstream, Case, Case_type, crsfile, obsfile, shapefile, orderflwfile, fpath_project, ncfilepath)
function write_subdomain_bc(fpath_map,fpath_crs,fpath_obs,fdir_out,time_start,is_upstream,varargin)

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

[obs,crs]=get_idx_grid_pli(fpath_map,fpath_crs,fpath_obs,varargin{:});
 
[obs,crs,time_v]=extract_map_info(fpath_map,obs,crs);
 
write_h_bc(obs,fdir_out,time_start,time_v,is_upstream);

write_q_bc(crs,fdir_out,time_start,time_v);

write_pli(crs,fdir_out)

%%
%%
% %% CALC

% [orderflw,flowlinkQ]=write_pli(crs_seg,orderflwfile,fpath_bc);
% 
% [Qobs,hobs]=read_obs(obsfile,Qpli,hpli);
% 
% %
% read_map()
% 
% write_q()
% 
% write_h()
% 
% write_ext()

end %function

%%
%% FUNCTIONS
%%
% 
function [obs,crs]=get_idx_grid_pli(fpath_map,fpath_crs,fpath_obs,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'delimiter','\t');

parse(parin,varargin{:});

delimiter=parin.Results.delimiter;

%% CALC

%read grid
gridInfo=EHY_getGridInfo(fpath_map,{'XYcen','XYuv'}); 
obs=D3D_io_input('read',fpath_obs,'delimiter',delimiter,'v',2);

edge_face=EHY_getMapModelData(fpath_map,'varName','mesh2d_edge_faces');
edge_face=edge_face.val;
dom=EHY_getMapModelData(fpath_map,'varName','mesh2d_flowelem_domain');
dom=dom.val;
face_x=EHY_getMapModelData(fpath_map,'varName','mesh2d_face_x');
face_x=face_x.val;
face_y=EHY_getMapModelData(fpath_map,'varName','mesh2d_face_y');
face_y=face_y.val;
edge_x=EHY_getMapModelData(fpath_map,'varName','mesh2d_edge_x');
edge_x=edge_x.val;
edge_y=EHY_getMapModelData(fpath_map,'varName','mesh2d_edge_y');
edge_y=edge_y.val;

% xcen_v=gridInfo.Xcen;
% ycen_v=gridInfo.Ycen;
% 
% xedg_v=gridInfo.Xu;
% yedg_v=gridInfo.Yu;

xcen_v=face_x;
ycen_v=face_y;

xedg_v=edge_x;
yedg_v=edge_y;

% test=EHY_getMapModelData(fpath_map,'varName','mesh2d_edge_x');

% edge_x=ncread(fpath_map,'mesh2d_edge_x');
% edge_y=ncread(fpath_map,'mesh2d_edge_y');

% edge_faces=ncread(fpath_map,'mesh2d_edge_faces');
% face_x=ncread(fpath_map,'mesh2d_face_x');
% face_y=ncread(fpath_map,'mesh2d_face_y');

%%

% figure
% hold on
% 
% scatter(edge_x(l),edge_y(l));
% scatter(face_x(edge_faces(:,l)),face_y(edge_faces(:,l)))
% 
% %%
% % figure
% % hold on
% % l=500000;
% % scatter(gridInfo.Xu(l),gridInfo.Yu(l))
% % scatter(gridInfo.Xcen(edge_face(l,:)),gridInfo.Ycen(edge_face(l,:)))
% 
% %%
% 
% figure
% hold on
% l=500000;
% scatter(edge_x(l),edge_y(l))
% scatter(face_x(edge_face(l,:)),face_y(edge_face(l,:)))


%%

ndom=max(dom)+1; %number of domains
% faces_local=NaN(size(gridInfo.Xcen));
faces_local=NaN(size(dom));
for kdom=1:ndom
    bol_dom=dom==kdom-1;
    faces_local(bol_dom)=1:1:sum(bol_dom);
end


%obs
nobs=numel(obs);
for kobs=1:nobs
    x=obs(kobs).xy(1);
    y=obs(kobs).xy(2);
    dist=hypot(xcen_v-x,ycen_v-y);
    [idx,min_v]=absmintol(dist,0,'do_disp_list',0,'tol',12,'do_break',1);
    obs(kobs).idx=idx;
end %kobs
idx_obs=[obs.idx];

%no problem if duplicate stations. There is a 90 degrees turn in the pli. 
% idx_obs_u=unique(idx_obs);
% if numel(idx_obs_u)~=numel(idx_obs)
%     messageOut(NaN,'There are two observation stations associated to the same cell.')
% end

%crs
crs=D3D_io_input('read',fpath_crs);
ncrs=numel(crs);
for kcrs=1:ncrs
    x=mean(crs(kcrs).xy(:,1));
    y=mean(crs(kcrs).xy(:,2));
    dist=hypot(xedg_v-x,yedg_v-y);
    [idx_edg,min_v]=absmintol(dist,0,'do_disp_list',0,'tol',12,'do_break',1);
    crs(kcrs).idx=idx_edg;   

    %direction
    %`edge_faces` cannot be used because it is a local of every partitioned grid. 
    %by construction, the closest two stations must be upstream and downstream from the link. 
    dist=hypot(xcen_v-x,ycen_v-y);
    [idx,min_v]=absmintol(dist,0,'do_disp_list',0,'tol',40,'do_break',1); %idx of global faces

    idx_faces=edge_face(idx_edg,:); %local faces

    idx_faces_possible=find(faces_local==idx_faces(1));

    x_possible=xcen_v(idx_faces_possible);
    y_possible=ycen_v(idx_faces_possible);



%     dom(idx) %domain number
%     xcen_v(idx)
% 
    idx_obs_2=find(idx_obs==idx);
    idx_obs_2=idx_obs_2(1); %remove duplicate
%     obs_name=obs(idx_obs_2).name;
%     obs(idx_obs_2).xy
    
end %kcrs

%% DEBUG

xy_obs_all=reshape([obs.xy],2,[])';
figure
hold on
scatter(gridInfo.Xcen,gridInfo.Ycen)
% scatter(face_x.val,face_y.val,'x')
scatter(x_possible,y_possible,'x')
scatter(xy_obs_all(:,1),xy_obs_all(:,2))
% scatter(xy_obs_all(idx_obs_2,1),xy_obs_all(idx_obs_2,2),'r','s')
% for kcrs=1:ncrs
plot(crs(kcrs).xy(:,1),crs(kcrs).xy(:,2),'LineWidth',2,'color','g')
% scatter(gridInfo.Xu(crs(kcrs).idx),gridInfo.Yu(crs(kcrs).idx),'m','x')
% scatter(gridInfo.Xu(crs(kcrs).idx),gridInfo.Yu(crs(kcrs).idx),'m','x')
% face_loc=edge_face(crs(kcrs).idx,:);
% scatter(gridInfo.Xcen(face_loc),gridInfo.Ycen(face_loc),'r','s')
% end

axis equal

%%
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

function write_h_bc(obs,fdir_out,time_start,time_v,is_upstream)

nobs=numel(obs);
ks=0;
for kobs=1:nobs
%     bc(kbc).name=strrep(deblank(hobs(k).Name),'O_1_', 'C_');
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

fpath=fullfile(fdir_out,'h.bc');
D3D_write_bc(fpath,bc)

end %function

%%

function write_q_bc(crs,fdir_out,time_start,time_v)

ncrs=numel(crs);
for kcrs=1:ncrs
%     bc(kcrs).name=strrep(deblank(crs(kcrs).Name),'O_1_', 'C_');
    
    bc(kcrs).name=deblank(crs(kcrs).name);
    bc(kcrs).function='time_veries';
    bc(kcrs).time_interpolation='linear';
    bc(kcrs).quantity{1}='time';
    bc(kcrs).unit{1}=sprintf('seconds since %s %s',string(time_start,'yyyy-MM-dd HH:mm:ss'),time_start.TimeZone);
    bc(kcrs).quantity{2}='dischargebnd';
    bc(kcrs).unit{2}='m3/s';

    bc(kcrs).val=[time_v,crs(kcrs).q];
end

fpath=fullfile(fdir_out,'q.bc');
D3D_write_bc(fpath,bc)

end %function

%%

function write_pli(crs,fdir_out)

ncrs=numel(crs);
for kcrs=1:ncrs
    name=strrep(crs(kcrs).name,'C_','');
    pli.name=name;
    pli.xy=crs(kcrs).xy;
    fpath=fullfile(fdir_out,sprintf('%s.pli',name));
    D3D_io_input('write',fpath,pli)
end %kcrs

end %function

%%

function [orderflw,flowlinkQ]=write_pli_old(crs_seg,orderflwfile,fpath_bc)

crs_seg = tekal('read', crsfile, 'loaddata');

% Initialize a new struct to store matching entries
Qpli = struct('Name', {}, 'Data', {});
hpli = struct('Name', {}, 'Data', {});
flowlinkQ = struct('Complete', {}, 'P0000', {}, 'P0001', {}, 'P0002', {},'P0003', {});
% Select relevant segments
plifile = crs_seg.Field;
orderflw= load(orderflwfile);
order_flw = orderflw.orderflw.Complete; %#V: Specific for 4 partitions?
order_flw0000 = orderflw.orderflw.P0000;
order_flw0001 = orderflw.orderflw.P0001;
order_flw0002 = orderflw.orderflw.P0002;
order_flw0003 = orderflw.orderflw.P0003;

for k = 1:numel(plifile)
    if contains(plifile(k).Name, Upstream) 
        Qpli(end+1).Name = plifile(k).Name;
        Qpli(end).Data = plifile(k).Data;
        %order_flw(i).orderedflownumbers
        flowlinkQ(end+1).Complete = order_flw(k).Data; 
        %lowlinkQ(end+1).Complete = Flowlinknr(i); 

    elseif contains(plifile(k).Name, Downstream)
        hpli(end+1).Name = plifile(k).Name;
        hpli(end).Data = plifile(k).Data;
    end 
end 

%Upstream boundary files (needs to be seperate files)
for k = 1 : numel(Qpli)
    uppli = fullfile(fpath_bc,sprintf('%s.pli',Qpli(k).Name));
    tekal('write', [uppli], Qpli(k))
end
%Downstream boundary files (needs to be seperate files)
for k = 1:numel(hpli)
    downpli = fullfile(fpath_bc,sprintf('%s.pli',hpli(k).Name));
    tekal('write', [downpli], hpli(k))
end

% uppli = [fpath_project,'boundary_conditions\',Upstream,'.pli'];
% downpli = [fpath_project,'boundary_conditions\',Downstream,'.pli'];
%     %uppli = 
% % Write an upstream and downstream .pli
% tekal('write', [uppli], hpli);
% tekal('write', [downpli], hpli);

end %function

%%

function [Qobs,hobs]=read_obs(obsfile,Qpli,hpli)

%#V: matrixread, cellread
fid = fopen(obsfile);
data = textscan(fid, '%f %f %s', 'Delimiter', '\t');
NameOBS = data{3};
fclose(fid);

%Save relevant observation points for Q boundary
Qobs=struct('Name','','X',[],'Y',[]);
for k = 1:numel(Qpli)
    Name = strrep(Qpli(k).Name, 'C_', ''); 
    
    for kobs=1:2
        Qobs(k).Name = sprintf('O_%d_%s',kobs,Name);
        
        idx_str=find(strcmp(Qobs(k).Name, NameOBS));
        Qobs(k).X = data{1}(idx_str);
        Qobs(k).Y = data{2}(idx_str);
    end %kobs
%     for j = 1:length(NameOBS)
%         if strcmp(Qobs(k).Name, NameOBS(j))
%             Qobs(k).X = data{1}(j);
%             Qobs(k).Y = data{2}(j);
%         end
%         if strcmp(Qobs2(k).Name, NameOBS(j))
%             Qobs2(k).X = data{1}(j);
%             Qobs2(k).Y = data{2}(j);
%         end
%     end
end %k

%Save relevant observation points for h boundary
hobs=struct('Name','','X',[],'Y',[]);
for k = 1:numel(hpli)
    Name = strrep(hpli(k).Name, 'C_', ''); 
    hobs(k).Name = ['O_1_', Name];
    idx_str=find(strcmp(hobs(k).Name, NameOBS));
    hobs(k).X = data{1}(idx_str);
    hobs(k).Y = data{2}(idx_str);
%     for j = 1:length(NameOBS)
%         if strcmp(hobs(k).Name, NameOBS(j))
%             hobs(k).X = data{1}(j);
%             hobs(k).Y = data{2}(j);
%         end
%     end
end

end %function

%%

%OUTPUT:
%   -time
%   -q
%   -s1
%   -bl

function read_map(fpath_map)

%#V: There is input in the function.
if isfile(fullfile(ncfilepath, 'Maas_map.nc'))
    %Time
    tdata = EHY_getmodeldata(fullfile(ncfilepath, 'Maas_map.nc'),'','dfm','varName','time');
    t = tdata.val.';
    %Discharge
    qdata = EHY_getmodeldata(fullfile(ncfilepath, 'Maas_map.nc'),'','dfm','varName','mesh2d_q1');
    q = qdata.val.';
    %water level 
    s1data = EHY_getMapModelData(fullfile(ncfilepath, 'Maas_map.nc'),'varName','mesh2d_s1');
    s1 = s1data.val.';
    bldata= EHY_getMapModelData(fullfile(ncfilepath, 'Maas_map.nc'),'varName','mesh2d_flowelem_bl');
    bl = bldata.val.';
    partition = 0;
    %% Load direction of flowlinks
    d3d_qp('openfile',fullfile(ncfilepath, 'Maas_map.nc'));
    d3d_qp('selectfield','Neighboring faces of mesh edges');
    d3d_qp('selectsubfield','Two=1');
    flowlink_to_face{1} = d3d_qp('loaddata'); 
    d3d_qp('selectsubfield','Two=2');
    flowlink_to_face{2} = d3d_qp('loaddata'); 

elseif isfile(fullfile(ncfilepath, 'Maas_0000_map.nc'))
    %Time
    tdata = EHY_getmodeldata(fullfile(ncfilepath, 'Maas_0000_map.nc'),'','dfm','varName','time');
    t = tdata.val.';
    %Discharge2
    qdata = EHY_getmodeldata(fullfile(ncfilepath, 'Maas_0000_map.nc'),'','dfm','varName','mesh2d_q1');
    q=qdata.val';
%     q0000 = qdata.val.';
%     qdata = EHY_getmodeldata(fullfile(ncfilepath, 'Maas_0001_map.nc'),'','dfm','varName','mesh2d_q1');
%     q0001 = qdata.val.';
%     qdata = EHY_getmodeldata(fullfile(ncfilepath, 'Maas_0002_map.nc'),'','dfm','varName','mesh2d_q1');
%     q0002 = qdata.val.';
%     qdata = EHY_getmodeldata(fullfile(ncfilepath, 'Maas_0003_map.nc'),'','dfm','varName','mesh2d_q1');
%     q0003 = qdata.val.';
    %water level 
    s1data = EHY_getMapModelData(fullfile(ncfilepath, 'Maas_0000_map.nc'),'varName','mesh2d_s1');
    s1 = s1data.val.';
    %bed level
    bldata= EHY_getMapModelData(fullfile(ncfilepath, 'Maas_0000_map.nc'),'varName','mesh2d_flowelem_bl');
    bl = bldata.val.';
    
    d3d_qp('selectdomain','partition 0000')    
    d3d_qp('selectfield','Neighboring faces of mesh edges');
    d3d_qp('selectsubfield','Two=1');
    flowlink_to_face0000{1} = d3d_qp('loaddata'); 
    d3d_qp('selectsubfield','Two=2');
    flowlink_to_face0000{2} = d3d_qp('loaddata'); 
    d3d_qp('selectdomain','partition 0001')    
    d3d_qp('selectfield','Neighboring faces of mesh edges');
    d3d_qp('selectsubfield','Two=1');
    flowlink_to_face0001{1} = d3d_qp('loaddata'); 
    d3d_qp('selectsubfield','Two=2');
    flowlink_to_face0001{2} = d3d_qp('loaddata');
    d3d_qp('selectdomain','partition 0002')    
    d3d_qp('selectfield','Neighboring faces of mesh edges');
    d3d_qp('selectsubfield','Two=1');
    flowlink_to_face0002{1} = d3d_qp('loaddata'); 
    d3d_qp('selectsubfield','Two=2');
    flowlink_to_face0002{2} = d3d_qp('loaddata');
    d3d_qp('selectdomain','partition 0003')    
    d3d_qp('selectfield','Neighboring faces of mesh edges');
    d3d_qp('selectsubfield','Two=1');
    flowlink_to_face0003{1} = d3d_qp('loaddata'); 
    d3d_qp('selectsubfield','Two=2');
    flowlink_to_face0003{2} = d3d_qp('loaddata');
    
    d3d_qp('selectfield', 'Topology data of 2D mesh - face indices');
    d3d_qp('selectdomain','partition 0000')
    faces0000 = d3d_qp('loaddata'); 
    d3d_qp('selectdomain','partition 0001')
    faces0001 = d3d_qp('loaddata'); 
    d3d_qp('selectdomain','partition 0002')
    faces0002 = d3d_qp('loaddata'); 
    d3d_qp('selectdomain','partition 0003')    
    faces0003 = d3d_qp('loaddata'); 

    partition = 1 ;
else
    disp('File does not exists')
end

end %function

%%

function write_q()

%Get locations of faces from complete map file
%#V: `faces` only used for writing BC?
%#V: paths should not be in functions
compmapfile = 'p:\archivedprojects\11209261-002-maas-mor-v2\C_Work\01_Model_40m\dflowfm2d-maas-j23_6-v1a\computations\test\S1300\results\Maas_map.nc';
d3d_qp('openfile',compmapfile);
d3d_qp('selectfield', 'Topology data of 2D mesh - face indices');
faces = d3d_qp('loaddata'); 

fname = sprintf('Maas_%s_%s_bnd.bc', ['C_',Upstream], Case);
fpath = fullfile(fpath_project, 'boundary_conditions','test',Case_type, 'flow',Case,fname);
kbc = 0;
if partition == 0
    xrounded = round(faces(1).X,6); %Some rounding difference between data from Quickplot and data from directly reading nc file
    yrounded = round(faces(1).Y,6)
else
    xrounded0 = round(faces0000(1).X,6); %Some rounding difference between data from Quickplot and data from directly reading nc file
    yrounded0 = round(faces0000(1).Y,6);
    xrounded1 = round(faces0001(1).X,6); %Some rounding difference between data from Quickplot and data from directly reading nc file
    yrounded1 = round(faces0001(1).Y,6);
    xrounded2 = round(faces0002(1).X,6); %Some rounding difference between data from Quickplot and data from directly reading nc file
    yrounded2 = round(faces0002(1).Y,6);
    xrounded3 = round(faces0003(1).X,6); %Some rounding difference between data from Quickplot and data from directly reading nc file
    yrounded3 = round(faces0003(1).Y,6);
end

for k = 1:numel(Qobs)
    if partition == 0
        idx = find(xrounded == Qobs(k).X);
        q1 = q(idx);
        flownr = flowlinkQ(k).Complete;
    else
        obsname = Qobs(k).Name(5:end);
        ordered_flw = {order_flw0000, order_flw0001, order_flw0002, order_flw0003};
        q = {q0000, q0001, q0002, q0003};
        xr = {xrounded0, xrounded1, xrounded2, xrounded3};
        yr = {yrounded0, yrounded1, yrounded2, yrounded3};
        ftf = {flowlink_to_face0000, flowlink_to_face0001, flowlink_to_face0002, flowlink_to_face0003};
        shouldbreak = false;
        for k = 1:numel(ordered_flw)
            flwlinks = ordered_flw{k};
            qpart = q{k};
            xrounded = xr{k};
            yrounded = yr{k};
            flowlink_to_face = ftf{k};
            for j = 1:numel(ordered_flw{k}) 
                flownrname = flwlinks(j).Name;
                flownrname = flownrname{1}(3:end);

                if strcmp(flownrname, obsname)
                    idx = find(xrounded == Qobs(k).X);
                    q1 = qpart(idx);
                    shouldbreak = true;
                    flownr = flwlinks(j).Data;
                    break
                end
            end
            if shouldbreak
                break
            end
        end

    end
    if yrounded(idx) == Qobs(k).Y
        kbc = kbc+1;
        bc(kbc).name=strrep(deblank(Qobs(k).Name),'O_1_', 'C_');
        bc(kbc).function='time_veries';
        bc(kbc).time_interpolation='linear';
        bc(kbc).quantity{1}='time';
        bc(kbc).unit{1}='minutes since 2035-01-01 00:00:00 +01:00';
        bc(kbc).quantity{2}='dischargebnd';
        bc(kbc).unit{2}='m3/s';
        
        %Check if sign is correct (SHOULD BE TESTED)
        
        if Qobs(k).X > Qobs2(k).X
            if flowlink_to_face{1}.X(abs(flownr))< flowlink_to_face{2}.X(abs(flownr))
                q1 =  -q1;
            end
        else
            if flowlink_to_face{1}.X(abs(flownr)) > flowlink_to_face{2}.X(abs(flownr))
                q1 = -q1;
            end
        end

        bc(kbc).val = [t([1, end])/60, q1([end,end]).'];

    else
        break
    end
end

D3D_write_bc(fpath,bc)

end %function

%%

function write_h()

clear bc
fname = sprintf('Maas_%s_%s_bnd.bc', ['H_',Downstream], Case);
fpath = fullfile(fpath_project, 'boundary_conditions','test',Case_type, 'flow',Case,fname);
delete(fpath)
kbc = 0;
for k = 1:numel(hobs)
    idx = find(xrounded == hobs(k).X)
    if yrounded(idx) == hobs(k).Y
        kbc = kbc+1;
        bc(kbc).name=strrep(deblank(hobs(k).Name),'O_1_', 'C_');
        bc(kbc).function='time_veries';
        bc(kbc).time_interpolation='linear';
        bc(kbc).quantity{1}='time';
        bc(kbc).unit{1}='minutes since 2035-01-01 00:00:00 +01:00';
        bc(kbc).quantity{2}='waterlevelbnd';
        bc(kbc).unit{2}='m';
        if isnan(s1(idx,[end])) % Replace NaN values with bed level values
            bc(kbc).val = [t([1, end])/60, [bl(idx), bl(idx)].'];
        else
            bc(kbc).val = [t([1, end])/60, s1(idx,[end, end]).'];
        end
    else
        break
    end
end
D3D_write_bc(fpath,bc)

end %function

%%

function write_ext()

base_path = 'p:\11210364-003-maas-mor\C_Work\01_Model_40m\dflowfm2d-maas-j23_6-v1a\computations\test\'
X = D3D_io_input('read', fullfile(base_path, Case, ['Maas_',Case,'_bnd.ext']));
fns = fieldnames(X);
bndc = -1; 
for LL = 1:numel(Qpli)
    bndc = bndc+1
    fn = sprintf('boundary%i',bndc);
    X.(fn).quantity = 'dischargebnd';
    X.(fn).locationfile = sprintf('../../../boundary_conditions/%s.pli', Qpli(LL).Name)
    X.(fn).forcingfile= sprintf('../../../boundary_conditions/test/%s/flow/%s/Maas_%s_%s_bnd.bc', ...
                     Case_type,Case, Upstream, Case);
end

for LL = 1:numel(hobs)
    bndc = bndc+1
    fn = sprintf('boundary%i',bndc);
    X.(fn).quantity = 'waterlevelbnd';
    X.(fn).locationfile = sprintf('../../../boundary_conditions/%s.pli', hpli(LL).Name);
    X.(fn).forcingfile= sprintf('../../../boundary_conditions/test/%s/flow/%s/Maas_%s_%s_bnd.bc', ...
                     Case_type,Case, Downstream, Case);
end
D3D_io_input('write', fullfile(fpath_project, 'computations','test',Case, ['Maas_',strrep(Upstream,'C_','Q_'),'_',Case,'_bnd.ext']), X);

end %function