function handles = ddb_initializeNourishments(handles, varargin)
%DDB_INITIALIZENOURISHMENTS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeNourishments(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeNourishments
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
ii=strmatch('Nourishments',{handles.Toolbox(:).name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            handles.Toolbox(ii).longName='Nourishments';
            return
    end
end

%% Domain
handles.Toolbox(ii).Input.modelOutlineHandle=[];
handles.Toolbox(ii).Input.xLim      = [0 0];
handles.Toolbox(ii).Input.yLim      = [0 0];
handles.Toolbox(ii).Input.dX        = 100;

handles.Toolbox(ii).Input.currentsFile='';
handles.Toolbox(ii).Input.currentSource='file';
handles.Toolbox(ii).Input.currentU=0;
handles.Toolbox(ii).Input.currentV=0;

%% Nourishments
handles.Toolbox(ii).Input.nourishments(1).polygonX=[];
handles.Toolbox(ii).Input.nourishments(1).polygonY=[];
handles.Toolbox(ii).Input.nourishments(1).polyLength=0;
handles.Toolbox(ii).Input.nourishments(1).type='volume';
handles.Toolbox(ii).Input.nourishments(1).volume=1e6;
handles.Toolbox(ii).Input.nourishments(1).thickness=1;
handles.Toolbox(ii).Input.nourishments(1).height=1;
handles.Toolbox(ii).Input.nourishments(1).area=0;

handles.Toolbox(ii).Input.nrNourishments=0;
handles.Toolbox(ii).Input.activeNourishment=1;
handles.Toolbox(ii).Input.nourishmentNames={''};

%% Concentration areas
handles.Toolbox(ii).Input.concentrationPolygons(1).polygonX=[];
handles.Toolbox(ii).Input.concentrationPolygons(1).polygonY=[];
handles.Toolbox(ii).Input.concentrationPolygons(1).polyLength=0;
handles.Toolbox(ii).Input.concentrationPolygons(1).concentration=0.02;

handles.Toolbox(ii).Input.nrConcentrationPolygons=0;
handles.Toolbox(ii).Input.activeConcentrationPolygon=1;
handles.Toolbox(ii).Input.concentrationNames={''};

%% Runtime
handles.Toolbox(ii).Input.nrYears=5;
handles.Toolbox(ii).Input.outputInterval=1;

%% Parameters
handles.Toolbox(ii).Input.equilibriumConcentration=0.02;
handles.Toolbox(ii).Input.diffusionCoefficient=10;
handles.Toolbox(ii).Input.settlingVelocity=0.02;


