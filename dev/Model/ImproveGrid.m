function varargout = ImproveGrid(varargin)
% IMPROVEGRID M-file for ImproveGrid.fig
%      IMPROVEGRID, by itself, creates a new IMPROVEGRID or raises the existing
%      singleton*.
%
%      H = IMPROVEGRID returns the handle to a new IMPROVEGRID or the handle to
%      the existing singleton*.
%
%      IMPROVEGRID('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMPROVEGRID.M with the given input arguments.
%
%      IMPROVEGRID('Property','Value',...) creates a new IMPROVEGRID or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImproveGrid_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImproveGrid_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImproveGrid

% Last Modified by GUIDE v2.5 21-Aug-2019 10:21:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ImproveGrid_OpeningFcn, ...
    'gui_OutputFcn',  @ImproveGrid_OutputFcn, ...
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


% --- Executes just before ImproveGrid is made visible.
function ImproveGrid_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImproveGrid (see VARARGIN)

% Choose default command line output for ImproveGrid
handles.output = hObject;

handles.outline = cell(1,3);
handles.oldSize = get(gcf,'pos');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ImproveGrid wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ImproveGrid_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%--------------------------------------------------------------------------
% for UNDO
function handles = resetState(handles)
if isfield(handles,'prevState')
    if isfield(handles.prevState,'ikle')
        handles.ikle = handles.prevState.ikle;
        handles.xy   =  handles.prevState.xy;
    end
    % nothing done to outline
end



function handles = saveState(handles)
 handles.prevState.ikle  = handles.ikle;
 handles.prevState.xy    = handles.xy;
 
 %-------------------------------------------------------------------------



% --- Executes on button press in PB_LOAD.
function PB_LOAD_Callback(hObject, eventdata, handles)
% hObject    handle to PB_LOAD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



cFiles ={'*.t3s','Blue Kanoo grid (*.t3s)';...
    '*.slf','Selafin file (*.slf)';...
    '*.*','all files (*.*)'};

if isfield(handles,'file')
    [file,path] = uigetfile(cFiles,'Select Grid File',handles.file);
else
    [file,path] = uigetfile(cFiles,'Select Grid File');
end
if ischar(file)
    theFile = [path,'',file];
    handles.file = theFile;
    [~,~,ext] = fileparts(theFile);
    % load file
    if strcmpi(ext,'.t3s')
        [handles.xy,handles.ikle] = Telemac.readT3s(theFile);
        if isfield(handles,'sctData')
            handles = rmfield(handles,'sctData');
        end
    elseif strcmpi(ext,'.slf')
        sctData = telheadr(theFile);
        sctData = telstepr(sctData,1);
        handles.sctData = sctData;
        handles.xy   = [sctData.XYZ(:,1:2),sctData.RESULT];
        handles.ikle = sctData.IKLE;
        clear sctData;
    else
        errordlg('Unknown file format');
        return;
    end
    handles.outline = {};
    
    % calc skewness
    
    % plot data
    
    set(gcf,'currentaxes',handles.myPlot)
    cla(handles.myPlot);
    TriangleGui.updatePlot(handles.ikle,handles.xy,@calcSkew,handles.outline)
    
    colorbar;
    grid on;
    axis equal;
    title('equiangle skewness');
    caxis([0 1]);
    
   
    
    guidata(hObject,handles);
end



function theSkewness = calcSkew(ikle, xy)
[~,triAngles]  = Triangle.calcTriangleStat(ikle,xy(:,1),xy(:,2));
theSkewness    = Triangle.calcTriangleSkewness(triAngles);


% --- Executes on button press in PB_save.
function PB_save_Callback(hObject, eventdata, handles)
% hObject    handle to PB_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'file')
    errordlg('No file is loaded yet');
    return;
end
cFiles = {'*.t3s','Blue Kanoo grid (*.t3s)';...
          '*.slf','Selafin file (*.slf)'};
[fileName,pathName] = uiputfile(cFiles,'Select output filename',handles.file);
if ischar(fileName)
    theFile = [pathName,fileName];
     [~,~,ext] = fileparts(theFile);
    
     % save t3s
    if strcmpi(ext,'.t3s')
        Telemac.writeT3s(theFile,handles.ikle,handles.xy);
    % save slf    
    elseif strcmpi(ext,'.slf')
        %make data structuer
        ikle = handles.ikle;
        xy   = handles.xy(:,1:2);
        if size(handles.xy)>2
            z = handles.xy(:,3:end);
            nrVar =size(z,2);
            for j=nrVar:-1:1
                prompt{j} = ['Give variable name for variable ',num2str(j)];
            end
            varNames = inputdlg(prompt,'Give variable names');
        else
            z = zeros(size(xy,1),1);
            varNames{1} = 'BOTTOM          M';
        end
        sctTel = Telemac.makeSct(ikle,xy,z,varNames,datenum([1979 4 15 0 0 0]),'Mesh made by ImproveGrid',1);
        % save
        fid = telheadw(sctTel,theFile);
        fid = telstepw(sctTel,fid);
        fclose(fid);
        
    end
end

% --- Executes on button press in PB_grid.
function PB_grid_Callback(hObject, eventdata, handles)
% hObject    handle to PB_grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles = saveState(handles);

