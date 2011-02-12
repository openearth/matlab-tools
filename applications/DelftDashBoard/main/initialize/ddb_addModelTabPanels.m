function ddb_addModelTabPanels

handles=getHandles;

% Model tabs
for i=1:length(handles.Model)
    elements=handles.Model(i).GUI.elements;
    if ~isempty(elements)
        elements=addUIElements(gcf,elements,'getFcn',@getHandles,'setFcn',@setHandles);
        set(elements(1).handle,'Visible','off');
        handles.Model(i).GUI.elements=elements;
    end
end

handles=ddb_addToolboxElements(handles);

setHandles(handles);
