function handles=ddb_initializeMAD(handles,varargin)

ii=strmatch('MAD',{handles.Toolbox(:).Name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            handles.Toolbox(ii).LongName='Model Application Database';
            return
    end
end

% set(handles.GUIHandles.Menu.Toolbox.MAD,'Enable','off');

handles.Toolbox(ii).KMLColor='red';
