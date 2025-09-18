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
%Given a simulation, the grid is modified to replace the bed level by fill
%values and it is executed.
%
%INPUT:
%   - 
%
%OUTPUT:
%
%OPTIONAL PAIR INPUT:
%   - 
%
%HISTORY:
%
%This function stems from script `main03_per_cell_obs_crs.m` in
%<28_get_partition_pli_grave_lith>.

function basename_all=create_observation_locations(fdir,fpath_obs,fpath_crs_h,fpath_crs_q,fpath_submodel_enc,bc_type)

%% PARSE

%% PATHS

simdef=D3D_simpath(fdir,'overwrite',true);

if ~isfield(simdef.file,'shp')
    error('Something went wrong with running the simulation. There are no shapefiles.')
end
if ~isfield(simdef.file.shp,'crs')
    error('Something went wrong with running the simulation. There are no cross-section shapefiles.')
end
if isempty(simdef.file.shp.crs)
    error('Something went wrong with running the simulation. There are no cross-section shapefiles.')
end
if ~isfile(simdef.file.shp.crs)
    error('Something went wrong with running the simulation. There are no cross-section shapefiles.')
end
fpath_shp=simdef.file.shp.crs{1,1};

if ~isfield(simdef.file,'map')
    err=true;
end
if err
    error('Something went wrong with running the simulation. I expect a map-file in the output folder of this run: %s',fdir)
end
fpath_map=simdef.file.map;

%% CALC

flownumbers=get_flownumber(fpath_shp);

%%

[flowlink_to_face,flowlink_to_node,faces,nodes]=get_grd_data(fpath_map);

%%

[node1x,node2x,node1y,node2y,upstreamx,upstreamy,downstreamx,downstreamy]=get_nodes(flownumbers,flowlink_to_face,flowlink_to_node,faces,fpath_submodel_enc,nodes);

%%

next_flowlink=get_next_flowlink(node1x,node2x,node1y,node2y);

%%

[visited,crs_order]=get_visited(next_flowlink);

%%

% figure
% hold on
% scatter(faces.X,faces.Y,10,'k')
% % plot(submodel_enc.xy(:,1),submodel_enc.xy(:,2),'c-*')
% % scatter(x_obs,y_obs,10,'r')
% scatter(node1x,node1y,'g') %upstream grid nodes
% scatter(node2x,node2y,'rx')
% axis equal

%%

% basename_all=get_basename(visited,flownumbers,node2x,node2y);

nv=max(visited);
if nv>2
    error('Prepare for this case.')
end
basename_all=cell(1,nv);
for kv=1:nv
    bol=visited==kv;
    str_visited=flownumbers(bol,1);
    str_visited_one=str_visited{1};
    basename_all{kv}=str_visited_one(1:end-7); %Relying on the last characters being of constant length 'Roermond_000000'
end %kv

%reorder basename such that the first is upstream (`q`) and the second is
%downstream (`h`).
idx_q=strcmp(bc_type,'q');
if idx_q(1)==false
    basename_all=fliplr(basename_all);
    bc_type=fliplr(bc_type);
    %change visited index
    visited_new=visited;
    visited_new(visited==1)=2;
    visited_new(visited==2)=1;
    visited=visited_new;
end

%% 

write_files(fpath_obs,fpath_crs_h,fpath_crs_q,visited,crs_order,basename_all,upstreamx,upstreamy,downstreamx,downstreamy,node1x,node1y,node2x,node2y,bc_type);

end %function

%%
%% FUNCTION
%%

function write_files(fpath_obs,fpath_crs_h,fpath_crs_q,visited,crs_order,basename_all,upstreamx,upstreamy,downstreamx,downstreamy,node1x,node1y,node2x,node2y,bc_type)

fileID = fopen(fpath_obs, 'w');
% Check if the file was opened successfully
if fileID == -1
    error('Unable to open the file for writing.');
end

boundaryfile_h=struct('Field',cell(1,1));
boundaryfile_q=boundaryfile_h;
 
