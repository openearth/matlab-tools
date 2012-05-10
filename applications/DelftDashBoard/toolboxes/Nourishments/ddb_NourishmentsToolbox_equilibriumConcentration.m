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
    setUIElements(handles.Model(md).GUI.elements.tabs(1).elements);
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'drawpolygon'}
            drawPolygon;
        case{'deletepolygon'}
            deleteConcentrationPolygon;
        case{'computenourishment'}
            ddb_computeNourishment;
        case{'selectpolygon'}
            refresh;
    end
end

%%
function drawPolygon
handles=getHandles;
ddb_zoomOff;
setHandles(handles);
UIPolyline(gca,'draw','Tag','ConcentrationOutline','Marker','o','Callback',@changePolygon,'closed',1,'LineColor','y','MarkerFaceColor','g','MarkerEdgeColor','k');

%%
function changePolygon(x,y,h)

handles=getHandles;

tp=getappdata(h,'type');

if strcmpi(tp,'vertex')
    % Vertex, so existing polygon
    p=getappdata(h,'parent');
    % Find which polygon this is
    for ii=1:handles.Toolbox(tb).Input.nrConcentrationPolygons
        if handles.Toolbox(tb).Input.concentrationPolygons(ii).polygonHandle==p
            iac=ii;
        end
    end
else
    % New nourishment
    iac=handles.Toolbox(tb).Input.nrConcentrationPolygons+1;
    handles.Toolbox(tb).Input.nrConcentrationPolygons=iac;
    handles.Toolbox(tb).Input.concentrationPolygons(iac).concentration=0.02;
    handles.Toolbox(tb).Input.concentrationNames{iac}=['C' num2str(iac)];
    handles.Toolbox(tb).Input.concentrationPolygons(iac).polygonHandle=h;
end

handles.Toolbox(tb).Input.activeConcentrationPolygon=iac;
handles.Toolbox(tb).Input.concentrationPolygons(iac).polygonX=x;
handles.Toolbox(tb).Input.concentrationPolygons(iac).polygonY=y;
handles.Toolbox(tb).Input.concentrationPolygons(iac).polyLength=length(x);

setHandles(handles);

refresh;

%%
function deleteConcentrationPolygon
handles=getHandles;
if handles.Toolbox(tb).Input.nrConcentrationPolygons>0
    iac=handles.Toolbox(tb).Input.activeConcentrationPolygon;
    try
        UIPolyline(handles.Toolbox(tb).Input.concentrationPolygons(iac).polygonHandle,'delete');
    end
    handles.Toolbox(tb).Input.nrConcentrationPolygons=handles.Toolbox(tb).Input.nrConcentrationPolygons-1;
    handles.Toolbox(tb).Input.concentrationPolygons=removeFromStruc(handles.Toolbox(tb).Input.concentrationPolygons,iac);
    handles.Toolbox(tb).Input.concentrationNames=[];
    for ii=1:handles.Toolbox(tb).Input.nrConcentrationPolygons
        handles.Toolbox(tb).Input.concentrationNames{ii}=['C' num2str(ii)];
    end
    handles.Toolbox(tb).Input.activeConcentrationPolygon=max(min(handles.Toolbox(tb).Input.nrConcentrationPolygons,iac),1);
    if handles.Toolbox(tb).Input.nrConcentrationPolygons==0
        handles.Toolbox(tb).Input.concentrationPolygons(1).polygonX=[];
        handles.Toolbox(tb).Input.concentrationPolygons(1).polygonY=[];
        handles.Toolbox(tb).Input.concentrationPolygons(1).polyLength=0;
        handles.Toolbox(tb).Input.concentrationPolygons(1).concentration=0.02;
    end
    setHandles(handles);
    refresh;
end

%%
function refresh
setUIElement('nourishmentspanel.equilibriumconcentration.listpolygons');
setUIElement('nourishmentspanel.equilibriumconcentration.editconcentration');
