function ddb_addModelTabs(handles)

sz=get(gcf,'Position');

strings{1}='Toolbox';
callbacks{1}=@ddb_selectToolbox;
width(1)=60;

fn=@ddb_selectModelTab;

for i=1:length(handles.Model(md).GUI.upperPanel.strings)
    strings{i+1}=handles.Model(md).GUI.upperPanel.longName{i};
    callbacks{i+1}=fn;
    inparg=handles.Model(md).GUI.upperPanel.shortName{i};
    inputarguments{i+1}=inparg;
    width(i+1)=handles.Model(md).GUI.upperPanel.width(i);
end

tabpanel(gcf,'tabpanel','change','position',[10 10 sz(3)-20 sz(4)-40],'strings',strings,'callbacks',callbacks,'width',width,'inputarguments',inputarguments);
