function ddb_editXBeachFlow

ddb_refreshScreen('Flow');

strings={'Boundaries','Settings'};
callbacks={@ddb_editXBeachFlowBoundaries,@ddb_editXBeachFlowSettings};
tabpanel(gcf,'tabpanel2','create',[50 20 910 140],strings,callbacks);

ddb_editXBeachFlowBoundaries;
