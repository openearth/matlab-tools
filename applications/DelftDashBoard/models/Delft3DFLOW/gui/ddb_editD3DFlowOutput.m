function ddb_editD3DFlowOutput

ddb_refreshScreen('Output');

strings={'Storage','Print','Details'};
callbacks={@ddb_editD3DFlowOutputStorage,@ddb_editD3DFlowOutputPrint,@ddb_editD3DFlowOutputDetails};
tabpanel(gcf,'tabpanel2','create',[50 20 900 140],strings,callbacks);

ddb_editD3DFlowOutputStorage;
