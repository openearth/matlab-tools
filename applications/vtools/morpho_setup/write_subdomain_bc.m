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
%PAIR INPUT:
%   -only_start_end = only write start and end of time series. -> write
%   last value as constant!
%
%OUTPUT:
%   -BC files
%
%TO DO:
%Option select either upstream or downstream water level. 
%Future: read information from obs-file

%lateral external written at same location as original. 

function write_subdomain_bc(fpath_map,fpath_crs,fpath_obs,fpath_ext,fdir_out,fpathrel_bc,fpathrel_pli,fname_h,fname_q,fname_ext,time_start,is_internal,boundaries,fpath_submodel_enc,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'only_start_end',true);

parse(parin,varargin{:});

only_start_end=parin.Results.only_start_end;

if isempty(fpath_map) || ~isfile(fpath_map)
    error('Please input map file.')
end

%% CALC
messageOut(NaN,'Start getting indices.')
[obs,crs,~]=get_idx_grid_pli(fpath_map,fpath_crs,fpath_obs,fpath_submodel_enc,varargin{:});

messageOut(NaN,'Start getting data.')
[obs,crs,time_v]=extract_map_info(fpath_map,obs,crs);

messageOut(NaN,'Start writing lateral bc.')
write_lateral_bc(fpath_ext, fdir_out, time_start, time_v, only_start_end);

messageOut(NaN,'Start writing water level boundary.')
%`bc_h`=cell(nh,2)
%   -`bc_h{kh,1}` = structure with h-boundary
%   -`bc_h{kh,2}` = name of the location
bc_h=write_h_bc(obs,fullfile(fdir_out,fpathrel_bc),time_start,time_v,is_internal,fname_h,only_start_end);

messageOut(NaN,'Start writing discharge boundary.')
bc_q=write_q_bc(crs,fullfile(fdir_out,fpathrel_bc),time_start,time_v,fname_q,only_start_end);

messageOut(NaN,'Start writing polylines.')
write_pli(crs,fullfile(fdir_out,fpathrel_pli))

messageOut(NaN,'Start writing external file.')
write_ext(fpath_ext,bc_h,bc_q,fdir_out,fpathrel_bc,fpathrel_pli,fname_h,fname_q,boundaries,fname_ext);

messageOut(NaN,'Done.')

end %function

%%
%% FUNCTIONS
%%

%%  

function [obs,crs,submodel_enc]=get_idx_grid_pli(fpath_map,fpath_crs,fpath_obs,fpath_submodel_enc,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'delimiter','\t');
addOptional(parin,'tol',15);

parse(parin,varargin{:});

delimiter=parin.Results.delimiter;
tol=parin.Results.tol;

do_enc=false;
if ~isempty(fpath_submodel_enc)
    do_enc=true;
end

%% CALC

%% read grid
matfilename = sprintf('%s_grid.mat', num2str(keyHash(fpath_map))); 
if exist(matfilename,'file')==2
    messageOut(NaN,sprintf('A mat-file with grid data exists. Loading: %s',matfilename));
    load(matfilename); 
else
    messageOut(NaN,sprintf('A mat-file with grid data does not exists. Loading: %s',fpath_map));
    gridInfo=EHY_getGridInfo(fpath_map,{'XYcen','XYuv'}); 
    xcen_ehy=gridInfo.Xcen;
    ycen_ehy=gridInfo.Ycen;
    xedg_ehy=gridInfo.Xu;
    yedg_ehy=gridInfo.Yu;
    
    %`edge_faces` from EHY cannot be used because it is a local of every partitioned grid and there is an inconsistency. 
    [edge_face,xcen_raw,ycen_raw,xedg_raw,yedg_raw,~,faces_local]=D3D_edge_faces(fpath_map);
    save(matfilename,'gridInfo','xcen_ehy','ycen_ehy', 'xedg_ehy', 'yedg_ehy', 'edge_face','xcen_raw','ycen_raw','xedg_raw','yedg_raw','faces_local');
end

%% obs
obs=D3D_io_input('read',fpath_obs,'delimiter',delimiter,'v',2);
nobs=numel(obs);
for kobs=1:nobs
    x=obs(kobs).xy(1);
    y=obs(kobs).xy(2);
    dist=hypot(xcen_ehy-x,ycen_ehy-y);
    [idx,min_v,flg_found] = absmintol(dist,0,'do_disp_list',0,'tol',tol,'do_break',0);
    %V: I think that we have to break in case it is not found. We should
    %discuss what happens otherwise. 
    if flg_found
        obs(kobs).idx=idx; %EHY index of cell centre
    else
        obs(kobs).idx=NaN; %not found
    end
