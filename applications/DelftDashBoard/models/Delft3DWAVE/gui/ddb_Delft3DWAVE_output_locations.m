function ddb_Delft3DWAVE_output_locations(varargin)

handles=getHandles;

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_Delft3DWAVE_plotOutputLocations(handles,'update');
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'selectpointfrommap'}
            h=varargin{2};
            nr=varargin{3};
            selectPointFromMap(h,nr);
        case{'selectpointfromlist'}
            selectPointFromList;
        case{'selectlocationset'}
            selectLocationSet;
        case{'addlocationset'}
            addLocationSet;
        case{'deletelocationset'}
            deleteLocationSet;
        case{'loadlocationfile'}
            loadLocationFile;
        case{'savelocationfile'}
            saveLocationFile;
        case{'addpoint'}
            setInstructions({'','','Click point on map to add observation point'}); 
            gui_clickpoint('xy','callback',@addPoint);
        case{'deletepoint'}
            deletePoint;
        case{'editcoordinate'}
            editCoordinates;
    end
end

%%
function selectPointFromMap(h,nr)
clearInstructions; 
handles=getHandles;
iac=[];
for ii=1:handles.Model(md).Input.nrlocationsets
    if handles.Model(md).Input.locationsets(ii).handle==h
        iac=ii;
        break
    end       
end
if ~isempty(iac)
    handles.Model(md).Input.activelocationset=iac;
    handles.Model(md).Input.locationsets(ii).activepoint=nr;
    ddb_Delft3DWAVE_plotOutputLocations(handles,'update');
    setHandles(handles);
    gui_updateActiveTab;
end

%%
function selectLocationSet
clearInstructions; 
handles=getHandles;
ddb_Delft3DWAVE_plotOutputLocations(handles,'update');

%%
function selectPointFromList
clearInstructions; 
handles=getHandles;
ddb_Delft3DWAVE_plotOutputLocations(handles,'update');

%%
function addLocationSet
clearInstructions; 
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.loc', 'File name new location file','');
if pathname==0
    return
