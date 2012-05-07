function handles = ddb_generateGridDelft3DFLOW(handles, id, x, y, z, varargin)
%DDB_GENERATEGRIDDELFT3DFLOW  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_generateGridDelft3DFLOW(handles, id, x, y, varargin)
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
%   ddb_generateGridDelft3DFLOW
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
if ~isempty(varargin)
    % Check if routine exists
    if strcmpi(varargin{1},'ddb_test')
        return
    end
end

ddb_plotDelft3DFLOW('delete','domain',id);
handles=ddb_initializeFlowDomain(handles,'griddependentinput',id,handles.Model(md).Input(id).runid);

set(gcf,'Pointer','arrow');

attName=handles.Model(md).Input(id).attName;

enc=ddb_enclosure('extract',x,y);
grd=[attName '.grd'];

if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    coord='Spherical';
else
    coord='Cartesian';
end

ddb_wlgrid('write','FileName',grd,'X',x,'Y',y,'Enclosure',enc,'CoordinateSystem',coord);

handles.Model(md).Input(id).grdFile=grd;
handles.Model(md).Input(id).encFile=[attName '.enc'];

handles.Model(md).Input(id).gridX=x;
handles.Model(md).Input(id).gridY=y;

[handles.Model(md).Input(id).gridXZ,handles.Model(md).Input(id).gridYZ]=getXZYZ(x,y);

nans=zeros(size(x));
nans(nans==0)=NaN;
handles.Model(md).Input(id).depth=nans;
handles.Model(md).Input(id).depthZ=nans;

handles.Model(md).Input(id).MMax=size(x,1)+1;
handles.Model(md).Input(id).NMax=size(x,2)+1;
handles.Model(md).Input(id).KMax=1;

handles.Model(md).Input(id).kcs=determineKCS(handles.Model(md).Input(id).gridX,handles.Model(md).Input(id).gridY);

handles=ddb_Delft3DFLOW_plotGrid(handles,'plot','domain',id);



