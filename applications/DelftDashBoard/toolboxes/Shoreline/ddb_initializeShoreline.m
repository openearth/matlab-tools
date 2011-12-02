function handles = ddb_initializeShoreline(handles, varargin)
%DDB_INITIALIZESHORELINE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeShoreline(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeShoreline
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
ii=strmatch('Shoreline',{handles.Toolbox(:).name},'exact');

handles.Toolbox(ii).Input.activeDataset=1;
handles.Toolbox(ii).Input.polyLength=0;
handles.Toolbox(ii).Input.polygonFile='';

handles.Toolbox(ii).Input.activeScale=1;
handles.Toolbox(ii).Input.scaleText={'1'};

handles.Toolbox(ii).Input.exportTypes={'ldb'};
handles.Toolbox(ii).Input.activeExportType='ldb';

handles.Toolbox(ii).Input.usedDataset=[];
handles.Toolbox(ii).Input.usedDatasets={''};
handles.Toolbox(ii).Input.nrUsedDatasets=0;
handles.Toolbox(ii).Input.activeUsedDataset=1;

handles.Toolbox(ii).Input.newDataset.xmin=0;
handles.Toolbox(ii).Input.newDataset.xmax=0;
handles.Toolbox(ii).Input.newDataset.dx=0;
handles.Toolbox(ii).Input.newDataset.ymin=0;
handles.Toolbox(ii).Input.newDataset.ymax=0;
handles.Toolbox(ii).Input.newDataset.dy=0;


