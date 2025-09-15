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
%Read FLORIS FUNIN file. 

function network=floris_to_fm_create_grid(network,csl,csd_add,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fid_log',NaN)

parse(parin,varargin{:})

fid_log=parin.Results.fid_log; 

%% START

messageOut(fid_log,'Start processing FUNIN.')

%% UNPACK DATA

v2struct(network); %A bit hidden. It unpacks network data
% network_branch_id=network.network_branch_id; %better to specify each of them?

offset_csl=[csl.chainage];
branch_id_csl={csl.branchId};

%We assume that there is one cross-section definition for each
%cross-section location and that they have the same order. An alternative
%if this data is not present is to interpolate between the coordinates of
%the nodes at the beginning and end of each branch.
x_csl=mean([csd_add.x_left;csd_add.x_right],1)';
y_csl=mean([csd_add.y_left;csd_add.y_right],1)';

%% DIMENSIONS

network_nEdges=numel(network_branch_id); %i.e., number of branches
network_nNodes=numel(network_node_id);
mesh1d_nNodes=numel(offset_csl);
mesh1d_nEdges=mesh1d_nNodes-network_nEdges; %first each branch is full

%% ALLOCATE

network_edge_length=NaN(network_nEdges,1);
network_geom_node_count=NaN(network_nEdges,1);
network_branch_order=NaN(network_nEdges,1);
network_branch_type=NaN(network_nEdges,1);

mesh1d_node_branch=NaN(mesh1d_nNodes,1);
mesh1d_node_offset=NaN(mesh1d_nNodes,1);
mesh1d_node_x=NaN(mesh1d_nNodes,1);
mesh1d_node_y=NaN(mesh1d_nNodes,1);

mesh1d_edge_branch=NaN(mesh1d_nEdges,1);
mesh1d_edge_offset=NaN(mesh1d_nEdges,1);
mesh1d_edge_x=NaN(mesh1d_nEdges,1);
mesh1d_edge_y=NaN(mesh1d_nEdges,1);
mesh1d_edge_nodes=NaN(2,mesh1d_nEdges);

%% CREATE SEPARATE BRANCHES

% idx_network_geom_0=1;
idx_mesh1d_edge_0=1;

%loop on branches
for kb=1:network_nEdges
    branch_id=network_branch_id{kb};
    bol_branch=strcmp(branch_id_csl,branch_id);

    %length of each geometry branch
    %Assume that there is a cross-section at the beginning and end of each
    %branch, and that the offset is the same as the network length.
    offset_branch=offset_csl(bol_branch);
    x_csl_branch=x_csl(bol_branch);
    y_csl_branch=y_csl(bol_branch);

    max_offset=max(offset_branch);
    network_edge_length(kb)=max_offset;

    network_branch_order(kb)=-1; %!ATTENTION I think this is only for visualization, but we should be careful. 
    network_branch_type(kb)=4; %1D

    %mesh1d
        %node
    mesh1d_node_branch(bol_branch)=kb-1; %0-based
    mesh1d_node_offset(bol_branch)=offset_branch;
    mesh1d_node_x(bol_branch)=x_csl_branch;
    mesh1d_node_y(bol_branch)=y_csl_branch;

        %edge
    nnodes=numel(offset_branch);
    nedges=nnodes-1;
    idx_mesh1d_edge_1=idx_mesh1d_edge_0+nedges-1;
    idx_edge=idx_mesh1d_edge_0:1:idx_mesh1d_edge_1;

    mesh1d_edge_offset(idx_edge)=cor2cen(offset_branch);
    mesh1d_edge_branch(idx_edge)=kb-1;
    mesh1d_edge_x(idx_edge)=cor2cen(x_csl_branch);
    mesh1d_edge_y(idx_edge)=cor2cen(y_csl_branch);

    idx_mesh1d_node=find(bol_branch);
    edge_nodes=[idx_mesh1d_node(1:end-1);idx_mesh1d_node(2:end)]-1; %0-based
    mesh1d_edge_nodes(:,idx_edge)=edge_nodes;


    idx_mesh1d_edge_0=idx_mesh1d_edge_1+1;
end

% %% BEGIN DEBUG
% 
% cmap=lines(network_nEdges);
% figure
% hold on
% axis equal
% for kb=1:network_nEdges
%     bol_br=mesh1d_node_branch==kb-1; %starts at 0
%     plot(mesh1d_node_x(bol_br),mesh1d_node_y(bol_br),'o','color',cmap(kb,:))
% end
% 
% for kb=1:network_nEdges
%     bol_br=mesh1d_edge_branch==kb-1; %starts at 0
%     plot(mesh1d_edge_x(bol_br),mesh1d_edge_y(bol_br),'+','color',cmap(kb,:))
% end
% 
% for kl=1:numel(mesh1d_edge_x)
%     kb=mesh1d_edge_branch(kl)+1;
%     plot(mesh1d_node_x(mesh1d_edge_nodes(:,kl)+1),mesh1d_node_y(mesh1d_edge_nodes(:,kl)+1),'color',cmap(kb,:))
% end
% 
% % END DEBUG

%% JOIN BRANCHES

%loop on network nodes
for kn=1:network_nNodes

    network_node_idx=kn-1; %0-based index of the network node.

    network_edge_nodes_loc_bol=network_edge_nodes==network_node_idx; %branches (rows) where the node under consideration is found as starting node of the branch (column 1) or end node of the branch (column 2).

    network_nodes_loc_sum=sum(network_edge_nodes_loc_bol,1); %total number of branches in which the node under consideration is found as starting and end node.

    %The node under consideration...
    if any(network_nodes_loc_sum==0)
        %is not found at the start or at the end of any branch. I.e., if it
        %is at the start of a branch, is not found at the end and
        %viceversa. It is a boundary node. There is nothing to be done to
        %such a branch.
        continue
    elseif isequal(network_nodes_loc_sum,[1,1])
        %is found once at the start and once at the end of a branch. It is
        %connecting only two branches. I.e., it could be removed. It does 
        %not matter if it is treated as bifurcation or confluence. 
        is_bifurcation=true;
    elseif network_nodes_loc_sum(1)==1 && network_nodes_loc_sum(2)>1
        %is the initial node of one branch and the final node of several 
        %branches.
        is_bifurcation=false;
    elseif network_nodes_loc_sum(1)>1 && network_nodes_loc_sum(2)==1
        %is the initial node of several branches and the final node of only
        %one branch.
        is_bifurcation=true;
    else 
        error('Case not considered.')
    end
    
    %`kb` is the index of the branch which is connected to several
    %branches.
    if is_bifurcation
        kb=find(network_edge_nodes_loc_bol(:,2));
    else
        kb=find(network_edge_nodes_loc_bol(:,1));
    end
    if numel(kb)>1
        error('`kb` must be a unique index.')
    end

    [mesh1d_edge_offset,mesh1d_edge_branch,mesh1d_node_offset,network_edge_length,mesh1d_edge_nodes,mesh1d_edge_x,mesh1d_edge_y]=connect_node(fid_log,is_bifurcation,kb,mesh1d_edge_nodes,mesh1d_edge_x,mesh1d_edge_y,mesh1d_node_branch,network_edge_nodes,network_branch_id,mesh1d_node_x,mesh1d_node_y,mesh1d_edge_offset,mesh1d_edge_branch,mesh1d_node_offset,network_edge_length);

end %network_nNodes

%% REORDER

%In D3D it is assumed that all links of each branch are ordered in offset.
%We break this when adding the connection ones. Here we reorder them. 

idx_order=NaN(size(mesh1d_edge_offset));
idx_first=1;
for kb=1:network_nEdges
    branch_idx=kb-1; %0-based index of the branch
    mesh1d_edge_branch_loc_bol=mesh1d_edge_branch==branch_idx;
    mesh1d_edge_branch_loc_idx=find(mesh1d_edge_branch_loc_bol);
    [~,idx_sort_loc]=sort(mesh1d_edge_offset(mesh1d_edge_branch_loc_bol));
    mesh1d_edge_branch_loc_sort=mesh1d_edge_branch_loc_idx(idx_sort_loc);

    nel=numel(idx_sort_loc);
    idx_order(idx_first:idx_first+nel-1)=mesh1d_edge_branch_loc_sort;

    %update first item
    idx_first=idx_first+nel;

end %network_nEdges

%reorder
mesh1d_edge_branch=mesh1d_edge_branch(idx_order);
mesh1d_edge_offset=mesh1d_edge_offset(idx_order);
mesh1d_edge_x=mesh1d_edge_x(idx_order);
mesh1d_edge_y=mesh1d_edge_y(idx_order);
mesh1d_edge_nodes=mesh1d_edge_nodes(:,idx_order);

%% GEOMETRY NETWORK

%Copy mesh1d_node to network_node
network_geom_x=NaN(size(mesh1d_node_x));
network_geom_y=network_geom_x;

for kb=1:network_nEdges
    branch_idx=kb-1; %0-based index of the branch
    mesh1d_node_branch_loc_bol=mesh1d_node_branch==branch_idx; %boolean of mesh1d_node of the branch

    network_geom_x(mesh1d_node_branch_loc_bol)=mesh1d_node_x(mesh1d_node_branch_loc_bol);
    network_geom_y(mesh1d_node_branch_loc_bol)=mesh1d_node_y(mesh1d_node_branch_loc_bol);
    network_geom_node_count(kb)=sum(mesh1d_node_branch_loc_bol);
end %network_nEdges

%% NAMES

network_node_long_name=network_node_id;
network_branch_long_name=network_branch_id;

n_mesh1d_node=numel(mesh1d_node_branch);
mesh1d_node_id=cell(n_mesh1d_node,1);
for k=1:n_mesh1d_node
    mesh1d_node_id{k}=sprintf('%02d_%10.5f',mesh1d_node_branch(k),mesh1d_node_offset(k));
end %n_mesh1d_node

mesh1d_node_long_name=mesh1d_node_id;

%% PACK

network=v2struct(network_edge_nodes,network_branch_id,network_branch_long_name,network_edge_length,network_node_id,network_node_long_name,network_node_x,network_node_y, ...
                network_geom_node_count,network_geom_x,network_geom_y,network_branch_order,network_branch_type, ...
                mesh1d_node_branch,mesh1d_node_offset,mesh1d_node_x,mesh1d_node_y,mesh1d_edge_branch,mesh1d_edge_offset,mesh1d_edge_x,mesh1d_edge_y,mesh1d_node_id,mesh1d_node_long_name,mesh1d_edge_nodes ...
                );

end %function

%%
%% FUNCTIONS
%%

function [mesh1d_edge_offset,mesh1d_edge_branch,mesh1d_node_offset,network_edge_length,mesh1d_edge_nodes,mesh1d_edge_x,mesh1d_edge_y]=connect_node(fid_log,is_bifurcation,kb,mesh1d_edge_nodes,mesh1d_edge_x,mesh1d_edge_y,mesh1d_node_branch,network_edge_nodes,network_branch_id,mesh1d_node_x,mesh1d_node_y,mesh1d_edge_offset,mesh1d_edge_branch,mesh1d_node_offset,network_edge_length)

%Names are set for the bifurcation case. These are reversed for the
%confluence case. 

if is_bifurcation
    str_origin='last';
    index_origin=2;
    index_dest=1;
    str_dest='first';
else
    str_origin='first';
    index_origin=1;
    index_dest=2;
    str_dest='last';
end

%connect final mesh1d_node of the current branch to first
%mesh1d_node of the branch of the destination network_node

%                                                                  modified branch 2                                               
% 
%                                               ├──────────────────────────────────────────────────────┤                           
% 
%            branch 1                                                      branch 2                                                
% 
% ├────────────────────────────────────────────┤             ├─────────────────────────────────────────┤                           
% 
% 
% 0───│───0───────│───────0─────────│──────────0------|------0───│────0─────│─────0─────────│──────────0                           
% 
% 
% 1       2               3                    3             1        2           3                    4      flow nodes           
% 
%     1           2                                              1          2               3                 original flow links  
% 
%                                                     1          2          3                                 modified flow links  
% 
% 

branch_origin=kb-1; %0-based index of the origin branch
mesh1d_node_branch_loc_bol=mesh1d_node_branch==branch_origin; %boolean of mesh1d_node of the origin branch
mesh1d_node_connection_origin_midx=find(mesh1d_node_branch_loc_bol==1,1,str_origin); %Matlab index of the mesh1d_node of the origin branch connecting to the destination branch

network_edge_nodes_loc=network_edge_nodes(kb,:); %origin and destination network_node of the origin branch
network_edge_nodes_dest=network_edge_nodes_loc(index_origin); %destination network_node of the origin branch
branch_dest_v=find(network_edge_nodes(:,index_dest)==network_edge_nodes_dest)-1; %0-based index of the destination branches. I.e., branches that have as origin the destination node of the origin branch

ndest=numel(branch_dest_v); %number of destination branches to which the origin branch is connected

%loop through destination branches
for kdest=1:ndest
    
    branch_dest_idx=branch_dest_v(kdest); %0-based index of the destination branch
    branch_dest_midx=branch_dest_idx+1; %Matlab index of the destination branch

    messageOut(fid_log,sprintf('Modifying branch %02d, %s',branch_dest_idx,network_branch_id{branch_dest_idx+1}))

    mesh1d_node_branch_dest_bol=mesh1d_node_branch==branch_dest_idx; %boolean of the mesh1d_node of the destination branch
    mesh1d_node_connection_dest_midx=find(mesh1d_node_branch_dest_bol==1,1,str_dest); %Matlab index of the mesh1d_node of the destination branch connecting to the origin branch

    mesh1d_edge_node_loc_midx=[mesh1d_node_connection_origin_midx;mesh1d_node_connection_dest_midx]; %Matlab indices of the mesh1d_node connecting origin and destination branch
    if ~is_bifurcation
        mesh1d_edge_node_loc_midx=flipud(mesh1d_edge_node_loc_midx);
    end
    mesh1d_edge_node_loc_idx=mesh1d_edge_node_loc_midx-1; %0-based indices of the mesh1d_node connecting origin and destination branch
    mesh1d_edge_x_loc=mean(mesh1d_node_x(mesh1d_edge_node_loc_midx));
    mesh1d_edge_y_loc=mean(mesh1d_node_y(mesh1d_edge_node_loc_midx));

    mesh1d_edge_nodes=cat(2,mesh1d_edge_nodes,mesh1d_edge_node_loc_idx);
    mesh1d_edge_x=cat(1,mesh1d_edge_x,mesh1d_edge_x_loc);
    mesh1d_edge_y=cat(1,mesh1d_edge_y,mesh1d_edge_y_loc);

    %compute distance between final node of origin branch and first
    %node of destination branch
    mesh1d_node_connection_dist_x=mesh1d_node_x(mesh1d_node_connection_dest_midx)-mesh1d_node_x(mesh1d_node_connection_origin_midx); %`x` distance between mesh1d_nodes at origin and destination of connection
    mesh1d_node_connection_dist_y=mesh1d_node_y(mesh1d_node_connection_dest_midx)-mesh1d_node_y(mesh1d_node_connection_origin_midx); %`y` distance between mesh1d_nodes at origin and destination of connection
    mesh1d_node_connection_dist=hypot(mesh1d_node_connection_dist_x,mesh1d_node_connection_dist_y); %mesh1d_node distance between origin and destination

    mesh1d_edge_connection_dist=mesh1d_node_connection_dist/2; %mesh1d_edge is at halfway distance between mesh1d_nodes

    mesh1d_edge_branch_dest_bol=mesh1d_edge_branch==branch_dest_idx; 
    mesh1d_edge_offset_dest=mesh1d_edge_offset(mesh1d_edge_branch_dest_bol); %original offset of the existing mesh1d_edge at destination branch
    mesh1d_edge_offset_dest=mesh1d_edge_offset_dest+mesh1d_node_connection_dist; %new offset of the existing mesh1d_edge at destination branch

    mesh1d_node_offset_dest=mesh1d_node_offset(mesh1d_node_branch_dest_bol);

    if is_bifurcation
        mesh1d_edge_offset(mesh1d_edge_branch_dest_bol)=mesh1d_edge_offset_dest; %assing new value of existing mesh1d_edge
        mesh1d_node_offset(mesh1d_node_branch_dest_bol)=mesh1d_node_offset(mesh1d_node_branch_dest_bol)+mesh1d_node_connection_dist; %adjust offset of mesh1d_node of destination branch   
        dist0=0;
    else
        dist0=mesh1d_node_offset_dest(end);
    end

    mesh1d_edge_offset_new=mesh1d_edge_connection_dist+dist0;

    mesh1d_edge_offset=cat(1,mesh1d_edge_offset,mesh1d_edge_offset_new); %assign new value of new mesh1d_edge

    mesh1d_edge_branch=cat(1,mesh1d_edge_branch,branch_dest_idx); %added edge pertains to the destination branch

    network_edge_length(branch_dest_midx)=network_edge_length(branch_dest_midx)+mesh1d_node_connection_dist; %new length of the destination branch        
end %ndest

end %function