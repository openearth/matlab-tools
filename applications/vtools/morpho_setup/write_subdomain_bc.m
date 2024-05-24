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
%   -only_start_end = only write start and end of time series. 
%
%OUTPUT:
%   -BC files
%
%TO DO:
%Option select either upstream or downstream water level. 
%Future: read information from obs-file

function write_subdomain_bc(fpath_map,fpath_crs,fpath_obs,fpath_ext,fdir_out,fpathrel_bc,fpathrel_pli,fname_h,fname_q,time_start,is_internal,boundaries,fpath_submodel_enc,model_case,varargin)

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
[obs,crs,submodel_enc]=get_idx_grid_pli(fpath_map,fpath_crs,fpath_obs,fpath_submodel_enc,varargin{:});

messageOut(NaN,'Start getting data.')
[obs,crs,time_v]=extract_map_info(fpath_map,obs,crs);

messageOut(NaN,'Start writing water level boundary.')
bc_h=write_h_bc(obs,fullfile(fdir_out,fpathrel_bc),time_start,time_v,is_internal,fname_h,only_start_end);

messageOut(NaN,'Start writing discharge boundary.')
bc_q=write_q_bc(crs,fullfile(fdir_out,fpathrel_bc),time_start,time_v,fname_q,only_start_end);

messageOut(NaN,'Start writing polylines.')
write_pli(crs,fullfile(fdir_out,fpathrel_pli))

messageOut(NaN,'Start writing external file.')
write_ext(fpath_ext,bc_h,bc_q,fdir_out,fpathrel_bc,fpathrel_pli,fname_h,fname_q,boundaries,model_case);

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

parse(parin,varargin{:});

delimiter=parin.Results.delimiter;

%% CALC

%read grid
matfilename = sprintf('%s_grid.mat', num2str(keyHash(fpath_map))); 
if exist(matfilename)==2; 
    load(matfilename); 
else
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
    [idx,min_v,flg_found] = absmintol(dist,0,'do_disp_list',0,'tol',12,'do_break', 0);
    %[idx,~]=absmintol(dist,0,'do_disp_list',0,'tol',12,'do_break',1);
    if flg_found
        obs(kobs).idx=idx; %EHY index of cell centre
    else
        obs(kobs).idx=NaN; %not found
    end
end %kobs
xy_obs_all=reshape([obs.xy],2,[])';


%% submodel_enc
submodel_enc=D3D_io_input('read',fpath_submodel_enc);%tekal('read', fpath_submodel_enc, 'loaddata');


%% crs
crs=D3D_io_input('read',fpath_crs);
ncrs=numel(crs);
for kcrs=1:ncrs
    x=mean(crs(kcrs).xy(:,1));
    y=mean(crs(kcrs).xy(:,2));
    dist=hypot(xedg_ehy-x,yedg_ehy-y);
    [idx_edg,min_v,flg_found] = absmintol(dist,0,'do_disp_list',0,'tol',12,'do_break',0);
    if flg_found
        crs(kcrs).idx=idx_edg; %EHY index of link
    else
        crs(kcrs).idx=NaN; 
        crs(kcrs).name=strrep(crs(kcrs).name,'C_','');
        continue
    end
    %direction
    dist=hypot(xedg_raw-x,yedg_raw-y);
    [idx_edg_raw,min_v,flg_found]=absmintol(dist,0,'do_disp_list',0,'tol',12,'do_break',0); %index of the link closest in raw coordinates
     idx_faces=edge_face(idx_edg_raw,:); %index of faces connected by the link in raw coordinates. Because it is a local variable, there are as many possible faces as partitions. 
 
     idx_faces_possible=find(faces_local==idx_faces(1)); %global index of possible origin faces connected by the link
 
     x_possible=xcen_raw(idx_faces_possible);
     y_possible=ycen_raw(idx_faces_possible);
 
     dist=hypot(x_possible-x,y_possible-y); 
    [idx_obs_1_loc,~]=absmintol(dist,0,'do_disp_list',0,'tol',40,'do_break',1); %index of origin face from the possible ones that is closest to the link in raw coordinates.

    x_obs=x_possible(idx_obs_1_loc); %x coordinate of the observation station that is origin of the link.
    y_obs=y_possible(idx_obs_1_loc); %y coordinate of the observation station that is origin of the link.

    bol = inpolygon(x_obs,y_obs,submodel_enc.xy(:,1),submodel_enc.xy(:,2));

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

%     figure
%     hold on
%     scatter(xcen_ehy,ycen_ehy)
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
matfilename = sprintf('%s.mat', num2str(keyHash(fpath_map))); 
if exist(matfilename)==2; 
    load(matfilename); 
