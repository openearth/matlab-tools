function ddb_openXBeach(opt)

handles=getHandles;

% DD
% ...some day...

% Single Domain
[filename, pathname, filterindex] = uigetfile('*.txt', 'Select Params file');
if pathname~=0   
%     ddb_plotXBeach(handles,'DeleteAll',0); % TO MAKE (empty)
    handles.model.xbeach.domain=[];
    handles.GUIData.NrFlowDomains=1;
    handles.ActiveDomain=1;

%     runid=filename(1:end-4); % Add runid to XBeach?
    runid = 'xbrid';
    handles=ddb_initializeXBeach(handles,1,runid);% Check
    
    handles.Model(4).InputDef = handles.Model(4).Input;% Add default output
    
    filename=['params.txt'];
    handles.model.xbeach.domain(handles.activeDomain).ParamsFile=[pathname filename];
    handles=ddb_readParams(handles,[pathname filename],1);
    handles=ddb_readAttributeXBeachFiles(handles,pathname); % need to add all files
    ddb_plotXBeach(handles,'plot',0); % make
%     ddb_refreshScreen
    ddb_updateDataInScreen;
    gui_updateActiveTab;
    handles.Model(4).Input(1).Runid = handles.Model(4).Input(1).runid;
    ddb_refreshDomainMenu;
%     handles=refresh(handles);   
    % handles=ddb_refreshFlowDomains(handles); %probably not needed

end        

setHandles(handles);
