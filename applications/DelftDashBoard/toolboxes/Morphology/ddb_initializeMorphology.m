function handles=ddb_initializeMorphology(handles,varargin)

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            return
    end
end

set(handles.GUIHandles.Menu.Toolbox.Morphology,'Enable','off');
