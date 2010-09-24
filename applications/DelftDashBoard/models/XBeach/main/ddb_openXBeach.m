function ddb_openXBeach(opt)

handles=getHandles;

% DD
   % some day...
% One Domain
[filename, pathname, filterindex] = uigetfile('*.txt', 'Select Params file');
if pathname~=0
    handles.Model(md).Input(handles.ActiveDomain).ParamsFile=[pathname filename];
    ddb_plotXBeach(handles,'DeleteAll',0); % make
    handles.Model(handles.ActiveModel.Nr).Input=[];
    handles.GUIData.NrFlowDomains=1;
    handles.ActiveDomain=1;
    runid=filename(1:end-4);
    handles=ddb_initializeXBeach(handles,1,runid);
    filename=[runid '.txt'];
    handles=ddb_readParams(handles,[pathname filename],1);
    handles=ddb_readAttributeXBeachFiles(handles,pathname); %make
    ddb_plotXBeach(handles,'plot',0); % make
    % handles=Refresh(handles);   
    % handles=ddb_refreshFlowDomains(handles); %probably not needed
end        

setHandles(handles);