for icrs = 1:max(visited)
    flowlink_idxs = find(visited == icrs); 
    flowlink_order = crs_order(find(visited == icrs)); 
    [~, sortidx] = sort(flowlink_order);
    idxcounter = 0; 
    for idx = sortidx.'
        idxcounter = idxcounter + 1;
        flowlink_shp = flowlink_idxs(idx); 
        % name=flownumbers{flowlink_shp,1}; 
        % stridx=strfind(name,'_');
        basename=basename_all{icrs};

        pli=[node2x(flowlink_shp), node2y(flowlink_shp); node1x(flowlink_shp), node1y(flowlink_shp)];
        switch bc_type{icrs}
            case 'h'
                % Write data to the observation file using fprintf
		        % point are from left to right - O_1 is upstream, O_2 is downstream 
                nameup = sprintf('O_1_%s_%06i',basename, idxcounter);
                fprintf(fileID, '%f\t%f\t%s\n', upstreamx(flowlink_shp), upstreamy(flowlink_shp), nameup);
                namedown = sprintf('O_2_%s_%06i',basename, idxcounter);
                fprintf(fileID, '%f\t%f\t%s\n', downstreamx(flowlink_shp), downstreamy(flowlink_shp), namedown);
                %Write to a crs for later writing the pli file
                boundaryfile_h=add_crs_data(boundaryfile_h,basename,idxcounter,pli);
            case 'q'
                boundaryfile_q=add_crs_data(boundaryfile_q,basename,idxcounter,pli);
        end
        
    end

end

%Write the boundary file
tekal('write', fpath_crs_h, boundaryfile_h);
tekal('write', fpath_crs_q, boundaryfile_q);

% Close the file
fclose(fileID);

disp('Data has been written');

% 
% orderflw0000 = struct('Data', {}, 'Name',{});
% orderflw0001 = struct('Data', {}, 'Name',{});
% orderflw0002 = struct('Data', {}, 'Name',{});
% orderflw0003 = struct('Data', {}, 'Name',{});
% 
% for i = 1:numel(boundaryfile.Field)
%     NeededName = boundaryfile.Field(i).Name(3:end);
%     idx = find(contains(ObjectID0000,NeededName));
%     if ~isempty(idx)
%         orderflw0000(end+1).Data = Flowlinknr0000(idx);
%         orderflw0000(end).Name = ObjectID0000(idx);
%     end
%     idx = find(contains(ObjectID0001,NeededName));
%     if ~isempty(idx)
%         orderflw0001(end+1).Data = Flowlinknr0001(idx);
%         orderflw0001(end).Name = ObjectID0001(idx);
%     end
%     idx = find(contains(ObjectID0002,NeededName));
%     if ~isempty(idx)
%         orderflw0002(end+1).Data = Flowlinknr0002(idx);
%         orderflw0002(end).Name = ObjectID0002(idx);
%     end
%     idx = find(contains(ObjectID0003,NeededName));
%     if ~isempty(idx)
%         orderflw0003(end+1).Data = Flowlinknr0003(idx);
%         orderflw0003(end).Name = ObjectID0003(idx);
%     end
% end
% 
% orderflw = struct('Complete', orderedflownumbers, 'P0000', orderflw0000, 'P0001', orderflw0001, 'P0002', orderflw0002, 'P0003', orderflw0003);
% save(outputfile_orderflw, 'orderflw')
% 

end %function


%%

function basename_all=get_basename(visited,flownumbers,node2x,node2y)

%%
figure(1)
clf;
counter = 0; 
for icrs = 1:max(visited)
    flowlink_idxs = find(visited == icrs); 
    flowlink_order = crs_order(find(visited == icrs)); 
    [~, sortidx] = sort(flowlink_order);
    idxcounter = 0; 
    for idx = sortidx.'
        counter = counter + 1; 
        idxcounter = idxcounter + 1;
        flowlink_shp = flowlink_idxs(idx); 
        plot(node2x(flowlink_shp),node2y(flowlink_shp),'.');
        text(node2x(flowlink_shp),node2y(flowlink_shp), num2str(icrs));
        hold on;
    end
