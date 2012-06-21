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
    % setUIElements('tropicalcyclonepanel.tracktable');
    handles=getHandles;
    if strcmpi(handles.screenParameters.coordinateSystem.type,'cartesian')
        giveWarning('text','The Tropical Cyclone Toolbox currently only works for geographic coordinate systems!');
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
            ddb_updateTrackTables;
    end
end

%%
function editTrackTable

handles=getHandles;

iq=handles.Toolbox(tb).Input.quadrant;

handles.Toolbox(tb).Input.trackVMax(:,iq)=handles.Toolbox(tb).Input.tableVMax;
handles.Toolbox(tb).Input.trackRMax(:,iq)=handles.Toolbox(tb).Input.tableRMax;
handles.Toolbox(tb).Input.trackPDrop(:,iq)=handles.Toolbox(tb).Input.tablePDrop;
handles.Toolbox(tb).Input.trackR100(:,iq)=handles.Toolbox(tb).Input.tableR100;
handles.Toolbox(tb).Input.trackR65(:,iq)=handles.Toolbox(tb).Input.tableR65;
handles.Toolbox(tb).Input.trackR50(:,iq)=handles.Toolbox(tb).Input.tableR50;
handles.Toolbox(tb).Input.trackR35(:,iq)=handles.Toolbox(tb).Input.tableR35;
handles.Toolbox(tb).Input.trackA(:,iq)=handles.Toolbox(tb).Input.tableA;
handles.Toolbox(tb).Input.trackB(:,iq)=handles.Toolbox(tb).Input.tableB;

setHandles(handles);

ddb_plotCycloneTrack;

