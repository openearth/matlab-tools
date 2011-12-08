function handles = ddb_readTiledBathymetries(handles)
%DDB_READTILEDBATHYMETRIES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readTiledBathymetries(handles)
%
%   Input:
%   handles =
%
%   Output:
%   handles =
%
%   Example
%   ddb_readTiledBathymetries
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% When enabled on OpenDAP
% % Check for updates on OpenDAP and add data to structure
% localdir = handles.bathyDir;
% url = 'http://opendap.deltares.nl/thredds/fileServer/opendap/deltares/delftdashboard/bathymetry/bathymetry.xml';
% xmlfile = 'bathymetry.xml';
% handles.bathymetry = ddb_getXmlData(localdir,url,xmlfile);
% 
% % Add specific fields to structure
% fld = fieldnames(handles.bathymetry);
% names = '';longNames = '';
% for ii=1:length(handles.bathymetry.(fld{1}))
%     handles.bathymetry.(fld{1})(ii).useCache = str2double(handles.bathymetry.(fld{1})(ii).useCache);
%     handles.bathymetry.(fld{1})(ii).edit = str2double(handles.bathymetry.(fld{1})(ii).edit);
%     names{ii}= handles.bathymetry.(fld{1})(ii).name;
%     longNames{ii} = handles.bathymetry.(fld{1})(ii).longName;
% end
% handles.bathymetry.datasets = names;
% handles.bathymetry.nrDatasets = length(handles.bathymetry.(fld{1}));

%% For the time being...
if exist([handles.bathyDir '\tiledbathymetries.def'])==2
    txt=ReadTextFile([handles.bathyDir '\tiledbathymetries.def']);
else
    error(['Bathymetry defintion file ''' [handles.bathyDir '\tiledbathymetries.def'] ''' not found!']);
end

k=0;
j=0;

for i=1:length(txt)
    switch lower(txt{i})
        case{'bathymetrydataset'}
            k=k+1;
            j=0;
            handles.bathymetry.nrDatasets=k;
            handles.bathymetry.datasets{k}=txt{i+1};
            handles.bathymetry.dataset(k).longName=txt{i+1};
            handles.bathymetry.dataset(k).type='tiles';
            handles.bathymetry.dataset(k).edit=0;
            handles.bathymetry.dataset(k).useCache=1;
        case{'horizontalcoordinatesystemname'}
            handles.bathymetry.dataset(k).horizontalCoordinateSystem.name=txt{i+1};
        case{'horizontalcoordinatesystemtype'}
            handles.bathymetry.dataset(k).horizontalCoordinateSystem.type=txt{i+1};
        case{'verticalcoordinatesystemname'}
            handles.bathymetry.dataset(k).verticalCoordinateSystem.name=txt{i+1};
        case{'verticalcoordinatesystemlevel'}
            handles.bathymetry.dataset(k).verticalCoordinateSystem.level=str2double(txt{i+1});
        case{'type'}
            handles.bathymetry.dataset(k).type=txt{i+1};
        case{'name'}
            handles.bathymetry.dataset(k).name=txt{i+1};
        case{'url'}
            handles.bathymetry.dataset(k).URL=txt{i+1};
        case{'usecache'}
            if strcmpi(txt{i+1}(1),'y')
                handles.bathymetry.dataset(k).useCache=1;
            else
                handles.bathymetry.dataset(k).useCache=0;
            end
        case{'zoomlevel'}
            j=j+1;
            handles.bathymetry.dataset(k).nrZoomLevels=j;
        case{'directoryname'}
            if j>0
                handles.bathymetry.dataset(k).zoomLevel(j).directoryName=txt{i+1};
            else
                handles.bathymetry.dataset(k).directoryName=txt{i+1};
            end
        case{'filename'}
            handles.bathymetry.dataset(k).zoomLevel(j).fileName=txt{i+1};
        case{'tilesize'}
            if strcmpi(handles.bathymetry.dataset(k).horizontalCoordinateSystem.Type,'geographic')
                handles.bathymetry.dataset(k).zoomLevel(j).tileSize(1)=str2double(txt{i+1});
                handles.bathymetry.dataset(k).zoomLevel(j).tileSize(2)=str2double(txt{i+2});
                handles.bathymetry.dataset(k).zoomLevel(j).tileSize(3)=str2double(txt{i+3});
            else
                handles.bathymetry.dataset(k).zoomLevel(j).tileSize=str2double(txt{i+1});
            end
        case{'gridcellsize'}
            if strcmpi(handles.bathymetry.dataset(k).horizontalCoordinateSystem.Type,'geographic')
                handles.bathymetry.dataset(k).zoomLevel(j).gridCellSize(1)=str2double(txt{i+1});
                handles.bathymetry.dataset(k).zoomLevel(j).gridCellSize(2)=str2double(txt{i+2});
                handles.bathymetry.dataset(k).zoomLevel(j).gridCellSize(3)=str2double(txt{i+3});
            else
                handles.bathymetry.dataset(k).zoomLevel(j).gridCellSize=str2double(txt{i+1});
            end
        case{'zoomlimits'}
            handles.bathymetry.dataset(k).zoomLevel(j).zoomLimits(1)=str2double(txt{i+1});
            handles.bathymetry.dataset(k).zoomLevel(j).zoomLimits(2)=str2double(txt{i+2});
        case{'nrzoomlevels'}
            handles.bathymetry.dataset(k).nrZoomLevels=str2double(txt{i+1});
        case{'xorigin'}
            handles.bathymetry.dataset(k).xOrigin=str2double(txt{i+1});
        case{'yorigin'}
            handles.bathymetry.dataset(k).yOrigin=str2double(txt{i+1});
        case{'dx'}
            handles.bathymetry.dataset(k).dX=str2double(txt{i+1});
        case{'dy'}
            handles.bathymetry.dataset(k).dY=str2double(txt{i+1});
        case{'maxtilesize'}
            handles.bathymetry.dataset(k).maxTileSize=str2double(txt{i+1});
        case{'nrcells'}
            handles.bathymetry.dataset(k).nrCells=str2double(txt{i+1});
        case{'refinementfac'}
            handles.bathymetry.dataset(k).refinementFactor=str2double(txt{i+1});
    end
end