handles.xy(:,[1 2]) = TriangleGui.movePoint(handles.ikle,handles.xy(:,[1 2]),@calcSkew,handles.outline);
handles = showMesh(handles);
guidata(hObject,handles);


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


% --- Executes on button press in PB_LoadOverLay.
function PB_LoadOverLay_Callback(hObject, eventdata, handles)
% hObject    handle to PB_LoadOverLay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



cFiles ={'*.i2s','Blue Kanoo line (*.i2s)';...
    '*.*','all files (*.*)'};

if isfield(handles,'file')
    [file,path] = uigetfile(cFiles,'Select Grid File',handles.file);
else
    [file,path] = uigetfile(cFiles,'Select Grid File');
end
if ischar(file)
    theFile = [path,'',file];
    % load file
    handles.outline{1} = Telemac.readKenue(theFile);
    % Plot
    cla(handles.myPlot);
    TriangleGui.updatePlot(handles.ikle,handles.xy,@calcSkew,handles.outline)
    handles = showMesh(handles);
    guidata(hObject,handles);
end




% --- Executes on button press in PB_addTriangle.
function PB_addTriangle_Callback(hObject, eventdata, handles)
% hObject    handle to PB_addTriangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% adds triangle from existing points


handles = saveState(handles);

if isfield(handles,'outline')
    [handles.ikle,handles.xy] = TriangleGui.addTriangle(handles.ikle,handles.xy,@calcSkew,3,handles.outline);
else
    [handles.ikle,handles.xy] = TriangleGui.addTriangle(handles.ikle,handles.xy,@calcSkew,3);
end
handles = showMesh(handles);
guidata(hObject,handles);


