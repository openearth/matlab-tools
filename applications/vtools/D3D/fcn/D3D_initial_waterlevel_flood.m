%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                      RIVV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%D3D_INITIAL_WATERLEVEL_FLOOD Create and write an initial water-level XYZ.
%   D3D_initial_waterlevel_flood(FPATH_BED,FPATH_GRID,FPATH_POINTS,FPATH_OUT)
%   interpolates bed elevations and water levels at DFM cell centers, floods
%   from the water-level points subject to the bed elevation, and writes
%   flooded cell centers as space-delimited x/y/waterlevel rows.


function D3D_initial_waterlevel_flood(fpath_bed,fpath_grid,fpath_waterlevel_points,fpath_output)

if ~isfile(fpath_bed) || ~isfile(fpath_grid) || ~isfile(fpath_waterlevel_points)
    error('D3D_initial_waterlevel_flood:MissingInputFile', ...
        'The bed, grid, and water-level point input files must exist.');
end

grid_info=EHY_getGridInfo(fpath_grid,{'XYcen','face_nodes'});
x_cell=grid_info.Xcen(:);
y_cell=grid_info.Ycen(:);
n_cell=numel(x_cell);
if numel(y_cell)~=n_cell || size(grid_info.face_nodes,2)~=n_cell
    error('D3D_initial_waterlevel_flood:InvalidGrid', ...
        'Cell-center coordinates and face connectivity must have matching sizes.');
end

bed_xyz=readmatrix(fpath_bed,'FileType','text');
if size(bed_xyz,2)~=3 || any(~isfinite(bed_xyz(:)))
    error('D3D_initial_waterlevel_flood:InvalidBedData', ...
        'The bed XYZ file must contain three finite numeric columns.');
end
F_bed=scatteredInterpolant(bed_xyz(:,1),bed_xyz(:,2),bed_xyz(:,3), ...
    'linear','nearest');
z_bed=F_bed(x_cell,y_cell);
if any(~isfinite(z_bed))
    error('D3D_initial_waterlevel_flood:MissingBedElevation', ...
        'Bed interpolation did not return a finite elevation at every cell center.');
end

[point_dir,point_name]=fileparts(fpath_waterlevel_points);
waterlevel_points=m_shaperead(fullfile(point_dir,point_name));
if ~strcmpi(waterlevel_points.ctype,'point')
    error('D3D_initial_waterlevel_flood:InvalidWaterLevelGeometry', ...
        'The water-level shapefile must contain point features.');
end
waterlevel_field=find(strcmpi(waterlevel_points.fieldnames,'waterlevel'),1);
if isempty(waterlevel_field)
    error('D3D_initial_waterlevel_flood:MissingWaterLevelField', ...
        'The water-level shapefile must contain a waterlevel field.');
end
point_xy=cell2mat(cellfun(@(xy)xy(1,1:2),waterlevel_points.ncst, ...
    'UniformOutput',false));
point_waterlevel=cell2mat(waterlevel_points.dbfdata(:,waterlevel_field));
if size(point_xy,1)<3 || any(~isfinite(point_xy(:))) || ...
        any(~isfinite(point_waterlevel(:)))
    error('D3D_initial_waterlevel_flood:InvalidWaterLevelPoints', ...
        'At least three water-level points with finite coordinates and values are required.');
end
F_waterlevel=scatteredInterpolant(point_xy(:,1),point_xy(:,2), ...
    point_waterlevel(:),'linear','none');
waterlevel_at_cells=F_waterlevel(x_cell,y_cell);
inside_point_hull=isfinite(waterlevel_at_cells);

point_seed_cells=zeros(size(point_xy,1),1);
for k=1:size(point_xy,1)
    distance_squared=(x_cell-point_xy(k,1)).^2+(y_cell-point_xy(k,2)).^2;
    [~,point_seed_cells(k)]=min(distance_squared);
end

waterlevel=fcn_flood_from_points(grid_info.face_nodes,z_bed, ...
    waterlevel_at_cells,inside_point_hull,point_seed_cells,point_waterlevel);
