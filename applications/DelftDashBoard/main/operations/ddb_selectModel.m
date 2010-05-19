function ddb_selectModel

handles=getHandles;

ii=strmatch(handles.ActiveModel.Name,{handles.Model.Name},'exact');

feval(handles.Model(ii).CallFcn);

tabpanel(handles.GUIHandles.MainWindow,'tabpanel','select','Toolbox');
