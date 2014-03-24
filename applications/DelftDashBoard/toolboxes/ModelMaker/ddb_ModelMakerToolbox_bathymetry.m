function ddb_ModelMakerToolbox_bathymetry(varargin)
%DDB_MODELMAKERTOOLBOX_BATHYMETRY  One line description goes here.
%
%   More detailed description goes here.

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
ddb_zoomOff;

if isempty(varargin)
    % New tab selected
    ddb_refreshScreen;
    setHandles(handles);
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch opt
        case{'usedataset'}
            useDataset;
        case{'showinfo'}
            showInfo;
        case{'removedataset'}
            removeDataset;
        case{'datasetup'}
            datasetUp;
        case{'datasetdown'}
            datasetDown;
        case{'generatebathymetry'}
            generateBathymetry;
        case{'pickselecteddataset'}
%            selectDataset;
    end
    
end

%%
function showInfo
handles=getHandles;
iac=handles.toolbox.modelmaker.bathymetry.activeDataset;
ddb_showBathyInfo(handles,iac);

%%
function useDataset

handles=getHandles;
iac=handles.toolbox.modelmaker.bathymetry.activeDataset;
% Check if dataset is already selected
usedd=1;
for i=1:handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets
    if handles.toolbox.modelmaker.bathymetry.selectedDatasets(i).number==iac
        usedd=0;
        break
    end
end
if usedd
    handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets=handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets+1;
    n=handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets;
    
    handles.toolbox.modelmaker.bathymetry.selectedDatasets(n).number=handles.toolbox.modelmaker.bathymetry.activeDataset;
    handles.toolbox.modelmaker.bathymetry.selectedDatasets(n).name=handles.bathymetry.datasets{iac};
    handles.toolbox.modelmaker.bathymetry.selectedDatasets(n).type=handles.bathymetry.dataset(iac).type;
    handles.toolbox.modelmaker.bathymetry.selectedDatasets(n).verticalDatum=handles.bathymetry.dataset(iac).verticalCoordinateSystem.name;
    handles.toolbox.modelmaker.bathymetry.selectedDatasets(n).verticalLevel=handles.bathymetry.dataset(iac).verticalCoordinateSystem.level;

    % Default values
    handles.toolbox.modelmaker.bathymetry.selectedDatasets(n).zMax=1e4;
    handles.toolbox.modelmaker.bathymetry.selectedDatasets(n).zMin=-1e4;

    handles.toolbox.modelmaker.bathymetry.selectedDatasets(n).startDate=floor(now);
    handles.toolbox.modelmaker.bathymetry.selectedDatasets(n).searchInterval=-1e5;

    handles.toolbox.modelmaker.bathymetry.selectedDatasetNames{n}=handles.bathymetry.longNames{iac};
    
    handles.toolbox.modelmaker.bathymetry.activeSelectedDataset=n;
    
    setHandles(handles);
end

%%
function removeDataset
% Remove selected dataset
handles=getHandles;
if handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets>0
    iac=handles.toolbox.modelmaker.bathymetry.activeSelectedDataset;    
    handles.toolbox.modelmaker.bathymetry.selectedDatasets = removeFromStruc(handles.toolbox.modelmaker.bathymetry.selectedDatasets, iac);
    handles.toolbox.modelmaker.bathymetry.selectedDatasetNames = removeFromCellArray(handles.toolbox.modelmaker.bathymetry.selectedDatasetNames, iac);
    handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets=handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets-1;
    handles.toolbox.modelmaker.bathymetry.activeSelectedDataset=max(min(handles.toolbox.modelmaker.bathymetry.activeSelectedDataset,handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets),1);
    if handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets==0
        handles.toolbox.modelmaker.bathymetry.selectedDatasets(1).type='unknown';
    end    
    setHandles(handles);
end

%%
function datasetUp
% Move selected dataset up
handles=getHandles;
if handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets>0
    iac=handles.toolbox.modelmaker.bathymetry.activeSelectedDataset;
    handles.toolbox.modelmaker.bathymetry.selectedDatasetNames=moveUpDownInCellArray(handles.toolbox.modelmaker.bathymetry.selectedDatasetNames,iac,'up');
    [handles.toolbox.modelmaker.bathymetry.selectedDatasets,iac,nr] = UpDownDeleteStruc(handles.toolbox.modelmaker.bathymetry.selectedDatasets, iac, 'up');
    handles.toolbox.modelmaker.bathymetry.activeSelectedDataset=iac;
    setHandles(handles);
end

%%
function datasetDown

% Move selected dataset down
handles=getHandles;
if handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets>0
    iac=handles.toolbox.modelmaker.bathymetry.activeSelectedDataset;
    handles.toolbox.modelmaker.bathymetry.selectedDatasetNames=moveUpDownInCellArray(handles.toolbox.modelmaker.bathymetry.selectedDatasetNames,iac,'down');
    [handles.toolbox.modelmaker.bathymetry.selectedDatasets,iac,nr] = UpDownDeleteStruc(handles.toolbox.modelmaker.bathymetry.selectedDatasets, iac, 'down');
    handles.toolbox.modelmaker.bathymetry.activeSelectedDataset=iac;
    setHandles(handles);
end

%% 
function generateBathymetry

handles=getHandles;
for i=1:handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets
    nr=handles.toolbox.modelmaker.bathymetry.selectedDatasets(i).number;
    datasets{i}=handles.bathymetry.datasets{nr};
    startdates(i)=handles.toolbox.modelmaker.bathymetry.selectedDatasets(i).startDate;
    searchintervals(i)=handles.toolbox.modelmaker.bathymetry.selectedDatasets(i).searchInterval;
    zmin(i)=handles.toolbox.modelmaker.bathymetry.selectedDatasets(i).zMin;
    zmax(i)=handles.toolbox.modelmaker.bathymetry.selectedDatasets(i).zMax;
    verticaloffsets(i)=handles.toolbox.modelmaker.bathymetry.selectedDatasets(i).verticalLevel;
end
verticaloffset=handles.toolbox.modelmaker.bathymetry.verticalDatum;

switch lower(handles.Model(md).name)
    case{'delft3dflow'}
        handles=ddb_generateBathymetry_Delft3DFLOW(handles,ad,'datasets',datasets,'startdates',startdates,'searchintervals',searchintervals, ...
            'zmin',zmin,'zmax',zmax,'verticaloffsets',verticaloffsets,'verticaloffset',verticaloffset,'internaldiffusion', ...
            handles.toolbox.modelmaker.bathymetry.internalDiffusion,'internaldiffusionrange',handles.toolbox.modelmaker.bathymetry.internalDiffusionRange);
    case{'delft3dwave'}
        handles=ddb_generateBathymetry_Delft3DWAVE(handles,awg,'datasets',datasets,'startdates',startdates,'searchintervals',searchintervals, ...
            'zmin',zmin,'zmax',zmax,'verticaloffsets',verticaloffsets,'verticaloffset',verticaloffset, ...
            handles.toolbox.modelmaker.bathymetry.internalDiffusion,'internaldiffusionrange',handles.toolbox.modelmaker.bathymetry.internalDiffusionRange);
    case{'dflowfm'}
        handles=ddb_generateBathymetry_DFlowFM(handles,awg,'datasets',datasets,'startdates',startdates,'searchintervals',searchintervals, ...
            'zmin',zmin,'zmax',zmax,'verticaloffsets',verticaloffsets,'verticaloffset',verticaloffset, ...
            handles.toolbox.modelmaker.bathymetry.internalDiffusion,'internaldiffusionrange',handles.toolbox.modelmaker.bathymetry.internalDiffusionRange);
end

setHandles(handles);
