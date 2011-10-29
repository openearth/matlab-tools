function ddb_selectToolbox
% This function is called to change the toolbox

handles=getHandles;

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
setHandles(handles);

% Find handle of tab panel and get tab info
el=getappdata(handles.Model(md).GUI.elements.handle,'element');
el.tabs(1).elements=handles.Model(md).GUI.elements.tabs(1).elements;
setappdata(handles.Model(md).GUI.elements.handle,'element',el);

% Select toolbox tab.
tabpanel('select','tag',handles.Model(md).name,'tabname','toolbox','runcallback',0);

% Check to see if there is a tab panel under this tab
elements=handles.Model(md).GUI.elements.tabs(1).elements;
itab=0;
for k=1:length(elements)
    if strcmpi(elements(k).style,'tabpanel')
        itab=1;
    end
end

% Set callback for the next time the toolbox tab is clicked
panel=get(handles.Model(md).GUI.elements.handle,'UserData');
callbacks=panel.callbacks;
inputArguments=panel.inputArguments;
if itab
    % Default callback
    callbacks{1}=@defaultTabCallback;
    inputArguments{1}={'tag',lower(handles.Model(md).name),'tabnr',1};
else
    callbacks{1}=handles.Toolbox(tb).callFcn;
    inputArguments{1}=[];
end
panel.callbacks=callbacks;
panel.inputArguments=inputArguments;
set(handles.Model(md).GUI.elements.handle,'UserData',panel);

% And now execute the callback
if isempty(inputArguments{1})
    feval(callbacks{1});
else
    feval(callbacks{1},inputArguments{1});
end
