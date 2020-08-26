function varargout = editLines(varargin)
% EDITLINES M-file for editLines.fig
%      EDITLINES, by itself, creates a new EDITLINES or raises the existing
%      singleton*.
%
%      H = EDITLINES returns the handle to a new EDITLINES or the handle to
%      the existing singleton*.
%
%      EDITLINES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDITLINES.M with the given input arguments.
%
%      EDITLINES('Property','Value',...) creates a new EDITLINES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before editLines_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to editLines_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help editLines

% Last Modified by GUIDE v2.5 29-Jan-2020 13:54:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @editLines_OpeningFcn, ...
    'gui_OutputFcn',  @editLines_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before editLines is made visible.
function editLines_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to editLines (see VARARGIN)

% Choose default command line output for editLines

% make sure open earth is loaded
try
    addOpenEarth;
catch
    disp('Running without OpenEarth');
end

handles.output = hObject;

handles.outline = cell(1,3);
handles.oldSize = get(gcf,'pos');

% initialize
handles.nrLayers = 0;
handles = resetEditLines(handles);

% make the colormap
myColor = colormap('colorcube');
mask = all(myColor==1,2);
myColor(mask,:) = [];
handles.myColor = myColor;


%add data coming in as new layer
indLine =  strcmpi('lineData',varargin);
indName =  strcmpi('lineName',varargin);

% Update handles structure
guidata(hObject, handles);

if any(indLine) && any (indName)
    indLine = find(indLine);
    lineData = varargin{indLine+1};
    indName = find(indName);
    theName = varargin{indName+1};
    
    handles = addLayer(handles,lineData,theName);
    handles = updatePlot(handles);
    
    % Update handles structure
    guidata(hObject, handles);
    
    % Make the GUI modal
    myFig = handles.figure1;
    set(myFig,'WindowStyle','modal')

    % UIWAIT makes modmod wait for user response (see UIRESUME)
    uiwait(myFig);
    
end
    


% --- Outputs from this function are returned to the command line.
function varargout = editLines_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

iLayer  = layerNr(handles);
if isfield(handles,'layers')
    varargout{2} = handles.layers(iLayer).line;
end


% --- Executes on button press in PB_LOAD.
function PB_LOAD_Callback(hObject, eventdata, handles)
% hObject    handle to PB_LOAD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


ZIP_PATH = 'd:\tmpkmldireditlines\';
cFiles ={'*.i2s','Blue Kanoo line (*.i2s)';...
         '*.kml','Google earth (*.kml)';...
         '*.kmz','Google earth (*.kmz)';...
         '*.ldb','Land boundary file (*.ldb)';...
    
    '*.*','all files (*.*)'};

if isfield(handles,'file')
    [file,path] = uigetfile(cFiles,'Select Grid File',handles.file);
else
    [file,path] = uigetfile(cFiles,'Select Grid File');
end
if ischar(file)
    theFile = fullfile(path,file);
    [~,theName,theType] = fileparts(theFile);
    % load file
    switch lower(theType)
        case '.i2s'
            cTmp = Telemac.readKenue(theFile);
        case '.kml'
            sctTmp = kml2struct(theFile);
            cTmp{1} = [sctTmp.Lon,sctTmp.Lat];
        case '.kmz'
            unzip(theFile,ZIP_PATH);
            tmpFile = dir(fullfile(ZIP_PATH,'*.kml'));
            if length(tmpFile)>1
                errordlg(['Something went wrong during unzip. Delete ',ZIP_PATH]);
                return;
            end
            newFile = fullfile(tmpFile.folder,tmpFile.name);
            sctTmp = kml2struct(newFile);
            cTmp{1} = [sctTmp.Lon,sctTmp.Lat];
            fclose all;
            rmdir(ZIP_PATH,'s');
        case '.ldb'
            tmp = landboundary('read',theFile);
            cTmp = PolyLine.convertNanLineType (tmp(:,1),tmp(:,2));
        otherwise
            errordlg('Unknown format');
            return
    end
    
    % Plot
    handles = addLayer(handles,cTmp,theName);
    handles = updatePlot(handles);
    
    handles.file = path;
    guidata(hObject,handles);
    
    
end

%--------------------------------------------------------------------------
% for UNDO
function handles = resetState(handles)
if isfield(handles,'prevLayers')
    handles.layers = handles.prevLayers;
end

function handles = saveState(handles)
if isfield(handles,'layers')
    handles.prevLayers = handles.layers;
end

%--------------------------------------------------------------------------

function handles = addLayer(handles,cData,theName)
% add a layer
handles.nrLayers = handles.nrLayers + 1 ;
handles.layers(handles.nrLayers).line = cData;
handles.LB_layer.String{handles.nrLayers} = theName;
handles.LB_destiny.String{handles.nrLayers} = theName;

