function ddb_nestingToolbox

handles=getHandles;
ddb_plotNesting(handles,'activate');

strings={'Nesting - Step 1','Nesting - Step 2'};
callbacks={@ddb_nestingToolbox1,@ddb_nestingToolbox2};
width=[120 120];
%tabpanel(gcf,'tabpanel2','create','position',[50 20 800 140],'strings',strings,'callbacks',callbacks,'width',width);
handles=getHandles;
panel=get(handles.Model(md).GUI.elements(1).handle,'UserData');
iac=panel.activeTab;
parent=panel.largeTabHandles(iac);
tabpanel('create','tag','tabpanel2','position',[40 10 800 140],'strings',strings,'callbacks',callbacks,'tabnames',strings,'Parent',parent,'activetabnr',1);

ddb_nestingToolbox1;
