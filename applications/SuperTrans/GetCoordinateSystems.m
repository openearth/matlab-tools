function varargout=GetCoordinateSystems(handles)
%GETCOORDINATESYSTEMS   load database with Coordinate Systems
%
% handles = GetCoordinateSystems
%
% [CoordinateSystems,...
%  Operations,...
%  CoordSysCart,...
%  CoordSysGeo]= GetCoordinateSystems
%
% loads struct handles with (meta-)info of all CoordinateSystems
% as stored in CoordinateSystems.mat (can take ~ 7 seconds) sorted in fields
%  * CoordinateSystems
%  * Operations
%  * CoordSysCart
%  * CoordSysGeo
%
% The database was created from elements of the <a href="http://trac.osgeo.org/gdal/wiki/DownloadSource">gdal library</a>.
%
%See also: SuperTrans = GetCoordinateSystems > SelectCoordinateSystem > ConvertCoordinates

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl	
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
% $Keywords:$

% 2009 mar 31: added documentation [Gerben de Boer]

   curdir=fileparts(which('SuperTrans'));
   load([curdir '\data\CoordinateSystems.mat']);
   load([curdir '\data\Operations.mat']);
   
   handles.CoordinateSystems=CoordinateSystems;
   handles.Operations       =Operations;
   
   nproj=0;
   ngeo=0;
   for i=1:length(handles.CoordinateSystems)
       switch lower(handles.CoordinateSystems(i).coord_ref_sys_kind),
           case{'projected'}
               nproj =nproj+1;
               CSProj=handles.CoordinateSystems(i);
               handles.CoordSysCart{nproj}=CSProj.coord_ref_sys_name;
           case{'geographic 2d'}
               ngeo =ngeo+1;
               CSGeo                    =handles.CoordinateSystems(i);
               handles.CoordSysGeo{ngeo}=CSGeo.coord_ref_sys_name;
       end
   end
   
   if     nargout==1
        varargout = {handles};
   elseif nargout==2
        varargout = {handles.CoordinateSystems,...
                     handles.Operations };
   elseif nargout==3
        varargout = {handles.CoordinateSystems,...
                     handles.Operations ,...
                     handles.CoordSysCart };
   elseif nargout==4
        varargout = {handles.CoordinateSystems,...
                     handles.Operations ,...
                     handles.CoordSysCart ,...
                     handles.CoordSysGeo };
   end

%%EOF