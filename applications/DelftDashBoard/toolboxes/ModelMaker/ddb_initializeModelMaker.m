function handles = ddb_initializeModelMaker(handles, varargin)
%DDB_INITIALIZEMODELMAKER  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeModelMaker(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeModelMaker
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
ii=strmatch('ModelMaker',{handles.Toolbox(:).name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            handles.Toolbox(ii).longName='Model Maker';
            return
    end
end

handles.Toolbox(ii).Input.nX=1;
handles.Toolbox(ii).Input.dX=0.1;
handles.Toolbox(ii).Input.xOri=0.0;
handles.Toolbox(ii).Input.nY=1;
handles.Toolbox(ii).Input.dY=0.1;
handles.Toolbox(ii).Input.yOri=1.0;
handles.Toolbox(ii).Input.lengthX=0.1;
handles.Toolbox(ii).Input.lengthY=0.1;
handles.Toolbox(ii).Input.rotation=0.0;
handles.Toolbox(ii).Input.sectionLength=10;
handles.Toolbox(ii).Input.sectionLengthMetres=50000;
handles.Toolbox(ii).Input.zMax=0;
handles.Toolbox(ii).Input.viewGridOutline=1;

handles.Toolbox(ii).Input.yOffshore=400;
handles.Toolbox(ii).Input.dxCoast=100;
handles.Toolbox(ii).Input.dyMinCoast=10;
handles.Toolbox(ii).Input.dyMaxCoast=50;
handles.Toolbox(ii).Input.coastSplineX=[];
handles.Toolbox(ii).Input.coastSplineY=[];
handles.Toolbox(ii).Input.courantCoast=10;
handles.Toolbox(ii).Input.nSmoothCoast=1.1;
handles.Toolbox(ii).Input.depthRelCoast=5;

handles.Toolbox(ii).Input.activeTideModelBC=1;
handles.Toolbox(ii).Input.activeTideModelIC=1;

% Make TPXO72 the default tide model
jj=strmatch('tpxo72',handles.tideModels.names,'exact');
if ~isempty(jj)
    handles.Toolbox(ii).Input.activeTideModelBC=jj;
    handles.Toolbox(ii).Input.activeTideModelIC=jj;
end

handles.Toolbox(ii).Input.gridOutlineHandle=[];

if strcmpi(handles.screenParameters.coordinateSystem.type,'cartesian')
    handles.Toolbox(ii).Input.dX=1000;
    handles.Toolbox(ii).Input.dY=1000;
end

%% Bathymetry
handles.Toolbox(ii).Input.bathymetry.activeDataset=1;
handles.Toolbox(ii).Input.bathymetry.activeSelectedDataset=1;
handles.Toolbox(ii).Input.bathymetry.selectedDatasetNames={''};
handles.Toolbox(ii).Input.bathymetry.selectedDatasets(1).verticalLevel=0;
handles.Toolbox(ii).Input.bathymetry.selectedDatasets(1).verticalDatum=0;
handles.Toolbox(ii).Input.bathymetry.nrSelectedDatasets=0;
handles.Toolbox(ii).Input.bathymetry.selectedDatasets(1).type='unknown';
handles.Toolbox(ii).Input.bathymetry.selectedDatasets(1).zMax=10000;
handles.Toolbox(ii).Input.bathymetry.selectedDatasets(1).zMin=-10000;
handles.Toolbox(ii).Input.bathymetry.selectedDatasets(1).startDate=datenum(2000,1,1);
handles.Toolbox(ii).Input.bathymetry.selectedDatasets(1).searchInterval=5;
handles.Toolbox(ii).Input.bathymetry.verticalDatum=0;

%% Initial conditions
handles.Toolbox(ii).Input.initialConditions.parameterList={'Water Level','Current'};
handles.Toolbox(ii).Input.initialConditions.activeParameter=1;
handles.Toolbox(ii).Input.initialConditions.parameter='Water Level';

handles.Toolbox(ii).Input.initialConditions.activeDataSource=1;
handles.Toolbox(ii).Input.initialConditions.dataSourceList={'Constant'};
handles.Toolbox(ii).Input.initialConditions.dataSource='Constant';
