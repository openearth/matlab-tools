function varargout = readNet(varargin)
%readNet   Reads network data of a D-Flow FM unstructured net.
%
%     G = dflowfm.readNet(ncfile)
%
%   reads the network network (grid) data from a D-Flow FM NetCDF file.
%    node: corner data
%    edge: links (connections)
%    face (previously cen or peri): flow = circumcenter = center data
%                                   perimeter  = contour data
%         stores FlowElements and NetElements
%
% Implemented are the *_net.nc (input), *_map.nc (output)
% and *_flowgeom.nc (output).
%
%
% See also: dflowfm, delft3d, grid_fun, patch2tri

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arthur van Dam & Gerben de Boer
%
%       <Arthur.vanDam@deltares.nl>; <g.j.deboer@deltares.nl>
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

% TO DO make G a true object with methods etc.

%% Input

OPT.node      = 1; % Read values at nodes
OPT.edge      = 1; % Read values at edges and flow links
OPT.face      = 1; % Read values at faces
OPT.peri2cell = 0; % overall faster when using plotNet with axis, so default 0
OPT.quiet     = 0; % this options switches off all bunch of warnings

if nargin==0
    varargout = {OPT};
    return
else
    ncfile   = varargin{1};
    OPT = setproperty(OPT,varargin{2:end});
end

%% Read network: nodes

G.file.name         = ncfile;

if nc_isvar(ncfile, 'mesh2d_node_x') && OPT.node
    G.node.x             = nc_varget(ncfile, 'mesh2d_node_x')';
    G.node.y             = nc_varget(ncfile, 'mesh2d_node_y')';
    G.node.z             = nc_varget(ncfile, 'mesh2d_node_z')';
    G.node.n             = size(G.node.x,2);
end

%% Read network: edges (links) between nodes

if nc_isvar(ncfile, 'mesh2d_node_x') && OPT.edge 
    G.edge.x                   = nc_varget(ncfile,'mesh2d_edge_x');
    G.edge.y                   = nc_varget(ncfile,'mesh2d_edge_y');
    
    G.edge.NetLink             = nc_varget(ncfile, 'mesh2d_edge_nodes');  
    G.edge.NetLinkSize         = size(G.edge.NetLink      ,2);
    
    G.edge.NetLinkType               = nc_varget(ncfile, 'mesh2d_edge_type'); 
    G.edge.NetLinkTypeFlag.flag_values   = nc_attget(ncfile, 'mesh2d_edge_type','flag_values');
    G.edge.NetLinkTypeFlag.flag_meanings = nc_attget(ncfile, 'mesh2d_edge_type','flag_meanings');
    G.edge.NetLinkTypeFlag.flag_meanings = textscan(G.edge.NetLinkTypeFlag.flag_meanings,'%s','CollectOutput',1);
end

%% Read network: faces (flow nodes)

if nc_isvar(ncfile, 'mesh2d_face_x') && OPT.face
    G.face.FlowElem_x                = nc_varget(ncfile, 'mesh2d_face_x');
    G.face.FlowElem_y                = nc_varget(ncfile, 'mesh2d_face_y');
    try % z value is only available in map-files
        G.face.FlowElem_z            = nc_varget(ncfile, 'mesh2d_flowelem_bl' ); % Bottom level
    end
    G.face.FlowElemSize              = size(G.face.FlowElem_x,2);
end

if nc_isvar(ncfile, 'mesh2d_face_x_bnd') && OPT.face
    G.face.FlowElemCont_x            = nc_varget(ncfile, 'mesh2d_face_x_bnd');
    G.face.FlowElemCont_y            = nc_varget(ncfile, 'mesh2d_face_y_bnd');
    
    G.face.FlowElemCont_x(G.face.FlowElemCont_x > realmax('single')./100)=nc_attget(ncfile, 'mesh2d_face_x_bnd','_FillValue');
    G.face.FlowElemCont_y(G.face.FlowElemCont_y > realmax('single')./100)=nc_attget(ncfile, 'mesh2d_face_y_bnd','_FillValue');
    
    if OPT.peri2cell
        [G.face.FlowElemCont_x ,G.face.FlowElemCont_y] = dflowfm.peri2cell(G.face.FlowElemCont_x ,G.face.FlowElemCont_y);
    end
    
end

if nc_isvar(ncfile, 'mesh2d_face_nodes') && OPT.edge
    G.face.FlowElemNode          = nc_varget(ncfile, 'mesh2d_face_nodes');    
    
    % new pointers for chopping up into triangles to be used in plotMap
    [G.tri,G.map3,G.ntyp] = patch2tri(G.node.x,G.node.y,G.face.FlowElemNode,'quiet',OPT.quiet);
end

%% if only 'file' field is present, .nc file is probably based on old format
if length(fieldnames(G)) == 1
    G = dflowfm.readNetOld(ncfile);
end

%% out

varargout = {G};