function ddb_DFlowFM_net(varargin)
%DDB_DFlowFM_net  One line description goes here.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
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
else
    opt=varargin{1};
    switch lower(opt)
        case{'selectnetfile'}
            selectNetFile;
    end
end

%%
function selectNetFile
handles=getHandles;

fname=handles.model.dflowfm.domain(ad).netfile;

%andles.model.dflowfm.domain(ad).netstruc=loadnetstruc(fname);
%handles.model.dflowfm.domain(ad).netstruc=loadnetstruc2(fname);
handles.model.dflowfm.domain(ad).netstruc=dflowfm.readNet(fname);
% handles.model.dflowfm.domain(ad).netstruc.edge.NetLink=handles.model.dflowfm.domain(ad).netstruc.edge.NetLink';

%handles.model.dflowfm.domain.circumference=ddb_findNetCircumference(handles.model.dflowfm.domain(ad).netstruc);
handles.model.dflowfm.domain.circumference=[];

% Zoom to grid
xl(1)=min(handles.model.dflowfm.domain.netstruc.node.x);
xl(2)=max(handles.model.dflowfm.domain.netstruc.node.x);
yl(1)=min(handles.model.dflowfm.domain.netstruc.node.y);
yl(2)=max(handles.model.dflowfm.domain.netstruc.node.y);
handles=ddb_zoomTo(handles,xl,yl,0.1);

handles=ddb_DFlowFM_plotGrid(handles,'plot','domain',ad,'color',[0.35 0.35 0.35],'visible',1,'active',1);

setHandles(handles);
