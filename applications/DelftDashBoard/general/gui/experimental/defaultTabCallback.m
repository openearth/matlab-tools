function defaultTabCallback(varargin)

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

% Delete existing UIControls
deleteUIControls;

% Find handle of tab panel and get tab info
h=findobj(gcf,'Tag',tag,'Type','uipanel');
el=getappdata(h,'element');
tab=el.tabs(tabnr);

% Now look for tab panels within this tab, and execute callback associated
% with active tabs
for k=1:length(tab.elements)
    if strcmpi(tab.elements(k).style,'tabpanel')
        % Find active tab
        hh=tab.elements(k).handle;
        el=getappdata(hh,'element');
        iac=el.activeTabNr;
        callback=el.tabs(iac).callback;
        feval(callback);        
    end    
end