function handles = addImage(handles,x,y,C,theName)
 % add a coloured background
  handles.image.x = x;
  handles.image.y = y;
  handles.image.C = C;
  handles.image.name = theName;

%--------------------------------------------------------------------------
% LAYERS
function handles = deleteLayer(handles,iLayer)
% delete a layer

handles.layers(iLayer).line = [];
% move upper layers
for i = iLayer+1:handles.nrLayers
    handles.layers(i-1).line = handles.layers(i).line;
end
handles.nrLayers = handles.nrLayers - 1 ;
% update list boxes
handles.LB_layer.Value = 1;
handles.LB_layer.String(iLayer) = [];
handles.LB_destiny.String(iLayer) = [];
if handles.LB_destiny.Value== (iLayer)
     handles.LB_destiny.Value = 1;
end

function handles = newLayer(handles,theName)
% make a new layer
handles.nrLayers = handles.nrLayers + 1;
handles.layers(handles.nrLayers).line = [];
handles.LB_layer.String{handles.nrLayers} = theName;
handles.LB_destiny.String{handles.nrLayers} = theName;


function handles = resetEditLines(handles)
% resets all layers
if isfield(handles,'layers')
    if isfield(handles.layers,'line')
        handles.layers= rmfield(handles.layers,'line');
    end
end
if isfield(handles,'image')
    handles = rmfield(handles,'image');
end
handles.nrLayers = 0;
handles.LB_layer.String = {};
handles.LB_destiny.String = {};
handles.LB_layer.Value = 1;
handles.LB_destiny.Value = 1;
handles.resetAxesLim = true;
if isfield(handles,'prevLayers')
    handles = rmfield(handles,'prevLayers');
end


%--------------------------------------------------------------------------
% plotting

function handles = updatePlot(handles,updateImage)
% plotting function

if nargin <2 
    updateImage = false;
end
handles.axesLim = [get(handles.myPlot,'xlim'),get(handles.myPlot,'ylim')];
ind = layerNr(handles);
hold on;
minX = inf;
minY = inf;
maxX = -inf;
maxY = -inf;

if updateImage
    cla(handles.myPlot);
end
% add image if needed
if get(handles.CB_showImage,'Value')&& isfield(handles,'image') && updateImage
    
    myGray = 0.25+colormap('gray')*0.75;
    colormap(myGray);
    image('XData',handles.image.x,'YData',handles.image.y,'CData',handles.image.C);
    axis equal; 
    grid on;
    hold on;
end

% find old plots and delete
oldPlots = findobj(handles.myPlot,'Type','line');
delete(oldPlots);

oldPlots = findobj(handles.myPlot,'Type','text');
delete(oldPlots);


for i = 1:handles.nrLayers
    nrLines = length(handles.layers(i).line);
    for j=1:nrLines
        if isempty( handles.layers(i).line{j})
            continue
        end
        x = handles.layers(i).line{j}(:,1);
        y = handles.layers(i).line{j}(:,2);
          minX = min(minX,min(x));
          maxX = max(maxX,max(x));
          minY = min(minY,min(y));
          maxY = max(maxY,max(y));
        if i==ind
            theColor = handles.myColor(1+mod(j,size(handles.myColor,1)),:);
            plot(x,y,'-o','color',theColor,'markersize',3);
            text(x(1),y(1),'start','color',theColor,'fontsize',8)
            
        else
            plot(x,y,'-','color',[0.75 0.75 0.75]);
        end
        
    end
end
grid on
axis equal;
if ~(handles.resetAxesLim)
    xlim(handles.axesLim(1:2));
    ylim(handles.axesLim(3:4));
else
      xlim([minX maxX]);
      ylim([minY maxY]);
%     handles.axesLim = [get(handles.myPlot,'xlim'),get(handles.myPlot,'ylim')];
      handles.resetAxesLim = false;
end

%--------------------------------------------------------------------------
% FIND

function [indI,indJ,indK] = findClosest(handles,x,y,useOrg)
% finds the line closest to a point
if nargin ==3
    useOrg = true;
end
maxDist = inf;
if useOrg
    i = layerNr(handles);
else
    i = destNr(handles);
end
nrLines = length(handles.layers(i).line);
for j=1:nrLines
    % look for closes point
    xTmp = handles.layers(i).line{j}(:,1);
    yTmp = handles.layers(i).line{j}(:,2);
    [dist,ind] = min( (xTmp-x).^2 + (yTmp-y).^2);
    if dist<maxDist
        indI = i;
        indJ = j;
        indK = ind;
        maxDist = dist;
    end
end

function [indI,indJ,indK] = findClosestLine(handles,x,y,useOrg)
% finds the line closest to a point
if nargin ==3
    useOrg = true;
end
maxDist = inf;
if useOrg
    i = layerNr(handles);
else
    i = destNr(handles);
