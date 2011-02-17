function ddb_editD3DFlowPhysicalParameters

ddb_refreshScreen('Phys. Parameters');

handles=getHandles;

strings={'Constants','Roughness','Viscosity'};
callbacks={@ddb_editD3DFlowConstants,@ddb_editD3DFlowRoughness,@ddb_editD3DFlowViscosity};
k=3;

if handles.Model(md).Input(ad).temperature.include
    k=k+1;
    strings{k}='Heat Flux';
    callbacks{k}=@ddb_editD3DFlowHeatFluxModel;
end

if handles.Model(md).Input(ad).Sediments
    k=k+1;
    strings{k}='Sediment';
    callbacks{k}=@ddb_editD3DFlowSediment;
    k=k+1;
    strings{k}='Morphology';
    callbacks{k}=@ddb_editD3DFlowMorphology;
end

if handles.Model(md).Input(ad).Wind
    k=k+1;
    strings{k}='Wind';
    callbacks{k}=@ddb_editD3DFlowWind;
end

if handles.Model(md).Input(ad).TidalForces
    k=k+1;
    strings{k}='Tidal Forces';
    callbacks{k}=@ddb_editD3DFlowTidalForces;
end

if handles.Model(md).Input(ad).Roller.Include
    k=k+1;
    strings{k}='Roller Model';
    callbacks{k}=@ddb_editD3DFlowRollerModel;
end

% tabpanel(gcf,'tabpanel2','create','position',[50 20 910 140],'strings',strings,'callbacks',callbacks);

handles=getHandles;
panel=get(handles.Model(md).GUI.elements(1).handle,'UserData');
iac=panel.activeTab;
parent=panel.largeTabHandles(iac);
tabpanel('create','tag','tabpanel2','position',[40 10 910 140],'strings',strings,'callbacks',callbacks,'tabnames',strings,'Parent',parent,'activetabnr',1);

ddb_editD3DFlowConstants;
