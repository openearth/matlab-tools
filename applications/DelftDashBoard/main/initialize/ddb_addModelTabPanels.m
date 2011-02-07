function ddb_addModelTabPanels

handles=getHandles;

% Model tabs
for i=1:length(handles.Model)
    elements=handles.Model(i).GUI.elements;
%     subFields{1}='Model';
%     subFields{2}='Input';
%     subIndices={i,1};
    if ~isempty(elements)
        elements=addUIElements(gcf,elements,'getFcn',@getHandles,'setFcn',@setHandles);
        set(elements(1).handle,'Visible','off');
        handles.Model(i).GUI.elements=elements;
    end
end

setHandles(handles);