% --- Executes on button press in PB_Triangle_New.
function PB_Triangle_New_Callback(hObject, eventdata, handles)
% hObject    handle to PB_Triangle_New (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% adds traingle with one new point


handles = saveState(handles);

if isfield(handles,'outline')
    [handles.ikle,handles.xy] = TriangleGui.addTriangle(handles.ikle,handles.xy,@calcSkew,2,handles.outline);
else
    [handles.ikle,handles.xy] = TriangleGui.addTriangle(handles.ikle,handles.xy,@calcSkew,2);
end
handles = showMesh(handles);
guidata(hObject,handles);


% --- Executes on button press in PB_Delete.
function PB_Delete_Callback(hObject, eventdata, handles)
% hObject    handle to PB_Delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%deletes a triangle


handles = saveState(handles);

[handles.ikle,handles.xy] = TriangleGui.deleteTriangle(handles.ikle,handles.xy,@calcSkew,handles.outline);
handles = showMesh(handles);
guidata(hObject,handles);


% --- Executes on button press in PB_Hist.
function PB_Hist_Callback(hObject, eventdata, handles)
% hObject    handle to PB_Hist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[theLength,theAngle]  =  Triangle.calcTriangleStat(handles.ikle,handles.xy(:,1),handles.xy(:,2));
theSkewness  = Triangle.calcTriangleSkewness(theAngle);

theThreshold = str2double(get(handles.ET_Threshold,'string'));

% length and angle
figure('pos',[100 100 1200 800]);
subplot(1,2,1)
hist(nanmean(theLength,2),100)
xlabel('Avergage grid length (m)');
ylabel('Nr of occurrances');grid on;

h2 = subplot(1,2,2);
hist(theSkewness,100)
hold on;
plot([theThreshold,theThreshold],get(h2,'ylim'))
xlabel('Skewness)');
hold off;grid on;



function ratio = calcElementLength(lengths,Connection)

nrNodes = max(Connection(:));
ratio = nan(nrNodes,1);
for i = 1:nrNodes
    nodes = (Connection==i);
    elements = find(any(nodes,2));
    % determine lines
    nrElements = length(elements);
    if nrElements>0
        allLengths = zeros(nrElements,2);
        
        for j=1:nrElements
            theElement = nodes(elements(j),:);
            switch find(theElement)
                case 1
                    allLengths(j,1) = lengths(elements(j),1);
                    allLengths(j,2) = lengths(elements(j),3);
                case 2
                    allLengths(j,1) = lengths(elements(j),1);
                    allLengths(j,2) = lengths(elements(j),2);
                case 3
                    allLengths(j,1) = lengths(elements(j),2);
                    allLengths(j,2) = lengths(elements(j),3);
            end
        end
        ratio (i) = max(allLengths(:))./min(allLengths(:));
    end
end




% --- Executes on button press in PB_ShowLength.
function PB_ShowLength_Callback(hObject, eventdata, handles)
% hObject    handle to PB_ShowLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



[theLength,theAngle]  = Triangle.calcTriangleStat(handles.ikle,handles.xy(:,1),handles.xy(:,2));
set(gcf,'currentaxes',handles.myPlot)
switch get(hObject,'string')
    case 'Show length'
        set(hObject,'string','Show skewness')
        handles.Colordata = mean(theLength,2);
        Plot.plotTriangle(handles.xy(:,1),handles.xy(:,2),handles.Colordata,handles.ikle);
        maxLength = max(theLength(:));
        nHunderds = 10^floor(log10(maxLength));
        maxLength = nHunderds*ceil(maxLength/nHunderds);
        title('mean grid size');caxis([0 maxLength]);colormap('jet');
    case 'Show skewness'
        handles.Colordata  = Triangle.calcTriangleSkewness(theAngle);
        set(hObject,'string','Show nr elements')
        Plot.plotTriangle(handles.xy(:,1),handles.xy(:,2),handles.Colordata,handles.ikle);
        title('equiangle skewness');caxis([0 1]);colormap('jet');
    case 'Show nr elements'
        h = waitbar(0,'counting nr of elements');
        handles.Colordata  = Triangle.calcNrElements(handles.ikle,handles.xy);
        close(h);
        set(hObject,'string','Show length ratio (node)')
        Plot.plotTriangle(handles.xy(:,1),handles.xy(:,2),handles.Colordata,handles.ikle);clim = ([0.5 max(handles.Colordata)+0.5]);caxis(clim);
        title('Nr elements');
        colormap(jet(floor(clim(2))));
    case 'Show length ratio (node)'
        handles.Colordata  = max(theLength,[],2)./min(theLength,[],2);
        set(hObject,'string','Show length ratio (element)')
        Plot.plotTriangle(handles.xy(:,1),handles.xy(:,2),handles.Colordata,handles.ikle);
        title('Length ratio (per node)');
        clim = ([0 ceil(max(handles.Colordata))]);caxis(clim);
        colormap(jet(clim(2)+1));
    case 'Show length ratio (element)'
        h = waitbar(0,'calculating length ratio');
        handles.Colordata  = calcElementLength(theLength,handles.ikle);
        close (h);
        set(hObject,'string','Show circumcenter ratio')
        Plot.plotTriangle(handles.xy(:,1),handles.xy(:,2),handles.Colordata,handles.ikle);
        title('Length ration (per element)');
        clim = ([0 ceil(max(handles.Colordata))]);caxis(clim);
        colormap(jet(clim(2)+1));
    case 'Show circumcenter ratio'
        handles.Colordata  =  Triangle.circumcenterRadius(handles.ikle,handles.xy)./min(theLength,[],2);
        set(hObject,'string','Show length')
        Plot.plotTriangle(handles.xy(:,1),handles.xy(:,2),handles.Colordata,handles.ikle);
        title('Circum center ratio');
        %clim = ([0 1]);caxis(clim);
        colormap('jet');
end


if isfield(handles,'outline')
    hold on;
    % lines
    if ~isempty(handles.outline{1})
        for i=1:length(handles.outline{1})
            plot(handles.outline{1}{i}(:,1),handles.outline{1}{i}(:,2),'-r','linewidth',3)
        end
    end
    %points
    if ~isempty(handles.outline{2})
        for i=1:length(handles.outline{2})
            plot(handles.outline{2}{i}(:,1),handles.outline{2}{i}(:,2),'*r','markersize',5)
        end
    end
    hold off;
end

shading flat;
colorbar;
grid on;
axis equal;
guidata(hObject,handles);


% --- Executes on button press in PB_Outliers.
function PB_Outliers_Callback(hObject, eventdata, handles)
% hObject    handle to PB_Outliers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


theThreshold = str2double(get(handles.ET_Threshold,'string'));
[~,theAngle]  = Triangle.calcTriangleStat(handles.ikle,handles.xy(:,1),handles.xy(:,2));
theSkewness  = Triangle.calcTriangleSkewness(theAngle);

wrongElement = find(theSkewness>theThreshold);
xyWrong = zeros(length(wrongElement),2);
% calculation of centroid
for i=1:length(wrongElement)
    xyWrong(i,:) =  mean(handles.xy(handles.ikle(wrongElement(i),:),1:2),1);
end
handles.outline{3} = {};
handles.outline{3}{1}.x = xyWrong(:,1);
handles.outline{3}{1}.y = xyWrong(:,2);
handles.outline{3}{1}.marker = 'rs';
handles.outline{3}{1}.legend = {'High skewness elements'};
guidata(hObject,handles);

cla(handles.myPlot);
TriangleGui.updatePlot(handles.ikle,handles.xy,@calcSkew,handles.outline)



function ET_Threshold_Callback(hObject, eventdata, handles)
% hObject    handle to ET_Threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ET_Threshold as text
%        str2double(get(hObject,'String')) returns contents of ET_Threshold as a double


% --- Executes during object creation, after setting all properties.
function ET_Threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ET_Threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PB_rubbish.
function PB_rubbish_Callback(hObject, eventdata, handles)
% hObject    handle to PB_rubbish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);

% deletes all triangles
nThreshold = 0.01;




theLength  = Triangle.calcTriangleStat(handles.ikle,handles.xy(:,1),handles.xy(:,2));
theMask = min(theLength,[],2) < nThreshold;
%

% delete triangles
[handles.ikle,handles.xy] = Triangle.deleteTri(handles.ikle,handles.xy,theMask);

% plot again
cla(handles.myPlot);
TriangleGui.updatePlot(handles.ikle,handles.xy,@calcSkew,handles.outline)


msgbox(['Nr of deleted triangles: ',num2str(sum(theMask))],'Deleting small triangles');

guidata(hObject,handles);