end
hold off;

%%

%??? error? flowlink_shp should be taken
for icrs = 1:max(visited)
    figure(gcf)
    basename_all{icrs} = input(sprintf('Provide basename for segment %i: ',icrs),'s');
    if isempty(basename_all{icrs})
        name=flownumbers{flowlink_shp,1}; 
        stridx=strfind(name,'_');
        basename_all{icrs}=sprintf('%s%02i',name(1:stridx(1)-1),icrs);
    end
end

end %function

%%

function [visited,crs_order]=get_visited(next_flowlink)

nr=numel(next_flowlink);

crs_no = 0;
visited = zeros(nr,1); 
crs_order = zeros(nr,1); 
% crs_flow_idx = zeros(nr,1); 
% orderedflownumbers = struct('Data', {});
while sum(visited==0) > 0
    crs_no = crs_no + 1; 
    % search forward
    flowlink_shp = min(find((visited==0))); 
    while ~isnan(flowlink_shp) 
        flowlink_shp_prev = flowlink_shp;
        flowlink_shp = next_flowlink(flowlink_shp);
    end

    crs_order_idx = 0; 
    % search backward to get all the links 
    flowlink_shp = flowlink_shp_prev;
    while ~isnan(flowlink_shp) 
       crs_order_idx = crs_order_idx + 1; 
       crs_order(flowlink_shp) = crs_order_idx; 
       visited(flowlink_shp) = crs_no;
       % name=flownumbers{flowlink_shp,1};
       % orderedflownumbers(end+1).Data =flownumbers{flowlink_shp,2};
       flowlink_shp = find(next_flowlink==flowlink_shp);
    end
end

end %function

%%

function next_flowlink=get_next_flowlink(node1x,node2x,node1y,node2y)

nr=numel(node1x);
next_flowlink=NaN(1,nr);

for flowlink_shp=1:nr
    tmp_flowlink_shp = find(node2x==node1x(flowlink_shp)&(node2y==node1y(flowlink_shp)));
    % if length(tmp_flowlink_shp) == 1
    if isscalar(tmp_flowlink_shp)
        next_flowlink(flowlink_shp) = tmp_flowlink_shp;
    % else
        % next_flowlink(flowlink_shp) = NaN;
    end
end

end

%%

function [node1x,node2x,node1y,node2y,upstreamx,upstreamy,downstreamx,downstreamy]=get_nodes(flownumbers,flowlink_to_face,flowlink_to_node,faces,fpath_submodel_enc,nodes)

nr=size(flownumbers,1);

%read submodel enclosure
submodel_enc=D3D_io_input('read',fpath_submodel_enc);%tekal('read', fpath_submodel_enc, 'loaddata');

upstream=NaN(1,nr);
upstreamx=NaN(1,nr);
upstreamy=NaN(1,nr);
downstream=NaN(1,nr);
downstreamx=NaN(1,nr);
downstreamy=NaN(1,nr);
node1=NaN(1,nr);
node2=NaN(1,nr);
node1x=NaN(1,nr);
node2x=NaN(1,nr);
node1y=NaN(1,nr);
node2y=NaN(1,nr);

for flowlink_shp=1:nr
    flowlink = flownumbers{flowlink_shp,2};
    % name=flownumbers{flowlink_shp,1};
    flowlink = abs(flowlink);
    
    x_obs = faces.X([flowlink_to_face{1}.Val(flowlink), flowlink_to_face{2}.Val(flowlink)]); 
    y_obs = faces.Y([flowlink_to_face{1}.Val(flowlink), flowlink_to_face{2}.Val(flowlink)]); 
    bol = inpolygon(x_obs,y_obs,submodel_enc.xy(:,1),submodel_enc.xy(:,2)); 

    % idx 1 is internal point, 2 is external point 
    face_idx_1 = find(bol);
    if isempty(face_idx_1)
        fcn_plot_nodes(faces,submodel_enc,x_obs,y_obs)
        error(['No observation point found inside the enclosure.' ...
            'We are trying to find which cell centre (i.e., observation station) is upstream and which is downstream.' ...
            'This is done by finding which of the two cell centres associated to a flow link is inside the enclosure' ...
            'and which one is outside. Most probably, the enclosure is not correct. It should follow the boundaries of ' ...
            'the submodel.'])
    end
    face_idx_2 = find(~bol);
    if isempty(face_idx_2)
        fcn_plot_nodes(faces,submodel_enc,x_obs,y_obs)
        error(['No observation point found outside the enclosure.' ...
            'We are trying to find which cell centre (i.e., observation station) is upstream and which is downstream.' ...
            'This is done by finding which of the two cell centres associated to a flow link is inside the enclosure' ...
            'and which one is outside. Most probably, the enclosure is not correct. It should follow the boundaries of ' ...
            'the submodel.'])
    end
