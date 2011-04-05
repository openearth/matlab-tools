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

% handles.Toolbox(ii).Input.overallModel   = 'Delft3D-FLOW';
% handles.Toolbox(ii).Input.detailedModel  = 'Delft3D-FLOW';
% handles.Toolbox(ii).Input.overallDomain  = 'abc';
% handles.Toolbox(ii).Input.detailedDomain = 'def';
% handles.Toolbox(ii).Input.adminFile      = 'nesting.adm';

handles.Toolbox(ii).Input.grdFile       = '';
handles.Toolbox(ii).Input.encFile       = '';
handles.Toolbox(ii).Input.bndFile       = '';

handles.Toolbox(ii).Input.admFile       = 'nesting.adm';
handles.Toolbox(ii).Input.trihFile      = '';
handles.Toolbox(ii).Input.zCor          = 0;
handles.Toolbox(ii).Input.nestHydro     = 1;
handles.Toolbox(ii).Input.nestTransport = 1;
