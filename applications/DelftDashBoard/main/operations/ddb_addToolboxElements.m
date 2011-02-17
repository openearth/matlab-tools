function handles=ddb_addToolboxElements(handles)
% Adds GUI elements to toolbox tab

% Find parent (the toolbox tab of the active model), and delete all
% children
parent=findobj(gcf,'Tag',[lower(handles.Model(md).name) '.toolbox']);
ch=get(parent,'Children');
delete(ch);
%drawnow;

h=findobj(gcf,'Tag','UIControl');
if ~isempty(h)
    delete(h);
%    drawnow;
end

if handles.Toolbox(tb).useXML
        
    % And now add the elements
    elements=handles.Toolbox(tb).GUI.elements;
    if ~isempty(elements)
        elements=addUIElements(gcf,elements,'getFcn',@getHandles,'setFcn',@setHandles,'Parent',parent);
%        drawnow;
        handles.Toolbox(tb).GUI.elements=elements;
    end
    
end