end %kobs
xy_obs_all=reshape([obs.xy],2,[])';

%% submodel_enc
if do_enc
    submodel_enc=D3D_io_input('read',fpath_submodel_enc);%tekal('read', fpath_submodel_enc, 'loaddata');
end

%% crs
crs=D3D_io_input('read',fpath_crs);
ncrs=numel(crs);
for kcrs=1:ncrs
    x=mean(crs(kcrs).xy(:,1));
    y=mean(crs(kcrs).xy(:,2));
    dist=hypot(xedg_ehy-x,yedg_ehy-y);
    [idx_edg,min_v,flg_found] = absmintol(dist,0,'do_disp_list',0,'tol',tol,'do_break',0);
    if flg_found
        crs(kcrs).idx=idx_edg; %EHY index of link
    else
        crs(kcrs).idx=NaN; 
        crs(kcrs).name=strrep(crs(kcrs).name,'C_','');
        continue
    end
    %direction
    dist=hypot(xedg_raw-x,yedg_raw-y);
    [idx_edg_raw,min_v,flg_found]=absmintol(dist,0,'do_disp_list',0,'tol',tol,'do_break',1); %index of the link closest in raw coordinates
    idx_faces=edge_face(idx_edg_raw,:); %index of faces connected by the link in raw coordinates. Because it is a local variable, there are as many possible faces as partitions. 
 
    idx_faces_possible=find(faces_local==idx_faces(1)); %global index of possible origin faces connected by the link
 
    x_possible=xcen_raw(idx_faces_possible);
    y_possible=ycen_raw(idx_faces_possible);
 
    dist=hypot(x_possible-x,y_possible-y); 
    [idx_obs_1_loc,min_v]=absmintol(dist,0,'do_disp_list',0,'tol',tol*4,'do_break',1); %index of origin face from the possible ones that is closest to the link in raw coordinates.

    x_obs=x_possible(idx_obs_1_loc); %x coordinate of the observation station that is origin of the link.
    y_obs=y_possible(idx_obs_1_loc); %y coordinate of the observation station that is origin of the link.

    if do_enc
        bol = inpolygon(x_obs,y_obs,submodel_enc.xy(:,1),submodel_enc.xy(:,2));
    else
        bol=true(size(x_obs));
    end

    %If the point is outside the submodel enclosure the flow is as it would
    %be in the submodel from outside to inside. Hence dir = 1;
    
    if bol
        dir=-1; %link goes from inside to outside 
    else
        dir=1; %link goes from outside to inside 
    end
    crs(kcrs).direction=dir;

    crs(kcrs).name=strrep(crs(kcrs).name,'C_','');

    %% DEBUG

    % figure
    % hold on
    % % scatter(xcen_ehy,ycen_ehy)
    % % scatter(xedg_raw,yedg_raw)
    % scatter(x_possible,y_possible)
    % % x=xy_obs_all(idx_obs,1);
    % % y=xy_obs_all(idx_obs,2);
    % scatter(x,y,'r','s')
    % % plot(crs(kcrs).xy(:,1),crs(kcrs).xy(:,2),'LineWidth',2,'color','g')
    % axis equal
    % % xlim([x-100,x+100])
    % % ylim([y-100,y+100])
    % % title(sprintf('%d',crs(kcrs).direction))
    % % pause(0.5)
    % % close all

end

end %function

%%

function [obs,crs,time_v]=extract_map_info(fpath_map,obs,crs)

matfilename = sprintf('%s.mat', num2str(keyHash(fpath_map))); 
if exist(matfilename,'file')==2
    messageOut(NaN,sprintf('A mat-file with map data exists. Loading: %s',matfilename));
    load(matfilename); 
else
    messageOut(NaN,sprintf('A mat-file with map data does not exists. Loading: %s',fpath_map));
    data_q=EHY_getMapModelData(fpath_map,'varName','mesh2d_q1');
    data_s1=EHY_getMapModelData(fpath_map,'varName','mesh2d_s1');
    data_bl=EHY_getMapModelData(fpath_map,'varName','bl');
    [~,~,~,time_v,~,~]=D3D_results_time(fpath_map,0,[1,Inf]); %time_dtime
    save(matfilename,'data_q','data_s1','data_bl','time_v');
