function ddb_ModelMakerToolbox_sfincs_mask(varargin)
%ddb_DrawingToolbox  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_DrawingToolbox(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_DrawingToolbox
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 Deltares
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

% $Id: ddb_drawingToolbox_export.m 12926 2016-10-15 07:47:58Z ormondt $
% $Date: 2016-10-15 09:47:58 +0200 (Sat, 15 Oct 2016) $
% $Author: ormondt $
% $Revision: 12926 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/drawing/ddb_drawingToolbox_export.m $
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotModelMaker('deactivate');
    ddb_plotsfincs('update','active',1,'visible',1);

    h=findobj(gca,'Tag','sfincsincludepolygon');
    if ~isempty(h)
        set(h,'Visible','on');
        uistack(h,'top');
    end
    h=findobj(gca,'Tag','sfincsexcludepolygon');
    if ~isempty(h)
        set(h,'Visible','on');
        uistack(h,'top');
    end
    
    handles=getHandles;
    ddb_sfincs_plot_mask(handles, 'update','domain',ad,'visible',1);
    
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'selectincludepolygon'}
            selectIncludePolygon;
        case{'drawincludepolygon'}
            drawIncludePolygon;
        case{'deleteincludepolygon'}
            deleteIncludePolygon;
        case{'loadincludepolygon'}
            loadIncludePolygon;
        case{'saveincludepolygon'}
            saveIncludePolygon;
        case{'selectexcludepolygon'}
            selectExcludePolygon;
        case{'drawexcludepolygon'}
            drawExcludePolygon;
        case{'deleteexcludepolygon'}
            deleteExcludePolygon;
        case{'loadexcludepolygon'}
            loadExcludePolygon;
        case{'saveexcludepolygon'}
            saveExcludePolygon;
        case{'generatemask'}
            generateMask;
    end
end




%%
function selectIncludePolygon
handles=getHandles;
setHandles(handles);


%%
function drawIncludePolygon

handles=getHandles;
ddb_zoomOff;

handles.toolbox.modelmaker.sfincs.mask.includepolygonhandle=gui_polyline('draw','tag','sfincsincludepolygon','marker','o', ...
    'createcallback',@createIncludePolygon,'changecallback',@changeIncludePolygon, ...
    'closed',1);

setHandles(handles);

%%
function createIncludePolygon(h,x,y)
handles=getHandles;
handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons=handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons+1;
iac=handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons;
handles.toolbox.modelmaker.sfincs.mask.includepolygon(iac).handle=h;
handles.toolbox.modelmaker.sfincs.mask.includepolygon(iac).x=x;
handles.toolbox.modelmaker.sfincs.mask.includepolygon(iac).y=y;
handles.toolbox.modelmaker.sfincs.mask.includepolygon(iac).length=length(x);
handles.toolbox.modelmaker.sfincs.mask.includepolygonnames{iac}=['polygon_' num2str(iac,'%0.3i')];
handles.toolbox.modelmaker.sfincs.mask.activeincludepolygon=iac;
setHandles(handles);
gui_updateActiveTab;

%%
function deleteIncludePolygon

handles=getHandles;

iac=handles.toolbox.modelmaker.sfincs.mask.activeincludepolygon;
if handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons>0
    h=handles.toolbox.modelmaker.sfincs.mask.includepolygon(iac).handle;
    if ~isempty(h)
        try
            delete(h);
        end
    end
end

handles.toolbox.modelmaker.sfincs.mask.includepolygon=removeFromStruc(handles.toolbox.modelmaker.sfincs.mask.includepolygon,iac);
handles.toolbox.modelmaker.sfincs.mask.includepolygonnames=removeFromCellArray(handles.toolbox.modelmaker.sfincs.mask.includepolygonnames,iac);

handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons=max(handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons-1,0);
handles.toolbox.modelmaker.sfincs.mask.activeincludepolygon=min(handles.toolbox.modelmaker.sfincs.mask.activeincludepolygon,handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons);

if handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons==0
    handles.toolbox.modelmaker.sfincs.mask.includepolygon=[];
    handles.toolbox.modelmaker.sfincs.mask.includepolygon(1).x=[];
    handles.toolbox.modelmaker.sfincs.mask.includepolygon(1).y=[];
    handles.toolbox.modelmaker.sfincs.mask.includepolygon(1).length=0;
    handles.toolbox.modelmaker.sfincs.mask.includepolygon(1).handle=[];
    handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons=0;
    handles.toolbox.modelmaker.sfincs.mask.includepolygonnames={''};
    handles.toolbox.modelmaker.sfincs.mask.activeincludepolygon=1;
end

setHandles(handles);

%%
function changeIncludePolygon(h,x,y,varargin)
handles=getHandles;
for ip=1:handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons
    if handles.toolbox.modelmaker.sfincs.mask.includepolygon(ip).handle==h
        iac=ip;
        break
    end
end

handles.toolbox.modelmaker.sfincs.mask.includepolygon(iac).x=x;
handles.toolbox.modelmaker.sfincs.mask.includepolygon(iac).y=y;
handles.toolbox.modelmaker.sfincs.mask.includepolygon(iac).length=length(x);
handles.toolbox.modelmaker.sfincs.mask.activeincludepolygon=iac;
setHandles(handles);
gui_updateActiveTab;

%%
function loadIncludePolygon

handles=getHandles;

% Clear all
handles.toolbox.modelmaker.sfincs.mask.includepolygon=[];
handles.toolbox.modelmaker.sfincs.mask.includepolygon(1).x=[];
handles.toolbox.modelmaker.sfincs.mask.includepolygon(1).y=[];
handles.toolbox.modelmaker.sfincs.mask.includepolygon(1).length=0;
handles.toolbox.modelmaker.sfincs.mask.includepolygon(1).handle=[];
handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons=0;
handles.toolbox.modelmaker.sfincs.mask.includepolygonnames={''};

h=findobj(gca,'Tag','sfincsincludepolygon');
delete(h);

data=tekal('read',handles.toolbox.modelmaker.sfincs.mask.includepolygonfile,'loaddata');
handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons=length(data.Field);
handles.toolbox.modelmaker.sfincs.mask.activeincludepolygon=1;
for ip=1:handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons
    x=data.Field(ip).Data(:,1);
    y=data.Field(ip).Data(:,2);
    if x(end)~=x(1) || y(end)~=y(1)
        x=[x;x(1)];
        y=[y;y(1)];
    end
    handles.toolbox.modelmaker.sfincs.mask.includepolygon(ip).x=x;
    handles.toolbox.modelmaker.sfincs.mask.includepolygon(ip).y=y;
    handles.toolbox.modelmaker.sfincs.mask.includepolygon(ip).length=length(x);
    handles.toolbox.modelmaker.sfincs.mask.includepolygonnames{ip}=deblank2(data.Field(ip).Name);
    h=gui_polyline('plot','x',x,'y',y,'tag','sfincsincludepolygon','marker','o', ...
        'changecallback',@changeIncludePolygon);
    handles.toolbox.modelmaker.sfincs.mask.includepolygon(ip).handle=h;
end

setHandles(handles);

%%
function saveIncludePolygon

handles=getHandles;

cs=handles.screenParameters.coordinateSystem.type;
if strcmpi(cs,'geographic')
    fmt='%12.7f %12.7f\n';
else
    fmt='%11.1f %11.1f\n';
end

fid=fopen(handles.toolbox.modelmaker.sfincs.mask.includepolygonfile,'wt');
for ip=1:handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons
    fprintf(fid,'%s\n',handles.toolbox.modelmaker.sfincs.mask.includepolygonnames{ip});
    fprintf(fid,'%i %i\n',[handles.toolbox.modelmaker.sfincs.mask.includepolygon(ip).length 2]);
    for ix=1:handles.toolbox.modelmaker.sfincs.mask.includepolygon(ip).length
        fprintf(fid,fmt,[handles.toolbox.modelmaker.sfincs.mask.includepolygon(ip).x(ix) handles.toolbox.modelmaker.sfincs.mask.includepolygon(ip).y(ix)]);
    end
