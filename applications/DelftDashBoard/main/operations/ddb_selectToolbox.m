function ddb_selectToolbox

ddb_refreshScreen('Toolbox');

handles=getHandles;

if handles.debugMode
    handles=ddb_readToolboxXML(handles,tb);
end

% Find parent
parent=findobj(gcf,'Tag',[lower(handles.Model(md).Name) '.toolbox']);
ch=get(parent,'Children');
delete(ch);

if handles.Toolbox(tb).useXML
    elements=handles.Toolbox(tb).GUI.elements;
    if ~isempty(elements)
        elements=addUIElements(gcf,elements,'getFcn',@getHandles,'setFcn',@setHandles,'Parent',parent);
        handles.Toolbox(tb).GUI.elements=elements;
    end
end

feval(handles.Toolbox(tb).CallFcn);
