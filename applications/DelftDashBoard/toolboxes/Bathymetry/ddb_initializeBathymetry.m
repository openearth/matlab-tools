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
handles.Toolbox(ii).Input.bathy_to_cut = 1;
handles.Toolbox(ii).Input.add_list_idx = [];

handles.Toolbox(ii).Input.rectanglehandle=[];
handles.Toolbox(ii).Input.rectanglex0=[];
handles.Toolbox(ii).Input.rectanglex0=[];
handles.Toolbox(ii).Input.rectangledx=[];
handles.Toolbox(ii).Input.rectangledy=[];

%% Import

handles.Toolbox(ii).Input.import.x0=0;
handles.Toolbox(ii).Input.import.y0=0;
handles.Toolbox(ii).Input.import.nx=300;
handles.Toolbox(ii).Input.import.ny=300;
handles.Toolbox(ii).Input.import.dx=0;
handles.Toolbox(ii).Input.import.dy=0;
handles.Toolbox(ii).Input.import.nrZoom=5;

handles.Toolbox(ii).Input.import.dataFile='';
handles.Toolbox(ii).Input.import.dataName='';
handles.Toolbox(ii).Input.import.datasource='';
handles.Toolbox(ii).Input.import.dataDir=[handles.bathymetry.dir];

% Raw data formats
handles.Toolbox(ii).Input.import.rawDataFormats{1}='arcinfogrid';
handles.Toolbox(ii).Input.import.rawDataFormatsText{1}='ArcInfo ASCII grid';
handles.Toolbox(ii).Input.import.rawDataFormatsExtension{1}='*.asc';
handles.Toolbox(tb).Input.bathymetry.rawDataFormatsType{1}='regulargrid';        

handles.Toolbox(ii).Input.import.rawDataFormats{2}='arcbinarygrid';
handles.Toolbox(ii).Input.import.rawDataFormatsText{2}='Arc Binary Grid';
handles.Toolbox(ii).Input.import.rawDataFormatsExtension{2}='*.adf';
handles.Toolbox(ii).Input.import.rawDataFormatsType{2}='regulargrid';        

handles.Toolbox(ii).Input.import.rawDataFormats{3}='matfile';
handles.Toolbox(ii).Input.import.rawDataFormatsText{3}='Mat File';
handles.Toolbox(ii).Input.import.rawDataFormatsExtension{3}='*.mat';
handles.Toolbox(ii).Input.import.rawDataFormatsType{3}='regulargrid';        

handles.Toolbox(ii).Input.import.rawDataFormats{4}='netcdf';
handles.Toolbox(ii).Input.import.rawDataFormatsText{4}='netCDF File';
handles.Toolbox(ii).Input.import.rawDataFormatsExtension{4}='*.nc';
handles.Toolbox(tb).Input.bathymetry.rawDataFormatsType{4}='regulargrid';        

handles.Toolbox(ii).Input.import.rawDataFormats{5}='adcircgrid';
handles.Toolbox(ii).Input.import.rawDataFormatsText{5}='ADCIRC grid';
handles.Toolbox(ii).Input.import.rawDataFormatsExtension{5}='*.grd';
handles.Toolbox(ii).Input.import.rawDataFormatsType{5}='unstructured';        

% handles.Toolbox(ii).Input.import.rawDataFormats{6}='xyz';
% handles.Toolbox(ii).Input.import.rawDataFormatsText{6}='XYZ File';
% handles.Toolbox(ii).Input.import.rawDataFormatsExtension{6}='*.xyz';
% handles.Toolbox(ii).Input.import.rawDataFormatsType{6}='unstructured';        

handles.Toolbox(ii).Input.import.rawDataFormat=handles.Toolbox(ii).Input.import.rawDataFormats{1};
handles.Toolbox(ii).Input.import.rawDataFormatExtension=handles.Toolbox(ii).Input.import.rawDataFormatsExtension{1};
handles.Toolbox(ii).Input.import.rawDataFormatSelectionText=['Select Data File (' handles.Toolbox(ii).Input.import.rawDataFormatsText{1} ')'];
handles.Toolbox(ii).Input.import.rawDataType=handles.Toolbox(tb).Input.bathymetry.rawDataFormatsType{1};