%     %Find neighbouring face for each flowlink number 
%     if flowlink > 0 %Check if flow link number is positive or negative
%         face_idx_1 = 1; 
%         face_idx_2 = 2; 
%     else
%         face_idx_1 = 2; 
%         face_idx_2 = 1; 
%     end
%     
    
    %Find upstream observation point
    %bol = inpolygon(x_obs,y_obs,submodel_enc.xy(:,1),submodel_enc.xy(:,2));

    upstream(flowlink_shp) = flowlink_to_face{face_idx_1}.Val(flowlink);
    % X(flowlink_shp) = flowlink_to_face{face_idx_1}.X(flowlink);
    % Y(flowlink_shp) = flowlink_to_face{face_idx_1}.Y(flowlink);
    
    upstreamx(flowlink_shp) = faces.X(upstream(flowlink_shp));
    upstreamy(flowlink_shp) = faces.Y(upstream(flowlink_shp));
    
    %Find downstream observation point
    downstream(flowlink_shp) = flowlink_to_face{face_idx_2}.Val(flowlink);
    
    downstreamx(flowlink_shp) = faces.X(downstream(flowlink_shp));
    downstreamy(flowlink_shp) = faces.Y(downstream(flowlink_shp));
    
    %Find start and end node of per cell boundary
    node1(flowlink_shp) = flowlink_to_node{1}.Val(flowlink);
    node2(flowlink_shp) = flowlink_to_node{2}.Val(flowlink);
    
    node1x(flowlink_shp) = nodes.X(node1(flowlink_shp));
    node1y(flowlink_shp) = nodes.Y(node1(flowlink_shp));
    
    node2x(flowlink_shp) = nodes.X(node2(flowlink_shp));
    node2y(flowlink_shp) = nodes.Y(node2(flowlink_shp));

    Av = [upstreamx(flowlink_shp)-downstreamx(flowlink_shp), 
         upstreamy(flowlink_shp)-downstreamy(flowlink_shp), 
         0]; 
    Bv = [node2x(flowlink_shp)-node1x(flowlink_shp), 
         node2y(flowlink_shp)-node1y(flowlink_shp), 
         0]; 
    Cv = cross(Av,Bv);
    if Cv(3) < 0
        tmp = node1x(flowlink_shp); 
        node1x(flowlink_shp) = node2x(flowlink_shp);
        node2x(flowlink_shp) = tmp;
        tmp = node1y(flowlink_shp); 
        node1y(flowlink_shp) = node2y(flowlink_shp);
        node2y(flowlink_shp) = tmp;
    end
end

end %function

%%

function [flowlink_to_face,flowlink_to_node,faces,nodes]=get_grd_data(fpath_map)

%Import relevant variables
d3d_qp('openfile',fpath_map);
d3d_qp('selectfield','Neighboring faces of mesh edges');
d3d_qp('selectsubfield','Two=1');
flowlink_to_face{1} = d3d_qp('loaddata'); 
d3d_qp('selectsubfield','Two=2');
flowlink_to_face{2} = d3d_qp('loaddata'); 
d3d_qp('selectfield', 'Topology data of 2D mesh - face indices');
faces = d3d_qp('loaddata'); 
d3d_qp('selectfield', 'Start and end nodes of mesh edges');
d3d_qp('selectsubfield','Two=1');
flowlink_to_node{1} = d3d_qp('loaddata'); 
d3d_qp('selectsubfield','Two=2');
flowlink_to_node{2} = d3d_qp('loaddata'); 
d3d_qp('selectfield', 'Topology data of 2D mesh - node indices');
nodes = d3d_qp('loaddata'); 

