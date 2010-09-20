function ddb_editXBeachFlow

ddb_refreshScreen('Flow');

strings={'Boundaries','Settings'};
callbacks={@ddb_editXBeachFlowBoundaries,@ddb_editXBeachFlowSettings};
tabpanel(gcf,'tabpanel2','create','position',[50 20 910 140],'strings',strings,'callbacks',callbacks);

ddb_editXBeachFlowBoundaries;
