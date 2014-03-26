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

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            handles.toolbox.modelmaker.longName='Model Maker';
            return
    end
end

handles.toolbox.modelmaker.nX=1;
handles.toolbox.modelmaker.dX=0.1;
handles.toolbox.modelmaker.wavedX=0.1;
handles.toolbox.modelmaker.xOri=0.0;
handles.toolbox.modelmaker.nY=1;
handles.toolbox.modelmaker.dY=0.1;
handles.toolbox.modelmaker.wavedY=0.1;
handles.toolbox.modelmaker.yOri=1.0;
handles.toolbox.modelmaker.lengthX=0.1;
handles.toolbox.modelmaker.lengthY=0.1;
handles.toolbox.modelmaker.rotation=0.0;
handles.toolbox.modelmaker.sectionLength=10;
handles.toolbox.modelmaker.sectionLengthMetres=50000;
handles.toolbox.modelmaker.zMax=0;
handles.toolbox.modelmaker.viewGridOutline=1;

handles.toolbox.modelmaker.yOffshore=400;
handles.toolbox.modelmaker.dxCoast=100;
handles.toolbox.modelmaker.dyMinCoast=10;
handles.toolbox.modelmaker.dyMaxCoast=50;
handles.toolbox.modelmaker.coastSplineX=[];
handles.toolbox.modelmaker.coastSplineY=[];
handles.toolbox.modelmaker.courantCoast=10;
handles.toolbox.modelmaker.nSmoothCoast=1.1;
handles.toolbox.modelmaker.depthRelCoast=5;

handles.toolbox.modelmaker.activeTideModelBC=1;
handles.toolbox.modelmaker.activeTideModelIC=1;

% Make TPXO72 the default tide model
jj=strmatch('tpxo72',handles.tideModels.names,'exact');
if ~isempty(jj)
    handles.toolbox.modelmaker.activeTideModelBC=jj;
    handles.toolbox.modelmaker.activeTideModelIC=jj;
end

handles.toolbox.modelmaker.gridOutlineHandle=[];

if strcmpi(handles.screenParameters.coordinateSystem.type,'cartesian')
    handles.toolbox.modelmaker.dX=1000;
    handles.toolbox.modelmaker.dY=1000;
end

%% Bathymetry
handles.toolbox.modelmaker.bathymetry.activeDataset=1;
handles.toolbox.modelmaker.bathymetry.activeSelectedDataset=1;
handles.toolbox.modelmaker.bathymetry.selectedDatasetNames={''};
handles.toolbox.modelmaker.bathymetry.selectedDatasets(1).verticalLevel=0;
handles.toolbox.modelmaker.bathymetry.selectedDatasets(1).verticalDatum=0;
handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets=0;
handles.toolbox.modelmaker.bathymetry.selectedDatasets(1).type='unknown';
handles.toolbox.modelmaker.bathymetry.selectedDatasets(1).zMax=10000;
handles.toolbox.modelmaker.bathymetry.selectedDatasets(1).zMin=-10000;
handles.toolbox.modelmaker.bathymetry.selectedDatasets(1).startDate=datenum(2000,1,1);
handles.toolbox.modelmaker.bathymetry.selectedDatasets(1).searchInterval=5;
handles.toolbox.modelmaker.bathymetry.verticalDatum=0;
handles.toolbox.modelmaker.bathymetry.internalDiffusion=0;
handles.toolbox.modelmaker.bathymetry.internalDiffusionRange=[-20000 20000];

%% Initial conditions
handles.toolbox.modelmaker.initialConditions.parameterList={'Water Level','Current'};
handles.toolbox.modelmaker.initialConditions.activeParameter=1;
handles.toolbox.modelmaker.initialConditions.parameter='Water Level';

handles.toolbox.modelmaker.initialConditions.activeDataSource=1;
handles.toolbox.modelmaker.initialConditions.dataSourceList={'Constant'};
handles.toolbox.modelmaker.initialConditions.dataSource='Constant';

%% Roughness
handles.toolbox.modelmaker.roughness.landelevation=0;
handles.toolbox.modelmaker.roughness.landroughness=0.08;
handles.toolbox.modelmaker.roughness.searoughness=0.024;
