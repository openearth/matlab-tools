function ddb_Delft3DFLOW_processes(varargin)


if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    setUIElements('delft3dflow.processes');
else
    
    opt=varargin{1};
    
    switch(lower(opt))

        case{'edittracers'}
            ddb_Delft3DFLOW_editTracers;
            setUIElement('delft3dflow.processes.checktracers');
            setUIElement('delft3dflow.processes.pushedittracers');


        case{'editsediments'}
            ddb_Delft3DFLOW_editSediments;
            setUIElement('delft3dflow.processes.checksediments');
            setUIElement('delft3dflow.processes.pusheditsediments');

        case{'checkconstituents'}

        case{'checksediments'}
%             handles=getHandles;
%             if handles.Model(md).Input(ad).sediments.include
%                 enableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','sediments');
%                 enableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','morphology');
%             else
%                 disableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','sediments');
%                 disableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','morphology');
%             end

        case{'checktemperature'}
%             handles=getHandles;
%             if handles.Model(md).Input(ad).temperature.include
%                 enableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','heatflux');
%             else
%                 disableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','heatflux');
%             end

        case{'checkwind'}
%             handles=getHandles;
%             if handles.Model(md).Input(ad).wind
%                 enableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','wind');
%             else
%                 disableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','wind');
%             end
            
        case{'checkroller'}
%             handles=getHandles;
%             if handles.Model(md).Input(ad).roller.include
%                 enableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','roller');
%             else
%                 disableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','roller');
%             end
            
        case{'checktidalforces'}
%             handles=getHandles;
%             if handles.Model(md).Input(ad).tidalForces
%                 enableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','tidalforces');
%             else
%                 disableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','tidalforces');
%             end
            
        case{'checkdredging'}
%             handles=getHandles;
%             if handles.Model(md).Input(ad).dredging
%                 enableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','dredging');
%             else
%                 disableTab(handles.GUIHandles.mainWindow,'delft3dflow.physicalparameters.physicalparameterspanel','dredging');
%             end

    end

    handles=getHandles;

    if handles.Model(md).Input(ad).salinity.include || handles.Model(md).Input(ad).temperature.include || ...
        handles.Model(md).Input(ad).sediments.include || handles.Model(md).Input(ad).tracers
        handles.Model(md).Input(ad).constituents=1;
    else
        handles.Model(md).Input(ad).constituents=0;
    end
    
    setHandles(handles);
    
end


