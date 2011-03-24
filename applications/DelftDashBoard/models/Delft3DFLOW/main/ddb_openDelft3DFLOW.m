function ddb_openDelft3DFLOW(opt)

handles=getHandles;

switch opt
    case {'opendomains'}
        % DD
        [filename, pathname, filterindex] = uigetfile('*.ddb', 'Select ddbound file');
        if pathname~=0
%            handles.WorkingDirectory=pathname;
            ddb_plotDelft3DFLOW('delete');
            handles.Model(md).Input=[];
            handles=ddb_readDDBoundFile(handles,filename);
            for i=1:handles.Model(md).nrDomains
                handles.activeDomain=i;
                runid=handles.Model(md).Input(i).runid;
                handles=ddb_initializeFlowDomain(handles,'all',i,runid);
                filename=[runid '.mdf'];
                handles=ddb_readMDF(handles,filename,i);
                handles=ddb_readAttributeFiles(handles,i);
            end
            handles.activeDomain=1;
            setHandles(handles);
            ddb_plotDelft3DFLOW('plot','active',0,'visible',1,'domain',0);
        end
    case {'openpresent'}
        % One Domain
        [filename, pathname, filterindex] = uigetfile('*.mdf', 'Select MDF file');
        if pathname~=0
%            handles.WorkingDirectory=pathname;
            ddb_plotDelft3DFLOW('delete');
            id=handles.activeDomain;
            handles.Model(md).Input=clearStructure(handles.Model(md).Input,id);
            runid=filename(1:end-4);
            handles.Model(md).domains{id}=runid;
            handles.Model(md).DDBoundaries=[];
            handles=ddb_initializeFlowDomain(handles,'all',id,runid);
            filename=[runid '.mdf'];
            handles=ddb_readMDF(handles,filename,id);
            handles=ddb_readAttributeFiles(handles,id);
            setHandles(handles);
            ddb_plotDelft3DFLOW('plot','active',0,'visible',1,'domain',0);
        end        
    case {'opennew'}
        % One Domain
        [filename, pathname, filterindex] = uigetfile('*.mdf', 'Select MDF file');
        if pathname~=0
%            handles.WorkingDirectory=pathname;
            ddb_plotDelft3DFLOW('delete');
            handles.Model(md).nrDomains=handles.Model(md).nrDomains+1;
            handles.activeDomain=handles.Model(md).nrDomains;
            id=handles.activeDomain;
            handles.Model(md).Input=appendStructure(handles.Model(md).Input);
            runid=filename(1:end-4);
            handles.Model(md).domains{id}=runid;
            handles.Model(md).DDBoundaries=[];
            handles=ddb_initializeFlowDomain(handles,'all',id,runid);
            filename=[runid '.mdf'];
            handles=ddb_readMDF(handles,filename,id);
            handles=ddb_readAttributeFiles(handles,id);
            setHandles(handles);
            ddb_plotDelft3DFLOW('plot','active',0,'visible',1,'domain',0);
        end        
end

elements=handles.Model(md).GUI.elements;
if ~isempty(elements)
    setUIElements(elements);
end

ddb_refreshDomainMenu;