% --- Executes on button press in PB_delete_many.
function PB_delete_many_Callback(hObject, eventdata, handles)
% hObject    handle to PB_delete_many (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
[handles.ikle,handles.xy] = TriangleGui.deleteManyTriangles(handles.ikle,handles.xy,@calcSkew,handles.outline);
guidata(hObject,handles);


% --- Executes on button press in PB_points.
function PB_points_Callback(hObject, eventdata, handles)
% hObject    handle to PB_points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



theFiles ={'*.xyz','Blue Kanoo point (*.xyz)';...
    '*.*','all files (*.*)'};

if isfield(handles,'file')
    [file,path] = uigetfile(theFiles,'Select Point File',handles.file);
else
    [file,path] = uigetfile(theFiles,'Select Point File');
end
if ischar(file)
    theFile = [path,'',file];
    % load file
    handles.outline{2} = Telemac.readKenue(theFile);
    % Plot
    set(gcf,'currentaxes',handles.myPlot)
    cla(handles.myPlot);
    TriangleGui.updatePlot(handles.ikle,handles.xy,@calcSkew,handles.outline)
    
    guidata(hObject,handles);
end


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


% --- Executes on button press in PB_mark_bad.

% --- Executes on button press in PB_mark_bad.
function PB_mark_bad_Callback(hObject, eventdata, handles)
% hObject    handle to PB_mark_bad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[theLength,theAngle]  = Triangle.calcTriangleStat(handles.ikle,handles.xy(:,1),handles.xy(:,2));

% calculate problems with angles

maskAngle = any(theAngle>0.5*pi,2);

% calculate difference in length of triangles

maskLength = (max(theLength,[],2)./min(theLength,[],2)) > 3;


% plot

% middle point of triangles
xTri = Triangle.triangleAverage(handles.ikle,handles.xy(:,1));
yTri = Triangle.triangleAverage(handles.ikle,handles.xy(:,2));
handles.outline{3} ={};
handles.outline{3}{1}.x = xTri(maskAngle);
handles.outline{3}{1}.y = yTri(maskAngle);
handles.outline{3}{1}.marker = '<r';
handles.outline{3}{2}.x = xTri(maskLength);
handles.outline{3}{2}.y = yTri(maskLength);
handles.outline{3}{2}.marker = '<g';
handles.outline{3}{1}.legend = {'angle > 90 deg','length ration > 3'};
guidata(hObject,handles);

cla(handles.myPlot);
TriangleGui.updatePlot(handles.ikle,handles.xy,@calcSkew,handles.outline)



% --- Executes on button press in PB_edge.
function PB_edge_Callback(hObject, eventdata, handles)
% hObject    handle to PB_edge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% calculate problems with areas of triangles

area = Triangle.triangleArea(handles.ikle,handles.xy);

[indexTri,nrEdge] = Triangle.findEdge(handles.ikle);

% look for wrong areas
maskArea = false(length(nrEdge),1);
theArea = zeros(length(nrEdge),1);

for i =1:length(nrEdge)
    index = indexTri(i,:);
    index(isnan(index)) = [];
    if ~isempty(index)
        areaRatio = area(i)./area(index);
        areaRatio(areaRatio<1) = 1./areaRatio(areaRatio<1);
        maskArea(i) = max(areaRatio)>3;
        theArea(i) = max(areaRatio);
    end
end


% plot

% middle point of triangles
xTri = Triangle.triangleAverage(handles.ikle,handles.xy(:,1));
yTri = Triangle.triangleAverage(handles.ikle,handles.xy(:,2));
hold on;
handles.outline{3} = {};
handles.outline{3}{1}.x      = xTri(maskArea);
handles.outline{3}{1}.y      = yTri(maskArea);
handles.outline{3}{1}.marker = 'sr';
handles.outline{3}{1}.legend = {'area ratio > 3'};
guidata(hObject,handles);

cla(handles.myPlot);
TriangleGui.updatePlot(handles.ikle,handles.xy,@calcSkew,handles.outline)



% --- Executes on button press in PB_nrCon.
function PB_nrCon_Callback(hObject, eventdata, handles)
% hObject    handle to PB_nrCon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



nrPoints = size(handles.xy,1);
connect = zeros(nrPoints,1);
hWait = waitbar(0,'counting connections');
for i=1:nrPoints
    connect(i) = sum(handles.ikle(:)==i);
    if mod(100*i,nrPoints)==0
        waitbar(i/nrPoints,hWait);
    end
end
close(hWait);

% calculate nr of connections

maxConnect = max(connect);

% plot
%Plot.plotTriangle(handles.xy(:,1),handles.xy(:,2),connect,handles.ikle);
%shading flat;
mask = (connect == maxConnect);
handles.outline{3}={};
handles.outline{3}{1}.x = handles.xy(mask,1);
handles.outline{3}{1}.y = handles.xy(mask,2);
handles.outline{3}{1}.marker = 'or';
handles.outline{3}{1}.legend = ['Elements with ',num2str(maxConnect),' connections'];

guidata(hObject,handles);
cla(handles.myPlot);
TriangleGui.updatePlot(handles.ikle,handles.xy,@calcSkew,handles.outline)


% --- Executes on button press in PB_del_all_outliers.
function PB_del_all_outliers_Callback(hObject, eventdata, handles)
% hObject    handle to PB_del_all_outliers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);