end
ncrs=numel(crs);
for kcrs=1:ncrs
    if isnan(crs(kcrs).idx)
        crs(kcrs).q=zeros([size(data_q.val,1),1]);
    else
        crs(kcrs).q=data_q.val(:,crs(kcrs).idx);
    end
end

nobs=numel(obs);
for kobs=1:nobs
    if isnan(obs(kobs).idx)
        obs(kobs).s1=NaN*ones([size(data_s1.val,1),1]);
        obs(kobs).bl=-999; % *ones([size(data_s1.val,1),1]);
    else
        obs(kobs).s1=data_s1.val(:,obs(kobs).idx);
        obs(kobs).bl=data_bl.val(obs(kobs).idx);
    end
end

end %function

%%

function bc_all=write_h_bc(obs,fdir_out,time_start,time_v,is_internal,fname_h,only_begin_last)

nobs=numel(obs);
location=''; %first time is empty, such that a new file is not written in `write_bc_if_new`
bc_all={};
bc=struct();
ks=0;
for kobs=1:nobs
    name=deblank(obs(kobs).name);
    if (strcmp(name(3),'1') && ~is_internal) || (strcmp(name(3),'2') && is_internal)
        continue
    end
   
    name(1:4)=''; %remove `O_1_`
    location_new=get_location(name);

    [bc,ks,bc_all]=write_bc_if_new(bc,ks,bc_all,location,location_new,fdir_out,fname_h);
    
    location=location_new;
    ks=ks+1;

    bc(ks).name=name;
    if ~only_begin_last
        bc(ks).function='timeseries';
        bc(ks).time_interpolation='linear';
        bc(ks).quantity{1}='time';
        bc(ks).unit{1}=sprintf('seconds since %s %s',string(time_start,'yyyy-MM-dd HH:mm:ss'),time_start.TimeZone);
        bc(ks).quantity{2}='waterlevelbnd';
        bc(ks).unit{2}='m';
    else
        bc(ks).function='constant';
        bc(ks).quantity{1}='waterlevelbnd';
        bc(ks).unit{1}='m'; 
    end

    %replace NaN values with bed level values
    val=obs(kobs).s1;
    bol_nan=isnan(val);
    val(bol_nan)=obs(kobs).bl;

    [time_s,val]=time_and_val(time_v,time_start,val,only_begin_last);

    if ~only_begin_last
        bc(ks).val=[time_s,val(:)];
    else
        bc(ks).val=val(end);
    end
    
end %kobs

[~,~,bc_all]=write_bc_if_new(bc,ks,bc_all,location,'dummy',fdir_out,fname_h); %`dummy` as input will trigger to write the last output

end %function

%%

function bc_all=write_q_bc(crs,fdir_out,time_start,time_v,fname_q,only_start_end)

ncrs=numel(crs);
location='';
bc_all={};
bc=struct();
ks=0;
for kcrs=1:ncrs    
    name=deblank(crs(kcrs).name);

    location_new=get_location(name);
    
    [bc,ks,bc_all]=write_bc_if_new(bc,ks,bc_all,location,location_new,fdir_out,fname_q);

    location=location_new;
    ks=ks+1;

    bc(ks).name=name;
    if ~only_start_end
        bc(ks).function='timeseries';
        bc(ks).time_interpolation='linear';
        bc(ks).quantity{1}='time';
        bc(ks).unit{1}=sprintf('seconds since %s %s',string(time_start,'yyyy-MM-dd HH:mm:ss'),time_start.TimeZone);
        bc(ks).quantity{2}='dischargebnd';
        bc(ks).unit{2}='m3/s';
    else
        bc(ks).function='constant';
        bc(ks).quantity{1}='dischargebnd';
        bc(ks).unit{1}='m3/s';        
    end
    if isnan(crs(kcrs).idx) 
        [time_s,val]=time_and_val(time_v,time_start,zeros(size(time_v)),only_start_end);
    else
        val=crs(kcrs).direction.*crs(kcrs).q; %if the link goes from downstream to upstream, a negative discharge must be positive.
        [time_s,val]=time_and_val(time_v,time_start,val,only_start_end);
    end
    if ~only_start_end
        bc(ks).val=[time_s,val];
    else
        bc(ks).val=val(end);
    end
end

[~,~,bc_all]=write_bc_if_new(bc,ks,bc_all,location,'dummy',fdir_out,fname_q); %`dummy` as input will trigger to write the last output

end %function

%%

function write_pli(crs,fdir_out)

