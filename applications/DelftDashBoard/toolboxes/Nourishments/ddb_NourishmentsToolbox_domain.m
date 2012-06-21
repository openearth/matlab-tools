function ddb_NourishmentsToolbox(varargin)
%DDB_GEOIMAGETOOLBOX  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_GeoImageToolbox(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_GeoImageToolbox
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
% Created: 01 Dec 2011
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
    ddb_plotNourishments('activate');
    handles=getHandles;
    clearInstructions;
%     % setUIElements(handles.Model(md).GUI.elements.tabs(1).elements);
else
    %Options selected
    handles=getHandles;
    opt=lower(varargin{1});
    switch opt
        case{'drawrectangle'}
            setInstructions({'','','Use mouse to draw model outline on map'});
            UIRectangle(handles.GUIHandles.mapAxis,'draw','Tag','ModelOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',0,'callback',@changeModelOnMap,'onstart',@deleteModel);
        case{'drawpolygon'}
            drawPolygon;
        case{'computenourishment'}
            ddb_computeNourishment;
        case{'editoutline'}
            editOutline;
        case{'loadcurrents'}
            loadCurrents;
        case{'selectnourishment'}
            selectNourishment;
        case{'deletepolygon'}
            deleteNourishment;
        case{'selecttype'}
            selectType;
        case{'editvolume','editheight','editthickness'}
            updateVolumesAndHeights;
            refresh;
    end
end

%%
function changeModelOnMap(x0,y0,dx,dy,rotation,h)

setInstructions({'','Left-click and drag markers to change corner points','Right-click and drag yellow marker to move entire box'});

handles=getHandles;
handles.Toolbox(tb).Input.modelOutlineHandle=h;
handles.Toolbox(tb).Input.xLim(1)=x0;
handles.Toolbox(tb).Input.yLim(1)=y0;
handles.Toolbox(tb).Input.xLim(2)=x0+dx;
handles.Toolbox(tb).Input.yLim(2)=y0+dy;

% cs=handles.screenParameters.coordinateSystem;
% dataCoord.name='WGS 84';
% dataCoord.type='geographic';
% 
% % Find bounding box for data
% if ~strcmpi(cs.name,'wgs 84') || ~strcmpi(cs.type,'geographic')
%     ddx=dx/10;
%     ddy=dy/10;
%     [xtmp,ytmp]=meshgrid(x0-ddx:ddx:x0+dx+ddx,y0-ddy:ddy:y0+dy+ddy);
%     [xtmp2,ytmp2]=ddb_coordConvert(xtmp,ytmp,cs,dataCoord);
%     dx=max(max(xtmp2))-min(min(xtmp2));
% end
% 
% npix=handles.Toolbox(tb).Input.nPix;
% zmlev=round(log2(npix*3/(dx)));
% zmlev=max(zmlev,4);
% zmlev=min(zmlev,23);
% 
% handles.Toolbox(tb).Input.zoomLevelStrings{1}=['auto (' num2str(zmlev) ')'];
% 
setHandles(handles);
% setUIElement('nourishmentspanel.domain.editxmin');
% setUIElement('nourishmentspanel.domain.editxmax');
% setUIElement('nourishmentspanel.domain.editymin');
% setUIElement('nourishmentspanel.domain.editymax');

%%
function editOutline
handles=getHandles;
if ~isempty(handles.Toolbox(tb).Input.imageOutlineHandle)
    try
        delete(handles.Toolbox(tb).Input.imageOutlineHandle);
    end
end
x0=handles.Toolbox(tb).Input.xLim(1);
y0=handles.Toolbox(tb).Input.yLim(1);
dx=handles.Toolbox(tb).Input.xLim(2)-x0;
dy=handles.Toolbox(tb).Input.yLim(2)-y0;

h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','ImageOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',0,'callback',@changeGeoImageOnMap, ...
    'onstart',@deleteImageOutline,'x0',x0,'y0',y0,'dx',dx,'dy',dy);
handles.Toolbox(tb).Input.imageOutlineHandle=h;
setHandles(handles);

%%
function deleteModel
handles=getHandles;
if ~isempty(handles.Toolbox(tb).Input.modelOutlineHandle)
    try
        delete(handles.Toolbox(tb).Input.modelOutlineHandle);
    end
end

%%
function drawPolygon
handles=getHandles;
ddb_zoomOff;
iac=handles.Toolbox(tb).Input.nrNourishments+1;
setHandles(handles);
UIPolyline(gca,'draw','Tag','NourishmentOutline','Marker','o','Callback',@changePolygon,'closed',1,'LineColor','r','MarkerFaceColor','b','MarkerEdgeColor','k','UserData',iac);

%%
function changePolygon(x,y,h)

handles=getHandles;

tp=getappdata(h,'type');

