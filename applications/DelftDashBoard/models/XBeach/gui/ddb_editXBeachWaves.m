function ddb_editXBeachWaves

ddb_refreshScreen('Waves');

strings={'Boundaries','Settings'};
callbacks={@ddb_editXBeachWaveBoundaries,@ddb_editXBeachWaveSettings};
%tabpanel(gcf,'tabpanel2','create','position',[50 20 910 140],'strings',strings,'callbacks',callbacks);

handles=getHandles;
panel=get(handles.Model(md).GUI.elements(1).handle,'UserData');
iac=panel.activeTab;
parent=panel.largeTabHandles(iac);
tabpanel('create','tag','tabpanel2','position',[40 10 970 140],'strings',strings,'callbacks',callbacks,'tabnames',strings,'Parent',parent,'activetabnr',1);

ddb_editXBeachWaveBoundaries;
