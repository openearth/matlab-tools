function ddb_Delft3DFLOW_grid(varargin)
%DDB_DELFT3DFLOW_GRID  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_Delft3DFLOW_grid(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_Delft3DFLOW_grid
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
    % setUIElements('delft3dflow.domain.domainpanel.grid');
else
    opt=varargin{1};
    switch lower(opt)
        case{'selectgrid'}
            selectGrid;
        case{'selectenclosure'}
            selectEnclosure;
        case{'generatelayers'}
            generateLayers;
        case{'editkmax'}
            editKMax;
        case{'changelayers'}
            changeLayers;
        case{'loadlayers'}
            loadLayers;
        case{'savelayers'}
            saveLayers;
        case{'selectzmodel'}
            selectZModel;
        case{'editztop'}
            editZTop;
        case{'editzbot'}
            editZBot;
    end
end

%%
function selectGrid
handles=getHandles;
filename=handles.Model(md).Input(ad).grdFile;
[x,y,enc]=ddb_wlgrid('read',filename);
handles.Model(md).Input(ad).gridX=x;
handles.Model(md).Input(ad).gridY=y;
handles.Model(md).Input(ad).MMax=size(x,1)+1;
handles.Model(md).Input(ad).NMax=size(x,2)+1;
[handles.Model(md).Input(ad).gridXZ,handles.Model(md).Input(ad).gridYZ]=getXZYZ(x,y);
handles.Model(md).Input(ad).kcs=determineKCS(handles.Model(md).Input(ad).gridX,handles.Model(md).Input(ad).gridY);
nans=zeros(size(handles.Model(md).Input(ad).gridX));
nans(nans==0)=NaN;
handles.Model(md).Input(ad).depth=nans;
handles.Model(md).Input(ad).depthZ=nans;
setHandles(handles);
% setUIElement('delft3dflow.domain.domainpanel.grid.textgridm');
% setUIElement('delft3dflow.domain.domainpanel.grid.textgridn');
handles=getHandles;
handles=ddb_Delft3DFLOW_plotGrid(handles,'plot');
setHandles(handles);

%%
function selectEnclosure
handles=getHandles;
mn=ddb_enclosure('read',handles.Model(md).Input(ad).encFile);
[handles.Model(md).Input(ad).gridX,handles.Model(md).Input(ad).gridY]=ddb_enclosure('apply',mn,handles.Model(md).Input(ad).gridX,handles.Model(md).Input(ad).gridY);
[handles.Model(md).Input(ad).gridXZ,handles.Model(md).Input(ad).gridYZ]=getXZYZ(handles.Model(md).Input(ad).gridX,handles.Model(md).Input(ad).gridY);
handles.Model(md).Input(ad).kcs=determineKCS(handles.Model(md).Input(ad).gridX,handles.Model(md).Input(ad).gridY);
handles=ddb_Delft3DFLOW_plotGrid(handles,'plot');
setHandles(handles);

%%
function generateLayers
ddb_Delft3DFLOW_generateLayers;

%%
function changeLayers
handles=getHandles;
handles.Model(md).Input(ad).sumLayers=sum(handles.Model(md).Input(ad).thick);
setHandles(handles);
% gui_updateActiveTab;

%%
function loadLayers
handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.lyr', 'Load layers file','');
if ~isempty(pathname)
    lyrs=load([pathname filename]);
    sm=sum(lyrs);
    if abs(sm-100)<1e-8
        handles.Model(md).Input(ad).thick=lyrs;
        handles.Model(md).Input(ad).sumLayers=100;
        handles.Model(md).Input(ad).KMax=length(lyrs);
        setHandles(handles);
    else
        ddb_giveWarning('Text','Sum of layers does not equal 100%');
    end
end

%%
function saveLayers
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.lyr', 'Save layers file','');
if ~isempty(pathname)
    lyrs=handles.Model(md).Input(ad).thick;
    save([pathname filename],'lyrs','-ascii');
end

%%
function editKMax
handles=getHandles;
kmax0=handles.Model(md).Input(ad).lastKMax;
kmax=handles.Model(md).Input(ad).KMax;
if kmax~=kmax0
    handles.Model(md).Input(ad).lastKMax=kmax;
    handles.Model(md).Input(ad).thick=[];
    if kmax==1
        handles.Model(md).Input(ad).thick=100;
    else
        for i=1:kmax
            thick(i)=0.01*round(100*100/kmax);
        end
        sumlayers=sum(thick);
        dif=sumlayers-100;
        thick(kmax)=thick(kmax)-dif;
        for i=1:kmax
            handles.Model(md).Input(ad).thick(i)=thick(i);
        end
    end
    setHandles(handles);
    handles.Model(md).Input(ad).sumLayers=sum(handles.Model(md).Input(ad).thick);
end

%%
function selectZModel
handles=getHandles;
switch handles.Model(md).Input(ad).dpuOpt
    case{'MEAN','UPW','MOR'}
        handles.Model(md).Input(ad).dpuOpt='MIN';
        setHandles(handles);
        ddb_giveWarning('text','DPUOPT set to MIN in numerical options!');
end



%%
function editZTop
handles=getHandles;
zmax=nanmax(nanmax(handles.Model(md).Input(ad).depth));
if zmax>handles.Model(md).Input(ad).zTop
    ButtonName = questdlg(['Maximum height model bathymetry (' num2str(zmax) ' m) exceeds Z Top! Adjust bathymetry?'], ...
        'Adjust bathymetry?', ...
        'No', 'Yes', 'Yes');
    switch ButtonName
        case 'Yes'
            [filename, pathname, filterindex] = uiputfile('*.dep', 'Select depth file',handles.Model(md).Input(ad).depFile);
            if ~isempty(pathname)
                handles.Model(md).Input(ad).depFile=filename;                
                handles.Model(md).Input(ad).depth=min(handles.Model(md).Input(ad).depth,handles.Model(md).Input(ad).zTop);
                ddb_wldep('write',filename,handles.Model(md).Input(ad).depth);
                handles=ddb_Delft3DFLOW_plotBathy(handles,'plot','domain',ad);
            end
    end    
end
setHandles(handles);

%%
function editZBot
handles=getHandles;
zmin=nanmin(nanmin(handles.Model(md).Input(ad).depth));
if zmin<handles.Model(md).Input(ad).zBot
    ddb_giveWarning('text',['Maximum depth in model (' num2str(zmin) ' m) exceeds Z Bot!']);
end
setHandles(handles);
