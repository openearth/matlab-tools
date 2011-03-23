function ddb_selectToolbox

handles=getHandles;

handles=ddb_addToolboxElements(handles);

setHandles(handles);

% Select toolbox by 'clicking' the toolbox tab. This will call
% selectToolbox.

tabpanel('select','tag',handles.Model(md).name,'tabname','toolbox','runcallback',0);

% Now execute the callback
% At this point, the elements are already in the GUI.
elements=handles.Model(md).GUI.elements.tabs(1).elements;
% Now look for tab panels within this tab, and execute callback associated
% with active tabs
itab=0;
for k=1:length(elements)
    if strcmpi(elements(k).style,'tabpanel')
        % Find active tab
        hh=elements(k).handle;
        el=getappdata(hh,'element');
        iac=el.activeTabNr;
        callback=el.tabs(iac).callback;
        if ~isempty(callback)
            itab=1;
            feval(callback);
        end
    end
end
% No tab panels found, execute the call function of the toolbox
if ~itab
    feval(handles.Toolbox(tb).callFcn);
end
    
%
% 
% 
% if handles.Toolbox(tb).useXML
%     
%     % At this point, the elements are already in the GUI.
%     elements=handles.Toolbox(tb).GUI.elements;
%     % Now look for tab panels within this tab, and execute callback associated
%     % with active tabs
%     itab=0;
%     for k=1:length(elements)
%         if strcmpi(elements(k).style,'tabpanel')
%             % Find active tab
%             hh=elements(k).handle;
%             el=getappdata(hh,'element');
%             iac=el.activeTabNr;
%             callback=el.tabs(iac).callback;
%             if ~isempty(callback)
%                 itab=1;
%                 feval(callback);
%             end
%         end
%     end
%     % No tab panels found, execute call function
%     if ~itab
%         feval(handles.Toolbox(tb).callFcn);
%     end
% 
% else
%     % Otherwise use old approach
%     feval(handles.Toolbox(tb).callFcn);
% end