handles.Toolbox(ii).Input.import.EPSGcode                     = 4326;
handles.Toolbox(ii).Input.import.EPSGname                     = 'WGS 84';
handles.Toolbox(ii).Input.import.EPSGtype                     = 'geographic';
handles.Toolbox(ii).Input.import.vertCoordName                = 'MSL';
handles.Toolbox(ii).Input.import.vertCoordLevel               = 0.0;
handles.Toolbox(ii).Input.import.vertUnits                    = 'm';
handles.Toolbox(ii).Input.import.nc_library                   = 'matlab';
handles.Toolbox(ii).Input.import.type                         = 'float';
handles.Toolbox(ii).Input.import.positiveUp                   = 1;

handles.Toolbox(ii).Input.import.radioGeo                     = 1;
handles.Toolbox(ii).Input.import.radioProj                    = 0;

handles.Toolbox(ii).Input.import.attributes.conventions                  = 'CF-1.4';
handles.Toolbox(ii).Input.import.attributes.CF_featureType               = 'grid';
handles.Toolbox(ii).Input.import.attributes.title                        = 'Name of data set';
handles.Toolbox(ii).Input.import.attributes.institution                  = 'Institution';
handles.Toolbox(ii).Input.import.attributes.source                       = 'Source';
handles.Toolbox(ii).Input.import.attributes.history                      = 'created by : ';
handles.Toolbox(ii).Input.import.attributes.references                   = 'No reference material available';
handles.Toolbox(ii).Input.import.attributes.comment                      = 'none';
handles.Toolbox(ii).Input.import.attributes.email                        = 'Your email here';
handles.Toolbox(ii).Input.import.attributes.version                      = '1.0';
handles.Toolbox(ii).Input.import.attributes.terms_for_use                = 'Use as you like';
handles.Toolbox(ii).Input.import.attributes.disclaimer                   = 'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';


%% Shoreline

handles.Toolbox(ii).Input.shoreline.x0=0;
handles.Toolbox(ii).Input.shoreline.y0=0;

handles.Toolbox(ii).Input.shoreline.nrCellsX=0;
handles.Toolbox(ii).Input.shoreline.nrCellsY=0;

handles.Toolbox(ii).Input.shoreline.dataFile='';
handles.Toolbox(ii).Input.shoreline.dataName='';
handles.Toolbox(ii).Input.shoreline.dataDir=[handles.bathymetry.dir];

handles.Toolbox(ii).Input.shoreline.EPSGcode                     = 4326;
handles.Toolbox(ii).Input.shoreline.EPSGname                     = 'WGS 84';
handles.Toolbox(ii).Input.shoreline.EPSGtype                     = 'geographic';
handles.Toolbox(ii).Input.shoreline.conventions                  = 'CF-1.4';
handles.Toolbox(ii).Input.shoreline.CF_featureType               = 'polyline';
handles.Toolbox(ii).Input.shoreline.title                        = 'Name of data set';
handles.Toolbox(ii).Input.shoreline.institution                  = 'Institution';
handles.Toolbox(ii).Input.shoreline.source                       = 'Source';
handles.Toolbox(ii).Input.shoreline.history                      = 'created by';
handles.Toolbox(ii).Input.shoreline.references                   = 'No reference material available';
handles.Toolbox(ii).Input.shoreline.comment                      = 'Comments';
handles.Toolbox(ii).Input.shoreline.email                        = 'Your email here';
handles.Toolbox(ii).Input.shoreline.version                      = '1.0';
handles.Toolbox(ii).Input.shoreline.terms_for_use                = 'Use as you like';
handles.Toolbox(ii).Input.shoreline.disclaimer                   = 'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';
handles.Toolbox(ii).Input.shoreline.nc_library                   = 'matlab';
handles.Toolbox(ii).Input.shoreline.type                         = 'float';


