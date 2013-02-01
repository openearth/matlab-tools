function ddb_TilingToolbox_bathymetry(varargin)
%DDB_TILINGTOOLBOX_BATHYMETRY  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_TilingToolbox_bathymetry(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_TilingToolbox_bathymetry
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
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
else
    %Options selected
    opt=lower(varargin{1});    
    switch opt
        case{'selectdataset'}
            selectDataset;
        case{'selectcs'}
            selectCS;
        case{'editattributes'}
            editAttributes;
        case{'generatetiles'}
            generateTiles;
        case{'selectrawdatatype'}
            selectRawDataType;
    end    
end


%%
function selectRawDataType

handles=getHandles;
ii=strmatch(handles.Toolbox(tb).Input.bathymetry.rawDataType,handles.Toolbox(tb).Input.bathymetry.rawDataTypes,'exact');
handles.Toolbox(tb).Input.bathymetry.rawDataTypeExtension=handles.Toolbox(tb).Input.bathymetry.rawDataTypeExtensions{ii};
handles.Toolbox(tb).Input.bathymetry.rawDataTypeSelectionText=['Select Data File (' handles.Toolbox(tb).Input.bathymetry.rawDataTypesText{ii} ')'];
setHandles(handles);

%%
function selectDataset

handles=getHandles;

switch lower(handles.Toolbox(tb).Input.bathymetry.rawDataType)
    case{'arcinfogrid'}
        [ncols,nrows,x0,y0,cellsz]=readArcInfo(handles.Toolbox(tb).Input.bathymetry.dataFile,'info');
    case{'arcbinarygrid'}
        [x,y,z,m] = arc_info_binary([fileparts(handles.Toolbox(tb).Input.bathymetry.dataFile) filesep]);
        clear x y z
        x0=m.X(1);
        y0=m.Y(end);
        ncols=m.nColumns;
        nrows=m.nRows;
end

% Determine default values for this dataset

handles.Toolbox(tb).Input.bathymetry.x0=x0;
handles.Toolbox(tb).Input.bathymetry.y0=y0;

if ncols>500 && nrows>500
    handles.Toolbox(tb).Input.bathymetry.nx=300;
    handles.Toolbox(tb).Input.bathymetry.ny=300;
    zm=1:50;
    nnx=ncols./(handles.Toolbox(tb).Input.bathymetry.nx.*2.^(zm-1));
    nny=nrows./(handles.Toolbox(tb).Input.bathymetry.ny.*2.^(zm-1));
    iix=find(nnx>1,1,'last');
    iiy=find(nny>1,1,'last');
    handles.Toolbox(tb).Input.bathymetry.nrZoom=max(iix,iiy);
else
    % Small dataset, no tiling required
    handles.Toolbox(tb).Input.bathymetry.nx=ncols;
    handles.Toolbox(tb).Input.bathymetry.ny=nrows;
    handles.Toolbox(tb).Input.bathymetry.nrZoom=1;
end

setHandles(handles);

%%
function selectCS

handles=getHandles;

% Open GUI to select data set

[cs,type,nr,ok]=ddb_selectCoordinateSystem(handles.coordinateData,handles.EPSG,'default',handles.Toolbox(tb).Input.bathymetry.EPSGname,'type','both','defaulttype',handles.Toolbox(tb).Input.bathymetry.EPSGtype);

if ok
    handles.Toolbox(tb).Input.bathymetry.EPSGname=cs;
    handles.Toolbox(tb).Input.bathymetry.EPSGtype=type;
    handles.Toolbox(tb).Input.bathymetry.EPSGcode=nr;
    
    switch lower(handles.Toolbox(tb).Input.bathymetry.EPSGtype)
        case{'geo','geographic','geographic 2d','geographic 3d','latlon','lonlat','spherical'}
            handles.Toolbox(tb).Input.bathymetry.radioGeo=1;
            handles.Toolbox(tb).Input.bathymetry.radioProj=0;
        otherwise
            handles.Toolbox(tb).Input.bathymetry.radioGeo=0;
            handles.Toolbox(tb).Input.bathymetry.radioProj=1;
    end
    setHandles(handles);

end

%%
function editAttributes
handles=getHandles;
attr=handles.Toolbox(tb).Input.bathymetry.attributes;
attr=ddb_editTilingAttributes(attr);
handles.Toolbox(tb).Input.bathymetry.attributes=attr;
setHandles(handles);

%%
function generateTiles

handles=getHandles;

OPT.EPSGcode                     = handles.Toolbox(tb).Input.bathymetry.EPSGcode;
OPT.EPSGname                     = handles.Toolbox(tb).Input.bathymetry.EPSGname;
OPT.EPSGtype                     = handles.Toolbox(tb).Input.bathymetry.EPSGtype;
OPT.VertCoordName                = handles.Toolbox(tb).Input.bathymetry.vertCoordName;
OPT.VertCoordLevel               = handles.Toolbox(tb).Input.bathymetry.vertCoordLevel;
OPT.VertUnits                    = handles.Toolbox(tb).Input.bathymetry.vertUnits;
OPT.nc_library                   = handles.Toolbox(tb).Input.bathymetry.nc_library;
OPT.tp                           = handles.Toolbox(tb).Input.bathymetry.type;
OPT.positiveup                   = handles.Toolbox(tb).Input.bathymetry.positiveUp;

f=fieldnames(handles.Toolbox(tb).Input.bathymetry.attributes);

for i=1:length(f);
    OPT.(f{i})=handles.Toolbox(tb).Input.bathymetry.attributes.(f{i});
end

fname=handles.Toolbox(tb).Input.bathymetry.dataFile;
dr=[handles.Toolbox(tb).Input.bathymetry.dataDir filesep handles.Toolbox(tb).Input.bathymetry.dataName filesep];
dataname=deblank(handles.Toolbox(tb).Input.bathymetry.dataName);
datatype=handles.Toolbox(tb).Input.bathymetry.rawDataType;
nrzoom=handles.Toolbox(tb).Input.bathymetry.nrZoom;
nx=handles.Toolbox(tb).Input.bathymetry.nx;
ny=handles.Toolbox(tb).Input.bathymetry.ny;

% Check data name
if isempty(dataname)
    ddb_giveWarning('text','Please first enter a data name.');
    return;
end
if ~isempty(find(dataname==' ', 1))
    ddb_giveWarning('text','Data name cannot have spaces in it.');
    return;
end
if strcmpi(handles.Toolbox(tb).Input.bathymetry.attributes.title,'Name of data set')
    ddb_giveWarning('text','Please enter proper title of dataset in attributes.');
    return;
end
if exist(dr,'dir')
    ddb_giveWarning('text','A dataset with this name already exists. Please remove it first.');
    return;
end
if ~isempty(strmatch(handles.Toolbox(tb).Input.bathymetry.attributes.title,handles.bathymetry.longNames))
    ddb_giveWarning('text','A dataset with this title already exists. Please change the title in attributes.');
    return;
end


wb = waitbox('Generating Tiles ...'); 
makeNCBathyTiles(fname,dr,dataname,datatype,nrzoom,nx,ny,OPT);
close(wb);

% Now add data to data xml
fname = [handles.bathymetry.dir 'bathymetry.xml'];
xmldata = xml_load(fname);
nd=length(xmldata)+1;
xmldata(nd).dataset.name=dataname;
xmldata(nd).dataset.longName=handles.Toolbox(tb).Input.bathymetry.attributes.title;
xmldata(nd).dataset.version='1';
xmldata(nd).dataset.type='netCDFtiles';
xmldata(nd).dataset.edit='0';
xmldata(nd).dataset.URL=[handles.Toolbox(tb).Input.bathymetry.dataDir handles.Toolbox(tb).Input.bathymetry.dataName];
xmldata(nd).dataset.useCache='1';
xml_save(fname,xmldata,'off');

% And finally add it to the menu
handles=getHandles;
handles.bathymetry=ddb_findBathymetryDatabases(handles.bathymetry);
% Clear existing menu
h=findobj(gcf,'Tag','menuBathymetry');
ch=get(h,'Children');
delete(ch);
for ii=1:handles.bathymetry.nrDatasets
    if strcmpi(handles.bathymetry.datasets{ii},handles.screenParameters.backgroundBathymetry)
        if handles.bathymetry.dataset(ii).isAvailable
            handles=ddb_addMenuItem(handles,'Bathymetry',handles.bathymetry.longNames{ii},'Callback',{@ddb_menuBathymetry},'Checked','on','Enable','on');
        else
            handles=ddb_addMenuItem(handles,'Bathymetry',handles.bathymetry.longNames{ii},'Callback',{@ddb_menuBathymetry},'Checked','on','Enable','off');
        end
    else
        if handles.bathymetry.dataset(ii).isAvailable
            handles=ddb_addMenuItem(handles,'Bathymetry',handles.bathymetry.longNames{ii},'Callback',{@ddb_menuBathymetry},'Checked','off','Enable','on');
        else
            handles=ddb_addMenuItem(handles,'Bathymetry',handles.bathymetry.longNames{ii},'Callback',{@ddb_menuBathymetry},'Checked','off','Enable','off');
        end
    end
end
setHandles(handles);
