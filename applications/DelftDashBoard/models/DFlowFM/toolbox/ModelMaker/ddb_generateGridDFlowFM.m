function handles = ddb_generateGridDFlowFM(handles, id, x, y, z, varargin)
%DDB_GENERATEGRIDDFlowFM  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_generateGridDFlowFM(handles, id, x, y, varargin)
%
%   Input:
%   handles  =
%   id       =
%   x        =
%   y        =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_generateGridDFlowFM
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
if ~isempty(varargin)
    % Check if routine exists
    if strcmpi(varargin{1},'ddb_test')
        return
    end
end

ddb_plotDFlowFM('delete','domain',id);
handles=ddb_initializeDFlowFMdomain(handles,'griddependentinput',id,handles.Model(md).Input(id).runid);

set(gcf,'Pointer','arrow');

% attName=handles.Model(md).Input(id).attName;
% 
% if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
%     coord='Spherical';
% else
%     coord='Cartesian';
% end
% 
netStruc=curv2net(x,y,z);
handles.Model(md).Input(id).netFile=[handles.Model(md).Input(id).runid '_net.nc'];
handles.Model(md).Input(id).netStruc=netStruc;
netStruc2nc(handles.Model(md).Input(id).netFile,netStruc);

handles=ddb_DFlowFM_plotGrid(handles,'plot','domain',id);
