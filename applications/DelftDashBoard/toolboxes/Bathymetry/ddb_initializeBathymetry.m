function handles = ddb_initializeBathymetry(handles, varargin)
%DDB_INITIALIZEBATHYMETRY  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeBathymetry(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeBathymetry
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
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
ii=strmatch('Bathymetry',{handles.Toolbox(:).name},'exact');

% handles=ddb_readTiledBathymetries(handles);
% handles.Bathymetry.Dataset=[];
% handles.Bathymetry.Datasets={'GEBCO','Etopo2','SRTM'};
% handles.Bathymetry.NrDatasets=3;
handles.Toolbox(ii).Input.activeDataset=1;
handles.Toolbox(ii).Input.polyLength=0;
handles.Toolbox(ii).Input.polygonFile='';

handles.Toolbox(ii).Input.bathyFile='';
handles.Toolbox(ii).Input.newbathyName='';
handles.Toolbox(ii).Input.newbathyresolution=0;

handles.Toolbox(ii).Input.activeZoomLevel=1;
handles.Toolbox(ii).Input.zoomLevelText={'1'};
handles.Toolbox(ii).Input.resolutionText='1';

handles.Toolbox(ii).Input.exportTypes={'xyz'};
handles.Toolbox(ii).Input.activeExportType='xyz';

handles.Toolbox(ii).Input.activeDirection='up';

handles.Toolbox(ii).Input.datum_type='Mean Sea Level';
handles.Toolbox(ii).Input.offset_value=0;

%handles.Bathymetry.activeDataset=1;

% for i=1:3
%     handles.Bathymetry.Dataset(i).Name=handles.Bathymetry.Datasets{i};
%     handles.Bathymetry.Dataset(i).HorizontalCoordinateSystem.Name='WGS 84';
%     handles.Bathymetry.Dataset(i).HorizontalCoordinateSystem.Type='Geographic';
%     handles.Bathymetry.Dataset(i).VerticalCoordinateSystem.Name='Mean Sea Level';
%     handles.Bathymetry.Dataset(i).VerticalCoordinateSystem.Level=0;
%     handles.Bathymetry.Dataset(i).Type='tiles';
%     handles.Bathymetry.Dataset(i).Edit=0;
%     handles.Bathymetry.Dataset(i).FileName='';
% end

handles.Toolbox(ii).Input.usedDataset=[];
handles.Toolbox(ii).Input.usedDatasets={''};
handles.Toolbox(ii).Input.nrUsedDatasets=0;
handles.Toolbox(ii).Input.activeUsedDataset=1;

handles.Toolbox(ii).Input.newDataset.xmin=0;
handles.Toolbox(ii).Input.newDataset.xmax=0;
handles.Toolbox(ii).Input.newDataset.dx=0;
handles.Toolbox(ii).Input.newDataset.ymin=0;
handles.Toolbox(ii).Input.newDataset.ymax=0;
handles.Toolbox(ii).Input.newDataset.dy=0;

handles.Toolbox(ii).Input.num_merge = 0;
handles.Toolbox(ii).Input.add_list = {};
handles.Toolbox(ii).Input.bathy_to_cut = [];
handles.Toolbox(ii).Input.add_list_idx = [];

handles.Toolbox(ii).Input.rectanglehandle=[];
handles.Toolbox(ii).Input.rectanglex0=[];
handles.Toolbox(ii).Input.rectanglex0=[];
handles.Toolbox(ii).Input.rectangledx=[];
handles.Toolbox(ii).Input.rectangledy=[];
