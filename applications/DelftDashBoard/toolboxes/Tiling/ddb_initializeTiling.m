function handles = ddb_initializeTiling(handles, varargin)
%DDB_INITIALIZETILING  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeTiling(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeTiling
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
ii=strmatch('Tiling',{handles.Toolbox(:).name},'exact');
if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            handles.Toolbox(ii).longName='Tiling';
            return
    end
end

%% Bathymetry

handles.Toolbox(ii).Input.bathymetry.x0=0;
handles.Toolbox(ii).Input.bathymetry.y0=0;
handles.Toolbox(ii).Input.bathymetry.nx=300;
handles.Toolbox(ii).Input.bathymetry.ny=300;
handles.Toolbox(ii).Input.bathymetry.nrZoom=5;

handles.Toolbox(ii).Input.bathymetry.dataFile='';
handles.Toolbox(ii).Input.bathymetry.dataName='';
handles.Toolbox(ii).Input.bathymetry.dataDir=[handles.bathymetry.dir];
handles.Toolbox(ii).Input.bathymetry.rawDataType='arcinfogrid';
handles.Toolbox(ii).Input.bathymetry.rawDataTypeExtension='*.asc';
handles.Toolbox(ii).Input.bathymetry.rawDataTypeSelectionText='Select Data File (ArcInfo ASCII grid file)';

handles.Toolbox(ii).Input.bathymetry.rawDataTypesText={'ArcInfo ASCII grid','Arc Binary Grid'};
handles.Toolbox(ii).Input.bathymetry.rawDataTypes={'arcinfogrid','arcbinarygrid'};
handles.Toolbox(ii).Input.bathymetry.rawDataTypeExtensions={'*.asc','*.adf'};

handles.Toolbox(ii).Input.bathymetry.EPSGcode                     = 4326;
handles.Toolbox(ii).Input.bathymetry.EPSGname                     = 'WGS 84';
handles.Toolbox(ii).Input.bathymetry.EPSGtype                     = 'geographic';
handles.Toolbox(ii).Input.bathymetry.vertCoordName                = 'MSL';
handles.Toolbox(ii).Input.bathymetry.vertCoordLevel               = 0.0;
handles.Toolbox(ii).Input.bathymetry.vertUnits                    = 'm';
handles.Toolbox(ii).Input.bathymetry.nc_library                   = 'matlab';
handles.Toolbox(ii).Input.bathymetry.type                         = 'float';
handles.Toolbox(ii).Input.bathymetry.positiveUp                   = 1;

handles.Toolbox(ii).Input.bathymetry.radioGeo                     = 1;
handles.Toolbox(ii).Input.bathymetry.radioProj                    = 0;

handles.Toolbox(ii).Input.bathymetry.attributes.conventions                  = 'CF-1.4';
handles.Toolbox(ii).Input.bathymetry.attributes.CF_featureType               = 'grid';
handles.Toolbox(ii).Input.bathymetry.attributes.title                        = 'Name of data set';
handles.Toolbox(ii).Input.bathymetry.attributes.institution                  = 'Institution';
handles.Toolbox(ii).Input.bathymetry.attributes.source                       = 'Source';
handles.Toolbox(ii).Input.bathymetry.attributes.history                      = 'created by : ';
handles.Toolbox(ii).Input.bathymetry.attributes.references                   = 'No reference material available';
handles.Toolbox(ii).Input.bathymetry.attributes.comment                      = 'none';
handles.Toolbox(ii).Input.bathymetry.attributes.email                        = 'Your email here';
handles.Toolbox(ii).Input.bathymetry.attributes.version                      = '1.0';
handles.Toolbox(ii).Input.bathymetry.attributes.terms_for_use                = 'Use as you like';
handles.Toolbox(ii).Input.bathymetry.attributes.disclaimer                   = 'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';


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