end
fclose(fid);



%%
function selectExcludePolygon
handles=getHandles;
setHandles(handles);


%%
function drawExcludePolygon

handles=getHandles;
ddb_zoomOff;

handles.toolbox.modelmaker.sfincs.mask.excludepolygonhandle=gui_polyline('draw','tag','sfincsexcludepolygon','color','b','marker','o', ...
    'createcallback',@createExcludePolygon,'changecallback',@changeExcludePolygon, ...
    'closed',1);

setHandles(handles);

%%
function createExcludePolygon(h,x,y)
handles=getHandles;
handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons=handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons+1;
iac=handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons;
handles.toolbox.modelmaker.sfincs.mask.excludepolygon(iac).handle=h;
handles.toolbox.modelmaker.sfincs.mask.excludepolygon(iac).x=x;
handles.toolbox.modelmaker.sfincs.mask.excludepolygon(iac).y=y;
handles.toolbox.modelmaker.sfincs.mask.excludepolygon(iac).length=length(x);
handles.toolbox.modelmaker.sfincs.mask.excludepolygonnames{iac}=['polygon_' num2str(iac,'%0.3i')];
handles.toolbox.modelmaker.sfincs.mask.activeexcludepolygon=iac;
setHandles(handles);
gui_updateActiveTab;

%%
function deleteExcludePolygon

handles=getHandles;

iac=handles.toolbox.modelmaker.sfincs.mask.activeexcludepolygon;
if handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons>0
    h=handles.toolbox.modelmaker.sfincs.mask.excludepolygon(iac).handle;
    if ~isempty(h)
        try
            delete(h);
        end
    end
end

handles.toolbox.modelmaker.sfincs.mask.excludepolygon=removeFromStruc(handles.toolbox.modelmaker.sfincs.mask.excludepolygon,iac);
handles.toolbox.modelmaker.sfincs.mask.excludepolygonnames=removeFromCellArray(handles.toolbox.modelmaker.sfincs.mask.excludepolygonnames,iac);

handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons=max(handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons-1,0);
handles.toolbox.modelmaker.sfincs.mask.activeexcludepolygon=min(handles.toolbox.modelmaker.sfincs.mask.activeexcludepolygon,handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons);

if handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons==0
    handles.toolbox.modelmaker.sfincs.mask.excludepolygon=[];
    handles.toolbox.modelmaker.sfincs.mask.excludepolygon(1).x=[];
    handles.toolbox.modelmaker.sfincs.mask.excludepolygon(1).y=[];
    handles.toolbox.modelmaker.sfincs.mask.excludepolygon(1).length=0;
    handles.toolbox.modelmaker.sfincs.mask.excludepolygon(1).handle=[];
    handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons=0;
    handles.toolbox.modelmaker.sfincs.mask.excludepolygonnames={''};
    handles.toolbox.modelmaker.sfincs.mask.activeexcludepolygon=1;
end

setHandles(handles);

%%
function changeExcludePolygon(h,x,y,varargin)
handles=getHandles;
for ip=1:handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons
    if handles.toolbox.modelmaker.sfincs.mask.excludepolygon(ip).handle==h
        iac=ip;
        break
    end
end

handles.toolbox.modelmaker.sfincs.mask.excludepolygon(iac).x=x;
handles.toolbox.modelmaker.sfincs.mask.excludepolygon(iac).y=y;
handles.toolbox.modelmaker.sfincs.mask.excludepolygon(iac).length=length(x);
handles.toolbox.modelmaker.sfincs.mask.activeexcludepolygon=iac;
setHandles(handles);
gui_updateActiveTab;

%%
function loadExcludePolygon

handles=getHandles;

% Clear all
handles.toolbox.modelmaker.sfincs.mask.excludepolygon=[];
handles.toolbox.modelmaker.sfincs.mask.excludepolygon(1).x=[];
handles.toolbox.modelmaker.sfincs.mask.excludepolygon(1).y=[];
handles.toolbox.modelmaker.sfincs.mask.excludepolygon(1).length=0;
handles.toolbox.modelmaker.sfincs.mask.excludepolygon(1).handle=[];
handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons=0;
handles.toolbox.modelmaker.sfincs.mask.excludepolygonnames={''};

