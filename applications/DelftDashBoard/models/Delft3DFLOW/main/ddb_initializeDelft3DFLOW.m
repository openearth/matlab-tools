function handles = ddb_initializeDelft3DFLOW(handles, varargin)
%DDB_INITIALIZEDELFT3DFLOW  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeDelft3DFLOW(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeDelft3DFLOW
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
if nargin>1
    switch varargin{1}
        case{'veryfirst'}
            ii=strmatch('Delft3DFLOW',{handles.Model.name},'exact');
            handles.Model(ii).longName='Delft3D-FLOW';
            return
    end
end

% handles.GUIData.activeDryPoint=1;
% handles.GUIData.activeThinDam=1;
% handles.GUIData.activeCrossSection=1;
% handles.GUIData.activeDischarge=1;
% handles.GUIData.activeDrogue=1;
% handles.GUIData.activeObservationPoint=1;
% handles.GUIData.activeOpenBoundary=1;

ii=strmatch('Delft3DFLOW',{handles.Model.name},'exact');


handles.Model(ii).Input=[];

runid='tst';

handles=ddb_initializeFlowDomain(handles,'all',1,runid);

handles.Model(ii).ddFile='test.ddb';
handles.Model(ii).DDBoundaries=[];

handles.Model(ii).menuview.grid=1;
handles.Model(ii).menuview.bathymetry=1;

