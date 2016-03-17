function ddb_TideDatabaseToolbox_export(varargin)
%DDB_TIDEDATABASETOOLBOX_EXPORT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_TideDatabaseToolbox_export(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_TideDatabaseToolbox_export
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
handles=getHandles;

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    % setUIElements('tidedatabasepanel.export');
    ddb_plotTideDatabase('activate');
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'selectmodel'}
            selectModel;
            %        case{'selectscale'}
            %            selectScale;
        case{'drawrectangle'}
            setInstructions({'','','Use mouse to draw data outline on map'});
            UIRectangle(handles.GUIHandles.mapAxis,'draw','Tag','TideDatabaseBox','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',0,'callback',@changeTideDatabaseBox,'onstart',@deleteTideDatabaseBox);
        case{'export'}
            exportData;
        case{'view'}
            viewCoTidalChart;
        case{'editoutline'}
            editOutline;
        case{'selectexportformat'}
            selectExportFormat;
    end
end

%%
function changeTideDatabaseBox(x0,y0,dx,dy,rotation,h)

setInstructions({'','Left-click and drag markers to change corner points','Right-click and drag yellow marker to move entire box'});
handles=getHandles;
handles.toolbox.tidedatabase.tideDatabaseBoxHandle=h;
handles.toolbox.tidedatabase.xLim(1)=x0;
handles.toolbox.tidedatabase.yLim(1)=y0;
handles.toolbox.tidedatabase.xLim(2)=x0+dx;
handles.toolbox.tidedatabase.yLim(2)=y0+dy;
setHandles(handles);

gui_updateActiveTab;

%%
function selectModel
handles=getHandles;
ii=handles.toolbox.tidedatabase.activeModel;
name=handles.tideModels.model(ii).name;
    if strcmpi(handles.tideModels.model(ii).URL(1:4),'http')
        tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
    else
        tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
    end
%nc_dump(tidefile);
cnst=nc_varget(tidefile,'tidal_constituents');
for ii=1:length(cnst)
    cnstlist{ii}=deblank(upper(cnst(ii,:)));
end
handles.toolbox.tidedatabase.constituentList=cnstlist;
handles.toolbox.tidedatabase.activeConstituent=1;

setHandles(handles);

%%
function viewCoTidalChart
handles=getHandles;
ii=handles.toolbox.tidedatabase.activeModel;
iac=handles.toolbox.tidedatabase.activeConstituent;
name=handles.tideModels.model(ii).name;
if strcmpi(handles.tideModels.model(ii).URL(1:4),'http')
    tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
else
    tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
end

xx=handles.toolbox.tidedatabase.xLim;
yy=handles.toolbox.tidedatabase.yLim;

if xx(2)==xx(1)
    ddb_giveWarning('text','First draw a box around the area of interest!');
    return
end

if ~strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    xg=xx(1):(xx(2)-xx(1))/10:xx(2);
    yg=yy(1):(yy(2)-yy(1))/10:yy(2);
    [xg,yg]=meshgrid(xg,yg);
    cs.name='WGS 84';
    cs.type='geographic';
    [xg,yg]=ddb_coordConvert(xg,yg,handles.screenParameters.coordinateSystem,cs);
    xx(1)=min(min(xg))-1;
    yy(1)=min(min(yg))-1;
    xx(2)=max(max(xg))+1;
    yy(2)=max(max(yg))+1;
end

cnst=handles.toolbox.tidedatabase.constituentList{iac};
[lon,lat,ampz,phasez,conList] = readTideModel(tidefile,'type','h','xlim',xx,'ylim',yy,'constituent',upper(cnst));
ampz=squeeze(ampz(:,:,iac));
phasez=squeeze(phasez(:,:,iac));

figure(20)
clf;
subplot(2,1,1)
ampm=reshape(ampz,[1 size(ampz,1)*size(ampz,2)]);
ampm=ampm(~isnan(ampm));
ampm=sort(ampm);
i98=round(0.98*length(ampm));
cmax=ampm(i98);
pcolor(lon,lat,ampz);shading flat;axis equal;caxis([0 cmax]);colorbar;
set(gca,'xlim',[lon(1) lon(end)],'ylim',[lat(1) lat(end)]);
subplot(2,1,2)
pcolor(lon,lat,phasez);shading flat;axis equal;caxis([0 360]);colorbar;
set(gca,'xlim',[lon(1) lon(end)],'ylim',[lat(1) lat(end)]);

    
%%
function selectExportFormat

