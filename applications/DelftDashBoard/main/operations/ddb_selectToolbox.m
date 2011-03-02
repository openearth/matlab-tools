function ddb_selectToolbox

handles=getHandles;

ddb_refreshScreen('Toolbox');

% Find parent (the toolbox tab of the active model)
% parent=findobj(gcf,'Tag',[lower(handles.Model(md).name) '.toolbox']);

if handles.Toolbox(tb).useXML
    
    % At this point, the elements are already in the GUI.
    
%    elements=getappdata(parent,'elements');
    elements=handles.Toolbox(tb).GUI.elements;
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
    % No tab panels found, execute call function
    if ~itab
        feval(handles.Toolbox(tb).callFcn);
    end

else
    % Otherwise use old approach
    feval(handles.Toolbox(tb).callFcn);
end
