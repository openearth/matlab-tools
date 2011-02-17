function handles=ddb_initializeNesting(handles,varargin)

ii=strmatch('Nesting',{handles.Toolbox(:).name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            return
    end
end

handles.Toolbox(ii).Input.overallModel   = 'Delft3D-FLOW';
handles.Toolbox(ii).Input.detailedModel  = 'Delft3D-FLOW';
handles.Toolbox(ii).Input.overallDomain  = 'abc';
handles.Toolbox(ii).Input.detailedDomain = 'def';
handles.Toolbox(ii).Input.adminFile      = 'nesting.adm';