% callculate outliers
theThreshold = str2double(get(handles.ET_Threshold,'string'));
[~,theAngle]  = Triangle.calcTriangleStat(handles.ikle,handles.xy(:,1),handles.xy(:,2));
theSkewness  = Triangle.calcTriangleSkewness(theAngle);
mask = (theSkewness >= theThreshold);

[handles.ikle,handles.xy] = Triangle.deleteTri(handles.ikle,handles.xy,mask);

% plot gain
set(gcf,'currentaxes',handles.myPlot)
cla(handles.myPlot);
handles.outline{3} = {};

cla(handles.myPlot);
TriangleGui.updatePlot(handles.ikle,handles.xy,@calcSkew,handles.outline)


guidata(hObject,handles);
msgbox(['Nr of deleted elements',num2str(sum(mask))],'delete outliers')


function [xOver,yOver,maskOver] = overCon(handles)

ikle = double(handles.ikle);
xy   = handles.xy;
maskOver = Triangle.getOverConAll(ikle,xy);
xOver = (xy(ikle(maskOver,1),1)+xy(ikle(maskOver,2),1)+xy(ikle(maskOver,3),1))/3;
yOver = (xy(ikle(maskOver,1),2)+xy(ikle(maskOver,2),2)+xy(ikle(maskOver,3),2))/3;


% --- Executes on button press in PB_overConstr.
function PB_overConstr_Callback(hObject, eventdata, handles)
% hObject    handle to PB_overConstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[xOver,yOver] = overCon(handles);

% add data
handles.outline{3} = {};
handles.outline{3}{1}.x = xOver;
handles.outline{3}{1}.y = yOver;
handles.outline{3}{1}.marker = 'hr';
handles.outline{3}{1}.legend = {'Overconstraint elements'};
guidata(hObject,handles);

% plot
cla(handles.myPlot);
TriangleGui.updatePlot(handles.ikle,handles.xy,@calcSkew,handles.outline)
handles = showMesh(handles);
guidata(hObject,handles);


msgbox(['Nr of overconstrained triangles: ',num2str(length(xOver))]);

% --- Executes on button press in PB_show_double.
function PB_show_double_Callback(hObject, eventdata, handles)
% hObject    handle to PB_show_double (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


ikle = handles.ikle;
xy   = handles.xy;
hWait = waitbar(0,'Determining double elements');
indDouble = Triangle.getDoubleElements(ikle);
xDouble = xy(indDouble,1);
yDouble = xy(indDouble,2);
close(hWait);

% add data
handles.outline{3} = {};
handles.outline{3}{1}.x = xDouble;
handles.outline{3}{1}.y = yDouble;
handles.outline{3}{1}.marker = '*r';
handles.outline{3}{1}.legend = {'Double elements'};
guidata(hObject,handles);

% plot
cla(handles.myPlot);
TriangleGui.updatePlot(handles.ikle,handles.xy,@calcSkew,handles.outline)

msgbox(['Nr of double triangles: ',num2str(sum(indDouble))]);


% --- Executes on button press in PB_thinBarrier.
function PB_thinBarrier_Callback(hObject, eventdata, handles)
% hObject    handle to PB_thinBarrier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);

THRESHOLD = 1e5; % 100 km
shiftDist = 0.01; % 1 cm Too big?
VERY_HIGH = 1e9;
VERY_SMALL = 1e-2;
BB_EXTRA   = 1e5; % 100 km;

shading faceted;
ikle = handles.ikle;
xy   = handles.xy;

% get the tickness
thicknessStr = inputdlg('Give the thickness of the thin barrier in m.','Input thickbess',1,{num2str(shiftDist)});
shiftDist   =  str2double(thicknessStr);
if isnan(shiftDist)
    errordlg('The input is not a valid thickness.','Thin barrier');
    shading flat;
    return
end


% prepare mesh info (boundary and edges)

t3sTri    = triangulation(double(ikle), xy(:,1), xy(:,2));
obcPoints = freeBoundary(t3sTri);
edgeLines = edges(t3sTri);

% click on points; at least 3
xList = [];
yList = [];
pointList = [];
nrPoint = 0;
while 1
    % read points until right mouse botton is pressed
    [x,y,w] = fastGinput(1);
    if w~=1
        break
    end
    % find points on the mesh and save
    
    [theInd,minDist] = TriangleGui.getDist(xy(:,1),xy(:,2),[x y]);
    if minDist>THRESHOLD
        msgbox(['No point found within ',num2str(THRESHOLD/1e3),' km from the mouse point.'],'Thin barrier');
    end
    
    
    if nrPoint~=0
        % find points in between clicked points
        
        % line connection the points
        xyL = xy([pointList(nrPoint),theInd],:);
        dx = diff(xyL(:,1));
        dy = diff(xyL(:,2));
        ds = sqrt(dx^2 +dy^2);
        dx = dx/ds;
        dy = dy/ds;
        nx = -dy;
        ny = dx;
        
        % look for points in between
        indP = pointList(nrPoint);
        while 1
            % look for all connecting poins
            mask   = any(edgeLines==indP,2);
            points = setxor(unique(edgeLines(mask,:)),indP);
            x = xy(indP,1);
            y = xy(indP,2);
            % find the closest point on an edge in the right direction
            isLeft = PolyLine.leftOf(x+[0 nx],y+[0 ny],xy(points,1),xy(points,2));
            points = points(~isLeft);
            if isempty(points)
                errordlg('No correct points can be found','Thin barrier');
                if nrPoint>1
                    delete(hTmp);
                end
                shading flat;
                return
            end
            dist = PolyLine.dist2line(xy(points,:),xyL(:,[1:2]));
            
            % add data to list
            [~,indTmp] = min(dist);
            indP = points(indTmp);
            nrPoint = nrPoint +1;
            pointList = [pointList,indP];
            dis2end = sqrt(sum(xy(theInd,:)-xy(indP,:)).^2);
            
            % stop if final point is reached
            if (dis2end<VERY_SMALL)
                break;
            end
        end
        
        
        
    else
        % do nothing for the first point
        nrPoint = nrPoint+1;
        pointList = [pointList,theInd];
    end
    hold on;
    hTmp = plot(xy(pointList,1),xy(pointList,2),'o-r');
