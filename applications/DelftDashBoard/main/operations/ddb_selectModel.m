function ddb_selectModel

handles=getHandles;


if handles.Model(md).useXML
    % Make tabs
    ddb_addModelTabs(handles);
%     % Change menu items (file, domain and view)
% %    changeModelMenuItems(handles.Model.Name);
else
   feval(handles.Model(md).CallFcn);
end

% Select toolbox
tabpanel(handles.GUIHandles.MainWindow,'tabpanel','select','tabname','Toolbox');
