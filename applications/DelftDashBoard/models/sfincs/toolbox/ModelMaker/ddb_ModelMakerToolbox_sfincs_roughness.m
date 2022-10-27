function ddb_ModelMakerToolbox_sfincs_roughness(varargin)
%DDB_MODELMAKERTOOLBOX_BATHYMETRY master function for bathy in DDB
%
%   When generateBathymetry is used first handles are loaded
%   1) A specific 'bathy generate' per model is applied
%   2) All these functions came back to ddb_ModelMakerToolbox_generateBathymetry
%   3) Bathys in the order presented and interpolation to model grid
%   4) End with diffusion and model offset

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

% $Id: ddb_ModelMakerToolbox_bathymetry.m 18438 2022-10-12 16:23:14Z ormondt $
% $Date: 2022-10-12 12:23:14 -0400 (Wed, 12 Oct 2022) $
% $Author: ormondt $
% $Revision: 18438 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/ModelMaker/ddb_ModelMakerToolbox_bathymetry.m $
% $Keywords: $

%%
handles=getHandles;
ddb_zoomOff;

if isempty(varargin)
    % New tab selected
    ddb_refreshScreen;
    setHandles(handles);
    ddb_plotModelMaker('deactivate');
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
        case{'generateroughness'}
            generate_roughness_map;
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
for i=1:handles.toolbox.modelmaker.sfincs.roughness.nrSelectedDatasets
    if handles.toolbox.modelmaker.sfincs.roughness.selectedDatasets(i).number==iac
        usedd=0;
        break
    end
end
if usedd
    handles.toolbox.modelmaker.sfincs.roughness.nrSelectedDatasets=handles.toolbox.modelmaker.sfincs.roughness.nrSelectedDatasets+1;
    n=handles.toolbox.modelmaker.sfincs.roughness.nrSelectedDatasets;
    
    handles.toolbox.modelmaker.sfincs.roughness.selectedDatasets(n).number=handles.toolbox.modelmaker.bathymetry.activeDataset;
    handles.toolbox.modelmaker.sfincs.roughness.selectedDatasets(n).name=handles.bathymetry.datasets{iac};
    handles.toolbox.modelmaker.sfincs.roughness.selectedDatasets(n).type=handles.bathymetry.dataset(iac).type;
    handles.toolbox.modelmaker.sfincs.roughness.selectedDatasets(n).verticalDatum=handles.bathymetry.dataset(iac).verticalCoordinateSystem.name;
    handles.toolbox.modelmaker.sfincs.roughness.selectedDatasets(n).verticalLevel=handles.bathymetry.dataset(iac).verticalCoordinateSystem.level;

    % Default values
    handles.toolbox.modelmaker.sfincs.roughness.selectedDatasets(n).zMax=1e4;
    handles.toolbox.modelmaker.sfincs.roughness.selectedDatasets(n).zMin=-1e4;

    handles.toolbox.modelmaker.sfincs.roughness.selectedDatasetNames{n}=handles.bathymetry.longNames{iac};
    
    handles.toolbox.modelmaker.sfincs.roughness.activeSelectedDataset=n;
    
    setHandles(handles);
    roughness_changed;
end

%%
function removeDataset
% Remove selected dataset
handles=getHandles;
if handles.toolbox.modelmaker.sfincs.roughness.nrSelectedDatasets>0
    iac=handles.toolbox.modelmaker.sfincs.roughness.activeSelectedDataset;    
    handles.toolbox.modelmaker.sfincs.roughness.selectedDatasets = removeFromStruc(handles.toolbox.modelmaker.sfincs.roughness.selectedDatasets, iac);
    handles.toolbox.modelmaker.sfincs.roughness.selectedDatasetNames = removeFromCellArray(handles.toolbox.modelmaker.sfincs.roughness.selectedDatasetNames, iac);
    handles.toolbox.modelmaker.sfincs.roughness.nrSelectedDatasets=handles.toolbox.modelmaker.sfincs.roughness.nrSelectedDatasets-1;
    handles.toolbox.modelmaker.sfincs.roughness.activeSelectedDataset=max(min(handles.toolbox.modelmaker.sfincs.roughness.activeSelectedDataset,handles.toolbox.modelmaker.sfincs.roughness.nrSelectedDatasets),1);
    if handles.toolbox.modelmaker.sfincs.roughness.nrSelectedDatasets==0
        handles.toolbox.modelmaker.sfincs.roughness.selectedDatasets(1).type='unknown';
    end    
    setHandles(handles);
    roughness_changed;
end

%%
function datasetUp
% Move selected dataset up
handles=getHandles;
if handles.toolbox.modelmaker.sfincs.roughness.nrSelectedDatasets>0
    iac=handles.toolbox.modelmaker.sfincs.roughness.activeSelectedDataset;
    handles.toolbox.modelmaker.sfincs.roughness.selectedDatasetNames=moveUpDownInCellArray(handles.toolbox.modelmaker.sfincs.roughness.selectedDatasetNames,iac,'up');
    [handles.toolbox.modelmaker.sfincs.roughness.selectedDatasets,iac,nr] = UpDownDeleteStruc(handles.toolbox.modelmaker.sfincs.roughness.selectedDatasets, iac, 'up');
    handles.toolbox.modelmaker.sfincs.roughness.activeSelectedDataset=iac;
    setHandles(handles);
    roughness_changed;
end

%%
function datasetDown

% Move selected dataset down
handles=getHandles;
if handles.toolbox.modelmaker.sfincs.roughness.nrSelectedDatasets>0
    iac=handles.toolbox.modelmaker.sfincs.roughness.activeSelectedDataset;
    handles.toolbox.modelmaker.sfincs.roughness.selectedDatasetNames=moveUpDownInCellArray(handles.toolbox.modelmaker.sfincs.roughness.selectedDatasetNames,iac,'down');
    [handles.toolbox.modelmaker.sfincs.roughness.selectedDatasets,iac,nr] = UpDownDeleteStruc(handles.toolbox.modelmaker.sfincs.roughness.selectedDatasets, iac, 'down');
    handles.toolbox.modelmaker.sfincs.roughness.activeSelectedDataset=iac;
    setHandles(handles);
    roughness_changed;
end

%%
function roughness_changed
handles=getHandles;
handles.toolbox.modelmaker.sfincs.roughness_changed=1;
setHandles(handles);

% %%
% function generate_roughness_map
% 
% handles=getHandles;
% 
% for ii=1:handles.toolbox.modelmaker.sfincs.roughness.nrSelectedDatasets
%     nr=handles.toolbox.modelmaker.sfincs.roughness.selectedDatasets(ii).number;
%     datasets(ii).name=handles.bathymetry.datasets{nr};
% end
% handles=ddb_ModelMakerToolbox_sfincs_generateBathymetry(handles,ad,datasets,'check',0,'roughness',1);
% handles.model.sfincs.domain(ad).roughness_type='file';
% handles.model.sfincs.domain(ad).input.manningfile='sfincs.rgh';
% setHandles(handles);
