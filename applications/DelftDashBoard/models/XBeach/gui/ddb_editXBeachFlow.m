function ddb_editXBeachFlow

ddb_refreshScreen('Flow');

strings={'Boundaries','Settings'};
callbacks={@ddb_editXBeachFlowBoundaries,@ddb_editXBeachFlowSettings};
%tabpanel(gcf,'tabpanel2','create','position',[50 20 910 140],'strings',strings,'callbacks',callbacks);

handles=getHandles;
panel=get(handles.Model(md).GUI.elements(1).handle,'UserData');
iac=panel.activeTab;
parent=panel.largeTabHandles(iac);
tabpanel('create','tag','tabpanel2','position',[40 10 910 140],'strings',strings,'callbacks',callbacks,'tabnames',strings,'Parent',parent,'activetabnr',1);

ddb_editXBeachFlowBoundaries;
