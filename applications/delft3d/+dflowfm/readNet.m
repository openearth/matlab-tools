function varargout = readNet(varargin)
%readNet   Reads network data of a D-Flow FM unstructured net.
%
%     G = dflowfm.readNet(ncfile) 
%
%   reads the network network (grid) data from a D-Flow FM NetCDF file. 
%    cor: node = corner data (incl. connectivity)
%    cen: flow = circumcenter = center data (incl. connectivity)
%   peri: perimeter  = contour data
%   face: links (connections)
%
% Implemented are the *_net.nc (input), *_map.nc (output)
% and *_flowgeom.nc (output).
%
% NOTE: cor and cen are exactly identical objects but their 
% meaning in the network differs. G.link contains the relation
% between the cor and cen object.
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

%% input

   OPT.peri2cell = 0; % overall faster when using plotNet with axis, so default 0
   OPT.cen       = 0; % whether to load cen data 
   OPT.cor       = 0; % ,,
   OPT.peri      = 1; % ,,
   OPT.link      = 1; % ,,
   OPT.face      = 0; % ,,
   OPT.quiet     = 0; % ,,
   
   if nargin==0
      varargout = {OPT};
      return
   else
      ncfile   = varargin{1};
      OPT = setproperty(OPT,varargin{2:end});
   end

%% read network: corners only: input file

   G.file.name         = ncfile;
   
   if nc_isvar(ncfile, 'NetNode_x'); % not for *_flowgeom.nc
   G.cor.x             = nc_varget(ncfile, 'NetNode_x')';
   G.cor.y             = nc_varget(ncfile, 'NetNode_y')';
   G.cor.z             = nc_varget(ncfile, 'NetNode_z')';
   G.cor.n             = size(G.cor.x,2);
   end
   
%% read network: links between corners only: input file

   if nc_isvar(ncfile, 'NetNode_x'); % not for *_flowgeom.nc
   G.cor.Link          = nc_varget(ncfile, 'NetLink')';     % link between two netnodes
   G.cor.LinkType      = nc_varget(ncfile, 'NetLinkType')'; % link between two netnodes
   G.cor.nLink         = size(G.cor.Link      ,2);
   
   G.cor.flag_values   = nc_attget(ncfile, 'NetLinkType','flag_values');
   G.cor.flag_meanings = nc_attget(ncfile, 'NetLinkType','flag_meanings');
   G.cor.flag_meanings = strread(G.cor.flag_meanings,'%s');
   end
 
%% < read network: centers too: output file >

   if nc_isvar(ncfile, 'FlowElem_xcc');
   G.cen.x             = nc_varget(ncfile, 'FlowElem_xcc')';
   G.cen.y             = nc_varget(ncfile, 'FlowElem_ycc')';
   G.cen.z             = nc_varget(ncfile, 'FlowElem_bl' )'; % Bottom level
   G.cen.n             = size(G.cen.x,2);
   end
   
% parallel: read cell domain number
   if nc_isvar(ncfile, 'FlowElemDomain')
       G.cen.idmn      = nc_varget(ncfile, 'FlowElemDomain')';
   end
   
%% < read network: contours too: output file >

   if nc_isvar(ncfile, 'FlowElemContour_x');
   
   G.peri.x            = nc_varget(ncfile, 'FlowElemContour_x')';
   G.peri.y            = nc_varget(ncfile, 'FlowElemContour_y')';
   
   % TO DO: use _fillvalue for this.
   G.peri.x(G.peri.x > realmax('single')./100)=nan;
   G.peri.y(G.peri.y > realmax('single')./100)=nan;
   
   if OPT.peri2cell
   
   [G.peri.x ,G.peri.y] = dflowfm.peri2cell(G.peri.x ,G.peri.y);
   
   end % OPT.peri2cell
   
%% < read network: links between centers too: output file >

   if nc_isvar(ncfile, 'FlowElemContour_x');
   
   G.cen.Link          = nc_varget(ncfile, 'FlowLink')';     % link between two flownodes
   G.cen.LinkType      = nc_varget(ncfile, 'FlowLinkType')'; % link between two flownodes
   G.cen.nLink         = size(G.cen.Link      ,2);

   G.cen.flag_values   = nc_attget(ncfile, 'FlowLinkType','flag_values');
   G.cen.flag_meanings = nc_attget(ncfile, 'FlowLinkType','flag_meanings');
   G.cen.flag_meanings = strread(G.cen.flag_meanings,'%s');
   
   end 

%% < read network: links between corners and centers too: output file >

   if nc_isvar(ncfile, 'NetElemNode') & OPT.link
   
   % make sure orientation is [n x 6], just like a delaunay tri is [n x 3]
   G.link              = nc_varget(ncfile, 'NetElemNode');
   G.bnd               = nc_varget(ncfile, 'BndLink')';
   
      if nc_isvar(ncfile, 'NetNode_x')
      % new pointers for chopping up into triangles to be used in plotMap
     [G.tri,G.map3,G.ntyp] = patch2tri(G.cor.x,G.cor.y,G.link,'quiet',OPT.quiet);
      end

   end 

%% < read network: faces too: output file >

   if nc_isvar(ncfile, 'FlowLink_xu') & OPT.face
   
   G.face.x              = nc_varget(ncfile, 'FlowLink_xu')';
   G.face.y              = nc_varget(ncfile, 'FlowLink_yu')';
  %G.face.z              = nc_varget(ncfile, 'FlowLink_zu')';
  
     if nc_isvar(ncfile, 'FlowLinkDomain') & OPT.face
         G.face.idmn     = nc_varget(ncfile, 'FlowLinkDomain')';
     end

   end
   
   end

%% out

   varargout = {G};