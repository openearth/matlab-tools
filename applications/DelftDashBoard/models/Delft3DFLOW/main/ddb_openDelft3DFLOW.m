function ddb_openDelft3DFLOW(opt)

handles=getHandles;

tbnr=strmatch('DD',{handles.Toolbox(:).name},'exact');

% opt='newdomain';
% if id==0
%     opt='ddbound';
% end
% if id>handles.GUIData.NrFlowDomains
%     opt='adddomain';
% end

switch opt
    case {'opendomains'}
        % DD
        [filename, pathname, filterindex] = uigetfile('ddbound', 'Select ddbound file');
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
                handles=ddb_readAttributeFiles(handles);
            end
            handles.activeDomain=1;
            for i=1:handles.Model(md).nrDomains
                ddb_plotDelft3DFLOW('plot','active',0,'visible',1,'domain',i);
            end
%             for i=1:handles.GUIData.nrFlowDomains
%                 if i~=handles.activeDomain
%                     ddb_plotDelft3DFLOW(handles,'deactivate',i);
%                 end
%             end
            ddb_refreshDomainMenu;
%            ddb_refreshFlowDomains;
        end
    case {'open'}
        % One Domain
        [filename, pathname, filterindex] = uigetfile('*.mdf', 'Select MDF file');
        if pathname~=0
%            handles.WorkingDirectory=pathname;
            ddb_plotDelft3DFLOW('delete');
            handles.Model(md).Input=[];
            handles.Model(md).nrDomains=1;
            handles.activeDomain=1;
            runid=filename(1:end-4);
            handles.Toolbox(tbnr).Input.domains=[];
            handles.Toolbox(tbnr).Input.DDBoundaries=[];
            handles=ddb_initializeFlowDomain(handles,'all',1,runid);
            filename=[runid '.mdf'];
            handles=ddb_readMDF(handles,filename,1);
            handles=ddb_readAttributeFiles(handles);
            setHandles(handles);
            ddb_plotDelft3DFLOW('plot','active',0,'visible',1,'domain',1);
%             ddb_refreshFlowDomains;
        end        
    case {'adddomain'}
        % One Domain
        [filename, pathname, filterindex] = uigetfile('*.mdf', 'Select MDF file');
        if pathname~=0
%            handles.WorkingDirectory=pathname;
            PlotAllFlowAttributes(handles,'deactivate');
            handles.Model(md).nrFlowDomains=id;
            handles.activeDomain=id;
            runid=filename(1:end-4);
            handles=ddb_initializeFlowDomain(handles,'all',id,runid);
            filename=[pathname filesep runid '.mdf'];
            handles=ddb_readMDF(handles,[filename],id);
            handles=ddb_readAttributeFiles(handles);
            setHandles(handles);
            for i=1:handles.Model(md).nrDomains-1
                ddb_plotDelft3DFLOW(handles,'deactivate',i);
            end
            ddb_plotDelft3DFLOW(handles,'plot',id);
%             ddb_refreshFlowDomains;
        end        
end

ddb_refreshDomainMenu;