ncrs=numel(crs);
for kcrs=1:ncrs
    name=crs(kcrs).name;
    pli(kcrs).name=name;
    pli(kcrs).xy=crs(kcrs).xy;

    %write in individual files
    fdir_out = get_full_dir(fullfile(fdir_out));
    fpath=fullfile(fdir_out,sprintf('%s.pli',name));
    if ~exist(fdir_out,'dir')
        mkdir(fdir_out);
    end    
    D3D_io_input('write',fpath,pli(kcrs))
end %kcrs

end %function

%%

function write_lateral_bc(fpath_ext, fdir_out, time_start, time_v, only_start_end)

%original external without [boundary]
ext_o=D3D_io_input('read',fpath_ext);
fn=fieldnames(ext_o);
bol=contains(fn,'lateral');

bc_all={};
bc=struct();

idx_lat=find(bol);
nlat=numel(idx_lat);
fpath_rel_lat=cell(nlat,1);
for klat=1:nlat
    idx_lat_loc=idx_lat(klat);
    fpath_rel_lat{klat}=ext_o.(fn{idx_lat_loc}).discharge;
end

%take unique
[~,idx]=unique(cell2table(fpath_rel_lat));
fpath_rel_lat=fpath_rel_lat(idx);
nlat=numel(fpath_rel_lat);

for klat=1:nlat
    fpath_lat_orig=fullfile(fileparts(fpath_ext),fpath_rel_lat{klat});
    lat=bct_io('read', fpath_lat_orig); 
    ns=length(lat.Table);
    for ks=1:ns
        bc(ks).name=lat.Table(ks).Location;
        if ~only_start_end
            bc(ks).function='timeseries';
            bc(ks).time_interpolation='linear';
            bc(ks).quantity{1}='time';
            bc(ks).unit{1}=sprintf('seconds since %s %s',string(time_start,'yyyy-MM-dd HH:mm:ss'),time_start.TimeZone);
            bc(ks).quantity{2}='lateral_discharge';
            bc(ks).unit{2}='m3/s';
        else
            bc(ks).function='constant';
            bc(ks).quantity{1}='lateral_discharge';
            bc(ks).unit{1}='m3/s';
        end
        val=lat.Table(ks).Data(:,2);
        [time_s,val]=time_and_val(time_v,time_start,val,only_start_end);
        if ~only_start_end
            bc(ks).val=[time_s,val];
        else
            bc(ks).val=val(end);
        end
    end
    [fdir_out_bc,fname, ~]=fileparts(fpath_lat_orig); 
    [~,~,bc_all]=write_bc_if_new(bc,ks,bc_all,'cmp','dummy',fdir_out_bc,fname); %`dummy` as input will trigger to write the file always
end

end %function

%%

function write_ext(fpath_ext,bc_h,bc_q,fdir_out,fpathrel_bc,fpathrel_pli,fname_h_bc,fname_q_bc,boundaries,fname_ext)