if strcmpi(tp,'vertex')
    % Vertex, so existing polygon
    p=getappdata(h,'parent');
    % Find which polygon this is
    for ii=1:handles.Toolbox(tb).Input.nrNourishments
        if handles.Toolbox(tb).Input.nourishments(ii).polygonHandle==p
            iac=ii;
        end
    end
else
    % New nourishment
    iac=handles.Toolbox(tb).Input.nrNourishments+1;
    handles.Toolbox(tb).Input.nrNourishments=iac;
    handles.Toolbox(tb).Input.nourishments(iac).type='volume';
    handles.Toolbox(tb).Input.nourishments(iac).volume=1e6;
    handles.Toolbox(tb).Input.nourishments(iac).thickness=1;
    handles.Toolbox(tb).Input.nourishments(iac).height=1;
    handles.Toolbox(tb).Input.nourishmentNames{iac}=['N' num2str(iac)];
    handles.Toolbox(tb).Input.nourishments(iac).polygonHandle=h;
end

handles.Toolbox(tb).Input.activeNourishment=iac;
handles.Toolbox(tb).Input.nourishments(iac).polygonX=x;
handles.Toolbox(tb).Input.nourishments(iac).polygonY=y;
handles.Toolbox(tb).Input.nourishments(iac).polyLength=length(x);
handles.Toolbox(tb).Input.nourishments(iac).area=polyarea(x,y);

setHandles(handles);

updateVolumesAndHeights;
refresh;

%%
function selectNourishment
refresh;

%%
function deleteNourishment
handles=getHandles;
if handles.Toolbox(tb).Input.nrNourishments>0
    iac=handles.Toolbox(tb).Input.activeNourishment;
    try
        UIPolyline(handles.Toolbox(tb).Input.nourishments(iac).polygonHandle,'delete');
    end
    handles.Toolbox(tb).Input.nrNourishments=handles.Toolbox(tb).Input.nrNourishments-1;
    handles.Toolbox(tb).Input.nourishments=removeFromStruc(handles.Toolbox(tb).Input.nourishments,iac);
    handles.Toolbox(tb).Input.nourishmentNames=[];
    for ii=1:handles.Toolbox(tb).Input.nrNourishments
        handles.Toolbox(tb).Input.nourishmentNames{ii}=['N' num2str(ii)];
    end
    handles.Toolbox(tb).Input.activeNourishment=max(min(handles.Toolbox(tb).Input.nrNourishments,iac),1);
    if handles.Toolbox(tb).Input.nrNourishments==0
        handles.Toolbox(tb).Input.nourishments(1).polygonX=[];
        handles.Toolbox(tb).Input.nourishments(1).polygonY=[];
        handles.Toolbox(tb).Input.nourishments(1).polyLength=0;
        handles.Toolbox(tb).Input.nourishments(1).type='volume';
        handles.Toolbox(tb).Input.nourishments(1).volume=1e6;
        handles.Toolbox(tb).Input.nourishments(1).thickness=1;
        handles.Toolbox(tb).Input.nourishments(1).height=1;
        handles.Toolbox(tb).Input.nourishments(1).area=0;
    end
    setHandles(handles);
    refresh;
end

%%
function updateVolumesAndHeights
handles=getHandles;
iac=handles.Toolbox(tb).Input.activeNourishment;
switch lower(handles.Toolbox(tb).Input.nourishments(iac).type)
    case{'volume'}
        handles.Toolbox(tb).Input.nourishments(iac).thickness=handles.Toolbox(tb).Input.nourishments(iac).volume / ...
            handles.Toolbox(tb).Input.nourishments(iac).area;
    case{'height'}        
%         handles.Toolbox(tb).Input.nourishments(iac).volume=handles.Toolbox(tb).Input.nourishments(iac).area * ...
%             handles.Toolbox(tb).Input.nourishments(iac).thickness;
    case{'thickness'}
        handles.Toolbox(tb).Input.nourishments(iac).volume=handles.Toolbox(tb).Input.nourishments(iac).area * ...
            handles.Toolbox(tb).Input.nourishments(iac).thickness;
end
setHandles(handles);

%%
function refresh
% setUIElement('nourishmentspanel.domain.listpolygons');
% setUIElement('nourishmentspanel.domain.selecttype');
% setUIElement('nourishmentspanel.domain.editvolume');
% setUIElement('nourishmentspanel.domain.editthickness');
% setUIElement('nourishmentspanel.domain.editheight');
% setUIElement('nourishmentspanel.domain.editarea');

%%
function selectType
updateVolumesAndHeights;
refresh;

%%
function loadCurrents
handles=getHandles;
s=load(handles.Toolbox(tb).Input.currentsFile);
h=findobj(gcf,'Tag','ResidualCurrents');
if ~isempty(h)
    delete(h);
end
q=quiver(s.x,s.y,s.u,s.v,'k');
set(q,'Tag','ResidualCurrents');