end
hold off;

% process
if nrPoint>=3
    % check that the points are on edges
    for i=2:nrPoint
        maskElm = any(ikle==pointList(i-1),2) & any(ikle==pointList(i),2);
        if sum(maskElm)==0
            errordlg(['Points ',num2str(i-1),' and ',num2str(i), ' do not share an edge.'],'Thin barrier');
            if nrPoint>1
                delete(hTmp);
            end
            shading flat;
            return
        end
    end
    
    % check if points are on a boundary
    
    
    % check start and end points
    if any(pointList(1)==obcPoints(:))
        startsOnObc = true;
    else
        startsOnObc = false;
    end
    if any(pointList(end)==obcPoints(:))
        endsOnObc = true;
    else
        endsOnObc = false;
    end
    % check points in the middle
    for i=2:nrPoint-1
        if any(pointList(i)==obcPoints(:))
            errordlg(['Point ',num2str(i),' is on a boundary. This is not allowed'],'Thin barrier');
            if nrPoint>1
                delete(hTmp);
            end
            shading flat;
            return
        end
    end
    
    
    % add extra points and move them
    nrXy= size(xy,1);
    nrRow = size(xy,2);
    xL = xy(pointList,1);
    yL = xy(pointList,2);
    xyTmp = zeros(nrPoint-2+startsOnObc+endsOnObc,nrRow);
    
    % add start and end points in case they are on the boundary
    if startsOnObc
        dx = xL(2)-xL(1);
        dy = yL(2)-yL(1);
        ds = sqrt(dx^2+dy^2);
        nx  = -dy/ds;
        ny  = dx/ds;
        iP = pointList(1);
        xyTmp(1)   = xy(iP,1)-nx*shiftDist;
        xyTmp(1,2)   = xy(iP,2)-ny*shiftDist;
        xyTmp(1,3:end)   = xy(iP,3:end);
        xy(iP,1)  = xy(iP,1)+nx*shiftDist;
        xy(iP,2)  = xy(iP,2)+ny*shiftDist;
    end
    
    % points in between
    for i=2:nrPoint-1
        dx = xL(i+1)-xL(i-1);
        dy = yL(i+1)-yL(i-1);
        ds = sqrt(dx^2+dy^2);
        nx  = -dy/ds;
        ny  = dx/ds;
        iP = pointList(i);
        xyTmp(i-1+startsOnObc,1)   = xy(iP,1)-nx*shiftDist;
        xyTmp(i-1+startsOnObc,2)   = xy(iP,2)-ny*shiftDist;
        xyTmp(i-1+startsOnObc,3:end)   = xy(iP,3:end);
        xy(iP,1)  = xy(iP,1)+nx*shiftDist;
        xy(iP,2)  = xy(iP,2)+ny*shiftDist;
    end
    
    if endsOnObc
        dx = xL(end)-xL(end-1);
        dy = yL(end)-yL(end-1);
        ds = sqrt(dx^2+dy^2);
        nx  = -dy/ds;
        ny  = dx/ds;
        iP = pointList(end);
        xyTmp(nrPoint-1+startsOnObc,1) = xy(iP,1)-nx*shiftDist;
        xyTmp(nrPoint-1+startsOnObc,2) = xy(iP,2)-ny*shiftDist;
        xyTmp(nrPoint-1+startsOnObc,3:end) = xy(iP,3:end);
        xy(iP,1)  = xy(iP,1)+nx*shiftDist;
        xy(iP,2)  = xy(iP,2)+ny*shiftDist;
    end
    xy = [xy;xyTmp];
    
    if startsOnObc
        newPointList = nrXy+(1:nrPoint);
    else
        newPointList = [0,nrXy+(1:nrPoint-1)];
    end
    
    
    % check self intersection of inputdata
    xSelf = intersections(xL,yL);
    if ~isempty(xSelf)
        errordlg('Selected points intersect. This is not allowed.','Thin barrier');
        if nrPoint>1
            delete(hTmp);
        end
        shading flat;
        return
    end
    
    % find elements find the specified node and change them depending on
    % the side of the line
    
    % make a polyline using the intersction of the bouning box and the
    % digitized segment
    [xBb,yBb] = PolyLine.boundingBox(xy(:,1),xy(:,2));
    xBb = xBb+[-1,1,1,-1,-1]'.*BB_EXTRA;
    yBb = yBb+[-1,-1,1,1,-1]'.*BB_EXTRA;
    polyLine  = PolyLine.leftOfPrepare(xL,yL,xBb,yBb);
    
    % now check whether the move poinrt in in the polyline  and the
    % centroid of the adjaced one as well. if both are in the polygon, the
    % connection needs to be moved
    
    % move start point
    if startsOnObc
        ikle = shiftElement(ikle,xy,pointList,newPointList,polyLine,1);
    end
    
    for i=2:nrPoint-1
        ikle = shiftElement(ikle,xy,pointList,newPointList,polyLine,i);
    end
    
    % move end point
    if endsOnObc
        ikle = shiftElement(ikle,xy,pointList,newPointList,polyLine,nrPoint);
    end
    
    
