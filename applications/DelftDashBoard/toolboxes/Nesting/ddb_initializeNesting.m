function handles=ddb_initializeNesting(handles,varargin)

ii=strmatch('Nesting',{handles.Toolbox(:).Name},'exact');

if nargin>1
    switch varargin{1}
        case{'veryfirst'}
            return
    end
end

handles.Toolbox(ii).Input.OverallModel   = 'Delft3D-FLOW';
handles.Toolbox(ii).Input.DetailedModel  = 'Delft3D-FLOW';
handles.Toolbox(ii).Input.OverallDomain  = 'abc';
handles.Toolbox(ii).Input.DetailedDomain = 'def';
handles.Toolbox(ii).Input.AdminFile      = 'nesting.adm';