end
nrLines = length(handles.layers(i).line);
for j=1:nrLines
    % look for closes point to line in a poliline
    xTmp = handles.layers(i).line{j}(:,1);
    yTmp = handles.layers(i).line{j}(:,2);
    % distance to line
    % distance to points to make sure that point is in between
    [dist,ind] = PolyLine.dist2poly([x y],[xTmp yTmp]);
    if dist<maxDist
        indI = i;
        indJ = j;
        indK = ind;
        maxDist = dist;
    end
end

function [indI,indJ,indK] = findPolyPoint (handles,xPoly,yPoly,useOrg)
    if nargin ==3
        useOrg = true;
    end
    if useOrg
        i = layerNr(handles);
    else
        i = destNr(handles);
    end
    nrLines = length(handles.layers(i).line);
    % preallocate
    indI = zeros(1000,1);
    indJ = zeros(1000,1);
    indK = cell(1000,1);
    n = 0;
    for j=1:nrLines
        xTmp = handles.layers(i).line{j}(:,1);
        yTmp = handles.layers(i).line{j}(:,2);
        in   = inpoly([xTmp,yTmp],[xPoly,yPoly]);
        if ~isempty(in)
            n = n+1;
            indK{n} = find(in);
            indJ(n) = j;
            indI(n) = i;
        end
    end
    % delete unused data
    if n>0
        indI(n+1:end) = [];
        indJ(n+1:end) = [];
        indK(n+1:end) = [];
    else
        indI = [];
        indJ = [];
        indK = {};
    end


function [indI,indJ] = findPoly (handles,xPoly,yPoly,useOrg)
   % finds all lines with its bounding box in a polygon
if nargin ==3
    useOrg = true;
end
if useOrg
    i = layerNr(handles);
else
    i = destNr(handles);
end
nrLines = length(handles.layers(i).line);
% preallocate
indI = zeros(1000,1);
indJ = zeros(1000,1);
n = 0;
for j=1:nrLines
    % inpoly on boundaing box
    xTmp = handles.layers(i).line{j}(:,1);
    yTmp = handles.layers(i).line{j}(:,2);
    bbLl = [min(xTmp),min(yTmp)]; 
    bbUr = [max(xTmp),max(yTmp)] ;
    in   = inpoly([bbLl;bbUr],[xPoly,yPoly]);
    % add datato list
    if all(in)
        n = n+1;
        indI(n) = i;
        indJ(n) = j;
    end
end
% delete unused data
if n>0
    indI(n+1:end) = [];
    indJ(n+1:end) = [];
else
    indI = [];
    indJ = [];
end

%--------------------------------------------------------------------------
% gui

function ind = layerNr(handles)
ind = handles.LB_layer.Value;

function ind = destNr(handles)
ind = handles.LB_destiny.Value;

function yesNo = useRbbox(handles)
yesNo = handles.CB_rbbox.Value;

function yesNo = useAppend(handles)
yesNo = handles.CB_append.Value;

function theName = layerName(handles)
    ind = handles.LB_layer.Value;
    theName =  handles.LB_layer.String{ind};
    
%--------------------------------------------------------------------------


% --- Executes on button press in PB_save.
function PB_save_Callback(hObject, eventdata, handles)
% hObject    handle to PB_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[fileName,pathName] = uiputfile({'*.i2s','Blue Kanoo grid (*.i2s)'},'Select output filename',fullfile(handles.file,[layerName(handles),'.i2s']));
if ischar(fileName)
    theFile = [pathName,fileName];
    ind = layerNr(handles);
    if length(ind)~=1
        errordlg('Only one layer can be selected ');
        return
    end
    cTmp = handles.layers(ind).line;
    Telemac.writeKenue(theFile,cTmp);
    handles.file = pathName;
    guidata(hObject,handles);
end



% --- Executes on button press in PB_zoom.
function PB_zoom_Callback(hObject, eventdata, handles)
% hObject    handle to PB_zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% sets zooming of the data
switch get(hObject,'string')
    case 'Zoom'
        set(hObject,'string','Zoom off')
        
        zoom;
    case 'Zoom off'
        set(hObject,'string','Zoom')
        
        zoom off;
end
guidata(hObject,handles);

% --- Executes on button press in PB_pan.
function PB_pan_Callback(hObject, eventdata, handles)
% hObject    handle to PB_pan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set panning of the data
switch get(hObject,'string')
    case 'Pan'
        set(hObject,'string','Pan off')
        
        pan;
    case 'Pan off'
        set(hObject,'string','Pan')
        
        pan off;
end
guidata(hObject,handles);




% % --------------------------------------------------------------------
% function uipushtool3_ClickedCallback(hObject, eventdata, handles)
% % hObject    handle to uipushtool3 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% PB_LOAD_Callback(hObject, eventdata, handles)


