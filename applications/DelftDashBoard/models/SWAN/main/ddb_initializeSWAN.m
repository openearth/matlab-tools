function handles=ddb_initializeSWAN(handles,varargin)

ii=strmatch('SWAN',{handles.Model.Name},'exact');

if nargin>1
    switch varargin{1}
        case{'veryfirst'}
            handles.Model(ii).LongName='SWAN';
            return
    end
end

handles.Model(ii).Input=[];

runid='tst';

handles=ddb_initializeDelft3DWAVEInput(handles,1,runid); % make internal stuff same as for Delft3DWAVE

% set(handles.GUIHandles.Menu.Model.SWAN,'Enable','off');
