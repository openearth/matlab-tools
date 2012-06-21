function handles = ddb_initializeObservationStations(handles, varargin)
%DDB_INITIALIZEOBSERVATIONSTATIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeObservationStations(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeObservationStations
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
ii=strmatch('ObservationStations',{handles.Toolbox(:).name},'exact');

ddb_getToolboxData(handles.Toolbox(ii).dataDir,ii);

dr=handles.Toolbox(ii).dataDir;
lst=dir([dr '*.mat']);

for i=1:length(lst)
    
    disp(['Loading observations database ' lst(i).name(1:end-4) ' ...']);
    
    load([dr lst(i).name(1:end-4) '.mat']);
    
    handles.Toolbox(ii).Input.databases{i}=s.DatabaseName;
    handles.Toolbox(ii).Input.database(i).shortName=lst(i).name(1:end-4);
    
    handles.Toolbox(ii).Input.database(i).databaseName=s.DatabaseName;
    handles.Toolbox(ii).Input.database(i).institution=s.Institution;
    handles.Toolbox(ii).Input.database(i).coordinateSystem=s.CoordinateSystem;
    handles.Toolbox(ii).Input.database(i).coordinateSystemType=s.CoordinateSystemType;
    handles.Toolbox(ii).Input.database(i).serverType=s.ServerType;
    handles.Toolbox(ii).Input.database(i).URL=s.URL;
    handles.Toolbox(ii).Input.database(i).stationNames=s.Name;
    handles.Toolbox(ii).Input.database(i).idCodes=s.IDCode;
    handles.Toolbox(ii).Input.database(i).parameters=s.Parameters;
    handles.Toolbox(ii).Input.database(i).x=s.x;
    handles.Toolbox(ii).Input.database(i).y=s.y;
    handles.Toolbox(ii).Input.database(i).xLoc=s.x;
    handles.Toolbox(ii).Input.database(i).yLoc=s.y;
    
end

handles.Toolbox(ii).Input.startTime=floor(now)-10;
handles.Toolbox(ii).Input.stopTime=floor(now)-1;
handles.Toolbox(ii).Input.timeStep=10.0;

handles.Toolbox(ii).Input.activeDatabase=1;
handles.Toolbox(ii).Input.activeObservationStation=1;

handles.Toolbox(ii).Input.observationStationHandle=[];
handles.Toolbox(ii).Input.activeObservationStationHandle=[];

handles.Toolbox(tb).Input.activeParameter=1;

for jj=1:15
    handles.Toolbox(ii).Input.(['radio' num2str(jj,'%0.2i')]).value=0;
    handles.Toolbox(ii).Input.(['radio' num2str(jj,'%0.2i')]).enable=0;
    handles.Toolbox(ii).Input.(['radio' num2str(jj,'%0.2i')]).text='';
end