% --- Executes on button press in PB_move.
function PB_move_Callback(hObject, eventdata, handles)
% hObject    handle to PB_move (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
w = 1;
while w==1
    % find closest point
    [x,y,w] =fastGinput(1);
    if w==1
        [indI,indJ,indK] = findClosest(handles,x,y);
        % find new location
        [x,y,w] =fastGinput(1);
        
        if w==1
            % change data
            handles.layers(indI).line{indJ}(indK,1:2) = [x,y];
            % update figure
            guidata(hObject,handles);
            handles = updatePlot(handles);
            
        end
        guidata(hObject,handles);
    end
end


% --- Executes on button press in PB_merge.
function PB_merge_Callback(hObject, eventdata, handles)
% hObject    handle to PB_merge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
w = 1;
while w==1
    % find first segment
    [x,y,w] =fastGinput(1);
    if w==1
        [i1,j1] = findClosest(handles,x,y);
        line1 = handles.layers(i1).line{j1};
        % find second segment
        [x,y,w] =fastGinput(1);
        if w==1
            [i2,j2] = findClosest(handles,x,y);
            line2 = handles.layers(i2).line{j2};
            if j1==j2 && i1==i2
                errordlg('You cannot merge a line with itself');
                return;
            end
            % change data
            handles.layers(i1).line{j1} = [line1;line2];
            handles.layers(i2).line(j2) = [];
            % update figure
            handles = updatePlot(handles);
        end
        guidata(hObject,handles);
    end
end


% --- Executes on button press in PB_moveLayer.
function PB_moveLayer_Callback(hObject, eventdata, handles)
% hObject    handle to PB_moveLayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if destNr(handles)==layerNr(handles)
    errordlg('Source and destination layer cannot be the same');
    return
end
handles = saveState(handles);

if useRbbox(handles)
    handles = rbboxCopyLine(handles,false);
    handles = updatePlot(handles);
    guidata(hObject,handles);
else
    w = 1;
    while w==1
        [handles,w] = moveCopyLine(handles,false);
        handles = updatePlot(handles);
        guidata(hObject,handles);
    end
end

handles = updatePlot(handles);
guidata(hObject,handles);


% --- Executes on selection change in LB_layer.
function LB_layer_Callback(hObject, eventdata, handles)
% hObject    handle to LB_layer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LB_layer contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LB_layer

guidata(hObject,handles);
handles = updatePlot(handles);
guidata(hObject,handles);
    


% --- Executes during object creation, after setting all properties.
function LB_layer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LB_layer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PB_split.
function PB_split_Callback(hObject, eventdata, handles)
% hObject    handle to PB_split (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% splits a line
handles = saveState(handles);
w = 1;
while w==1
    % find first segment
    [x,y,w] =fastGinput(1);
    if w==1
        [i1,j1,k1] = findClosest(handles,x,y);
        nrLines = length(handles.layers(i1).line);
        if k1==1 || k1==size(handles.layers(i1).line{j1},1)
            errordlg('Cannot split first and last point of a line');
            return
        end
        handles.layers(i1).line{nrLines+1} = handles.layers(i1).line{j1}(k1:end,:);
        handles.layers(i1).line{j1} = handles.layers(i1).line{j1}(1:k1,:);
        
        handles = updatePlot(handles);
        
        guidata(hObject,handles);
    end
end

% --- Executes on button press in PB_deletePoint.
function PB_deletePoint_Callback(hObject, eventdata, handles)
% hObject    handle to PB_deletePoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
if useRbbox(handles)
    
    [xBox,yBox] = Util.rbboxSelect(gca);
    [indI,indJ,indK] = findPolyPoint(handles,xBox',yBox') ;
    if isempty(indJ)
        msgbox('No lines in bounding box');
        return;
    end
    % delete points
    for i = 1:length(indJ)
        handles.layers(indI(i)).line{indJ(i)}(indK{i},:) = [];
    end
    
    handles = updatePlot(handles);
    guidata(hObject,handles);
else
    w = 1;
    while w==1
        % find first segment
        [x,y,w] =fastGinput(1);
        if w==1
            [i1,j1,k1] = findClosest(handles,x,y);
            handles.layers(i1).line{j1}(k1,:) = [];
            handles = updatePlot(handles);
            guidata(hObject,handles);
        end
    end
end


% --- Executes on button press in PB_delteLine.
function PB_delteLine_Callback(hObject, eventdata, handles)
% hObject    handle to PB_delteLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
if useRbbox(handles)
    [xBox,yBox] = Util.rbboxSelect(gca);
    [indI,indJ] = findPoly (handles,xBox',yBox') ;
    if isempty(indJ)
        msgbox('No lines in bounding box');
        return;
    end
    for i= length(indJ):-1:1
        handles.layers(indI(i)).line(indJ(i)) = [];
    end
    handles = updatePlot(handles);
    guidata(hObject,handles);
else
    w = 1;
    while w==1
        % find first segment
        [x,y,w] =fastGinput(1);
        if w==1
            [i1,j1] = findClosest(handles,x,y);
            handles.layers(i1).line(j1) = [];
            handles = updatePlot(handles);
            guidata(hObject,handles);
        end
    end
end

function handles = rbboxCopyLine(handles,doCopy)
    % move or copies a line use a rubberbox select
    [xBox,yBox] = Util.rbboxSelect(gca);
    [indI,indJ] = findPoly (handles,xBox',yBox') ;
    if isempty(indJ)
        msgbox('No lines in bounding box');
        return;
    end
    % add data to destination layer
    nrLines = length(indJ);    
    if useAppend(handles)
        % select point of line to append
        [x,y,w]  = fastGinput(1);
        [i2,j2] = findClosest(handles,x,y,false);
        if (w~=1)
            return
        end
        for i = 1:nrLines
            handles.layers(i2).line{j2} = [handles.layers(i2).line{j2};handles.layers(indI(i)).line{indJ(i)}];
        end
    else
        % make new lines
        i2 =destNr(handles);
        for i = 1:nrLines
            j2 = length(handles.layers(i2).line)+1;
            handles.layers(i2).line{j2} = handles.layers(indI(i)).line{indJ(i)};
        end
    end
    
    % delete lines if needed
    if ~doCopy
          for i = nrLines:-1:1
              handles.layers(indI(i)).line(indJ(i)) = [];
          end
    end


function [handles,w] = moveCopyLine(handles,doCopy)
        %moves or copy a line between layers by clinking on it
        
        % find first segment
        [x,y,w] =fastGinput(1);
        if w==1
            [i1,j1] = findClosest(handles,x,y);
            theLine = handles.layers(i1).line{j1};
            % select second line to which the dat ais append
            if  useAppend(handles)
                [x,y,w] = fastGinput(1);
                if w==1
                    [i2,j2] = findClosest(handles,x,y,false);
                end
                handles.layers(i2).line(j2) = [handles.layers(i2).line(j2);theLine];
            else
                % add as new line
                i2 = destNr(handles);
                nrLines = length(handles.layers(i2).line);
                handles.layers(i2).line{nrLines+1} = theLine;
            end
            % delete the orginal line
            if ~doCopy
                handles.layers(i1).line(j1) = [];
            end
        end

% --- Executes on button press in PB_copy.
function PB_copy_Callback(hObject, eventdata, handles)
% hObject    handle to PB_copy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
if destNr(handles)==layerNr(handles)
    errordlg('Source and destination layer cannot be the same');
    return
end

if useRbbox(handles)
    handles = rbboxCopyLine(handles,true);
    handles = updatePlot(handles);
    guidata(hObject,handles);
else
    w = 1;
    while w==1
        [handles,w] = moveCopyLine(handles,true);
        handles = updatePlot(handles);
        guidata(hObject,handles);
    end
end

handles = updatePlot(handles);
guidata(hObject,handles);



% --- Executes on button press in PB_digitize.
function PB_digitize_Callback(hObject, eventdata, handles)
% hObject    handle to PB_digitize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
w = 1;
n = 0;
while w==1
    % find first segment
    [x,y,w] =fastGinput(1);
    if w==1
        n = n+1;
        xTmp(n,1) = x;
        yTmp(n,1) = y;
      
    end
    if n>1
        delete(hTmp);
        hTmp = plot(xTmp,yTmp,'-ok');
    else
        hTmp = plot(xTmp,yTmp,'ok');
    end
    
end

ind = layerNr(handles);
nrLines = length(handles.layers(ind).line)+1;
handles.layers(ind).line{nrLines} = [xTmp,yTmp,zeros(size(xTmp))];
handles = updatePlot(handles);
guidata(hObject,handles);


% --- Executes on selection change in LB_destiny.
function LB_destiny_Callback(hObject, eventdata, handles)
% hObject    handle to LB_destiny (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LB_destiny contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LB_destiny


% --- Executes during object creation, after setting all properties.
function LB_destiny_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LB_destiny (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PB_flip.
function PB_flip_Callback(hObject, eventdata, handles)
% hObject    handle to PB_flip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
w = 1;
while w==1
    % find first segment
    [x,y,w] =fastGinput(1);
    if w==1
        [i1,j1] = findClosest(handles,x,y);
        handles.layers(i1).line{j1} = flipud(handles.layers(i1).line{j1});
        handles = updatePlot(handles);
        guidata(hObject,handles);
    end
end



% --- Executes on button press in CB_rbbox.
function CB_rbbox_Callback(hObject, eventdata, handles)
% hObject    handle to CB_rbbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_rbbox


% --- Executes on button press in CB_append.
function CB_append_Callback(hObject, eventdata, handles)
% hObject    handle to CB_append (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_append


% --- Executes on button press in PB_deleteLayer.
function PB_deleteLayer_Callback(hObject, eventdata, handles)
% hObject    handle to PB_deleteLayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
iLayer  = layerNr(handles);
buttonName = questdlg('Delete layer');
if strcmpi(buttonName,'yes')
    handles    = deleteLayer(handles,iLayer);
    handles    = updatePlot(handles);
    guidata(hObject,handles);
end

% --- Executes on button press in PB_rest.
function PB_rest_Callback(hObject, eventdata, handles)
% hObject    handle to PB_rest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

buttonName = questdlg('Sure you want to reset? all your changes will be lost.');
if strcmpi(buttonName,'yes')
    handles    = resetEditLines(handles);
    handles    = updatePlot(handles);
    handles.resetAxesLim = true;
    guidata(hObject,handles);
end


% --- Executes during object creation, after setting all properties.
function uipanel2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PB_newLayer.
function PB_newLayer_Callback(hObject, eventdata, handles)
% hObject    handle to PB_newLayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


tmp = inputdlg('Give the name of the new layer');
if isempty(tmp)
    return
end
theName = tmp{1};
handles = newLayer(handles,theName);
handles    = updatePlot(handles);
    guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'toolbar','none');
guidata(hObject,handles);


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% resize the figure is needed

% in this case the axes is resize
newSize = get(gcf, 'pos');

% axPos = get(handles.myPlot,'pos');
% axPos(3:4) = newSize(3:4)./handles.oldSize(3:4);
% set(handles.myPlot,'pos',axPos);


handles.oldSize = newSize;
guidata(hObject,handles);


% --- Executes on button press in PB_deleteSeg.
function PB_deleteSeg_Callback(hObject, eventdata, handles)
% hObject    handle to PB_deleteSeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
w = 1;
while w==1
    % find first segment
    [x,y,w] =fastGinput(1);
    if w==1
        [i1,j1,k1] = findClosest(handles,x,y);
        [x,y,w] =fastGinput(1);
        [i2,j2,k2] = findClosest(handles,x,y);
        if (i1~=i2)||(j1~=j2)
            errordlg('Two different lines selected');
            return
        end
        if (k1==k2)
            errordlg('Select two different points');
            return
        end
        if k1<k2
            mask = k1:k2;
        else
            mask = k2:k1;
        end
%         if sum(mask)>length(x)/2
%             mask2       = true(size(handles.layers(i1).line{j1},1),1);
%             mask2(mask) = false;
%             mask        = mask2;
%         end
        handles.layers(i1).line{j1}(mask,:) = [];
        
        handles = updatePlot(handles);
        guidata(hObject,handles);
    end
end


% --- Executes on button press in PB_undo.
function PB_undo_Callback(hObject, eventdata, handles)
% hObject    handle to PB_undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = resetState(handles);
handles = updatePlot(handles);
guidata(hObject,handles);


% --- Executes on button press in PB_close.
function PB_close_Callback(hObject, eventdata, handles)
% hObject    handle to PB_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
w = 1;
while w==1
    % find first segment
    [x,y,w] =fastGinput(1);
    if w==1
        [i1,j1] = findClosest(handles,x,y);
        x = handles.layers(i1).line{j1}(:,1);
        y = handles.layers(i1).line{j1}(:,2);
        d  = (x(end)-x(1))^2 + (y(end)-y(1))^2;
        if sqrt(d) < 1e-9
            
            errordlg('The line is already closed');
            return;
        end
        % close line
        handles.layers(i1).line{j1}(end+1,:)= handles.layers(i1).line{j1}(1,:);
        
        % update plot
        handles = updatePlot(handles);
        guidata(hObject,handles);
    end
end


% --- Executes on button press in PB_ruler.
function PB_ruler_Callback(hObject, eventdata, handles)
% hObject    handle to PB_ruler (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


UtilPlot.ruler(false);


% --- Executes on button press in PB_resample.
function PB_resample_Callback(hObject, eventdata, handles)
% hObject    handle to PB_resample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
w = 1;
while w==1
    % find first segment
    [x,y,w] =fastGinput(1);
    if w==1
        [i1,j1,k1] = findClosest(handles,x,y);
        [x,y,w] =fastGinput(1);
        [i2,j2,k2] = findClosest(handles,x,y);
        if (i1~=i2)||(j1~=j2)
            errordlg('Two different lines selected');
            return
        end
        if (k1==k2)
            errordlg('Select two different points');
            return
        end
        [k1,k2]= Util.sortVal(k1,k2);
        
        % resample with specified 
        tmp = inputdlg('Give resample distance','Resample');
        if isempty(tmp)
            return
        end
        dxRes = str2double(tmp{1});
        if isnan(dxRes) || dxRes<=0
            errordlg('Invalid value for resampling distance');
            return
        end
            
        x = handles.layers(i1).line{j1}(k1:k2,1);
        y = handles.layers(i1).line{j1}(k1:k2,2);
        
        [x2,y2] = Resample.resamplePolylineEqual(x,y,dxRes);
        tmp =  [x2,y2,zeros(size(x2))];
        handles.layers(i1).line{j1} = [handles.layers(i1).line{j1}(1:k1,:);
                                      tmp(2:end-1,:);
                                      handles.layers(i1).line{j1}(k2:end,:);
                                      ];
        % update 
        handles = updatePlot(handles);
        guidata(hObject,handles);
    end
end

function [threshold, method, cont] = getSimpPar
            % resample with specified
            tmp = inputdlg({'Give simplify tolerance';'Give method; (1: Visvalingam (area based); 2: Opheim (distance based); 3: Douglas (distance based))'},'Simplify');
            if isempty(tmp)
                cont = false;
                return
            end
            threshold = str2double(tmp{1});
            if isnan(threshold) || threshold<=0
                errordlg('Invalid value for resampling distance');
                cont = false;
                return
            end
            method = str2double(tmp{2});
            if isnan(method) || method <1 || method > 3
                errordlg('Invalid value for method');
                cont = false;
                return
            end
            cont = true;


% --- Executes on button press in PB_simplify.
function PB_simplify_Callback(hObject, eventdata, handles)
% hObject    handle to PB_simplify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
if useRbbox(handles)
    [xBox,yBox] = Util.rbboxSelect(gca);
    [indI,indJ] = findPoly (handles,xBox',yBox') ;
    if isempty(indJ)
        msgbox('No lines in bounding box');
        return;
    end
    [threshold, method, cont] = getSimpPar;
    if ~cont
        return;
    end
        
    for j=1:length(indJ)
        x = handles.layers(indI(j)).line{indJ(j)}(:,1);
        y = handles.layers(indI(j)).line{indJ(j)}(:,2);
        switch method
            case 1
                [x2,y2] = PolyLine.simpArea(x,y,threshold);
            case 2
                [x2,y2] = PolyLine.simpPerpendicular (x,y,threshold);
            case 3
                [x2,y2] = PolyLine.simpDp(x,y,threshold);
        end
        handles.layers(indI(j)).line{indJ(j)} =[x2, y2,zeros(size(x2))];
    end
    
    handles = updatePlot(handles);
    guidata(hObject,handles);
    
    
else
    w = 1;
    while w==1
        % find first segment
        [x,y,w] =fastGinput(1);
        if w==1
            [i1,j1,k1] = findClosest(handles,x,y);
            [x,y,w] =fastGinput(1);
            [i2,j2,k2] = findClosest(handles,x,y);
            if (i1~=i2)||(j1~=j2)
                errordlg('Two different lines selected');
                return
            end
            if (k1==k2)
                errordlg('Select two different points');
                return
            end
            [k1,k2]= Util.sortVal(k1,k2);
            
            [threshold, method, cont] = getSimpPar;
            if ~cont 
                return;
            end
            
            x = handles.layers(i1).line{j1}(k1:k2,1);
            y = handles.layers(i1).line{j1}(k1:k2,2);
            switch method
                case 1
                    [x2,y2] = PolyLine.simpArea(x,y,threshold);
                case 2
                    [x2,y2] = PolyLine.simpPerpendicular (x,y,threshold);
                case 3
                    [x2,y2] = PolyLine.simpDp(x,y,threshold);
            end
            tmp = [x2,y2,zeros(size(x2))];
            handles.layers(i1).line{j1} = [handles.layers(i1).line{j1}(1:k1,:);
                tmp(2:end-1,:);
                handles.layers(i1).line{j1}(k2:end,:);
                ];
            % update
            handles = updatePlot(handles);
            guidata(hObject,handles);
        end
    end
end


% --- Executes on button press in PB_insert.
function PB_insert_Callback(hObject, eventdata, handles)
% hObject    handle to PB_insert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
  handles = saveState(handles);
  w = 1;
    while w==1
        % find first segment
        [x,y,w] =fastGinput(1);
        if w==1
            [i1,j1,k1] = findClosestLine(handles,x,y);
            handles.layers(i1).line{j1} = [handles.layers(i1).line{j1}(1:k1,:);
                [x y 0];
                handles.layers(i1).line{j1}(k1+1:end,:);
                ];
            % update
            handles = updatePlot(handles);
            guidata(hObject,handles);
        end
    end


% --- Executes on button press in PB_transform.
function PB_transform_Callback(hObject, eventdata, handles)
% hObject    handle to PB_transform (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
w = 1;
while w==1
    % find first segment
    [x,y,w] =fastGinput(1);
    if w==1
        [i1,j1] = findClosest(handles,x,y);
        tmp = inputdlg({'Dx [?]','Dy [?]','Rotation around center boundaing box: phi [deg]'},'Transform options',1,{'0','0','0'});
        if isempty(tmp)
            return;
        end
        dx =  str2double(tmp{1});
        dy =  str2double(tmp{2});
        phi = str2double(tmp{3});
        if isnan(dx)
            errordlg('Wrong value for dx');
            return
        end
        if isnan(dy)
            errordlg('Wrong value for dy');
            return
        end
        if isnan(phi)
            errordlg('Wrong value for phi');
            return
        end
        % scale to rotate around center of boundarng bopx
        tmpX  = handles.layers(i1).line{j1}(:,1);
        tmpY  = handles.layers(i1).line{j1}(:,2);
        dbX   = (max(tmpX)+min(tmpX))/2;
        dbY   = (max(tmpY)+min(tmpY))/2;
        tmpX  = tmpX-dbX;
        tmpY  = tmpY-dbY;
        tmpX2 = tmpX.*cosd(phi) -tmpY.*sind(phi);
        tmpY2 = tmpX.*sind(phi) +tmpY.*cosd(phi);
        
        handles.layers(i1).line{j1}(:,1) = tmpX2 +dbX + dx;
        handles.layers(i1).line{j1}(:,2) = tmpY2 +dbY + dy;
        
        handles = updatePlot(handles);
        guidata(hObject,handles);
    end
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function loadBackground_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to loadBackground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cFiles ={'*.tif','Geotiff (*.tif)';...
    '*.*','all files (*.*)'};

if isfield(handles,'file')
    [file,path] = uigetfile(cFiles,'Select Grid File',handles.file);
else
    [file,path] = uigetfile(cFiles,'Select Grid File');
end
if ischar(file)
    theFile = fullfile(path,file);
    [~,theName,theType] = fileparts(theFile);    
    % load file
    
    switch  lower(theType)
        case '.tif'
            [C,x,y] = geoimread(theFile);
        case '.asc'
            % arcview ascii
            [x,y,C]    = Import.readArcView(theFile);
        otherwise
            errordlg('This format is not yet programmed');
            return;
    end

    % Plot
    handles = addImage(handles,x,y,C,theName);
    handles = updatePlot(handles);
    
    handles.file = path;
    guidata(hObject,handles);
    
    
end


% --- Executes on button press in PB_convertCoor.
function PB_convertCoor_Callback(hObject, eventdata, handles)
% hObject    handle to PB_convertCoor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

errordlg('Not yet implemented. I will do it later. Or do it yourself');

% --- Executes on button press in CB_showImage.
function CB_showImage_Callback(hObject, eventdata, handles)
% hObject    handle to CB_showImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_showImage

useImage =  get(hObject,'Value');
if useImage && ~isfield(handles,'image')
    errordlg('No image data is loaded. Use the bomb in the toolbar');
    set(hObject,'Value',false);
    guidata(hObject,handles);
    return;
end
handles  = updatePlot(handles,true);
guidata(hObject,handles);


% --- Executes on button press in PB_xyLim.
function PB_xyLim_Callback(hObject, eventdata, handles)
% hObject    handle to PB_xyLim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.resetAxesLim = true;
handles  = updatePlot(handles);
guidata(hObject,handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end


% --- Executes on button press in PB_moveSegment.
function PB_moveSegment_Callback(hObject, eventdata, handles)
% hObject    handle to PB_moveSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
uiwait(msgbox('Click first on two points to get the segment. Then click on two points to get the new points.'));

w = 1;
while w==1
    % find first segment
    [x0,y0,w] =fastGinput(1);
    if w==1
        % find segment
        [i1,j1,k1] = findClosest(handles,x0,y0);
        [x1,y1,w] =fastGinput(1);
        [i2,j2,k2] = findClosest(handles,x1,y1);
        if (i1~=i2)
            errordlg('Two different layers selected');
            return
        end        
        if (j1~=j2)
            errordlg('Two different lines selected');
            return
        end
        if (k1==k2)
            errordlg('Select two different points');
            return
        end
        if k1<k2
            mask = k1:k2;
        else
            mask = k2:k1;
        end
        % find new location
        [x01,y01,w] =fastGinput(1);
        [x11,y11,w] =fastGinput(1);
        %transform data  take care to avoid division by zero
        xTmp = handles.layers(i1).line{j1}(mask,1); 
        yTmp = handles.layers(i1).line{j1}(mask,2);
        xLoc = (xTmp-x0) ./(x1-x0);
        yLoc = (yTmp-y0) ./(y1-y0);
        xTmp2 = x01+(xLoc) .*(x11-x01);
        yTmp2 = y01+(yLoc) .*(y11-y01);
%         if abs(x1-x0)>0
%             t =(xTmp-x0) /(x1-x0);
%         else
%             t =(yTmp-y0) /(y1-y0);
%         end
%         xTmp2 = t.*(x11-x01)+x01;
%         yTmp2 = t.*(y11-y01)+y01;
        % update
        handles.layers(i1).line{j1}(mask,1) = xTmp2;
        handles.layers(i1).line{j1}(mask,2) = yTmp2;
        
       
handles  = updatePlot(handles);
guidata(hObject,handles);
    end
end