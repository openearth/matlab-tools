function handles=ddb_ModelMakerToolbox_DFlowFM_generateBathymetry(handles,datasets,varargin)

icheck=1;
overwrite=1;
filename=[];
id=ad;
modeloffset=0;

%% Read input arguments
for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'check'}
                icheck=varargin{i+1};
            case{'overwrite'}
                overwrite=varargin{i+1};
            case{'filename'}
                filename=varargin{i+1};
            case{'domain'}
                id=varargin{i+1};
            case{'modeloffset'}
                modeloffset=varargin{i+1};
        end
    end
end

%% Check should NOT be performed when called by CSIPS toolbox
if icheck
    % Check if there is already a grid
    if handles.model.delft3dflow.domain(ad).MMax==0
        ddb_giveWarning('Warning','First generate or load a grid');
        return
    end
    % File name
    if isempty(handles.model.delft3dflow.domain(ad).depFile)
        handles.model.delft3dflow.domain(ad).depFile=[handles.model.delft3dflow.domain(ad).attName '.dep'];
    end
    [filename,ok]=gui_uiputfile('*.dep', 'Depth File Name',handles.model.delft3dflow.domain(ad).depFile);
    if ~ok
        return
    end
    % Check if there is already data in depth matrix
    dmax=max(max(handles.model.delft3dflow.domain(ad).depth));
    if isnan(dmax)
        overwrite=1;
    else
        ButtonName = questdlg('Overwrite existing bathymetry?', ...
            'Delete existing bathymetry', ...
            'Cancel', 'No', 'Yes', 'Yes');
        switch ButtonName,
            case 'Cancel',
                return;
            case 'No',
                overwrite=0;
            case 'Yes',
                overwrite=1;
        end
    end
end

%% Grid coordinates and type
xg=handles.model.dflowfm.domain(id).netstruc.nodeX;
yg=handles.model.dflowfm.domain(id).netstruc.nodeX;
zg=handles.model.dflowfm.domain(id).depth;
gridtype='unstructured';

%% Generate bathymetry
[xg,yg,zg]=ddb_ModelMakerToolbox_generateBathymetry(handles,xg,yg,zg,datasets,'filename',filename,'overwrite',overwrite,'gridtype',gridtype,'modeloffset',modeloffset);

%% Update model data
handles.model.dflowfm.domain(id).netstruc.nodeZ=zg;
% Net file
netStruc2nc(handles.model.dflowfm.domain(id).netfile,handles.model.dflowfm.domain(id).netstruc,'cstype',handles.screenParameters.coordinateSystem.type);
% Plot
% TODO handles=ddb_DFlowFM_plotBathymetry(handles,'plot');

