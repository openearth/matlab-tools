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

s=xml2struct([dr 'ObservationStations.xml'],'structuretype','supershort');

for k=1:length(s.database)

    f=str2func(s.database(k).callback);

    handles.Toolbox(ii).Input.database(k).callback=f;

    database=feval(f,'readdatabase','inputfile',[dr s.database(k).file]);
    fld=fieldnames(database);
    for j=1:length(fld)
        handles.Toolbox(ii).Input.database(k).(fld{j})=database.(fld{j});
    end
    handles.Toolbox(ii).Input.databaselongnames{k}=s.database(k).longname;
    handles.Toolbox(ii).Input.database(k).activeobservationstation=1;
    
end

handles.Toolbox(ii).Input.starttime=floor(now)-10;
handles.Toolbox(ii).Input.stoptime=floor(now)-1;
handles.Toolbox(ii).Input.timestep=10.0;

handles.Toolbox(ii).Input.activedatabase=1;
handles.Toolbox(ii).Input.activeobservationstation=1;

handles.Toolbox(ii).Input.observationstationshandle=[];

handles.Toolbox(ii).Input.activeparameter=1;

for jj=1:15
    handles.Toolbox(ii).Input.(['radio' num2str(jj,'%0.2i')]).value=0;
    handles.Toolbox(ii).Input.(['radio' num2str(jj,'%0.2i')]).enable=0;
    handles.Toolbox(ii).Input.(['radio' num2str(jj,'%0.2i')]).text='';
end

handles.Toolbox(ii).Input.downloadeddatasets=[];
handles.Toolbox(ii).Input.downloadeddatanames=[];

handles.Toolbox(ii).Input.polygonlength=0;
handles.Toolbox(ii).Input.exporttype='mat';

% Export options
handles.Toolbox(ii).Input.includename=1;
handles.Toolbox(ii).Input.includeid=0;
handles.Toolbox(ii).Input.includedatabase=0;
handles.Toolbox(ii).Input.includetimestamp=0;
handles.Toolbox(ii).Input.exportallparameters=0;

handles.Toolbox(ii).Input.showstationnames=1;
handles.Toolbox(ii).Input.showstationids=0;
handles.Toolbox(ii).Input.stationlist={''};
handles.Toolbox(ii).Input.textstation='';
