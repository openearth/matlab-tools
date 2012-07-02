function ddb_openDelft3DWAVE(opt)

handles=getHandles;

switch lower(opt)
    case{'open'}
        % One Domain
        [filename, pathname, filterindex] = uigetfile('*.mdw','Select MDW file');
        runid   = filename(1:end-4);
        if pathname~=0
            % Delete all domains
            ddb_plotDelft3DWAVE('delete','domain',0);
            handles.Model(ad).Input = [];
            handles.activeWaveGrid                      = 1;
            handles.Toolbox(tb).Input.domains           = [];
            handles  = ddb_initializeDelft3DWAVEInput(handles,runid);
            filename =[runid '.mdw'];
            handles  = ddb_readMDW(handles,[pathname filename]);
            handles  = ddb_Delft3DWAVE_readAttributeFiles(handles);
            setHandles(handles);
            ddb_plotDelft3DWAVE('plot','active',0,'visible',1,'wavedomain',awg);
            gui_updateActiveTab;
        end        
    otherwise
end
