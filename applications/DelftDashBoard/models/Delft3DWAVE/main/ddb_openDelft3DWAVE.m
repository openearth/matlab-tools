function handles=ddb_openSWAN(handles,id)

tb=strmatch('DD',    {handles.Toolbox(:).Name},'exact');
ii=strmatch('Delft3DWAVE',{handles.Model.Name},'exact');

switch id
    case 0
        % DD
        [filename, pathname, filterindex] = uigetfile('ddbound', 'Select ddbound file');
        if pathname~=0
            ddb_PlotDelft3DWave(handles,'DeleteAll',0);
            handles.Model(handles.ActiveModel.Nr).Input=[];
            handles=ddb_readDDBoundFile(handles,[pathname filename]);
            for i=1:handles.GUIData.NrWaveDomains
                handles.ActiveDomain=i;
                runid    = handles.Toolbox(tb).Input.Domains{i};
                handles  = ddb_initializeWaveDomain(handles,i,runid);
                filename = [runid '.mdf'];
                handles  = ddb_readMDW             (handles,filename,i);
                handles  = ddb_readAttributeFiles  (handles);
            end
            handles.ActiveDomain=1;
            for i=1:handles.GUIData.NrFlowDomains
                ddb_plotWaveAttributes(handles,i);
            end
            handles=RefreshDomains(handles);
        end
    otherwise
    ext = '.mdw';
        % One Domain
        [filename, pathname, filterindex] = uigetfile(['*',ext], 'Select MDW file');
         runid   = filename(1:end-4);
        if pathname~=0
            ddb_plotDelft3DWAVE(handles,'DeleteAll',0);
            handles.Model(handles.ActiveModel.Nr).Input = [];
            handles.GUIData.NrFlowDomains               = 1;
            handles.ActiveDomain                        = 1;
            handles.Toolbox(tb).Input.Domains           = [];
            handles.Toolbox(tb).Input.DDBoundaries      = [];
            handles  = ddb_initializeDelft3DWAVEInput(handles,1,runid);
            filename =[runid '.' ext];
            handles  = ddb_readMDW                   (handles,[pathname filename],1);
            handles  = ddb_readAttributeFiles        (handles);
            ddb_plotWaveAttributes                   (handles,1);
            handles  = ddb_refreshWaveDomains        (handles);
        end        
end
