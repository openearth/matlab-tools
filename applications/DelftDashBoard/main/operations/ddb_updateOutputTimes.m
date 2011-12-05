function ddb_updateOutputTimes(varargin)
%ddb_Delft3DFLOW_changeStartStopTimes
%
%   This function updates start and stop times of output, when start or
%   stop time of model is changed. Start and stop times of wind input are
%   also updated.
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
nrdomains=length(handles.Model(md).Input);
% Start and stop times of other domains
for id=1:nrdomains
    if id~=ad
        handles.Model(md).Input(id).startTime=handles.Model(md).Input(id).startTime;
        handles.Model(md).Input(id).stopTime=handles.Model(md).Input(ad).stopTime;
    end
end
% Output times for all domains
for id=1:nrdomains
    if isfield(handles.Model(md).Input(id),'mapStartTime')
        handles.Model(md).Input(id).mapStartTime=handles.Model(md).Input(id).startTime;
    end
    if isfield(handles.Model(md).Input(id),'mapStopTime')
        handles.Model(md).Input(id).mapStopTime=handles.Model(md).Input(id).stopTime;
    end
    if isfield(handles.Model(md).Input(id),'comStartTime')
        handles.Model(md).Input(id).comStartTime=handles.Model(md).Input(id).startTime;
    end
    if isfield(handles.Model(md).Input(id),'comStopTime')
        handles.Model(md).Input(id).comStopTime=handles.Model(md).Input(id).stopTime;
    end
    if isfield(handles.Model(md).Input(id),'windTimeSeriesSpeed')
        if length(handles.Model(md).Input(id).windTimeSeriesSpeed)==2
            if handles.Model(md).Input(id).windTimeSeriesSpeed(1)==handles.Model(md).Input(id).windTimeSeriesSpeed(2) && ...
                handles.Model(md).Input(id).windTimeSeriesDirection(1)==handles.Model(md).Input(id).windTimeSeriesDirection(2)
                handles.Model(md).Input(id).windTimeSeriesT(1)=handles.Model(md).Input(id).startTime;
                handles.Model(md).Input(id).windTimeSeriesT(2)=handles.Model(md).Input(id).stopTime;
            end
        end        
    end
end
setHandles(handles);

