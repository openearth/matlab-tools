function ddb_nestingToolbox

handles=getHandles;
ddb_plotNesting(handles,'activate');

strings={'Nesting - Step 1','Nesting - Step 2'};
callbacks={@ddb_nestingToolbox1,@ddb_nestingToolbox2};
width=[120 120];
tabpanel(gcf,'tabpanel2','create','position',[50 20 800 140],'strings',strings,'callbacks',callbacks,'width',width);
ddb_nestingToolbox1;