end %function

%%

function flownumbers=get_flownumber(fpath_shp)

% read shape file 
linknumbers = shp2struct(fpath_shp,'read_val',true);
%get names and flow link numbers
a = linknumbers.val{1,1};
b = linknumbers.val{1,2};
ObjectID = a.Val;
Flowlinknr = b.Val; 
%Select only relevant flowlinks
% idx = startsWith (ObjectID, 'P');
% ObjectID = ObjectID(idx);
% Flowlinknr = Flowlinknr(idx);

% % read shape file 
% linknumbers0000 = shp2struct(shapefile0000,'read_val',true);
% %get names and flow link numbers
% a = linknumbers0000.val{1,1};
% b = linknumbers0000.val{1,2};
% ObjectID0000 = a.Val;
% Flowlinknr0000 = b.Val; 
% %Select only relevant flowlinks
% idx = startsWith (ObjectID0000, 'P');
% ObjectID0000 = ObjectID0000(idx);
% Flowlinknr0000 = Flowlinknr0000(idx);
% 
% % read shape file 
% linknumbers0001 = shp2struct(shapefile0001,'read_val',true);
% %get names and flow link numbers
% a = linknumbers0001.val{1,1};
% b = linknumbers0001.val{1,2};
% ObjectID0001 = a.Val;
% Flowlinknr0001 = b.Val; 
% %Select only relevant flowlinks
% idx = startsWith (ObjectID0001, 'P');
% ObjectID0001 = ObjectID0001(idx);
% Flowlinknr0001 = Flowlinknr0001(idx);
% 
% % read shape file 
% linknumbers0002 = shp2struct(shapefile0002,'read_val',true);
% %get names and flow link numbers
% a = linknumbers0002.val{1,1};
% b = linknumbers0002.val{1,2};
% ObjectID0002 = a.Val;
% Flowlinknr0002 = b.Val; 
% %Select only relevant flowlinks
% idx = startsWith (ObjectID0002, 'P');
% ObjectID0002 = ObjectID0002(idx);
% Flowlinknr0002 = Flowlinknr0002(idx);
% 
% % read shape file 
% linknumbers0003 = shp2struct(shapefile0003,'read_val',true);
% %get names and flow link numbers
% a = linknumbers0003.val{1,1};
% b = linknumbers0003.val{1,2};
% ObjectID0003 = a.Val;
% Flowlinknr0003 = b.Val; 
% %Select only relevant flowlinks
% idx = startsWith (ObjectID0003, 'P');
% ObjectID0003 = ObjectID0003(idx);
% Flowlinknr0003 = Flowlinknr0003(idx);

%Store relevant flowlinks
flownumbers = cell(length(Flowlinknr),2);
flownumbers(:,1) = ObjectID;
flownumbers(:,2) = num2cell(Flowlinknr);
% [nr,nc] = size(flownumbers);

end %function

%%

function fcn_plot_nodes(faces,submodel_enc,x_obs,y_obs)

figure
hold on
scatter(faces.X,faces.Y,10,'k')
plot(submodel_enc.xy(:,1),submodel_enc.xy(:,2),'g-*')
scatter(x_obs,y_obs,10,'r')
axis equal

end

%%

function boundaryfile=add_crs_data(boundaryfile,basename,idxcounter,pli)
          
nc=numel(boundaryfile.Field);
nl=nc+1; 
namecrs=sprintf('C_%s_%06i',basename, idxcounter);
% convention for segment-point ordering is right to left, convention for cross-section ordering is left to right
boundaryfile.Field(nl).Data=pli;  
boundaryfile.Field(nl).Name=namecrs;

end