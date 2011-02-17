function handles=ddb_initializeUnibestCL(handles,varargin)

if nargin>1
    switch varargin{1}
        case{'veryfirst'}
            ii=strmatch('UnibestCL',{handles.Model.name},'exact');
            handles.Model(ii).longName='UnibestCL';
            return
    end
end

ii=strmatch('UnibestCL',{handles.Model.name},'exact');

handles.Model(ii).Input=[];

runid='tst';

handles=ddb_initializeUnibestCLInput(handles,runid);

set(handles.GUIHandles.Menu.Model.UnibestCL,'Enable','on');
