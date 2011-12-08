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
    setUIElements('modelmakerpanel.bathymetry');
    setHandles(handles);
%    ddb_plotModelMaker('activate');
%    if ~isempty(handles.Toolbox(tb).Input.gridOutlineHandle)
%        setInstructions({'Left-click and drag markers to change corner points','Right-click and drag YELLOW marker to move entire box', ...
%            'Right-click and drag RED markers to rotate box (note: rotating grid in geographic coordinate systems is NOT recommended!)'});
%    end
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch opt
        case{'usedataset'}
            useDataset;
        case{'removedataset'}
            removeDataset;
        case{'datasetup'}
            datasetUp;
        case{'datasetdown'}
            datasetDown;
        case{'generatebathymetry'}
            generateBathymetry;
        case{'pickselecteddataset'}
            selectDataset;
    end
    
end

%%
function selectDataset
setUIElements('modelmakerpanel.bathymetry');

%%
function useDataset

handles=getHandles;
iac=handles.Toolbox(tb).Input.bathymetry.activeDataset;
% Check if dataset is already selected
usedd=1;
for i=1:handles.Toolbox(tb).Input.bathymetry.nrSelectedDatasets
    if handles.Toolbox(tb).Input.bathymetry.selectedDatasets(i).number==iac
        usedd=0;
        break
    end
end
if usedd
    handles.Toolbox(tb).Input.bathymetry.nrSelectedDatasets=handles.Toolbox(tb).Input.bathymetry.nrSelectedDatasets+1;
    n=handles.Toolbox(tb).Input.bathymetry.nrSelectedDatasets;
    
    handles.Toolbox(tb).Input.bathymetry.selectedDatasets(n).number=handles.Toolbox(tb).Input.bathymetry.activeDataset;
    handles.Toolbox(tb).Input.bathymetry.selectedDatasets(n).name=handles.bathymetry.datasets{iac};

    % Default values
    handles.Toolbox(tb).Input.bathymetry.selectedDatasets(n).zMax=1e4;
    handles.Toolbox(tb).Input.bathymetry.selectedDatasets(n).zMin=-1e4;
    
    handles.Toolbox(tb).Input.bathymetry.selectedDatasetNames{n}=handles.bathymetry.datasets{iac};
    
    handles.Toolbox(tb).Input.bathymetry.activeSelectedDataset=n;
    
    setHandles(handles);
    setUIElements('modelmakerpanel.bathymetry');
%    setUIElement('modelmakerpanel.bathymetry.selecteddatasets');
end

%%
function removeDataset
% Remove selected dataset
handles=getHandles;
if handles.Toolbox(tb).Input.bathymetry.nrSelectedDatasets>0
    iac=handles.Toolbox(tb).Input.bathymetry.activeSelectedDataset;    
    handles.Toolbox(tb).Input.bathymetry.selectedDatasets = removeFromStruc(handles.Toolbox(tb).Input.bathymetry.selectedDatasets, iac);
    handles.Toolbox(tb).Input.bathymetry.selectedDatasetNames = removeFromCellArray(handles.Toolbox(tb).Input.bathymetry.selectedDatasetNames, iac);
    handles.Toolbox(tb).Input.bathymetry.nrSelectedDatasets=handles.Toolbox(tb).Input.bathymetry.nrSelectedDatasets-1;
    handles.Toolbox(tb).Input.bathymetry.activeSelectedDataset=max(min(handles.Toolbox(tb).Input.bathymetry.activeSelectedDataset,handles.Toolbox(tb).Input.bathymetry.nrSelectedDatasets),1);
    setHandles(handles);
    setUIElements('modelmakerpanel.bathymetry');
%    setUIElement('modelmakerpanel.bathymetry.selecteddatasets');
end

%%
function datasetUp
% Move selected dataset up
handles=getHandles;
if handles.Toolbox(tb).Input.bathymetry.nrSelectedDatasets>0
    iac=handles.Toolbox(tb).Input.bathymetry.activeSelectedDataset;
    handles.Toolbox(tb).Input.bathymetry.selectedDatasetNames=moveUpDownInCellArray(handles.Toolbox(tb).Input.bathymetry.selectedDatasetNames,iac,'up');
    [handles.Toolbox(tb).Input.bathymetry.selectedDatasets,iac,nr] = UpDownDeleteStruc(handles.Toolbox(tb).Input.bathymetry.selectedDatasets, iac, 'up');
    handles.Toolbox(tb).Input.bathymetry.activeSelectedDataset=iac;
    setHandles(handles);
    setUIElements('modelmakerpanel.bathymetry');
%    setUIElement('modelmakerpanel.bathymetry.selecteddatasets');
end

%%
function datasetDown

% Move selected dataset down
handles=getHandles;
if handles.Toolbox(tb).Input.bathymetry.nrSelectedDatasets>0
    iac=handles.Toolbox(tb).Input.bathymetry.activeSelectedDataset;
    handles.Toolbox(tb).Input.bathymetry.selectedDatasetNames=moveUpDownInCellArray(handles.Toolbox(tb).Input.bathymetry.selectedDatasetNames,iac,'down');
    [handles.Toolbox(tb).Input.bathymetry.selectedDatasets,iac,nr] = UpDownDeleteStruc(handles.Toolbox(tb).Input.bathymetry.selectedDatasets, iac, 'down');
    handles.Toolbox(tb).Input.bathymetry.activeSelectedDataset=iac;
    setHandles(handles);
    setUIElements('modelmakerpanel.bathymetry');
%    setUIElement('modelmakerpanel.bathymetry.selecteddatasets');
end

%% 
function generateBathymetry
handles=getHandles;
if handles.Toolbox(tb).Input.bathymetry.nrSelectedDatasets>0
    id=handles.activeDomain;
    handles = ddb_generateBathymetry(handles, id, 'datasets',handles.Toolbox(tb).Input.bathymetry.selectedDatasetNames);
    setHandles(handles);
end
