function handles=ddb_openDelft3DFLOW(handles,id)

tbnr=strmatch('DD',{handles.Toolbox(:).Name},'exact');

opt='newdomain';
if id==0
    opt='ddbound';
end
if id>handles.GUIData.NrFlowDomains
    opt='adddomain';
end

switch opt
    case {'ddbound'}
        % DD
        [filename, pathname, filterindex] = uigetfile('ddbound', 'Select ddbound file');
        if pathname~=0
%            handles.WorkingDirectory=pathname;
            ddb_plotDelft3DFLOW(handles,'delete');
            handles.Model(md).Input=[];
            handles=ddb_readDDBoundFile(handles,[filename]);
            for i=1:handles.GUIData.NrFlowDomains
                handles.ActiveDomain=i;
                runid=handles.Toolbox(tbnr).Input.Domains{i};
                handles=ddb_initializeFlowDomain(handles,'all',i,runid);
                filename=[runid '.mdf'];
                handles=ddb_readMDF(handles,filename,i);
                handles=ddb_readAttributeFiles(handles);
            end
            handles.ActiveDomain=1;
            for i=1:handles.GUIData.NrFlowDomains
                ddb_plotDelft3DFLOW(handles,'plot',i);
            end
            for i=1:handles.GUIData.NrFlowDomains
                if i~=handles.ActiveDomain
                    ddb_plotDelft3DFLOW(handles,'deactivate',i);
                end
            end
            handles=ddb_refreshFlowDomains(handles);
        end
    case {'newdomain'}
        % One Domain
        [filename, pathname, filterindex] = uigetfile('*.mdf', 'Select MDF file');
        if pathname~=0
%            handles.WorkingDirectory=pathname;
            ddb_plotDelft3DFLOW(handles,'delete');
            handles.Model(md).Input=[];
            handles.GUIData.NrFlowDomains=1;
            handles.ActiveDomain=1;
            runid=filename(1:end-4);
            handles.Toolbox(tbnr).Input.Domains=[];
            handles.Toolbox(tbnr).Input.DDBoundaries=[];
            handles=ddb_initializeFlowDomain(handles,'all',1,runid);
            filename=[runid '.mdf'];
            handles=ddb_readMDF(handles,[filename],1);
            handles=ddb_readAttributeFiles(handles);
            ddb_plotDelft3DFLOW(handles,'plot',1);
            handles=ddb_refreshFlowDomains(handles);
        end        
    case {'adddomain'}
        % One Domain
        [filename, pathname, filterindex] = uigetfile('*.mdf', 'Select MDF file');
        if pathname~=0
%            handles.WorkingDirectory=pathname;
            PlotAllFlowAttributes(handles,'deactivate');
            handles.GUIData.NrFlowDomains=id;
            handles.ActiveDomain=id;
            runid=filename(1:end-4);
            handles=ddb_initializeFlowDomain(handles,'all',id,runid);
            filename=[pathname filesep runid '.mdf'];
            handles=ddb_readMDF(handles,[filename],id);
            handles=ddb_readAttributeFiles(handles);
            for i=1:handles.GUIData.NrFlowDomains-1
                ddb_plotDelft3DFLOW(handles,'deactivate',i);
            end
            ddb_plotDelft3DFLOW(handles,'plot',id);
            handles=ddb_refreshFlowDomains(handles);
        end        
end
