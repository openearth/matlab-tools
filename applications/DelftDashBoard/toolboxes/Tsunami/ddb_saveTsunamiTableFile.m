function ddb_saveTsunamiTableFile(handles, filename)
%DDB_SAVETSUNAMITABLEFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_saveTsunamiTableFile(handles, filename)
%
%   Input:
%   handles  =
%   filename =
%
%
%
%
%   Example
%   ddb_saveTsunamiTableFile
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
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

xml.longitude=handles.Toolbox(tb).Input.segmentLon;
xml.latitude=handles.Toolbox(tb).Input.segmentLat;
xml.strike=handles.Toolbox(tb).Input.segmentStrike;
xml.width=handles.Toolbox(tb).Input.segmentWidth;
xml.depth=handles.Toolbox(tb).Input.segmentDepth;
xml.dip=handles.Toolbox(tb).Input.segmentDip;
xml.sliprake=handles.Toolbox(tb).Input.segmentSlipRake;
xml.slip=handles.Toolbox(tb).Input.segmentSlip;
xml_save(filename,xml,'off');