if ~strcmp(fpathrel_bc(end),'\') && ~strcmp(fpathrel_bc(end),'/')
    fpathrel_bc(end)='/';
end

%rework external
ext_o=D3D_io_input('read',fpath_ext);
fn=fieldnames(ext_o);
bol=contains(fn,'boundary');
ext_boundary_o=rmfield(ext_o,fn(~bol)); %original external only [boundary]
ext_o=rmfield(ext_o,fn(bol)); %original external without [boundary]
kboundary_o=sum(~bol); %number of boundaries which are not [boundary] (e.g., [lateral])
fn=fieldnames(ext_o);
bol=contains(fn,'lateral');

%change the path of the laterals to the new laterals external file
for klat=find(bol).'
    [fpathlat, fpathname, ~] = fileparts(ext_o.(fn{klat}).discharge);
    ext_o.(fn{klat}).discharge = strrep(fullfile(fpathlat, [fpathname, '_cmp.bc']), '\' , '/');
end

nbc=size(boundaries,1); %number of intervals (i.e., subdomains)
for kbc=1:nbc
    ext=ext_o;
    kboundary=kboundary_o;
    
    bc=which_bc(boundaries(kbc,1),bc_q(:,2),bc_q,ext_boundary_o); %`boundaries(kbc,1)` is upstream, a `q` BC.
    [ext,kboundary]=add_ext(ext,kboundary,bc,'dischargebnd' ,fpathrel_pli,fpathrel_bc,fname_q_bc); %q

    bc=which_bc(boundaries(kbc,2),bc_h(:,2),bc_h,ext_boundary_o); %`boundaries(kbc,2)` is downstream, an `h` BC.
    [ext,kboundary]=add_ext(ext,kboundary,bc,'waterlevelbnd',fpathrel_pli,fpathrel_bc,fname_h_bc); %h
    
    %laterals should be added?
    
    fpath=fullfile(fdir_out,sprintf('%s_%s_%s.ext',fname_ext,boundaries{kbc,1},boundaries{kbc,2}));
    mkdir_check(fdir_out);

    D3D_io_input('write',fpath,ext);
end %kbc

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

for kmap=1:npart
    fpath_map_loc=ncFiles{kmap};

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
    domain_all=cat(1,domain_all,(kmap-1).*ones(size(face_x)));
end

ndom=max(domain_all)+1; %number of domains
faces_local=NaN(size(domain_all));
for kdom=1:ndom
    bol_dom=domain_all==kdom-1;
    faces_local(bol_dom)=1:1:sum(bol_dom);
end

end %function

%%

function [ext,kboundary]=add_ext(ext,kboundary,bc,str,fpathrel_pli,fpathrel_bc,fname_bc)

nbch=numel(bc);
for kbch=1:nbch
    kboundary=kboundary+1;

    fnloc=sprintf('boundary%i',kboundary);
    if ~isfield(bc(kbch),'locationfile') %added from crs and obs
        location=get_location(bc(kbch).name);
        fname=fcn_fname_bc(fname_bc,location);

        ext.(fnloc).quantity=str;
        ext.(fnloc).locationfile=sprintf('%s%s.pli',fpathrel_pli,bc(kbch).name);
        ext.(fnloc).forcingfile=sprintf('%s%s',fpathrel_bc,fname);
    else %in the original external file
        ext.(fnloc)=bc(kbch);
        if isfield(ext.(fnloc),'name')
            ext.(fnloc)=rmfield(ext.(fnloc),'name');
        end
    end

end %kbch

end %function

%%

function [time_s,val]=time_and_val(time_v,time_start,val,only_start_end)

time_s=seconds(time_v-time_start);
if only_start_end
    time_s=time_s([1,end]);
    val=val([end,end]);
end

end %function

%%

%Write a bc-file if the new location is different than the current
%location and provide an empty bc structure to write the next one.
%If the current location is empty, a file is not written and the
%new empty bc structure is provided. 
%
function [bc,ks,bc_all]=write_bc_if_new(bc,ks,bc_all,location,location_new,fdir_out,fname_h)

if ~strcmp(location,location_new) %add data to existing
    if ~isempty(location) %write and save
        fname=fcn_fname_bc(fname_h,location);
        fdir_out=get_full_dir(fullfile(fdir_out));
        fpath=fullfile(fdir_out,fname);
        mkdir_check(fdir_out,NaN,1,1);
        D3D_write_bc(fpath,bc)
        messageOut(NaN,sprintf('bc-file created: %s',fpath));
        bc_all=cat(1,bc_all,{bc,location});
    end
    ks=0;
    bc=struct();
end

end %function

%%

function location=get_location(name)

location=name(1:end-7); %it assumed to be `#name_123456` 

end %function

%%

function location_bc_o=location_boundary_original(ext_boundary_o)

fn_boundary_o=fieldnames(ext_boundary_o);
nbo=numel(fn_boundary_o);
location_bc_o=cell(nbo,1);
for kbo=1:nbo
    lf=ext_boundary_o.(fn_boundary_o{kbo}).locationfile;
    [~,location_bc_o{kbo}]=fileparts(lf);
end

end %function

%%

function bc=which_bc(boundaries,bc_q,bc_in,bc_o)
    
bol=strcmpi(boundaries,bc_q);

%Search if the name of the boundary is in the BC
if sum(bol)~=1
    %If it is not, then check if it in the original external.
    location_boundary_o=location_boundary_original(bc_o);
    bol=strcmpi(boundaries,location_boundary_o);
    if sum(bol)~=1
        %If it is not, error.
        error('BC not found in %s',boundaries)
    else
        %If it is there, take it.
        fn=fieldnames(bc_o);
        bc=bc_o.(fn{bol});
        bc.name=location_boundary_o{bol};
    end
else
    %If it is, then take it.
    bc=bc_in{bol,1};
end

end %function

%%

function fname=fcn_fname_bc(fname_h,location)

fname=sprintf('%s_%s.bc',fname_h,location);

end %function