else
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
location='';
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
        bc(ks).function='astronomic';
        bc(ks).quantity{1}='astronomic component'; 		
        bc(ks).unit{1}='-'; 
        bc(ks).quantity{2}='waterlevelbnd amplitude'; 		
        bc(ks).unit{2}='m'; 
        bc(ks).quantity{3}='waterlevelbnd phase'; 		
        bc(ks).unit{3}='rad/deg/minutes'; 
    end

    %replace NaN values with bed level values
    val=obs(kobs).s1;
    bol_nan=isnan(val);
    val(bol_nan)=obs(kobs).bl;

    [time_s,val]=time_and_val(time_v,time_start,val,only_begin_last);

    if ~only_begin_last
        bc(ks).val=[time_s,val(:)];
    else
        bc(ks).val={'A0',val(end),0.0};
    end
    
end

[~,~,bc_all]=write_bc_if_new(bc,ks,bc_all,location,'dummy',fdir_out,fname_h);

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
        bc(ks).function='astronomic';
        bc(ks).quantity{1}='astronomic component'; 		
        bc(ks).unit{1}='-'; 
        bc(ks).quantity{2}='dischargebnd amplitude'; 		
        bc(ks).unit{2}='m3/s'; 
        bc(ks).quantity{3}='dischargebnd phase'; 		
        bc(ks).unit{3}='rad/deg/minutes'; 
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
        bc(ks).val={'A0',val(end),0.0};
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

function write_ext(fpath_ext,bc_h,bc_q,fdir_out,fpathrel_bc,fpathrel_pli,fname_h_bc,fname_q_bc,boundaries,model_case)

if ~strcmp(fpathrel_bc(end),'\') && ~strcmp(fpathrel_bc(end),'/')
    fpathrel_bc(end)='/';
end

%original external without [boundary]
ext_o=D3D_io_input('read',fpath_ext);
fn=fieldnames(ext_o);
bol=contains(fn,'boundary');
ext_boundary_o=rmfield(ext_o,fn(~bol));
ext_o=rmfield(ext_o,fn(bol));
kboundary_o=sum(~bol); %boundaries which are not [boundary] (e.g., [lateral])

nbc=size(boundaries,1);
for kbc=1:nbc
    ext=ext_o;
    kboundary=kboundary_o;
    
    bc=which_bc(boundaries(kbc,1),bc_q(:,2),bc_q,ext_boundary_o);
    [ext,kboundary]=add_ext(ext,kboundary,bc,'dischargebnd' ,fpathrel_pli,fpathrel_bc,fname_q_bc); %q

    bc=which_bc(boundaries(kbc,2),bc_h(:,2),bc_h,ext_boundary_o);
    [ext,kboundary]=add_ext(ext,kboundary,bc,'waterlevelbnd',fpathrel_pli,fpathrel_bc,fname_h_bc); %h
    
    fpath=fullfile(fdir_out,sprintf('ext_%s_%s_%s_bnd.ext',boundaries{kbc,1},boundaries{kbc,2},model_case));
    if ~isfolder(fdir_out);
        mkdir(fdir_out);
    end
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

end

%%

function [bc,ks,bc_all]=write_bc_if_new(bc,ks,bc_all,location,location_new,fdir_out,fname_h)

if ~strcmp(location,location_new) %add data to existing
    if ~isempty(location) %write and save
        fname=fcn_fname_bc(fname_h,location);
        fdir_out = get_full_dir(fullfile(fdir_out));
        fpath=fullfile(fdir_out,fname);
        if ~isfolder(fdir_out)
            mkdir(fdir_out);
        end
        D3D_write_bc(fpath,bc)
        messageOut(NaN,sprintf('bc-file created: %s',fpath));
        bc_all=cat(1,bc_all,{bc,location});
    end
    ks=0;
    bc=struct();
end

end

%%

function location=get_location(name)

location=name(1:end-7); %it assumed to be `#name_123456` 

end

%%

function location_bc_o=location_boundary_original(ext_boundary_o)

fn_boundary_o=fieldnames(ext_boundary_o);
nbo=numel(fn_boundary_o);
location_bc_o=cell(nbo,1);
for kbo=1:nbo
    lf=ext_boundary_o.(fn_boundary_o{kbo}).locationfile;
    [~,location_bc_o{kbo}]=fileparts(lf);
end

end

%%

function bc=which_bc(boundaries,bc_q,bc_in,bc_o)
    
bol=strcmpi(boundaries,bc_q);
location_boundary_o=location_boundary_original(bc_o);

if sum(bol)~=1
    bol=strcmpi(boundaries,location_boundary_o);
    if sum(bol)~=1
        error('BC not found in %s',boundaries)
    else
        fn=fieldnames(bc_o);
        bc=bc_o.(fn{bol});
        bc.name=location_boundary_o{bol};
    end
else
    bc=bc_in{bol,1};
end

end

%%

function fname=fcn_fname_bc(fname_h,location)

fname=sprintf('%s_%s.bc',fname_h,location);

end
