function ddb_editXBeachDomain

ddb_refreshScreen('Domain');

strings={'Grid','Bathymetry'};
callbacks={@ddb_editXBeachGrid,@ddb_editXBeachBathymetry};
%tabpanel(gcf,'tabpanel2','create','position',[50 20 900 140],'strings',strings,'callbacks',callbacks);

handles=getHandles;
panel=get(handles.Model(md).GUI.elements(1).handle,'UserData');
iac=panel.activeTab;
parent=panel.largeTabHandles(iac);
tabpanel('create','tag','tabpanel2','position',[40 10 900 140],'strings',strings,'callbacks',callbacks,'tabnames',strings,'Parent',parent,'activetabnr',1);

ddb_editXBeachGrid;

