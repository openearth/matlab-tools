function varargin = KMLmesh(lat,lon,varargin)
% KMLMESH Just like mesh
%
%    KMLmesh(lat,lon,z,<keyword,value>)
% 
% KMLmesh differs from KMLpcolor in the sense that KMLmesh
% plots actual lines, whereas KMLpcolor plots patches. 
% KMLline objects loads an order of mangitude FASTER in Google Earth. 
% Consequently, KMLline does not color the mesh as a function of as MESH 
% does. Use KMLpcolor or KMLsurf instead for meshes colorized by z value.
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLmesh()
%
% See also: googlePlot, KMLpcolor, mesh, pcolor

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@Deltares.nl
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

% TO DO: patches without outlines, outline as separate polygons, to prevent course resolution lines at low angles
% KMLline(lat,lon)
% KMLline(lat',lon')

%% process <keyword,value>

   OPT            = KMLline();

   if nargin==0
      varargout = {OPT};
      return
   end

%% see if height is defined

   if ~isempty(varargin)
       if ~ischar(varargin{1});
           z = varargin{1};
           varargin = varargin(2:length(varargin));
           OPT.is3D        = true;      
       end
   end
   
   [OPT, Set, Default] = setProperty(OPT, varargin);

%% get filename, gui for filename, if not set yet

   if isempty(OPT.fileName)
      [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as',[mfilename,'.kml']);
      OPT.fileName = fullfile(filePath,fileName);
   end

%% set kmlName if it is not set yet

   if isempty(OPT.kmlName)
      [ignore OPT.kmlName] = fileparts(OPT.fileName);
   end

%% make mesh

   kmlcode = [];
   if OPT.is3D
   kmlcode = [kmlcode KMLline(lat ,lon ,z ,varargin{:})];
   kmlcode = [kmlcode KMLline(lat',lon',z',varargin{:})]; % overwrites previous one
   else
   kmlcode = [kmlcode KMLline(lat ,lon ,varargin{:})];
   kmlcode = [kmlcode KMLline(lat',lon',varargin{:})]; % overwrites previous one
   end

%% start KML

   OPT.fid=fopen(OPT.fileName,'w');

%% HEADER

   OPT_header = struct(...
              'name',OPT.kmlName,...
              'open',0,...
       'description',OPT.description);
   output = KML_header(OPT_header);
   fprintf(OPT.fid,output);

% print output

   fprintf(OPT.fid,kmlcode);

%% close KML

   output = KML_footer;
   fprintf(OPT.fid,output);
   fclose(OPT.fid);

%% compress to kmz?

   if strcmpi  ( OPT.fileName(end-2:end),'kmz')
       movefile( OPT.fileName,[OPT.fileName(1:end-3) 'kml'])
       zip     ( OPT.fileName,[OPT.fileName(1:end-3) 'kml']);
       movefile([OPT.fileName '.zip'],OPT.fileName)
       delete  ([OPT.fileName(1:end-3) 'kml'])
   end

%% openInGoogle?

   if OPT.openInGE
       system(OPT.fileName);
   end
   
%% EOF