flooded_cells=isfinite(waterlevel);
xyz=[x_cell(flooded_cells),y_cell(flooded_cells),waterlevel(flooded_cells)];
writematrix(xyz,fpath_output,'FileType','text','Delimiter','space');
fprintf('Flooded from %d water-level points; wrote %d of %d mesh cells to %s\n', ...
    numel(point_seed_cells),size(xyz,1),n_cell,fpath_output);
end %function D3D_initial_waterlevel_flood

function waterlevel=fcn_flood_from_points(face_nodes,z_bed, ...
    waterlevel_at_cells,inside_point_hull,point_seed_cells,point_waterlevel)

n_cell=numel(z_bed);
adjacency=fcn_cell_adjacency(face_nodes,n_cell);
seed_cells_unique=unique(point_seed_cells);
[~,~,seed_group]=unique(point_seed_cells);
seed_level=accumarray(seed_group,point_waterlevel(:),[],@mean);
valid_seed=seed_level>=z_bed(seed_cells_unique);
if ~any(valid_seed)
    error('D3D_initial_waterlevel_flood:NoValidSeeds', ...
        'All water-level points are below the bed at their nearest cell centers.');
end
seed_cells=seed_cells_unique(valid_seed);
seed_level=seed_level(valid_seed);

waterlevel=NaN(n_cell,1);
waterlevel(seed_cells)=seed_level;
queue=zeros(n_cell,1);
queue_tail=numel(seed_cells);
queue(1:queue_tail)=seed_cells;
queue_head=1;
while queue_head<=queue_tail
    cell_index=queue(queue_head);
    queue_head=queue_head+1;
    neighbors=find(adjacency(cell_index,:));
    neighbors=neighbors(:);
    unvisited=~isfinite(waterlevel(neighbors));
    neighbor_level=repmat(waterlevel(cell_index),numel(neighbors),1);
    inside_hull=inside_point_hull(neighbors);
    neighbor_level(inside_hull)=waterlevel_at_cells(neighbors(inside_hull));
    can_flood=unvisited & isfinite(neighbor_level) & ...
        z_bed(neighbors)<=neighbor_level;
    neighbors=neighbors(can_flood);
    if ~isempty(neighbors)
        neighbor_level=neighbor_level(can_flood);
        waterlevel(neighbors)=neighbor_level;
        queue_tail=queue_tail+numel(neighbors);
        queue(queue_tail-numel(neighbors)+1:queue_tail)=neighbors;
    end
end

end %function fcn_flood_from_points

function adjacency=fcn_cell_adjacency(face_nodes,n_cell)

faces=face_nodes.';
n_face=size(faces,1);
n_vertices=sum(isfinite(faces),2);
if n_face~=n_cell || any(n_vertices<3)
    error('D3D_initial_waterlevel_flood:InvalidConnectivity', ...
        'Every mesh cell must have at least three face nodes.');
end

edge_nodes=zeros(0,2);
edge_faces=zeros(0,1);
face_index=(1:n_face).';
for k=1:size(faces,2)
    next_vertex=mod(k,n_vertices)+1;
    next_nodes=faces(sub2ind(size(faces),face_index,next_vertex));
    valid=k<=n_vertices & isfinite(faces(:,k)) & isfinite(next_nodes);
    these_edges=[faces(valid,k),next_nodes(valid)]+1;
    edge_nodes=[edge_nodes;sort(these_edges,2)]; %#ok<AGROW>
    edge_faces=[edge_faces;face_index(valid)]; %#ok<AGROW>
end

[~,~,edge_group]=unique(edge_nodes,'rows');
edge_count=accumarray(edge_group,1);
if any(edge_count>2)
    error('D3D_initial_waterlevel_flood:NonManifoldGrid', ...
        'A mesh edge is shared by more than two cells.');
end
internal_edge=edge_count(edge_group)==2;
internal_group=edge_group(internal_edge);
internal_faces=edge_faces(internal_edge);
[~,order]=sort(internal_group);
cell_pairs=reshape(internal_faces(order),2,[]).';
adjacency=sparse([cell_pairs(:,1);cell_pairs(:,2)], ...
    [cell_pairs(:,2);cell_pairs(:,1)],true,n_cell,n_cell);

end %function fcn_cell_adjacency