function handles=ddb_addToolboxElements(handles)
% Adds GUI elements to toolbox tab

% Delete existing toolbox elements
parent=handles.Model(md).GUI.elements.tabs(1).handle;
ch=get(parent,'Children');
if ~isempty(ch)
    delete(ch);
end

% And now add the new elements
toolboxElements=handles.Toolbox(tb).GUI.elements;
handles.Model(md).GUI.elements.tabs(1).elements=toolboxElements;
handles.Model(md).GUI.elements.tabs(1).elements=addUIElements(gcf,toolboxElements,'getFcn',@getHandles,'setFcn',@setHandles,'Parent',parent);

% % Find parent (the toolbox tab of the active model), and delete all
% % children
% parent=findobj(gcf,'Tag',[lower(handles.Model(md).name) '.toolbox']);
% ch=get(parent,'Children');
% delete(ch);
% %drawnow;
% 
% h=findobj(gcf,'Tag','UIControl');
% if ~isempty(h)
%     delete(h);
% %    drawnow;
% end
% 
% if handles.Toolbox(tb).useXML
%         
%     % And now add the elements
%     elements=handles.Toolbox(tb).GUI.elements;
%     if ~isempty(elements)
%         elements=addUIElements(gcf,elements,'getFcn',@getHandles,'setFcn',@setHandles,'Parent',parent);
% %        drawnow;
%         handles.Toolbox(tb).GUI.elements=elements;
%     end
%     
% end
