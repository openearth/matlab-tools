function ddb_OMSToolbox

ddb_refreshScreen('Toolbox');

strings={'Parameters','Stations','Maps'};
callbacks={@ddb_editOMSParameters,@ddb_editOMSStations,@ddb_editOMSMaps};

%tabpanel(gcf,'tabpanel2','create','position',[50 20 910 140],'strings',strings,'callbacks',callbacks,'width',width);

handles=getHandles;
panel=get(handles.Model(md).GUI.elements(1).handle,'UserData');
iac=panel.activeTab;
parent=panel.largeTabHandles(iac);
tabpanel('create','tag','tabpanel2','position',[40 10 910 140],'strings',strings,'callbacks',callbacks,'tabnames',strings,'Parent',parent,'activetabnr',1);

ddb_editOMSParameters;
