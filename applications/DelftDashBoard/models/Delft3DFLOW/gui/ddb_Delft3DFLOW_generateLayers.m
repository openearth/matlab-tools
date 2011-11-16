function ddb_Delft3DFLOW_generateLayers(varargin)

if isempty(varargin)
    ddb_zoomOff;
    % Make new GUI
    handles=getHandles;
    xmldir=handles.Model(md).xmlDir;
    xmlfile='Delft3DFLOW.generatelayers.xml';
    if strcmpi(handles.Model(md).Input(ad).layerType,'z')
        handles.Model(md).Input(ad).layerOption=1;
    end
    for k=1:handles.Model(md).Input(ad).KMax
        handles.Model(md).Input(ad).layerStrings{k}=num2str(handles.Model(md).Input(ad).thick(k),'%8.3f');
    end
    [handles,ok]=newGUI(xmldir,xmlfile,handles,'iconfile',[handles.settingsDir '\icons\deltares.gif']);
    if ok
        setHandles(handles);
        setUIElement('delft3dflow.domain.domainpanel.grid.sumlayers');
        setUIElement('delft3dflow.domain.domainpanel.grid.layertable');
    end
    setUIElements('delft3dflow.domain.domainpanel.grid');
else
    opt=varargin{1};
    switch lower(opt)
        case{'generatelayers'}
            generateLayers;
        case{'pushok'}
            handles=getTempHandles;
            handles.ok=1;
            setTempHandles(handles);
            close(gcf);
        case{'pushcancel'}
            handles=getTempHandles;
            handles.ok=0;
            setTempHandles(handles);
            close(gcf);
    end
end

%%
function generateLayers

handles=getTempHandles;

switch handles.Model(md).Input(ad).layerOption
    case 1
        % Increasing from surface
        thick=generateLayerThickness('kmax',handles.Model(md).Input(ad).KMax,'type',handles.Model(md).Input(ad).layerType, ...
            'zbot',handles.Model(md).Input(ad).zBot,'ztop',handles.Model(md).Input(ad).zTop, ...
            'thicktop',handles.Model(md).Input(ad).thickTop);
    case 2
        % Increasing from bottom
        thick=generateLayerThickness('kmax',handles.Model(md).Input(ad).KMax,'type',handles.Model(md).Input(ad).layerType, ...
            'zbot',handles.Model(md).Input(ad).zBot,'ztop',handles.Model(md).Input(ad).zTop, ...
            'thickbot',handles.Model(md).Input(ad).thickBot);
    case 2
        % Increasing from top and bottom
        thick=generateLayerThickness('kmax',handles.Model(md).Input(ad).KMax,'type',handles.Model(md).Input(ad).layerType, ...
            'zbot',handles.Model(md).Input(ad).zBot,'ztop',handles.Model(md).Input(ad).zTop, ...
            'thicktop',handles.Model(md).Input(ad).thickTop,'thickbot',handles.Model(md).Input(ad).thickBot);
    case 4
        % Equidistant
        thick=generateLayerThickness('kmax',handles.Model(md).Input(ad).KMax,'type',handles.Model(md).Input(ad).layerType, ...
            'zbot',handles.Model(md).Input(ad).zBot,'ztop',handles.Model(md).Input(ad).zTop);
end

handles.Model(md).Input(ad).thick=thick';

for k=1:handles.Model(md).Input(ad).KMax
    handles.Model(md).Input(ad).layerStrings{k}=num2str(handles.Model(md).Input(ad).thick(k),'%8.3f');
end

setTempHandles(handles);

setUIElement('testje.listlayers');


