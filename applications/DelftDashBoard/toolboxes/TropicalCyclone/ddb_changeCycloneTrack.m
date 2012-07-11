function ddb_changeCycloneTrack(x, y, varargin)
%DDB_CHANGECYCLONETRACK  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_changeCycloneTrack(x, y, varargin)
%
%   Input:
%   x        =
%   y        =
%   varargin =
%
%
%
%
%   Example
%   ddb_changeCycloneTrack
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

handles=getHandles;

setInstructions({'','Left-click and drag track vertices to change track position','Right-click track vertices to change cyclone parameters'});

if handles.Toolbox(tb).Input.trackT(1)>handles.Model(md).Input(ad).startTime
    ddb_giveWarning('text','Start time cyclone is greater than simulation start time!');
end

if handles.Toolbox(tb).Input.trackT(end)<handles.Model(md).Input(ad).stopTime
    ddb_giveWarning('text','Stop time cyclone is smaller than simulation stop time!');
end

handles.Toolbox(tb).Input.nrTrackPoints=length(x);
handles.Toolbox(tb).Input.trackX=x;
handles.Toolbox(tb).Input.trackY=y;

if handles.Toolbox(tb).Input.newTrack
    
    handles.Toolbox(tb).Input.trackT=handles.Toolbox(tb).Input.startTime:handles.Toolbox(tb).Input.timeStep/24:handles.Toolbox(tb).Input.startTime+(length(x)-1)*handles.Toolbox(tb).Input.timeStep/24;
    zers=zeros(length(x),4);
    handles.Toolbox(tb).Input.trackVMax=zers+handles.Toolbox(tb).Input.vMax;
    handles.Toolbox(tb).Input.trackPDrop=zers+handles.Toolbox(tb).Input.pDrop;
    handles.Toolbox(tb).Input.trackRMax=zers+handles.Toolbox(tb).Input.rMax;
    handles.Toolbox(tb).Input.trackR100=zers+handles.Toolbox(tb).Input.r100;
    handles.Toolbox(tb).Input.trackR65=zers+handles.Toolbox(tb).Input.r65;
    handles.Toolbox(tb).Input.trackR50=zers+handles.Toolbox(tb).Input.r50;
    handles.Toolbox(tb).Input.trackR35=zers+handles.Toolbox(tb).Input.r35;
    handles.Toolbox(tb).Input.trackA=zers+handles.Toolbox(tb).Input.parA;
    handles.Toolbox(tb).Input.trackB=zers+handles.Toolbox(tb).Input.parB;
    
    handles=ddb_setTrackTableValues(handles);
    
end

handles.Toolbox(tb).Input.newTrack=0;

setHandles(handles);

ddb_plotCycloneTrack;
ddb_updateTrackTables;

gui_updateActiveTab;
