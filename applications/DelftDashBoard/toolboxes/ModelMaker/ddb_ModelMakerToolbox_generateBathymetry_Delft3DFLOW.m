function handles=ddb_ModelMakerToolbox_generateBathymetry_Delft3DFLOW(handles,datasets)

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
% Use background bathymetry data
handles=ddb_ModelMakerToolbox_generateBathymetry(handles,'delft3dflow',ad,'datasets',datasets,'filename',filename,'overwrite',overwrite);