end
curdir=[lower(cd) '\'];
if ~strcmpi(curdir,pathname)
    filename=[pathname filename];
end
n=handles.Model(md).Input.nrlocationsets+1;
handles.Model(md).Input.nrlocationsets=n;
handles.Model(md).Input.locationsets=ddb_initializeDelft3DWAVELocationSet(handles.Model(md).Input.locationsets,n);
handles.Model(md).Input.locationfile{n}=filename;
handles.Model(md).Input.activelocationset=n;
setHandles(handles);

%%
function deleteLocationSet
clearInstructions; 
handles=getHandles;
iac=handles.Model(md).Input.activelocationset;
if handles.Model(md).Input.nrlocationsets>0
    handles=ddb_Delft3DWAVE_plotOutputLocations(handles,'delete');
    handles.Model(md).Input.nrlocationsets=handles.Model(md).Input.nrlocationsets-1;
    handles.Model(md).Input.locationsets = removeFromStruc(handles.Model(md).Input.locationsets,iac);
    handles.Model(md).Input.activelocationset=max(min(iac,handles.Model(md).Input.nrlocationsets),1);
    handles.Model(md).Input.locationfile=removeFromCellArray(handles.Model(md).Input.locationfile,iac);
    if handles.Model(md).Input.nrlocationsets==0
        handles.Model(md).Input.locationfile={''};
    end
    handles=ddb_Delft3DWAVE_plotOutputLocations(handles,'plot','visible',1,'active',1);
    ddb_Delft3DWAVE_plotOutputLocations(handles,'update');    
    setHandles(handles);
    gui_updateActiveTab;
end

%%
function loadLocationFile
clearInstructions; 
handles=getHandles;
newfile=handles.Model(md).Input.newlocationfile;
try
    xy=load(newfile);
catch
    ddb_giveWarning('text','Could not load location file!');
    return
end
x=xy(:,1)';
y=xy(:,2)';
n=strmatch(newfile,handles.Model(md).Input.locationfile,'exact');
if isempty(n)
    % New file
    n=handles.Model(md).Input.nrlocationsets+1;
    handles.Model(md).Input.locationsets=ddb_initializeDelft3DWAVELocationSet(handles.Model(md).Input.locationsets,n);
    handles.Model(md).Input.nrlocationsets=n;
end
handles.Model(md).Input.locationfile{n}=newfile;
handles.Model(md).Input.activelocationset=n;
handles.Model(md).Input.locationsets(n).activepoint=1;
handles.Model(md).Input.locationsets(n).x=x;
handles.Model(md).Input.locationsets(n).y=y;
handles.Model(md).Input.locationsets(n).nrpoints=length(x);
handles.Model(md).Input.locationsets(n).pointtext={''};
for ii=1:length(x)
    handles.Model(md).Input.locationsets(n).pointtext{ii}=num2str(ii);
end
handles=ddb_Delft3DWAVE_plotOutputLocations(handles,'plot','visible',1,'active',1);
setHandles(handles);

%%
function saveLocationFile
clearInstructions; 
handles=getHandles;
iac=handles.Model(md).Input.activelocationset;
handles.Model(md).Input.locationfile{iac}=handles.Model(md).Input.newlocationfile;
ddb_Delft3DWAVE_saveLocationFile(handles.Model(md).Input.locationfile{iac},handles.Model(md).Input.locationsets(iac));
setHandles(handles);

%%
function addPoint(x,y)
clearInstructions; 
handles=getHandles;
iac=handles.Model(md).Input.activelocationset;
nr=handles.Model(md).Input.locationsets(iac).nrpoints+1;
handles.Model(md).Input.locationsets(iac).nrpoints=nr;
handles.Model(md).Input.locationsets(iac).activepoint=nr;
handles.Model(md).Input.locationsets(iac).x(nr)=x;
handles.Model(md).Input.locationsets(iac).y(nr)=y;
handles.Model(md).Input.locationsets(iac).pointtext={''};
for ii=1:nr
    handles.Model(md).Input.locationsets(iac).pointtext{ii}=num2str(ii);
end
handles=ddb_Delft3DWAVE_plotOutputLocations(handles,'plot','visible',1,'active',1);
ddb_Delft3DWAVE_plotOutputLocations(handles,'update');
setHandles(handles);
gui_updateActiveTab;

%%
function deletePoint
clearInstructions; 
handles=getHandles;
iac=handles.Model(md).Input.activelocationset;
handles.Model(md).Input.locationsets(iac).nrpoints=handles.Model(md).Input.locationsets(iac).nrpoints-1;
ii=handles.Model(md).Input.locationsets(iac).activepoint;
nr=handles.Model(md).Input.locationsets(iac).nrpoints;

handles.Model(md).Input.locationsets(iac).x = removeFromVector(handles.Model(md).Input.locationsets(iac).x,ii);
handles.Model(md).Input.locationsets(iac).y = removeFromVector(handles.Model(md).Input.locationsets(iac).y,ii);

handles.Model(md).Input.locationsets(iac).activepoint=max(min(ii,nr),1);

handles.Model(md).Input.locationsets(iac).pointtext={''};
for ii=1:nr
    handles.Model(md).Input.locationsets(iac).pointtext{ii}=num2str(ii);
end

handles=ddb_Delft3DWAVE_plotOutputLocations(handles,'plot','visible',1,'active',1);
ddb_Delft3DWAVE_plotOutputLocations(handles,'update');

setHandles(handles);
gui_updateActiveTab;

%%
function editCoordinates
clearInstructions; 
handles=getHandles;
handles=ddb_Delft3DWAVE_plotOutputLocations(handles,'plot','visible',1,'active',1);
ddb_Delft3DWAVE_plotOutputLocations(handles,'update');
setHandles(handles);