else
    if nrPoint>1
        delete(hTmp);
    end
    errordlg('At least three nodes are needed','Thin barrier');
    shading flat;
    return
    
end

%shading flat;
% save mesh (no new plot needed yet)
% cla(handles.myPlot);
% TriangleGui.updatePlot(handles.ikle,handles.xy,@calcSkew,handles.outline)

handles.ikle = ikle;
handles.xy = xy;

% update plot
cla(handles.myPlot);
TriangleGui.updatePlot(handles.ikle,handles.xy,@calcSkew,handles.outline)


guidata(hObject,handles);


function ikle = shiftElement(ikle,xy,pointList,newPointList,polyLine,i)
% changes the connection table depending on whether a points is on a
% side of a polyline
% private helper function
maskElm = find(any(ikle==pointList(i),2));
nrElem = length(maskElm);
xMoved = xy(pointList(i),1);
yMoved = xy(pointList(i),2);
pointInP = inpoly([xMoved,yMoved],polyLine);
for j=1:nrElem
    % centroid of element
    iCol  = maskElm(j);
    iElem =  ikle(iCol,:);
    xC = sum(xy(iElem,1))/3;
    yC = sum(xy(iElem,2))/3;
    
    % check whether in polygon
    elementInP = inpoly([xC,yC],polyLine);
    
    %check if it should be moved
    changePoint = xor(pointInP,elementInP) ;
    if changePoint
        ind = ikle(iCol,:)==pointList(i);
        ikle(iCol,ind) = newPointList(i);
    end
end


% --- Executes on button press in PB_Mesh.
function PB_Mesh_Callback(hObject, eventdata, handles)
% hObject    handle to PB_Mesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% sets zooming of the data
switch get(handles.PB_Mesh,'string')
    case 'Show mesh lines'
        set(handles.PB_Mesh,'string','Hide mesh lines')
        shading faceted
    case 'Hide mesh lines'
        set(handles.PB_Mesh,'string','Show mesh lines')
        shading flat
end
guidata(hObject,handles);

function handles = showMesh(handles)
% show mesh; depending on the button. This is used by all other plot
% functions
switch get(handles.PB_Mesh,'string')
    case 'Show mesh lines'
        shading flat;
    case 'Hide mesh lines'
        shading faceted;
end




% --- Executes on button press in PB_deleteDoublePoint.
function PB_deleteDoublePoint_Callback(hObject, eventdata, handles)
% hObject    handle to PB_deleteDoublePoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);

tmp = inputdlg('Define maximum distance for a node to be equal in meter', 'Threshold', 1, {'1'});
threshold = str2double(tmp{1});
if isnan(threshold)
    errordlg('Not a valid threshold value');
    return
end
hWait = waitbar(0,'Deleting double nodes');
orgSize = size(handles.xy,1);
[handles.ikle,handles.xy] = Triangle.deleteDoubleNode(handles.ikle,handles.xy,threshold,hWait);
close(hWait);

guidata(hObject,handles);

% update plot
cla(handles.myPlot);
TriangleGui.updatePlot(handles.ikle,handles.xy,@calcSkew,handles.outline)
handles = showMesh(handles);
guidata(hObject,handles);

newSize = size(handles.xy,1);
nrDeleted = -newSize+orgSize;
msgbox(['Nr of deleted nodes: ',num2str(nrDeleted)]);


% --- Executes on button press in PB_overlay.
function PB_overlay_Callback(hObject, eventdata, handles)
% hObject    handle to PB_overlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles = saveState(handles);
THRESHOLD = 0.001.^2;

ikle = handles.ikle;
nrElem = size(ikle,1);
xy   = handles.xy;

xyC  = Triangle.centerGravity(xy,ikle);
doubleElemList = zeros(nrElem,1);
n = 0;

% look for elements with the same centroid
hWait = waitbar(0,'Looking for double elements');
for i=1:nrElem
    if mod(i,100)==0
        waitbar(i/nrElem,hWait)
    end
    % only look once
    if n>0 && any(doubleElemList(1:n)==i)
        continue
    end
    dist = (xyC(i,1)-xyC(:,1)).^2 + (xyC(i,2)-xyC(:,2)).^2;
    mask = dist < THRESHOLD;
    if sum(mask)>1
        doubleElem = setdiff(find(mask),i);
        nrDouble = length(doubleElem);
        doubleElemList(n+1:n+nrDouble) = doubleElem;
        n = n + nrDouble;
    end
end
close(hWait);
% delete unused numbers
doubleElemList(doubleElemList==0) = [];

