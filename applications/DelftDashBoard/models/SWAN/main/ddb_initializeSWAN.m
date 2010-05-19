function handles=ddb_initializeSWAN(handles,varargin)

if nargin>1
    switch varargin{1}
        case{'veryfirst'}
            return
    end
end

ii=strmatch('SWAN',{handles.Model.Name},'exact');

handles.Model(ii).Input=[];

runid='tst';

handles=ddb_initializeSWANInput(handles,1,runid);

set(handles.GUIHandles.Menu.Model.SWAN,'Enable','off');