h=findobj(gca,'Tag','sfincsexcludepolygon');
delete(h);

data=tekal('read',handles.toolbox.modelmaker.sfincs.mask.excludepolygonfile,'loaddata');
handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons=length(data.Field);
handles.toolbox.modelmaker.sfincs.mask.activeexcludepolygon=1;
for ip=1:handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons
    x=data.Field(ip).Data(:,1);
    y=data.Field(ip).Data(:,2);
    if x(end)~=x(1) || y(end)~=y(1)
        x=[x;x(1)];
        y=[y;y(1)];
    end
    handles.toolbox.modelmaker.sfincs.mask.excludepolygon(ip).x=x;
    handles.toolbox.modelmaker.sfincs.mask.excludepolygon(ip).y=y;
    handles.toolbox.modelmaker.sfincs.mask.excludepolygon(ip).length=length(x);
    handles.toolbox.modelmaker.sfincs.mask.excludepolygonnames{ip}=deblank2(data.Field(ip).Name);
    h=gui_polyline('plot','x',x,'y',y,'tag','sfincsexcludepolygon','color','b','marker','o', ...
        'changecallback',@changeIncludePolygon);
    handles.toolbox.modelmaker.sfincs.mask.excludepolygon(ip).handle=h;
end

setHandles(handles);

%%
function saveExcludePolygon

handles=getHandles;

cs=handles.screenParameters.coordinateSystem.type;
if strcmpi(cs,'geographic')
    fmt='%12.7f %12.7f\n';
else
    fmt='%11.1f %11.1f\n';
end

fid=fopen(handles.toolbox.modelmaker.sfincs.mask.excludepolygonfile,'wt');
for ip=1:handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons
    fprintf(fid,'%s\n',handles.toolbox.modelmaker.sfincs.mask.excludepolygonnames{ip});
    fprintf(fid,'%i %i\n',[handles.toolbox.modelmaker.sfincs.mask.excludepolygon(ip).length 2]);
    for ix=1:handles.toolbox.modelmaker.sfincs.mask.excludepolygon(ip).length
        fprintf(fid,fmt,[handles.toolbox.modelmaker.sfincs.mask.excludepolygon(ip).x(ix) handles.toolbox.modelmaker.sfincs.mask.excludepolygon(ip).y(ix)]);
    end
end
fclose(fid);

%%
function generateMask

handles=getHandles;

id=ad;

%% Grid coordinates and type
% These are the centre points !
xg=handles.model.sfincs.domain(id).gridx;
yg=handles.model.sfincs.domain(id).gridy;
zg=handles.model.sfincs.domain(id).gridz;

%% Update model data
handles.model.sfincs.domain(id).gridz=zg;

%% Now make the mask matrix
zmin=handles.toolbox.modelmaker.sfincs.zmin;
zmax=handles.toolbox.modelmaker.sfincs.zmax;

xy_in=handles.toolbox.modelmaker.sfincs.mask.includepolygon;
xy_ex=handles.toolbox.modelmaker.sfincs.mask.excludepolygon;

msk=sfincs_make_mask(xg,yg,zg,[zmin zmax],'includepolygon',xy_in,'excludepolygon',xy_ex);
msk(isnan(zg))=0;
handles.model.sfincs.domain(id).mask=msk;

%% And save the files
indexfile=handles.model.sfincs.domain(id).input.indexfile;
bindepfile=handles.model.sfincs.domain(id).input.depfile;
binmskfile=handles.model.sfincs.domain(id).input.mskfile;

% handles.model.sfincs.domain(id).input.inputformat='asc';

if strcmpi(handles.model.sfincs.domain(id).input.inputformat,'bin')
    sfincs_write_binary_inputs(zg,msk,indexfile,bindepfile,binmskfile);
else
    sfincs_write_ascii_inputs(zg,msk,bindepfile,binmskfile);
end

handles = ddb_sfincs_plot_mask(handles, 'plot');

setHandles(handles);

