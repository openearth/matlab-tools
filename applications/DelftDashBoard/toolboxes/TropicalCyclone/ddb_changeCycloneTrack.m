function ddb_changeCycloneTrack(varargin)
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

h=varargin{1};
x=varargin{2};
y=varargin{3};
nr=[];

if nargin==4
    nr=varargin{4};
end

setInstructions({'','Left-click and drag track vertices to change track position','Right-click track vertices to change cyclone parameters'});


handles.toolbox.tropicalcyclone.nrTrackPoints=length(x);
handles.toolbox.tropicalcyclone.trackX=x;
handles.toolbox.tropicalcyclone.trackY=y;

if isempty(nr)

    % New track
    
    % Delete existing track
    try
        delete(h);
    end
    handles.toolbox.tropicalcyclone.trackhandle=[];

    handles.toolbox.tropicalcyclone.trackT=handles.toolbox.tropicalcyclone.startTime:handles.toolbox.tropicalcyclone.timeStep/24:handles.toolbox.tropicalcyclone.startTime+(length(x)-1)*handles.toolbox.tropicalcyclone.timeStep/24;
    zers=zeros(length(x),4);
    handles.toolbox.tropicalcyclone.trackVMax=zers+handles.toolbox.tropicalcyclone.vMax;
    handles.toolbox.tropicalcyclone.trackPDrop=zers+handles.toolbox.tropicalcyclone.pDrop;
    handles.toolbox.tropicalcyclone.trackRMax=zers+handles.toolbox.tropicalcyclone.rMax;
    handles.toolbox.tropicalcyclone.trackR100=zers+handles.toolbox.tropicalcyclone.r100;
    handles.toolbox.tropicalcyclone.trackR65=zers+handles.toolbox.tropicalcyclone.r65;
    handles.toolbox.tropicalcyclone.trackR50=zers+handles.toolbox.tropicalcyclone.r50;
    handles.toolbox.tropicalcyclone.trackR35=zers+handles.toolbox.tropicalcyclone.r35;
    handles.toolbox.tropicalcyclone.trackA=zers+handles.toolbox.tropicalcyclone.parA;
    handles.toolbox.tropicalcyclone.trackB=zers+handles.toolbox.tropicalcyclone.parB;
    
    handles=ddb_setTrackTableValues(handles);
    
    setHandles(handles);
    
    ddb_plotCycloneTrack;

    if handles.toolbox.tropicalcyclone.trackT(1)>handles.Model(md).Input(ad).startTime
        ddb_giveWarning('text','Start time cyclone is greater than simulation start time!');
    end
    
    if handles.toolbox.tropicalcyclone.trackT(end)<handles.Model(md).Input(ad).stopTime
        ddb_giveWarning('text','Stop time cyclone is smaller than simulation stop time!');
    end

else
    setHandles(handles);
end

gui_updateActiveTab;
