function defaultTabCallback(varargin)
% Default tab callback. Callback is executed when no callback is assigned
% to tab. This function tries to find tabpanel with current tab, finds
% active tab in that tabpanel, and tries to execute callback assigned to
% this active tab.

varargin=varargin{1};

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'tag'}
                tag=varargin{i+1};
            case{'tabnr'}
                tabnr=varargin{i+1};
        end
    end    
end

% Find handle of tab panel and get tab info
h=findobj(gcf,'Tag',tag,'Type','uipanel');
el=getappdata(h,'element');
tab=el.tabs(tabnr).tab;

% Now look for tab panels within this tab, and execute callback associated
% with active tabs
for k=1:length(tab.elements)
    if strcmpi(tab.elements(k).element.style,'tabpanel')
        % Find active tab
        hh=tab.elements(k).element.handle;
        el=getappdata(hh,'element');
        iac=el.activetabnr;
        callback=el.tabs(iac).tab.callback;
        if ~isempty(callback)
            feval(callback);        
        end
        break
    end    
end

