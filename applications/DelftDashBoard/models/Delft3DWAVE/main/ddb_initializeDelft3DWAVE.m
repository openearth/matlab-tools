function handles=ddb_initializeDelft3DWAVE(handles,varargin)

ii=strmatch('Delft3DWAVE',{handles.Model.Name},'exact');

if nargin>1
    switch varargin{1}
        case{'veryfirst'}
            handles.Model(ii).LongName='Delft3D-WAVE';
            return
    end
end

handles.Model(ii).Input=[];

runid='tst';

handles=ddb_initializeDelft3DWAVEInput(handles,1,runid);

set(handles.GUIHandles.Menu.Model.Delft3DWAVE,'Enable','on');
