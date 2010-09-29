function ddb_resetAll

handles=getHandles;

for i=1:length(handles.Model)
    try
        feval(handles.Model(i).PlotFcn,handles,'delete');
    end
end

for i=1:length(handles.Toolbox)
    try
        feval(handles.Toolbox(i).PlotFcn,handles,'delete');
    end
end

ddb_initialize('all');

handles=getHandles;

handles.activeToolbox.Name='ModelMaker';
handles.activeToolbox.Nr=1;

c=handles.GUIHandles.Menu.Toolbox.ModelMaker;
p=get(c,'Parent');
ch=get(p,'Children');
set(ch,'Checked','off');
set(c,'Checked','on');

setHandles(handles);

tabpanel(handles.GUIHandles.MainWindow,'tabpanel','select','tabname','Toolbox');
