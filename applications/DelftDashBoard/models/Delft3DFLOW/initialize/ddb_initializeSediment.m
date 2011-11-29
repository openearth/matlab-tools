function handles = ddb_initializeSediment(handles, id, ii)
%DDB_INITIALIZESEDIMENT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeSediment(handles, id, ii)
%
%   Input:
%   handles =
%   id      =
%   ii      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_initializeSediment
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

%% Sediment name and type must be defined before this

handles.Model(md).Input(id).sediment(ii).ICOpt='Constant';
handles.Model(md).Input(id).sediment(ii).ICConst=0;
handles.Model(md).Input(id).sediment(ii).ICPar=[0 0];
handles.Model(md).Input(id).sediment(ii).BCOpt='Constant';
handles.Model(md).Input(id).sediment(ii).BCConst=0;
handles.Model(md).Input(id).sediment(ii).BCPar=[0 0];

handles.Model(md).Input(id).sediment(ii).rhoSol           = 2.6500000e+003;
handles.Model(md).Input(id).sediment(ii).iniSedThick      = 5.0000000e+000;
handles.Model(md).Input(id).sediment(ii).facDSS           = 1.0000000e+000;
handles.Model(md).Input(id).sediment(ii).salMax           = 0.0000000e+000;
handles.Model(md).Input(id).sediment(ii).wS0              = 2.5000000e-001;
handles.Model(md).Input(id).sediment(ii).wSM              = 2.5000000e-001;
handles.Model(md).Input(id).sediment(ii).tCrSed           = 1.0000000e+003;
handles.Model(md).Input(id).sediment(ii).tCrEro           = 5.0000000e-001;
handles.Model(md).Input(id).sediment(ii).eroPar           = 1.0000000e-004;
handles.Model(md).Input(id).sediment(ii).sedDia           = 2.0000000e-001;
handles.Model(md).Input(id).sediment(ii).sedD10           = 3.0000000e-001;
handles.Model(md).Input(id).sediment(ii).sedD90           = 1.0000000e-001;

handles.Model(md).Input(id).sediment(ii).uniformThickness=1;
handles.Model(md).Input(id).sediment(ii).uniformTCrEro=1;
handles.Model(md).Input(id).sediment(ii).uniformTCrSed=1;
handles.Model(md).Input(id).sediment(ii).uniformEroPar=1;
handles.Model(md).Input(id).sediment(ii).sdbFile='';
handles.Model(md).Input(id).sediment(ii).tceFile='';
handles.Model(md).Input(id).sediment(ii).tcdFile='';
handles.Model(md).Input(id).sediment(ii).eroFile='';

switch lower(handles.Model(md).Input(id).sediment(ii).type)
    case{'cohesive'}
        handles.Model(md).Input(id).sediment(ii).cDryB            =  5.0000000e+002;
    case{'non-cohesive'}
        handles.Model(md).Input(id).sediment(ii).cDryB            =  1.6000000e+003;
end

% Boundaries
t0=handles.Model(md).Input(id).startTime;
t1=handles.Model(md).Input(id).stopTime;

for j=1:handles.Model(md).Input(id).nrOpenBoundaries
    handles.Model(md).Input(id).openBoundaries(j).sediment(ii).nrTimeSeries=2;
    handles.Model(md).Input(id).openBoundaries(j).sediment(ii).timeSeriesT=[t0;t1];
    handles.Model(md).Input(id).openBoundaries(j).sediment(ii).timeSeriesA=[0.0;0.0];
    handles.Model(md).Input(id).openBoundaries(j).sediment(ii).timeSeriesB=[0.0;0.0];
    handles.Model(md).Input(id).openBoundaries(j).sediment(ii).profile='Uniform';
    handles.Model(md).Input(id).openBoundaries(j).sediment(ii).interpolation='Linear';
    handles.Model(md).Input(id).openBoundaries(j).sediment(ii).discontinuity=1;
end

% Discharges
for j=1:handles.Model(md).Input(id).nrDischarges
    nt=length(handles.Model(md).Input(id).discharges(j).timeSeriesT);
    handles.Model(md).Input(id).discharges(j).sediment(ii).timeSeries=zeros(nt,1);
end