handles=getHandles;
iac=handles.toolbox.tidedatabase.activeExportFormatIndex;
handles.toolbox.tidedatabase.activeExportFormat=handles.toolbox.tidedatabase.exportFormats{iac};
handles.toolbox.tidedatabase.activeExportFormatExtension=handles.toolbox.tidedatabase.exportFormatExtensions{iac};
setHandles(handles);

%%
function exportData

handles=getHandles;

xx=handles.toolbox.tidedatabase.xLim;
yy=handles.toolbox.tidedatabase.yLim;

if xx(2)==xx(1)
    ddb_giveWarning('text','First draw a box around the area of interest!');
    return
end

wb = waitbox('Exporting tide data ...');pause(0.1);

try
    
    filename=handles.toolbox.tidedatabase.exportFile;
    
    filename=filename(1:end-4);
    
    ii=handles.toolbox.tidedatabase.activeModel;
    name=handles.tideModels.model(ii).name;
    
    if strcmpi(handles.tideModels.model(ii).URL(1:4),'http')
        tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
    else
        tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
    end

    % H
    if ~strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
        xg=xx(1):(xx(2)-xx(1))/10:xx(2);
        yg=yy(1):(yy(2)-yy(1))/10:yy(2);
        [xg,yg]=meshgrid(xg,yg);
        cs.name='WGS 84';
        cs.type='geographic';
        [xg,yg]=ddb_coordConvert(xg,yg,handles.screenParameters.coordinateSystem,cs);
        xx(1)=min(min(xg))-1;
        yy(1)=min(min(yg))-1;
        xx(2)=max(max(xg))+1;
        yy(2)=max(max(yg))+1;
    end
    
    [lon,lat,ampz,phasez,conList] = readTideModel(tidefile,'type','h','xlim',xx,'ylim',yy,'constituent','all');    
    
    for i=1:length(conList)
        if ~strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
            xx=handles.toolbox.tidedatabase.xLim;
            yy=handles.toolbox.tidedatabase.yLim;
            xg=xx(1):10000:xx(2);
            yg=yy(1):10000:yy(2);
            [xg,yg]=meshgrid(xg,yg);
            [xglo,ygla]=ddb_coordConvert(xg,yg,handles.screenParameters.coordinateSystem,cs);
            [lo,la]=meshgrid(lon,lat);
            amp{i}=interp2(lo,la,squeeze(ampz(:,:,i)),xglo,ygla);
            phi{i}=interp2(lo,la,squeeze(phasez(:,:,i)),xglo,ygla);            
        else
            [xg,yg]=meshgrid(lon,lat);
            amp{i}=squeeze(ampz(:,:,i));
            phi{i}=squeeze(phasez(:,:,i));
        end
    end

    switch lower(handles.toolbox.tidedatabase.activeExportFormat)
        case{'mat'}
            for icon=1:length(conList)
                ii=icon*2-1;
                s.parameters(ii).parameter.name=['Amplitude - ' conList{icon}];
                s.parameters(ii).parameter.quantity='scalar';
                s.parameters(ii).parameter.x=xg;
                s.parameters(ii).parameter.y=yg;
                s.parameters(ii).parameter.val=amp{icon};
                s.parameters(ii).parameter.size=[0 0 size(xg,1) size(xg,2) 0];
                ii=icon*2;
                s.parameters(ii).parameter.name=['Phase - ' conList{icon}];
                s.parameters(ii).parameter.quantity='scalar';
                s.parameters(ii).parameter.x=xg;
                s.parameters(ii).parameter.y=yg;
                s.parameters(ii).parameter.val=phi{icon};
                s.parameters(ii).parameter.size=[0 0 size(xg,1) size(xg,2) 0];
            end
            save([filename '.mat'],'-struct','s');
            close(wb);
            return
        case{'tek'}
            ddb_saveAstroMapFile([filename '.tek'],xg,yg,conList,amp,phi);
    end

    % U

    xx=handles.toolbox.tidedatabase.xLim;
    yy=handles.toolbox.tidedatabase.yLim;

    if ~strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
        xg=xx(1):(xx(2)-xx(1))/10:xx(2);
        yg=yy(1):(yy(2)-yy(1))/10:yy(2);
        [xg,yg]=meshgrid(xg,yg);
        cs.name='WGS 84';
        cs.type='geographic';
        [xg,yg]=ddb_coordConvert(xg,yg,handles.screenParameters.coordinateSystem,cs);
        xx(1)=min(min(xg))-1;
        yy(1)=min(min(yg))-1;
        xx(2)=max(max(xg))+1;
        yy(2)=max(max(yg))+1;
    end
        
    [lon,lat,ampz,phasez,conList] = readTideModel(tidefile,'type','u','xlim',xx,'ylim',yy,'constituent','all');
    
    for i=1:length(conList)
        if ~strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
            xx=handles.toolbox.tidedatabase.xLim;
            yy=handles.toolbox.tidedatabase.yLim;
            xg=xx(1):10000:xx(2);
            yg=yy(1):10000:yy(2);
            [xg,yg]=meshgrid(xg,yg);
            [xglo,ygla]=ddb_coordConvert(xg,yg,handles.screenParameters.coordinateSystem,cs);
            [lo,la]=meshgrid(lon,lat);
            amp{i}=interp2(lo,la,squeeze(ampz(:,:,i)),xglo,ygla);
            phi{i}=interp2(lo,la,squeeze(phasez(:,:,i)),xglo,ygla);            
        else
            [xg,yg]=meshgrid(lon,lat);
            amp{i}=squeeze(ampz(:,:,i));
            phi{i}=squeeze(phasez(:,:,i));
        end
    end
    
    switch lower(handles.toolbox.tidedatabase.activeExportFormat)
        case{'tek'}
            ddb_saveAstroMapFile([filename '.u.tek'],xg,yg,conList,amp,phi);
    end

    % V

    xx=handles.toolbox.tidedatabase.xLim;
    yy=handles.toolbox.tidedatabase.yLim;

    if ~strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
        xg=xx(1):(xx(2)-xx(1))/10:xx(2);
        yg=yy(1):(yy(2)-yy(1))/10:yy(2);
        [xg,yg]=meshgrid(xg,yg);
        cs.name='WGS 84';
        cs.type='geographic';
        [xg,yg]=ddb_coordConvert(xg,yg,handles.screenParameters.coordinateSystem,cs);
        xx(1)=min(min(xg))-1;
        yy(1)=min(min(yg))-1;
        xx(2)=max(max(xg))+1;
        yy(2)=max(max(yg))+1;
    end
    
    [lon,lat,ampz,phasez,conList] = readTideModel(tidefile,'type','v','xlim',xx,'ylim',yy,'constituent','all');
    
    for i=1:length(conList)
        if ~strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
            xx=handles.toolbox.tidedatabase.xLim;
            yy=handles.toolbox.tidedatabase.yLim;
            xg=xx(1):10000:xx(2);
            yg=yy(1):10000:yy(2);
            [xg,yg]=meshgrid(xg,yg);
            [xglo,ygla]=ddb_coordConvert(xg,yg,handles.screenParameters.coordinateSystem,cs);
            [lo,la]=meshgrid(lon,lat);
            amp{i}=interp2(lo,la,squeeze(ampz(:,:,i)),xglo,ygla);
            phi{i}=interp2(lo,la,squeeze(phasez(:,:,i)),xglo,ygla);            
        else
            [xg,yg]=meshgrid(lon,lat);
            amp{i}=squeeze(ampz(:,:,i));
            phi{i}=squeeze(phasez(:,:,i));
        end
    end
    
    switch lower(handles.toolbox.tidedatabase.activeExportFormat)
        case{'tek'}
            ddb_saveAstroMapFile([filename '.u.tek'],xg,yg,conList,amp,phi);
    end
    
    close(wb);
    
catch
    close(wb);
    ddb_giveWarning('text','An error occured while generating tide data!');
end

%%
function editOutline
handles=getHandles;
deleteTideDatabaseBox;
x0=handles.toolbox.tidedatabase.xLim(1);
y0=handles.toolbox.tidedatabase.yLim(1);
dx=handles.toolbox.tidedatabase.xLim(2)-x0;
dy=handles.toolbox.tidedatabase.yLim(2)-y0;
h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','ImageOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',0,'callback',@changeTideDatabaseBox, ...
    'onstart',@deleteTideDatabaseBox,'x0',x0,'y0',y0,'dx',dx,'dy',dy);
handles.toolbox.tidedatabase.tideDatabaseBoxHandle=h;
setHandles(handles);

%%
function deleteTideDatabaseBox
handles=getHandles;
if ~isempty(handles.toolbox.tidedatabase.tideDatabaseBoxHandle)
    try
        delete(handles.toolbox.tidedatabase.tideDatabaseBoxHandle);
    end
end


