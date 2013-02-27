function ddb_BathymetryToolbox_export(varargin)
%DDB_BATHYMETRYTOOLBOX_EXPORT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_BathymetryToolbox_export(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_BathymetryToolbox_export
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
    selectDataset;
    ddb_plotBathymetry('activate');
    h=findobj(gca,'Tag','bathymetrypolygon');
    set(h,'Visible','on');
    h=findobj(gca,'Tag','bathymetryrectangle');
    set(h,'Visible','off');
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'selectdataset'}
            selectDataset;
        case{'selectzoomlevel'}
            selectZoomLevel;
        case{'drawpolygon'}
            drawPolygon;
        case{'deletepolygon'}
            deletePolygon;
        case{'loadpolygon'}
            loadPolygon;
        case{'savepolygon'}
            savePolygon;
        case{'export'}
            exportData;
    end
end

%%
function selectDataset
handles=getHandles;
handles.Toolbox(tb).Input.activeZoomLevel=1;
handles=setResolutionText(handles);
handles.Toolbox(tb).Input.zoomLevelText=[];
for i=1:length(handles.bathymetry.dataset(handles.Toolbox(tb).Input.activeDataset).zoomLevel)
    handles.Toolbox(tb).Input.zoomLevelText{i}=num2str(i);
end
setHandles(handles);

%%
function selectZoomLevel
handles=getHandles;
handles=setResolutionText(handles);
setHandles(handles);

%%
function handles=setResolutionText(handles)

cellSize=handles.bathymetry.dataset(handles.Toolbox(tb).Input.activeDataset).zoomLevel(handles.Toolbox(tb).Input.activeZoomLevel).dx;
if strcmpi(handles.bathymetry.dataset(handles.Toolbox(tb).Input.activeDataset).horizontalCoordinateSystem.type,'Geographic')
    cellSize=cellSize*111111;
    handles.Toolbox(tb).Input.resolutionText=['Cell Size : ~ ' num2str(cellSize,'%10.0f') ' m'];
else
    handles.Toolbox(tb).Input.resolutionText=['Cell Size : ' num2str(cellSize,'%10.0f') ' m'];
end

%%
function exportData

handles=getHandles;

filename=handles.Toolbox(tb).Input.bathyFile;

if handles.bathymetry.dataset(handles.Toolbox(tb).Input.activeDataset).isAvailable
    
    wb = waitbox('Exporting samples ...');pause(0.1);
    
    cs.name=handles.bathymetry.dataset(handles.Toolbox(tb).Input.activeDataset).horizontalCoordinateSystem.name;
    cs.type=handles.bathymetry.dataset(handles.Toolbox(tb).Input.activeDataset).horizontalCoordinateSystem.type;
    
    [xx,yy]=ddb_coordConvert(handles.Toolbox(tb).Input.polygonX,handles.Toolbox(tb).Input.polygonY,handles.screenParameters.coordinateSystem,cs);
    
    ii=handles.Toolbox(tb).Input.activeDataset;
    str=handles.bathymetry.datasets;
    bset=str{ii};
    
    xlim(1)=min(xx);
    xlim(2)=max(xx);
    ylim(1)=min(yy);
    ylim(2)=max(yy);
    
    fname=filename;
    
    zoomlevel=handles.Toolbox(tb).Input.activeZoomLevel;
    
    [x,y,z,ok]=ddb_getBathymetry(handles.bathymetry,xlim,ylim,'bathymetry',bset,'zoomlevel',zoomlevel);
    
    extension=filename(end-2:end);
    
    switch lower(extension)
        case{'xyz'}
            
            [x,y]=ddb_coordConvert(x,y,cs,handles.screenParameters.coordinateSystem);
            
            np=size(x,1)*size(x,2);
            
            x=reshape(x,[np,1]);
            y=reshape(y,[np,1]);
            z=reshape(z,[np,1]);
            
            in = inpolygon(x,y,handles.Toolbox(tb).Input.polygonX,handles.Toolbox(tb).Input.polygonY);
            
            x=x(in);
            y=y(in);
            z=z(in);
            isn=isnan(z);
            
            %     if min(isn)==0
            x=x(~isn);
            y=y(~isn);
            z=z(~isn);
            %     end
            
            if strcmpi(handles.Toolbox(tb).Input.activeDirection,'down')
                z=z*-1;
            end
            
            data(:,1)=x;
            data(:,2)=y;
            data(:,3)=z;
            
            save(fname,'data','-ascii');
            
        case{'asc'}

            arcgridwrite(filename,x,y,z);

    
    end

    close(wb);
    
end

%%
function drawPolygon
handles=getHandles;
ddb_zoomOff;
h=findobj(gcf,'Tag','bathymetrypolygon');
if ~isempty(h)
    delete(h);
end

handles.Toolbox(tb).Input.polygonX=[];
handles.Toolbox(tb).Input.polygonY=[];
handles.Toolbox(tb).Input.polyLength=0;

handles.Toolbox(tb).Input.polygonhandle=gui_polyline('draw','tag','bathymetrypolygon','marker','o', ...
    'createcallback',@createPolygon,'changecallback',@changePolygon, ...
    'closed',1);

setHandles(handles);

%%
function createPolygon(h,x,y)
handles=getHandles;
handles.Toolbox(tb).Input.polygonhandle=h;
handles.Toolbox(tb).Input.polygonX=x;
handles.Toolbox(tb).Input.polygonY=y;
handles.Toolbox(tb).Input.polyLength=length(x);
setHandles(handles);
gui_updateActiveTab;

%%
function deletePolygon
handles=getHandles;
handles.Toolbox(tb).Input.polygonX=[];
handles.Toolbox(tb).Input.polygonY=[];
handles.Toolbox(tb).Input.polyLength=0;
h=findobj(gcf,'Tag','bathymetrypolygon');
if ~isempty(h)
    delete(h);
end
setHandles(handles);

%%
function changePolygon(h,x,y,varargin)
handles=getHandles;
handles.Toolbox(tb).Input.polygonX=x;
handles.Toolbox(tb).Input.polygonY=y;
handles.Toolbox(tb).Input.polyLength=length(x);
setHandles(handles);

%%
function loadPolygon
handles=getHandles;
[x,y]=landboundary('read',handles.Toolbox(tb).Input.polygonFile);
handles.Toolbox(tb).Input.polygonX=x;
handles.Toolbox(tb).Input.polygonY=y;
handles.Toolbox(tb).Input.polyLength=length(x);
h=findobj(gca,'Tag','bathymetrypolygon');
delete(h);
h=gui_polyline('plot','x',x,'y',y,'tag','bathymetrypolygon','marker','o', ...
        'changecallback',@changePolygon);
handles.Toolbox(tb).Input.polygonhandle=h;
setHandles(handles);

%%
function savePolygon
handles=getHandles;
x=handles.Toolbox(tb).Input.polygonX;
y=handles.Toolbox(tb).Input.polygonY;
if size(x,1)==1
    x=x';
end
if size(y,1)==1
    y=y';
end

landboundary('write',handles.Toolbox(tb).Input.polygonFile,x,y);
