function handles=ddb_openSWAN(handles,id)

tb=strmatch('DD',{handles.Toolbox(:).Name},'exact');
ii=strmatch('Delft3DFLOW',{handles.Model.Name},'exact');

switch id
    case 0
        % DD
        [filename, pathname, filterindex] = uigetfile('ddbound', 'Select ddbound file');
        if pathname~=0
            ddb_plotDelft3DFLOW(handles,'DeleteAll',0);
            handles.Model(handles.ActiveModel.Nr).Input=[];
            handles=ddb_readDDBoundFile(handles,[pathname filename]);
            for i=1:handles.GUIData.NrFlowDomains
                handles.ActiveDomain=i;
                runid=handles.Toolbox(tb).Input.Domains{i};
                handles=ddb_initializeFlowDomain(handles,i,runid);
                filename=[runid '.mdf'];
                handles=ddb_readMDF(handles,filename,i);
                handles=ddb_readAttributeFiles(handles);
            end
            handles.ActiveDomain=1;
            for i=1:handles.GUIData.NrFlowDomains
                ddb_plotFlowAttributes(handles,i);
            end
            handles=RefreshDomains(handles);
        end
    otherwise
        % One Domain
        [filename, pathname, filterindex] = uigetfile('*.mdf', 'Select MDF file');
        if pathname~=0
            ddb_plotDelft3DFLOW(handles,'DeleteAll',0);
            handles.Model(handles.ActiveModel.Nr).Input=[];
            handles.GUIData.NrFlowDomains=1;
            handles.ActiveDomain=1;
            runid=filename(1:end-4);
            handles.Toolbox(tb).Input.Domains=[];
            handles.Toolbox(tb).Input.DDBoundaries=[];
            handles=ddb_initializeFlowDomain(handles,1,runid);
            filename=[runid '.mdf'];
            handles=ddb_readMDF(handles,[pathname filename],1);
            handles=ddb_readAttributeFiles(handles);
            ddb_plotFlowAttributes(handles,1);
            handles=ddb_refreshFlowDomains(handles);
        end        
end
