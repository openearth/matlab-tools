function ddb_selectToolbox

handles=getHandles;

ddb_refreshScreen('Toolbox');

% % If debug mode, reload the the active toolbox xml file
% if handles.debugMode
%     handles=ddb_readToolboxXML(handles,tb);
% end

% Find parent (the toolbox tab of the active model)
parent=findobj(gcf,'Tag',[lower(handles.Model(md).Name) '.toolbox']);

if handles.Toolbox(tb).useXML
        
    elements=getappdata(parent,'elements');
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
        feval(handles.Toolbox(tb).CallFcn);
    end

else
    % Otherwise use old approach
    feval(handles.Toolbox(tb).CallFcn);
end
