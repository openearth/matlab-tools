function handles=ddb_initializeUCIT(handles,varargin)

ii=strmatch('UCIT',{handles.Toolbox(:).Name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            return
    end
end

set(handles.GUIHandles.Menu.Toolbox.UCIT,'Enable','off');

handles.Toolbox(ii).Input.FirstTime=1;
