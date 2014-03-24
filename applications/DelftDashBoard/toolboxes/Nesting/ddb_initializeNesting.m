function handles = ddb_initializeNesting(handles, varargin)
%DDB_INITIALIZENESTING  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeNesting(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeNesting
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%

ddb_getToolboxData(handles.toolbox.nesting.dataDir,'nesting','Nesting');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            return
    end
end

% Nest 1
handles.toolbox.nesting.detailmodeltype   = 'delft3dflow';
handles.toolbox.nesting.detailmodelcsname = 'unspecified';
handles.toolbox.nesting.detailmodelcstype = 'unspecified';
handles.toolbox.nesting.grdFile       = '';
handles.toolbox.nesting.encFile       = '';
handles.toolbox.nesting.bndFile       = '';
handles.toolbox.nesting.depFile       = '';
handles.toolbox.nesting.extfile       = '';

% Nest 2
handles.toolbox.nesting.admFile       = 'nesting.adm';
handles.toolbox.nesting.trihFile      = '';
handles.toolbox.nesting.zCor          = 0;
handles.toolbox.nesting.nestHydro     = 1;
handles.toolbox.nesting.nestTransport = 1;

handles.toolbox.nesting.singleSP2file='';