% plotting
nrDoubleElem = length(doubleElemList);
if nrDoubleElem > 1
    xDouble  = xyC(doubleElemList,1);
    yDouble  = xyC(doubleElemList,2);
    % add data
    handles.outline{3} = {};
    handles.outline{3}{1}.x = xDouble;
    handles.outline{3}{1}.y = yDouble;
    handles.outline{3}{1}.marker = '*r';
    handles.outline{3}{1}.legend = {'Double elements'};
    
    % delete from mesh
    [handles.ikle,handles.xy] = Triangle.deleteTri(handles.ikle,handles.xy,doubleElemList);
    guidata(hObject,handles);
    
    % plot
    cla(handles.myPlot);
    TriangleGui.updatePlot(handles.ikle,handles.xy,@calcSkew,handles.outline)
end

msgbox(['Number of double elements deleted: ',num2str(nrDoubleElem)]);


% % --------------------------------------------------------------------
% function uipushtool3_ClickedCallback(hObject, eventdata, handles)
% % hObject    handle to uipushtool3 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% PB_LOAD_Callback(hObject, eventdata, handles)


% --- Executes on button press in PB_deleteOver.
function PB_deleteOver_Callback(hObject, eventdata, handles)
% hObject    handle to PB_deleteOver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PB_split2.
function PB_split2_Callback(hObject, eventdata, handles)
% hObject    handle to PB_split2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
[handles.ikle,handles.xy] = TriangleGui.splitTriangle(handles.ikle,handles.xy,@calcSkew,2,handles.outline);
guidata(hObject,handles);



% --- Executes on button press in PB_split3.
function PB_split3_Callback(hObject, eventdata, handles)
% hObject    handle to PB_split3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
[handles.ikle,handles.xy] = TriangleGui.splitTriangle(handles.ikle,handles.xy,@calcSkew,3,handles.outline);
guidata(hObject,handles);


% --- Executes on button press in PB_NumericalVertexEdit.
function PB_NumericalVertexEdit_Callback(hObject, eventdata, handles)
% hObject    handle to PB_NumericalVertexEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
handles.xy(:,[1 2]) = TriangleGui.movePointNumerical(handles.ikle,handles.xy(:,[1 2]),@calcSkew,handles.outline);
guidata(hObject,handles);

% --- Executes on button press in PB_undo.
function PB_undo_Callback(hObject, eventdata, handles)
% hObject    handle to PB_undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = resetState(handles);
guidata(hObject,handles);
cla(handles.myPlot);
TriangleGui.updatePlot(handles.ikle,handles.xy,@calcSkew,handles.outline)
handles = showMesh(handles);
guidata(hObject,handles);

% --- Executes on button press in PB_NodeNumberQuery.
function PB_NodeNumberQuery_Callback(hObject, eventdata, handles)
% hObject    handle to PB_NodeNumberQuery (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
handles.xy(:,[1 2]) = TriangleGui.nodeNumberQuery(handles.ikle,handles.xy(:,[1 2]),handles.outline);
guidata(hObject,handles);


% --- Executes on button press in PB_del_overcon.
function PB_del_overcon_Callback(hObject, eventdata, handles)
% hObject    handle to PB_del_overcon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% determine overconstraint elemnts

[xOver,yOver, indOver] = overCon(handles);


% rubber box selection
[xBox,yBox] = Util.rbboxSelect(handles.myPlot);
mask = inpoly([xOver,yOver],[xBox',yBox']);
maskToDel = indOver(mask);
if ~isempty(maskToDel)
    [handles.ikle,handles.xy] = Triangle.deleteTri(handles.ikle,handles.xy,maskToDel);
    
    
    % determine overconstraint again over deleting elements
    
    [xOver,yOver] = overCon(handles);
    
    % add data
    handles.outline{3} = {};
    handles.outline{3}{1}.x = xOver;
    handles.outline{3}{1}.y = yOver;
    handles.outline{3}{1}.marker = 'hr';
    handles.outline{3}{1}.legend = {'Overconstraint elements'};
    guidata(hObject,handles);
    
    % plot
    cla(handles.myPlot);
    TriangleGui.updatePlot(handles.ikle,handles.xy,@calcSkew,handles.outline)
    handles = showMesh(handles);
    guidata(hObject,handles);
end

msgbox([num2str(length(maskToDel)),' overconstraint element deleted!']);


% --- Executes on button press in PB_split4.
function PB_split4_Callback(hObject, eventdata, handles)
% hObject    handle to PB_split4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
[handles.ikle,handles.xy] = TriangleGui.splitManyTriangle(handles.ikle,handles.xy,@calcSkew,4,handles.outline);
handles = showMesh(handles);
guidata(hObject,handles);


% --- Executes on button press in PB_showBoundary.
function PB_showBoundary_Callback(hObject, eventdata, handles)
% hObject    handle to PB_showBoundary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


sct.IKLE = handles.ikle;
sct.XYZ  = handles.xy(:,1:2);
[outLine, xOut,yOut] = Telemac.getBoundary(sct,true);
hold on
for i=1:length(xOut)
    plot(xOut{i},yOut{i},'k-o','linewidth',2);
end

msgbox(['There are ',num2str(length(xOut)),' boundaries.']);
