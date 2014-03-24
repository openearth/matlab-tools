function ddb_TropicalCycloneToolbox_editTrackTable(varargin)
%DDB_TROPICALCYCLONETOOLBOX_EDITTRACKTABLE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_TropicalCycloneToolbox_editTrackTable(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_TropicalCycloneToolbox_editTrackTable
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
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotTropicalCyclone('activate');
    gui_updateActiveTab;
    handles=getHandles;
    if strcmpi(handles.screenParameters.coordinateSystem.type,'cartesian')
        ddb_giveWarning('text','The Tropical Cyclone Toolbox currently only works for geographic coordinate systems!');
    end
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'edittracktable'}
            editTrackTable;
        case{'selectquadrant'}
            handles=getHandles;
            handles=ddb_setTrackTableValues(handles);
            setHandles(handles);
    end
end

%%
function editTrackTable

handles=getHandles;

iq=handles.toolbox.tropicalcyclone.quadrant;

handles.toolbox.tropicalcyclone.trackVMax(:,iq)=handles.toolbox.tropicalcyclone.tableVMax;
handles.toolbox.tropicalcyclone.trackRMax(:,iq)=handles.toolbox.tropicalcyclone.tableRMax;
handles.toolbox.tropicalcyclone.trackPDrop(:,iq)=handles.toolbox.tropicalcyclone.tablePDrop;
handles.toolbox.tropicalcyclone.trackR100(:,iq)=handles.toolbox.tropicalcyclone.tableR100;
handles.toolbox.tropicalcyclone.trackR65(:,iq)=handles.toolbox.tropicalcyclone.tableR65;
handles.toolbox.tropicalcyclone.trackR50(:,iq)=handles.toolbox.tropicalcyclone.tableR50;
handles.toolbox.tropicalcyclone.trackR35(:,iq)=handles.toolbox.tropicalcyclone.tableR35;
handles.toolbox.tropicalcyclone.trackA(:,iq)=handles.toolbox.tropicalcyclone.tableA;
handles.toolbox.tropicalcyclone.trackB(:,iq)=handles.toolbox.tropicalcyclone.tableB;

setHandles(handles);

try
    delete(handles.toolbox.tropicalcyclone.trackhandle);
end
handles.toolbox.tropicalcyclone.trackhandle=[];

ddb_plotCycloneTrack;
