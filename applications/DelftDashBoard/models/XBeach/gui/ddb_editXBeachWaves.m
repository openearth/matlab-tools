function ddb_editXBeachWaves

ddb_refreshScreen('Waves');

strings={'Boundaries','Settings'};
callbacks={@EditXbeachWaveBoundaries,@ddb_editXBeachWaveSettings};
tabpanel(gcf,'tabpanel2','create','position',[50 20 910 140],'strings',strings,'callbacks',callbacks);

ddb_editXBeachWaveBoundaries;
