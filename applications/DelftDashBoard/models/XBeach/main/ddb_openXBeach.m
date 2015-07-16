function ddb_openXBeach(opt)

handles=getHandles;

% DD
% ...some day...

% Single Domain
[filename, pathname, filterindex] = uigetfile('*.txt', 'Select Params file');
if pathname~=0   

    handles.model.xbeach.domain=[];

    handles.activeDomain=1;

    runid = 'xbrid';

    handles=ddb_initializeXBeach(handles,1,runid);% Check
    
    filename='params.txt';
    handles.model.xbeach.domain(handles.activeDomain).params_file=[pathname filename];
    
    handles=ddb_readParams(handles,[pathname filename],1);
    handles=ddb_XBeach_readAttributeFiles(handles,pathname); % need to add all files

    setHandles(handles);
    
    ddb_plotXBeach('plot','domain',ad); % make
    
    
    ddb_updateDataInScreen;
    gui_updateActiveTab;
    ddb_refreshDomainMenu;

end        


