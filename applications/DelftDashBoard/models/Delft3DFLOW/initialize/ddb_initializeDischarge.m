function handles = ddb_initializeDischarge(handles, id, n)
%DDB_INITIALIZEDISCHARGE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeDischarge(handles, id, n)
%
%   Input:
%   handles =
%   id      =
%   n       =
%
%   Output:
%   handles =
%
%   Example
%   ddb_initializeDischarge
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
handles.Model(md).Input(id).discharges(n).name='unknown';
handles.Model(md).Input(id).discharges(n).M=0;
handles.Model(md).Input(id).discharges(n).N=0;
handles.Model(md).Input(id).discharges(n).K=0;
handles.Model(md).Input(id).discharges(n).mOut=0;
handles.Model(md).Input(id).discharges(n).nOut=0;
handles.Model(md).Input(id).discharges(n).kOut=0;
handles.Model(md).Input(id).discharges(n).interpolation='linear';
handles.Model(md).Input(id).discharges(n).type='normal';
t0=handles.Model(md).Input(id).startTime;
t1=handles.Model(md).Input(id).stopTime;
handles.Model(md).Input(id).discharges(n).timeSeriesT=[t0;t1];
handles.Model(md).Input(id).discharges(n).timeSeriesQ=[0.0;0.0];
handles.Model(md).Input(id).discharges(n).timeSeriesM=[0.0;0.0];
handles.Model(md).Input(id).discharges(n).timeSeriesD=[0.0;0.0];
handles.Model(md).Input(id).discharges(n).nrTimeSeries=2;

% Salinity
handles.Model(md).Input(id).discharges(n).salinity.timeSeries=[0.0;0.0];

% Temperature
handles.Model(md).Input(id).discharges(n).temperature.timeSeries=[20.0;20.0];

% Sediments
for i=1:handles.Model(md).Input(id).nrSediments
    handles.Model(md).Input(id).discharges(n).sediment(i).timeSeries=[0.0;0.0];
end

% Tracers
for i=1:handles.Model(md).Input(id).nrTracers
    handles.Model(md).Input(id).discharges(n).tracer(i).timeSeries=[0.0;0.0];
end


