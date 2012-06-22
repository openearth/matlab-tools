function ddb_Delft3DFLOW_bathymetry(varargin)
%DDB_DELFT3DFLOW_BATHYMETRY  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_Delft3DFLOW_bathymetry(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_Delft3DFLOW_bathymetry
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
if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    % setUIElements('delft3dflow.domain.domainpanel.bathymetry');
else
    opt=varargin{1};
    switch lower(opt)
        case{'selectdepthfile'}
            selectDepthFile;
    end
end

%%
function selectDepthFile
handles=getHandles;
filename=handles.Model(md).Input(ad).depFile;
dp=ddb_wldep('read',filename,[handles.Model(md).Input(ad).MMax,handles.Model(md).Input(ad).NMax]);
handles.Model(md).Input(ad).depth=-dp(1:end-1,1:end-1);
handles.Model(md).Input(ad).depth(handles.Model(md).Input(ad).depth==999.999)=NaN;
handles.Model(md).Input(ad).depthZ=getDepthZ(handles.Model(md).Input(ad).depth,handles.Model(md).Input(ad).dpsOpt);
handles=ddb_Delft3DFLOW_plotBathy(handles,'plot','domain',ad);
setHandles(handles);
%ddb_plotFlowBathymetry(handles,'plot',ad);

