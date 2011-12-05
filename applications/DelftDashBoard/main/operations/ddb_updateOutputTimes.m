function ddb_updateOutputTimes(varargin)
%ddb_Delft3DFLOW_changeStartStopTimes
%
%   This function updates start and stop times of output, when start or
%   stop time of model is changed.
%   To be used within Delft Dashboard only

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
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
% Created: 05 Dec 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

handles=getHandles;
if isfield(handles.Model(md).Input(ad),'mapStartTime')
    handles.Model(md).Input(ad).mapStartTime=handles.Model(md).Input(ad).startTime;
end
if isfield(handles.Model(md).Input(ad),'mapStopTime')
    handles.Model(md).Input(ad).mapStopTime=handles.Model(md).Input(ad).stopTime;
end
if isfield(handles.Model(md).Input(ad),'comStartTime')
    handles.Model(md).Input(ad).comStartTime=handles.Model(md).Input(ad).startTime;
end
if isfield(handles.Model(md).Input(ad),'comStopTime')
    handles.Model(md).Input(ad).comStopTime=handles.Model(md).Input(ad).stopTime;
end
setHandles(handles);

