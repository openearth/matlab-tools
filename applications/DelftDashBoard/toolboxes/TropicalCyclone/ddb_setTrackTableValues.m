function handles = ddb_setTrackTableValues(handles)
%DDB_SETTRACKTABLEVALUES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_setTrackTableValues(handles)
%
%   Input:
%   handles =
%
%   Output:
%   handles =
%
%   Example
%   ddb_setTrackTableValues
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
iq=handles.Toolbox(tb).Input.quadrant;
handles.Toolbox(tb).Input.tableVMax=squeeze(handles.Toolbox(tb).Input.trackVMax(:,iq));
handles.Toolbox(tb).Input.tableRMax=squeeze(handles.Toolbox(tb).Input.trackRMax(:,iq));
handles.Toolbox(tb).Input.tablePDrop=squeeze(handles.Toolbox(tb).Input.trackPDrop(:,iq));
handles.Toolbox(tb).Input.tableR100=squeeze(handles.Toolbox(tb).Input.trackR100(:,iq));
handles.Toolbox(tb).Input.tableR65=squeeze(handles.Toolbox(tb).Input.trackR65(:,iq));
handles.Toolbox(tb).Input.tableR50=squeeze(handles.Toolbox(tb).Input.trackR50(:,iq));
handles.Toolbox(tb).Input.tableR35=squeeze(handles.Toolbox(tb).Input.trackR35(:,iq));
handles.Toolbox(tb).Input.tableA=squeeze(handles.Toolbox(tb).Input.trackA(:,iq));
handles.Toolbox(tb).Input.tableB=squeeze(handles.Toolbox(tb).Input.trackB(:,iq));

