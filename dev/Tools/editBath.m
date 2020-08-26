%TODO:
% urgent
% -add lines to a line
% -change names of layers
% -better names for saving files
% edit other variables

function varargout = editBath(varargin)
% EDITBATH MATLAB code for editBath.fig
%      EDITBATH, by itself, creates a new EDITBATH or raises the existing
%      singleton*.
%
%      H = EDITBATH returns the handle to a new EDITBATH or the handle to
%      the existing singleton*.
%
%      EDITBATH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDITBATH.M with the given input arguments.
%
%      EDITBATH('Property','Value',...) creates a new EDITBATH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before editBath_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to editBath_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help editBath

% Last Modified by GUIDE v2.5 02-Mar-2020 16:41:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @editBath_OpeningFcn, ...
    'gui_OutputFcn',  @editBath_OutputFcn, ...
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


% --- Executes just before editBath is made visible.
function editBath_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to editBath (see VARARGIN)

% Choose default command line output for editBath
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
try
    addOpenEarth;
catch
end
% UIWAIT makes editBath wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = editBath_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in LB_meshLayer.
function LB_meshLayer_Callback(hObject, eventdata, handles)
% hObject    handle to LB_meshLayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LB_meshLayer contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LB_meshLayer


% --- Executes during object creation, after setting all properties.
function LB_meshLayer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LB_meshLayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in LB_layerTo.
function LB_layerTo_Callback(hObject, eventdata, handles)
% hObject    handle to LB_layerTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LB_layerTo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LB_layerTo


% --- Executes during object creation, after setting all properties.
function LB_layerTo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LB_layerTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in LB_lineLayer.
function LB_lineLayer_Callback(hObject, eventdata, handles)
% hObject    handle to LB_lineLayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LB_lineLayer contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LB_lineLayer


% --- Executes during object creation, after setting all properties.
function LB_lineLayer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LB_lineLayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in LB_dataLayer.
function LB_dataLayer_Callback(hObject, eventdata, handles)
% hObject    handle to LB_dataLayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LB_dataLayer contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LB_dataLayer


% --- Executes during object creation, after setting all properties.
function LB_dataLayer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LB_dataLayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function MENU_file_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MENU_create_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_create (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_14_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_15_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_18_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_24_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function MENU_setConstant_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_setConstant (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 handles = saveState(handles);

inputQuest = {'Set constant or range [1 = constant]; [0 = range (specify min and max)])';
    'Give constant value to use';
    'Give minimum to use';
    'Give maximum to use'};
tmp = inputdlg(inputQuest,'constant value',[1 1 1 1],{'1','0','-99999','99999'});
if isempty(tmp)
    return;
end
useCst = str2double(tmp{1});
if isnan(useCst) || useCst<0 || useCst>1
    errordlg('Invalid input');
    return;
end

if useCst
    cst = str2double(tmp{2});
    if isnan(cst)
        errordlg('Invalid input');
        return;
    end
else
    cstMin = str2double(tmp{3});
    if isnan(cstMin)
        errordlg('Invalid input');
        return;
    end
    cstMax = str2double(tmp{4});
    if isnan(cstMax)
        errordlg('Invalid input');
        return;
    end
end


iLayer = meshLayer(handles);
indBath = getIntBath(handles);
[x,y,z,ikle,name] = getMeshData(handles);


[~,~,mask] = getMaskData(handles);
if numel(mask)~=numel(x)
    errordlg('The mask is on different mesh. Remake the mask for the current mesh.');
    return;
end


if useCst
    handles.meshLayer(iLayer).sctTel.RESULT(mask,indBath) = cst;
else
    z = handles.meshLayer(iLayer).sctTel.RESULT(mask,indBath);
    z = max(z,cstMin);
    z = min(z,cstMax);
    handles.meshLayer(iLayer).sctTel.RESULT(mask,indBath) = z;
end

updateView(handles);
guidata(hObject,handles);

% --------------------------------------------------------------------
function MENU_setMin_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_setMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);


iLayer1 = meshLayer(handles);
iLayer2 = meshLayerTo(handles);
[~,~,z1,~,name1] = getMeshData(handles,iLayer1);
[~,~,z2,~,name2] = getMeshData(handles,iLayer2);

[~,~,mask] = getMaskData(handles);
if numel(mask)~=numel(z1)
    errordlg('The mask is on different mesh. Remake the mask for the current mesh.');
    return;
end

if numel(z1) ~= numel(z2)
    errordlg('Mesh must be the same');
    return;
end
answer = questdlg(['Taking maximum of ',name1,' and ',name2],'Continue');
if strcmpi(answer,'YES')
    z1(mask)= min(z1(mask),z2(mask));
    handles = setMeshData(handles,z1);
    updateView(handles);
    guidata(hObject,handles);
end

% --------------------------------------------------------------------
function MENU_setMax_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_setMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);


iLayer1 = meshLayer(handles);
iLayer2 = meshLayerTo(handles);
[~,~,z1,~,name1] = getMeshData(handles,iLayer1);
[~,~,z2,~,name2] = getMeshData(handles,iLayer2);

[~,~,mask] = getMaskData(handles);
if numel(mask)~=numel(z2)
    errordlg('The mask is on different mesh. Remake the mask for the current mesh.');
    return;
end

if numel(z1) ~= numel(z2)
    errordlg('Mesh must be the same');
    return;
end
answer = questdlg(['Taking maximum of ',name1,' and ',name2],'Continue');
if strcmpi(answer,'YES')
    z1(mask)= max(z1(mask),z2(mask));
    handles = setMeshData(handles,z1);
    updateView(handles);
    guidata(hObject,handles);
end

% --------------------------------------------------------------------
function setEquation_Callback(hObject, eventdata, handles)
% hObject    handle to setEquation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);

iLayer1 = meshLayer(handles);
[handles,indexCon,nrCon]  = getCon(handles);
[x,y,z,ikle,name] = getMeshData(handles,iLayer1); %#ok<ASGLU>
[x2,y2,z2,ikle2,name2] = getMeshData(handles,meshLayerTo(handles)); %#ok<ASGLU>

% TODO add interpolation
answer = inputdlg({'Add equation. Variables to use are x, y, ikle and z, and z2 '},'Add equation',1,{''});
if isempty(answer)
    return;
end
theEq = answer{1};


[~,~,mask] = getMaskData(handles);
if numel(mask)~=numel(x)
    errordlg('The mask is on different mesh. Remake the mask for the current mesh.');
    return;
end


% find closest point
zOut = eval(theEq);
if any(~mask)
    answer = questdlg('Click to select zones');
    if strcmpi(answer,'cancel')
        return;
    else
        useClump = strcmpi(answer,'yes');
    end
    if useClump
        while true
            [xP,yP,wP] = fastGinput(1);
            % stop on right click
            if wP~=1
                break
            end
            [~,indStart] = min((x-xP).^2+(y-yP).^2);
            % select areas
            indClump  =  Triangle.findClump(ikle,[x y],mask,indStart,indexCon,nrCon);
            
            z(indClump) = zOut(indClump);
            handles =setMeshData(handles,z);
            updateView(handles);
            guidata(hObject,handles);
        end
    else
        z(mask) = zOut(mask);
        handles =setMeshData(handles,z);
        updateView(handles);
        guidata(hObject,handles);
    end
else
    
    handles =setMeshData(handles,zOut);
    updateView(handles);
    guidata(hObject,handles);
end


% --------------------------------------------------------------------
function MENU_3dview_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_3dview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get polyline

uiwait(msgbox('Select start and end point of each line you want to use for extracting data. Finish with right mouse button.','Extract data','modal'));
[xPoly,yPoly]  = UserInput.getPoly(true);
xyPoly = [xPoly',yPoly'];
clipboard('copy',xyPoly);

iLayer1 = meshLayer(handles);
[x,y,z,ikle,name] = getMeshData(handles,iLayer1);
[xyz] = [x,y,z];

xyTri = Triangle.centerGravity(xyz(:,1:2),ikle);
mask  = inpoly(xyTri,xyPoly);

[ikle,xyz] = Triangle.getSubset(ikle,xyz,mask);


% make 3D plot
z = xyz(:,3);
xy = xyz(:,1:2);
aFac = 1;
UtilPlot.reportFigureTemplate
trisurf(ikle,xy(:,1),xy(:,2),aFac.*z,z);
axis
colorbar;
shading interp;



% --------------------------------------------------------------------
function MENU_shorProfile_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_shorProfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);

% get polyline
uiwait(msgbox('Select start and end point of each line you want to use for extracting data. Finish with right mouse button.','Extract data','modal'));
[xPoly,yPoly]  = UserInput.getPoly();
clipboard('copy',[xPoly',yPoly']);

% resample
cellAns = inputdlg('Enter resampling distance.','Resample',1,{'10'});
if isempty(cellAns)
    return
end
dx = (str2double(cellAns{1}));
if isnan(dx) || dx<=0.0
    errordlg('Distance is invalid');
    return
end
[xPoly,yPoly,s] = Resample.resamplePolyline(xPoly,yPoly,dx);

% interpolate
[x,y,z,ikle,name] = getMeshData(handles);
sctInterp = Triangle.interpTrianglePrepare(ikle,x,y,xPoly,yPoly);
zInt = Triangle.interpTriangle(sctInterp,z);

% alternative mesh
plotTo = meshLayer(handles)~=meshLayerTo(handles);
if plotTo
    [x,y,z,ikle,name2] = getMeshData(handles,meshLayerTo(handles));
    sctInterp = Triangle.interpTrianglePrepare(ikle,x,y,xPoly,yPoly);
    zInt2 = Triangle.interpTriangle(sctInterp,z);
end


% plot
UtilPlot.reportFigureTemplate
plot(s,zInt,'DisplayName',name)
if plotTo
    hold on;
    plot(s,zInt2,'DisplayName',name2)
    legend;
end
grid on;
xlabel('dist [m]');
ylabel('z [m]')



% --------------------------------------------------------------------
function MENU_filter_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);

% get data
[x,y,z,ikle] = getMeshData(handles);
sctOptions = struct;
% apply mask
answer = questdlg('Use line layer as mask');
switch upper(answer)
    case 'YES'
        [xPoly,yPoly] = getLineData(handles);
        sctOptions.xyPoly = [xPoly{1},yPoly{1}];
    case 'CANCEL'
        return;
end
% filter
z = Triangle.filterTri(ikle,[x,y],z, sctOptions);
iLayer = meshLayer(handles);
indBath = getIntBath(handles);
handles.meshLayer(iLayer).sctTel.RESULT(:,indBath) = z;

%update
updateView(handles);
guidata(hObject,handles);

% --------------------------------------------------------------------
function MENU_smudge_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_smudge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
errordlg('Todo');


function myInterp = makeInterpolator(xP,yP,zP)

% select interpolation method
if isvector(xP)
    question =    {'Give interpolation method [nearest, linear, or natural]';
        'Give extrapolation method [nearest, linear, natural or none]';
        };
else
    question =    {'Give interpolation method [linear, nearest, next, previous, pchip, cubic, makima, or spline. ]';
        'Give extrapolation method [linear, nearest, next, previous, pchip, cubic, makima, spline or none]';
        };
end
answer = inputdlg(question,'Interpolation Method',[1 ;1 ],{'linear';'nearest'},true);
if isempty(answer)
    return;
end
Method = answer{1};
ExtrapolationMethod  = answer{2};

hWait = waitbar(0.5, 'Loading data. The bar is not updated. Sorry.', 'WindowStyle', 'modal');

% interpolator
if isvector(xP)
    mask = isnan(xP)|isnan(yP)|isnan(zP);
    xP = xP(~mask);
    yP = yP(~mask);
    zP = zP(~mask);
    myInterp = scatteredInterpolant(xP,yP,zP,Method,ExtrapolationMethod);
else
    try
        myInterp = griddedInterpolant(xP,yP,zP,Method,ExtrapolationMethod);
    catch
        myInterp = griddedInterpolant(xP',yP',zP',Method,ExtrapolationMethod);
    end
end
close(hWait);


% --------------------------------------------------------------------
function MENU_interpData_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_interpData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);

% get point data
[xP,yP,zP] = getPointData(handles);

% get data
[x,y,z] = getMeshData(handles);

myInterp = makeInterpolator(xP,yP,zP);

% use mask
[~,~,mask] = getMaskData(handles);
if numel(mask)~=numel(x)
    errordlg('The mask is on different mesh. Remake the mask for the current mesh.');
    return;
end



hWait = waitbar(0.5, 'Loading data. The bar is not updated. Sorry.', 'WindowStyle', 'modal');
% interpolate
z(mask) = myInterp(x(mask),y(mask));

iLayer  = meshLayer(handles);
iBath   = getIntBath(handles);
handles.meshLayer(iLayer).sctTel.RESULT(:,iBath) = z;
close(hWait);
%update
updateView(handles);
guidata(hObject,handles);

% --------------------------------------------------------------------
function MENU_interpProfile_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_interpProfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% extract profile
handles = saveState(handles);

uiwait(msgbox('Click to select a profile to extract.'));
[xPoly,yPoly] = UserInput.getPoly();

% resample
answer = inputdlg({'Resampling distance'},'Get distance',[1],{'50'});
if isempty(answer)
    return
end

dx = str2double(answer{1});
if isnan(dx)
    errordlg('Wrong input');
    return
end

[xPoly,yPoly,dPoly] = Resample.resamplePolyline(xPoly,yPoly,dx);
nrPoly = length(xPoly);

% interpolate data
[x,y,z,ikle] = getMeshData(handles);
sctInterp = Triangle.interpTrianglePrepare(ikle,x,y,xPoly,yPoly);
zPoly = Triangle.interpTriangle(sctInterp,z);

%select a line to project the data on

[xTrans,yTrans,~,nameTrans]  = getLineData(handles);

% resample
answer = inputdlg({'Resampling distance along transect'},'Get distance',[1],{'50'});
if isempty(answer)
    return
end

dy = str2double(answer{1});
if isnan(dy)
    errordlg('Wrong input');
    return
end

[xT,yT] = Resample.resamplePolyline(xTrans{1},yTrans{1},dy);

[~,~,ind] = intersections(xPoly,yPoly,xT,yT);
if isempty(ind)
    errordlg('Profiles must intersect. I will change this later');
    return;
end
d0 = interp1(1:length(xPoly),dPoly,ind);
dX = dPoly-d0;

% coordinates of the profiles
[xTnew,yTnew] = PolyLine.crossSections(xT,yT,dX);
nrProf = size(yTnew,2);
% z data

xNew = zeros(nrProf*nrPoly,1);
yNew = zeros(nrProf*nrPoly,1);
zNew = zeros(nrProf*nrPoly,1);
for i = 1:nrProf
    xNew((i-1)*nrPoly+1:i*nrPoly) = xTnew(:,i);
    yNew((i-1)*nrPoly+1:i*nrPoly) = yTnew(:,i);
    zNew((i-1)*nrPoly+1:i*nrPoly) = zPoly;
end

% update
handles = addData(handles,xNew,yNew,zNew,['dataPoints along ',nameTrans]);
updateView(handles);
guidata(hObject,handles);


% --------------------------------------------------------------------
function MENU_createLine_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_createLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);

%uiwait(msgbox('Select start and end point of each line you want to use for extracting data. Finish with right mouse button.','Extract data','modal'));
answer = questdlg('Is the line closed','Closed line');
switch lower(answer)
    case 'yes'
        isClosed = true;
    case 'no'
        isClosed = false;
    otherwise
        return;
end
[xPoly,yPoly]  = UserInput.getPoly(isClosed);
clipboard('copy',[xPoly',yPoly']);
xPoly = {xPoly'};
yPoly = {yPoly'};
zPoly = {ones(size(xPoly))'};

name = inputdlg({'Specify the name of the layer'},'Layer name',1,{'new layer'});
if isempty(name)
    return;
end
name = name{1};
handles = addLine(handles,xPoly,yPoly,zPoly,name);
updateView(handles);
guidata(hObject,handles);


% --------------------------------------------------------------------
function MENU_createSlope_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_createSlope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
% get parameters
question = {'Point resolution [m]';
    'Slope [1/ans] i.e. specify 100 for a slope of 1:100; For upward slope, use a negative number.';
    'Distance x from boundingbox [m]';
    'Distance y from boundingbox [m]';
    'Crest elevation [m]';
    'Slope on [1]: inside; [2]: outside,[3]: both'
    'Equation (use "dist" to give distance to the line) e.g. -2.*exp(-(dist./100).^2))'
    };
answer = inputdlg(question,'makeSlope',[1 1 1 1 1 1 1],{'50','3','1000','1000','0','2',''});
if isempty(answer)
    return;
end

dx =str2double(answer{1});
if isnan(dx)
    errordlg('Wrong inpy for dx')
    return;
end
slope =str2double(answer{2});
if isnan(slope)
    errordlg('Wrong input for slope')
    return;
end
slope = 1/slope;
bbX =str2double(answer{3});
if isnan(bbX)
    errordlg('Wrong input for noundingbox x')
    return;
end
bbY =str2double(answer{4});
if isnan(bbY)
    errordlg('Wrong input for noundingbox y')
    return;
end

crest =str2double(answer{5});
if isnan(crest)
    errordlg('Wrong input for crest')
    return;
end
inOut =str2double(answer{6});
if isnan(inOut)||inOut<1||inOut>3
    errordlg('Wrong input for inOut')
    return;
end
theEq = answer{7};

% get polyline
[xPoly,yPoly,~,name] = getLineData(handles);
xPoly = xPoly{1};
yPoly = yPoly{1};
[xBb,yBb]  = PolyLine.boundingBox(xPoly,yPoly);
xR = xBb(1:2)' +[-bbX,bbX];
yR = yBb(2:3)' +[-bbY,bbY];

[xP,yP] = meshgrid(xR(1):dx:xR(2),yR(1):dx:yR(2));

dist = PolyLine.dist2poly([xP(:),yP(:)],[xPoly,yPoly]);
% select whether slope is on inside or outside of polyline (for closed
% polylines only)
if inOut==1||2 && xPoly(1)==xPoly(end) && yPoly(1)==yPoly(end)
    mask = inpoly([xP(:),yP(:)],[xPoly,yPoly]);
    if inOut ==1
        dist(~mask) = 0;
    else
        dist(mask) = 0;
    end
end

if ~isempty(theEq)
    zP = eval(theEq);
else
    zP = crest - dist.*slope;
end
zP = reshape(zP,size(xP));

% add data layer
name = ['slope of ',name,' (1:',num2str(1/slope),')'];
handles = addData(handles,xP,yP,zP,name);

% update
updateView(handles);
guidata(hObject,handles);



% --------------------------------------------------------------------
function MENU_loadMesh_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_loadMesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if isfield(handles,'theFile')
    defFile = handles.theFile;
else
    defFile = '';
end
theFilter = {'*.slf';'*.t3s'};
[file,path]=uigetfile(theFilter,'Get lines file',defFile);
iLayer = length(handles.LB_meshLayer.String)+1;
if ischar(file)
    theFile = fullfile(path,file);
    [~,fileName,theExt] = fileparts(theFile);
    switch theExt
        case '.slf'
            sctTel = telheadr(theFile);
            sctTel = telstepr(sctTel,1);
            handles.meshLayer(iLayer).sctTel = sctTel;
            handles.meshLayer(iLayer).name = fileName;
            allFiles = [handles.LB_meshLayer.String;{fileName}];
            set(handles.LB_meshLayer,'String',allFiles);
            set(handles.LB_layerTo,'String',allFiles);
            fclose(sctTel.fid);
        case '.t3s'
            errordlg('Implement it yourself');
            return;
        otherwise
            errordlg('Implement it yourself');
            return;
            
    end
    handles.theFile = theFile;
    handles = updateView(handles);
    guidata(hObject,handles);
    
end


function [iLayer,nrLayer] = maskLayer(handles)
% get layer number
iLayer  = get(handles.LB_maskLayer,'Value');
nrLayer = length(get(handles.LB_maskLayer,'String'));


function [iLayer,nrLayer] = meshLayer(handles)
% get layer number
iLayer  = get(handles.LB_meshLayer,'Value');
nrLayer = length(get(handles.LB_meshLayer,'String'));

function iLayer = meshLayerTo(handles)
% get layer number
iLayer = get(handles.LB_layerTo,'Value');

function [iLayer,nrLayer] = lineLayer(handles)
% get layer number
iLayer  = get(handles.LB_lineLayer,'Value');
nrLayer = length(get(handles.LB_lineLayer,'String'));

function [iLayer,nrLayer] = dataLayer(handles)
% get layer number
iLayer  = get(handles.LB_dataLayer,'Value');
nrLayer = length(get(handles.LB_dataLayer,'String'));


% --------------------------------------------------------------------
function MENU_saveMesh_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_saveMesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if isfield(handles,'theFile')
    defFile = handles.theFile;
else
    defFile = '';
end
theFilter = {'*.slf';'*.t3s'};
[file,path]=uiputfile(theFilter,'Save mesh file',defFile);
iLayer = meshLayer(handles);
if ischar(file)
    theFile = fullfile(path,file);
    [~,fileName,theExt] = fileparts(theFile);
    switch theExt
        case '.slf'
            sctTel = handles.meshLayer(iLayer).sctTel;
            fid = telheadw(sctTel,theFile);
            fid = telstepw(sctTel,fid);
            fclose(fid);
        case '.t3s'
            errordlg('Implement it yourself');
            return;
    end
    handles.theFile = theFile;
end

guidata(hObject,handles);


function handles = addMask(handles,x,y,mask,ikle,name)
% add mask layer to interface
% handles = addMask(handles,x,y,mask,ikle,name)
[~,indMask] = maskLayer(handles);
indMask = indMask+1;
handles.maskLayer(indMask).x = x;
handles.maskLayer(indMask).y = y;
handles.maskLayer(indMask).mask = mask;
handles.maskLayer(indMask).ikle = ikle;
handles.maskLayer(indMask).name = name;
handles.LB_maskLayer.String = [handles.LB_maskLayer.String;{name}];


function handles = addLine(handles,x,y,z,name)
% add lines layer to interface
% handles = addLine(handles,x,y,z,name)
[~,indLine] = lineLayer(handles);
indLine = indLine+1;
handles.lineLayer(indLine).x = x;
handles.lineLayer(indLine).y = y;
handles.lineLayer(indLine).z = z;
handles.lineLayer(indLine).name = name;
handles.LB_lineLayer.String = [handles.LB_lineLayer.String;{name}];

function handles = addData(handles,x,y,z,name)
% add point data layer to interface
% handles = addPoint(handles,x,y,z,name)

[~,indPoint] = dataLayer(handles);
indPoint = indPoint+1;
handles.dataLayer(indPoint).x = x;
handles.dataLayer(indPoint).y = y;
handles.dataLayer(indPoint).z = z;
handles.dataLayer(indPoint).name = name;
handles.LB_dataLayer.String = [handles.LB_dataLayer.String;{name}];

function handles = addMesh(handles,sctTel,name)
% add a telemac mesh to interface
% handles = addMesh(handles,sctTel,name)
[~,indMesh] = meshLayer(handles);
indMesh = indMesh+1;
handles.meshLayer(indMesh).sctTel = sctTel;
handles.meshLayer(indMesh).name = name;
handles.LB_meshLayer.String = [handles.LB_meshLayer.String;{name}];
handles.LB_layerTo.String = [handles.LB_layerTo.String;{name}];


% --------------------------------------------------------------------
function MENU_loadLines_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_loadLines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'theFile')
    defFile = handles.theFile;
else
    defFile = '';
end
theFilter = {'*.i2s';'*.mat'};
[file,path]=uigetfile(theFilter,'Get lines file',defFile);
if ischar(file)
    theFile = fullfile(path,file);
    [~,fileName,theExt] = fileparts(theFile);
    switch theExt
        case '.i2s'
            tmp = Telemac.readKenue(theFile);
            for i=length(tmp):-1:1
                x{i} = tmp{i}(:,1);
                y{i} = tmp{i}(:,2);
                z{i} = tmp{i}(:,3);
            end
            handles = addLine(handles,x,y,z,fileName);
        case '.shp'
            fid = shape('open',fileName);
            data = shape('read',fid,0,'polyline');
            x{1} = data(:,1);
            y{1} = data(:,2);
            if size(data,2)>2
                z{1} = data(:,3);
            else
                z{1} = nan(size(x));
            end
            handles = addLine(handles,x,y,z,fileName);
        case '.mat'
            tmp = load(theFile);
            try
                handles = addLine(handles,tmp.x,tmp.y,tmp.z,fileName);
            catch
                errordlg('Wrong format type in .mat file');
                return;
            end
            
    end
    handles.theFile = theFile;
end
handles = updateView(handles);
guidata(hObject,handles);

% --------------------------------------------------------------------
function MENU_saveLines_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_saveLines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'theFile')
    defFile = handles.theFile;
else
    defFile = '';
end
theFilter = {'*.i2s';'*.mat'};
[file,path]=uiputfile(theFilter,'Get lines file',defFile);
iLayer = lineLayer(handles);
if ischar(file)
    theFile = fullfile(path,file);
    [~,~,theExt] = fileparts(theFile);
    x = handles.lineLayer(iLayer).x;
    y = handles.lineLayer(iLayer).y;
    z = handles.lineLayer(iLayer).z;
    switch theExt
        case '.i2s'
            for i=length(x):-1:1
                tmp{i}(:,3) = z{i};
                tmp{i}(:,2) = y{i};
                tmp{i}(:,1) = x{i};
            end
            Telemac.writeKenue(theFile,tmp);
        case '.mat'
            saveas(theFile,'x','y','z');
    end
    handles.theFile = theFile;
end
guidata(hObject,handles)
% --------------------------------------------------------------------
function MENU_loadData_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_loadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% TODO: set used defined value
MIN_VAL = -1e12;

if isfield(handles,'theFile')
    defFile = handles.theFile;
else
    defFile = '';
end
theFilter = {'*.mat';'*.xyz';'*.tif';'*.asc'};
[file,path]=uigetfile(theFilter,'Get fata file',defFile);
if ischar(file)
    theFile = fullfile(path,file);
    [~,fileName,theExt] = fileparts(theFile);
    hWait = waitbar(0.5, 'Loading data. The bar is not updated. Sorry.', 'WindowStyle', 'modal');
    switch theExt
        case '.xyz'
            tmp = Telemac.readKenue(theFile);
            mask = tmp{1}(:,3)>MIN_VAL;
            x = tmp{1}(mask,1);
            y = tmp{1}(mask,2);
            z = tmp{1}(mask,3);
            mask = isnan(x)|isnan(y);
            x(mask) = [];
            y(mask) = [];
            z(mask) = [];
    
        case '.asc'
            % check if 2d matrix
            [x,y,z] = Import.readArcView(theFile);
        case '.tif'
            %[z,x,y] = geoimread(theFile);
            tmp   = GEOTIFF_READ(theFile);
            [x,y] = meshgrid(tmp.x,tmp.y);
            z     = tmp.z;
        case '.shp'
            fid = shape('open',fileName);
            data = shape('read',fid,0,'point');
            x = data(:,1);
            y = data(:,2);
            if size(data,2)>2
                z = data(:,3);
            else
                z = nan(size(x));
            end
            
            %data = shape('read',fid,0,'polyline');
        case '.mat'
            tmp = load(theFile);
            try
                x = tmp.x;
                y = tmp.y;
                z = tmp.z;
            catch
                errordlg('Invalid format for .mat file');
                return;
            end
            mask = isnan(x)|isnan(y);
            x(mask) = [];
            y(mask) = [];
            z(mask) = [];            
    end
    close(hWait);
    handles = addData(handles,x,y,z,fileName);
    handles.theFile = theFile;
end
handles = updateView(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function MENU_saveData_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_saveData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if isfield(handles,'theFile')
    defFile = handles.theFile;
else
    defFile = '';
end
theFilter = {'*.mat';'*.xyz';'*.asc'};
[file,path]=uiputfile(theFilter,'Get data file',defFile);
iLayer = dataLayer(handles);
if ischar(file)
    theFile = fullfile(path,file);
    [~,~,theExt] = fileparts(theFile);
    x = handles.dataLayer(iLayer).x;
    y = handles.dataLayer(iLayer).y;
    z = handles.dataLayer(iLayer).z;
    switch theExt
        case '.xyz'
            tmp{1}(:,3) = z;
            tmp{1}(:,2) = y;
            tmp{1}(:,1) = x;
            Telemac.writeKenue(theFile,tmp);
        case '.asc'
            % check if 2d matrix
            if size(x,1)==1 || size(x,2)==1
                errordlg('Wrong data format for ArcView');
                return
            end
            Export.writeArcView(x,y,z,theFile);
        case '.mat'
            save(theFile,'x','y','z');
    end
    handles.theFile = theFile;
end
guidata(hObject,handles)


function ET_limMin_Callback(hObject, eventdata, handles)
% hObject    handle to ET_limMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ET_limMin as text
%        str2double(get(hObject,'String')) returns contents of ET_limMin as a double


% --- Executes during object creation, after setting all properties.
function ET_limMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ET_limMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ET_limMax_Callback(hObject, eventdata, handles)
% hObject    handle to ET_limMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ET_limMax as text
%        str2double(get(hObject,'String')) returns contents of ET_limMax as a double


% --- Executes during object creation, after setting all properties.
function ET_limMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ET_limMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PB_scaleXy.
function PB_scaleXy_Callback(hObject, eventdata, handles)
% hObject    handle to PB_scaleXy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[x,y] = getMeshData(handles);
xLim = [min(x) max(x)];
yLim = [min(y) max(y)];
if isempty(xLim)
    xLim = [1e16 -1e-16];
    yLim = [1e16 -1e-16];
end
[x,y] = getLineData(handles);
for i=length(x):-1:1
    xLim2(i,:) = [min(x{i}(:)), max(x{i}(:))];
    yLim2(i,:) = [min(y{i}(:)), max(y{i}(:))];
end
if length(x)==0
    xLim2 = [1e16 -1e-16];
    yLim2 = [1e16 -1e-16];
end
xLim2 = min(xLim2,[],1);
yLim2 = min(yLim2,[],1);

[x,y] = getPointData(handles);
xLim3 = [min(x(:)) max(x(:))];
yLim3 = [min(y(:)) max(y(:))];
if isempty(xLim3)
    xLim3 = [1e16 -1e-16];
    yLim3 = [1e16 -1e-16];
end
xLim = [min([xLim(1),xLim2(1),xLim3(1)]),max([xLim(2),xLim2(2),xLim3(2)])];
yLim = [min([yLim(1),yLim2(1),yLim3(1)]),max([yLim(2),yLim2(2),yLim3(2)])];
if ~isempty (xLim)
    set(handles.hMap,'xlim',xLim);
    set(handles.hMap,'ylim',yLim);
    handles.xyLim(2,:) = get(handles.hMap,'ylim');
    handles.xyLim(1,:) = get(handles.hMap,'xlim');
end
guidata(hObject,handles);

function indBath = getIntBath(handles,iLayer)
%gets the index of the bathymetry

if nargin ==1
    iLayer = meshLayer(handles);
end
sctTel = handles.meshLayer(iLayer).sctTel;
if isfield(handles,'fieldName')
    defName = handles.fieldName;
else
    defName = 'BOTTOM';
end
indBath = Telemac.findVar(defName,sctTel);


% --- Executes on button press in PB_scale.
function PB_scale_Callback(hObject, eventdata, handles)
% hObject    handle to PB_scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[~,~,z] = getMeshData(handles);
zLim = [min(z),max(z)];
[~,~,z] = getPointData(handles);
zLim2 = [min(z(:)),max(z(:))];
if isempty(zLim)
    zLim = zLim2;
elseif isempty(zLim2)
    % do nothing
else
    zLim = [min(zLim(1),zLim2(1)),max(zLim(2),zLim2(2))];
end

if ~isempty(zLim)
    caxis(zLim);
    set(handles.ET_limMin,'String',num2str(zLim(1)));
    set(handles.ET_limMax,'String',num2str(zLim(2)));
end
guidata(hObject,handles);

% --- Executes on button press in PB_scaleView.
function PB_scaleView_Callback(hObject, eventdata, handles)
% hObject    handle to PB_scaleView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[x,y,z] = getMeshData(handles);
xLim = get(handles.hMap,'xlim');
yLim = get(handles.hMap,'ylim');
mask = x>=xLim(1) & x<=xLim(2) & y>=yLim(1) & y<=yLim(2);
zLim = [min(z(mask)),max(z(mask))];
[x,y,z] = getPointData(handles);
x = x(:);
y = y(:);
z = z(:);
mask = x>=xLim(1) & x<=xLim(2) & y>=yLim(1) & y<=yLim(2);
zLim2 = [min(z(mask)),max(z(mask))];
if isempty(zLim)
    zLim = zLim2;
elseif isempty(zLim2)
    % do nothing
else
    zLim = [min(zLim(1),zLim2(1)),max(zLim(2),zLim2(2))];
end
if ~isempty(zLim)
    caxis(zLim);
    set(handles.ET_limMin,'String',num2str(zLim(1)));
    set(handles.ET_limMax,'String',num2str(zLim(2)));
end
guidata(hObject,handles);

function handles = setMaskData(handles,mask,iLayer)
% sets data to a mask
if nargin <3
    iLayer = maskLayer(handles);
end
handles.maskLayer(iLayer).mask = mask;

function [x,y,mask,ikle,name,ok] = getMaskData(handles,iLayer,askToUse)
% extracts data from a mask
%
if nargin ==1
    iLayer = maskLayer(handles);
end
if nargin <3
    askToUse = true;
end

if isfield(handles,'maskLayer')&&~isempty(handles.maskLayer)
    if askToUse
        answer  = questdlg('Use the mask?','Use mask');
        switch lower(answer)
            case 'yes'
                mask = handles.maskLayer(iLayer).mask;
                ok = 1;
            case 'no'
                mask = true(size(handles.maskLayer(iLayer).mask));
                ok = 1;
            case 'cancel'
                ok = 0;
                mask = [];
        end
    else
        mask = handles.maskLayer(iLayer).mask;
    end
    
    x = handles.maskLayer(iLayer).x;
    y = handles.maskLayer(iLayer).y;
    ikle = handles.maskLayer(iLayer).ikle;
    name = handles.maskLayer(iLayer).name;
else
    tmp  = getMeshData(handles);
    mask = true(size(tmp));
    x = [];
    y = [];
    ikle = [];
    name = '';
end

function handles = setLineData(handles,x,y,z,iLayer)
% changes data for a line
%
% handles = setLineData(handles,x,y,z,iLayer)
if nargin <5
    iLayer = lineLayer(handles);
end
handles.lineLayer(iLayer).x = x;
handles.lineLayer(iLayer).y = y;
handles.lineLayer(iLayer).z = z;

function handles = setMeshData(handles,z,iLayer)
%sets data back in a TELEMAC mesh
% handles = setMeshData(handles,z,iLayer)
if nargin <3
    iLayer = meshLayer(handles);
end
indBath = getIntBath(handles,iLayer);
handles.meshLayer(iLayer).sctTel.RESULT(:,indBath) = z;

function [x,y,z,ikle,name,sctTel] = getMeshData(handles,iLayer)
% extracts data from a TELEMAC mesh
% [x,y,z,ikle,name,sctTel] = getMeshData(handles,iLayer)
if nargin ==1
    iLayer = meshLayer(handles);
end
if isfield(handles,'meshLayer')&&~isempty(handles.meshLayer)
    indBath = getIntBath(handles,iLayer);
    x = handles.meshLayer(iLayer).sctTel.XYZ(:,1);
    y = handles.meshLayer(iLayer).sctTel.XYZ(:,2);
    z = handles.meshLayer(iLayer).sctTel.RESULT(:,indBath);
    ikle = double(handles.meshLayer(iLayer).sctTel.IKLE);
    name = handles.meshLayer(iLayer).name;
    sctTel = handles.meshLayer(iLayer).sctTel;
else
    x =[];
    y = [];
    z = [];
    ikle = [];
    name = '';
    sctTel = [];
end

function handles = setPointData(handles,x,y,z)
% set point data values
%
% handles = setPointData(handles,x,y,z)
%
iLayer = dataLayer(handles);
handles.dataLayer(iLayer).x = x;
handles.dataLayer(iLayer).y = y;
handles.dataLayer(iLayer).z = z;

function [x,y,z,name] = getPointData(handles,iLayer)
% extracts data from a dataset
%
% [x,y,z,name] = getPointData(handles,iLayer)
%
if nargin ==1
    iLayer = dataLayer(handles);
end
if isfield(handles,'dataLayer')&& ~isempty(handles.dataLayer)
    x = handles.dataLayer(iLayer).x;
    y = handles.dataLayer(iLayer).y;
    z = handles.dataLayer(iLayer).z;
    name = handles.dataLayer(iLayer).name;
else
    x = [];
    y = [];
    z = [];
    name = '';
end

function [x,y,z,name] = getLineData(handles,iLayer)
% extracts data from a dataset
if nargin ==1
    iLayer = lineLayer(handles);
end
if isfield(handles,'lineLayer')&&~isempty(handles.lineLayer)
    x = handles.lineLayer(iLayer).x;
    y = handles.lineLayer(iLayer).y;
    z = handles.lineLayer(iLayer).z;
    name = handles.lineLayer(iLayer).name;
else
    x = [];
    y = [];
    name = '';
    z = [];
end

function [cLim,ok] = getClim(handles)
% get cAxis limits
cLim(1) = str2double(get(handles.ET_limMin,'String'));
cLim(2) = str2double(get(handles.ET_limMax,'String'));
if any(isnan(cLim))
    errordlg('Wrong axis limits');
    ok = false;
    return;
end
ok =true;

function handles = updateView(handles,lineOnly)
% plots the data

if nargin ==1
    lineOnly = false;
end

% store limits on axis
if isfield( handles,'xyLim')
    handles.xyLim(2,:) = get(handles.hMap,'ylim');
    handles.xyLim(1,:) = get(handles.hMap,'xlim');
end

plotType = get(handles.PU_shading,'string');
plotType = plotType{get(handles.PU_shading,'value')};

if ~lineOnly
    [cLim,ok] = getClim(handles);
    nrColor = 64;
    indCmap  = get(handles.PU_colorbar,'Value');
    cMapNames = get(handles.PU_colorbar,'String');
    theColorMap = UtilPlot.colormapIMDC(cMapNames{indCmap},nrColor);
    if ~ok
        return;
    end
    cla(handles.hMap);
    hold on;
    % plots the mesh data
    if get(handles.CB_plotMesh,'Value')
        [x,y,z,ikle] = getMeshData(handles);
        colormap(theColorMap);
        if ~isempty(x)
            
            if get(handles.CB_hillShade,'Value')
                zHill = hillshadetri(z,x,y,ikle);
                Plot.plotTriangle(x,y,zHill,ikle,handles.hMap);
                shading interp;
                caxis([0 255]);
                colormap(gray);
            else
                if strcmpi(plotType,'points')
                    plotOptions.nrBins = 64;
                    plotOptions.minZ = cLim(1);
                    plotOptions.maxZ = cLim(2);
                    plotOptions.colorMap= theColorMap;
                    Plot.scatterFast(x,y,z,plotOptions);
                else
                    Plot.plotTriangle(x,y,z,ikle,handles.hMap);
                    [~,shadingType]= strtok(plotType);
                    shading(strtrim(shadingType));
                    caxis(cLim);
                    colorbar;
                end
            end
        end
    end
    % plots the mesh
    if get(handles.CB_addMesh,'Value')
        [x,y,z,ikle] = getMeshData(handles);
        if ~isempty(x)
            triplot(ikle,x,y,'k');
        end
    end
   
    %plots values
    if get(handles.CB_showValues,'Value')
        [x,y,z,ikle] = getMeshData(handles);
        xLim = get(handles.hMap,'xlim');
        yLim = get(handles.hMap,'ylim');
        mask = find(x>=xLim(1) & x<=xLim(2) & y>=yLim(1) & y<=yLim(2));
        for i=1:min(length(mask),500)
            ind = mask(i);
            text(x(ind),y(ind),num2str(z(ind),'%5.2f'),'fontsize',8);
        end
    end
    
    % plot the data
    if get(handles.CB_plotData,'Value')
        [x,y,z] = getPointData(handles);
        
        
        
        plotOptions.nrBins = 64;
        plotOptions.minZ = cLim(1);
        plotOptions.maxZ = cLim(2);
        plotOptions.colorMap= theColorMap;
        if isfield(handles,'pointDataStride')
            dp =  handles.pointDataStride;
        else
            dp = 1;
        end
        
        if isvector(x)
            tmp = rand(size(x));
            mask = tmp<(1/dp);
            Plot.scatterFast(x(mask),y(mask),z(mask),plotOptions);
        else
            Plot.scatterFast(x(1:dp:end,1:dp:end),y(1:dp:end,1:dp:end),z(1:dp:end,1:dp:end),plotOptions);
        end
    end
end

% add model outlines
if get(handles.CB_outline,'Value')
    [~,~,~,~,name,sctTel] = getMeshData(handles);
    if ~isempty(sctTel)
        [~, xOut,yOut] = Telemac.getBoundary(sctTel,true);
        for i =1:length(xOut)
            plot(xOut{i},yOut{i},'r','linewidth',2);
        end
    end
end

% plots mask
if get(handles.CB_plotMask,'Value')
     [x,y,mask,ikle] = getMaskData(handles,maskLayer(handles),false);
     if ~isempty(x)
        hPatch = patch('faces',ikle,'vertices',[x,y],'FaceColor','r','EdgeColor','none','FaceVertexAlphaData',0.25.*(mask),'FaceAlpha','flat','EdgeAlpha',0);
     end
end

% plots all lines

if get(handles.CB_plotLines,'Value')
    if ~lineOnly
        for j = 1:length(get(handles.LB_lineLayer,'String'))
            [x,y] = getLineData(handles,j);
            for i =1:length(x)
                plot(x{i}',y{i}','k','color',[0.7 0.7 0.7],'linewidth',0.5);
            end
        end
    end
    if isfield(handles,'hLine')
        for iLine=1:length(handles.hLine)
            delete(handles.hLine{iLine});
        end
        handles = rmfield(handles,'hLine');
    end
    [x,y] = getLineData(handles);
    for i =1:length(x)
        handles.hLine{i}= plot(x{i}',y{i}','-k','linewidth',2);
    end
end


axis equal;
if isfield(handles,'xyLim')
    xlim(handles.xyLim(1,:));
    ylim(handles.xyLim(2,:));
else
    handles.xyLim(2,:) = get(handles.hMap,'ylim');
    handles.xyLim(1,:) = get(handles.hMap,'xlim');
end
grid on
colorbar


% --- Executes on button press in CB_plotMesh.
function CB_plotMesh_Callback(hObject, eventdata, handles)
% hObject    handle to CB_plotMesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_plotMesh


% --- Executes on button press in CB_plotData.
function CB_plotData_Callback(hObject, eventdata, handles)
% hObject    handle to CB_plotData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_plotData

if get(hObject,'Value')
    answer = inputdlg({'Specify stride for plotting'},'Number points',[1],{'1'});
    if isempty(answer)
        return
    end
    stride = str2double(answer{1});
    if isnan(stride)|| stride==0
        errordlg('Invalid stride');
        return
    end
    handles.pointDataStride = stride;
    guidata(hObject,handles);
end



% --- Executes on button press in CB_plotLines.
function CB_plotLines_Callback(hObject, eventdata, handles)
% hObject    handle to CB_plotLines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_plotLines


% --------------------------------------------------------------------
function MENU_copy_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_copy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MENU_delete_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MENU_deleteMesh_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_deleteMesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
% delete layer containig the selected mesh
iLayer = meshLayer(handles);
handles.meshLayer(iLayer) = [];
tmp = get(handles.LB_meshLayer,'String');
tmp(iLayer) = [];
set(handles.LB_meshLayer,'String',tmp);
set(handles.LB_meshLayer,'Value',1);
set(handles.LB_layerTo,'String',tmp);
set(handles.LB_layerTo,'Value',1);

handles = updateView(handles);
guidata(hObject,handles);


% --------------------------------------------------------------------
function MENU_deleteLines_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_deleteLines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = saveState(handles);
%delete layer with lines
iLayer = lineLayer(handles);
handles.lineLayer(iLayer) = [];
tmp = get(handles.LB_lineLayer,'String');
tmp(iLayer) = [];
set(handles.LB_lineLayer,'String',tmp);
set(handles.LB_lineLayer,'Value',1);
guidata(hObject,handles);
handles = updateView(handles);
guidata(hObject,handles);


% --------------------------------------------------------------------
function MENU_deleteData_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_deleteDataPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = saveState(handles);
%delete layer with data
iLayer = dataLayer(handles);
handles.dataLayer(iLayer) = [];
tmp = get(handles.LB_dataLayer,'String');
tmp(iLayer) = [];
set(handles.LB_dataLayer,'String',tmp);
set(handles.LB_dataLayer,'Value',1);
handles = updateView(handles);
guidata(hObject,handles);


% --------------------------------------------------------------------
function MENU_copyMesh_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_copyMesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = saveState(handles);
iMesh = meshLayer(handles);
name   = [handles.meshLayer(iMesh).name,'_copy'];
sctTel = handles.meshLayer(iMesh).sctTel;
handles = addMesh(handles,sctTel,name);
guidata(hObject,handles);

% --------------------------------------------------------------------
function MENU_copyLines_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_copyLines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = saveState(handles);
iLines = lineLayer(handles);
[x,y,z] = getLineData(handles,iLines);
name  = [handles.lineLayer(iLines).name,'_copy'];
handles = addLine(handles,x,y,z,name);
guidata(hObject,handles);


% --------------------------------------------------------------------
function MENU_copyData_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_copyData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = saveState(handles);
iData = dataLayer(handles);
[x,y,z,name] = getPointData(handles);
name  = [name,'_copy'];
handles = addData(handles,x,y,z,name);
guidata(hObject,handles);


% --------------------------------------------------------------------
function MENU_medianFilter_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_medianFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
%ask filter size 
answer = inputdlg({'Give the filter size [use low integer values]'},'Filter size',1,{'1'});
if isempty(answer)
    return
end
nrGen = str2double(answer{1});
if isnan(nrGen)
    errordlg('Invalid input');
    return;
end

% get data
[x,y,z,ikle,name,sctTel] = getMeshData(handles);
[handles,indexCon,nrCon] = getConMesh(handles);
%filter
zFilt = Triangle.filterMedian(ikle,[x,y],z,nrGen,indexCon, nrCon);

% update data
handles = setMeshData(handles,zFilt);

handles = updateView(handles);
guidata(hObject,handles);

% --------------------------------------------------------------------
function MENU_lineData_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_lineData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles = saveState(handles);
answer = inputdlg({'Give the alpha volume radius [m]'},'Radius alphavol',1,{'500'});
if isempty(answer)
    return
end
radius = str2double(answer{1});
if isnan(radius)
    errordlg('Invalid input');
    return;
end

hWait = waitbar(0.5, 'Loading data. The bar is not updated. Sorry.', 'WindowStyle', 'modal');
% calculate surrounding line
[x,y,z,name] = getPointData(handles);
x = x(:);
y = y(:);
xy = [x,y];
[~,alphaData] = alphavol(xy,radius);
% myTri = triangulation(alphaData.tri(),x,y);
% myObc = freeBoundary(myTri);
polyObc =PolyLine.makePoly(alphaData.bnd);

for i=length(polyObc):-1:1
    xLine{i} = x(polyObc{i});
    yLine{i} = y(polyObc{i});
    zLine{i} = z(polyObc{i});
end
name  = ['Envelop of ',name];

handles = addLine(handles,xLine,yLine,zLine,name);
handles = updateView(handles);
guidata(hObject,handles);
close(hWait);


% --- Executes on button press in CB_addMesh.
function CB_addMesh_Callback(hObject, eventdata, handles)
% hObject    handle to CB_addMesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_addMesh


% --- Executes on button press in CB_showValues.
function CB_showValues_Callback(hObject, eventdata, handles)
% hObject    handle to CB_showValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_showValues


% --------------------------------------------------------------------
function MENU_deleteDataPoint_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_deleteDataPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);

% get dat apoints
[x,y,z] = getPointData(handles);
x = x(:);
y = y(:);
z = z(:);

% get line
answer = questdlg('Use line layer?');
switch upper(answer)
    case 'YES'
        [mask,ok] = getMask(handles,x,y);
        if ~ok
            retunr
        end
    case 'NO'
        [xPoly,yPoly]  = UserInput.getPoly(true);
        xPoly = xPoly';
        yPoly = yPoly';
        if length(xPoly)< 3
            return;
        end
        mask  = inpoly([x,y],[xPoly,yPoly]);
    otherwise
        return
end
% make mask

%delete points
x(mask) = [];
y(mask) = [];
z(mask) = [];
handles = setPointData(handles,x,y,z);

% update
handles = updateView(handles);
guidata(hObject,handles);

% --------------------------------------------------------------------
function MENU_diffMeshData_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_diffMeshData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = saveState(handles);
% get data
iLayer = meshLayer(handles);
iLayer2 = meshLayerTo(handles);
[x,y,z,~,name,sctTel] = getMeshData(handles,iLayer);
[~,~,z2,~,name2,sctTel2] = getMeshData(handles,iLayer2);

if numel(z)~=numel(z2)
    sctInterp= Telemac.interpTriPrepare(sctTel2,x,y);
    z2 = Triangle.interpTriangle(sctInterp,z2);
end
% cal difference
indBath = getIntBath(handles);
sctTel.RESULT(:,indBath) = z-z2;
% add new data
newName = [name,' minus ', name2];
handles = addMesh(handles,sctTel,newName);
% update
handles = updateView(handles);
guidata(hObject,handles);


% --- Executes on button press in PB_apply.
function PB_apply_Callback(hObject, eventdata, handles)
% hObject    handle to PB_apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = updateView(handles);
guidata(hObject,handles);


% --------------------------------------------------------------------
function MENU_lines_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_lines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MENU_data_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MENU_warpData_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_warpData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%make mask by clicking
handles = saveState(handles);
[xPoly,yPoly,hPoly] = UserInput.getPoly(true);
xPoly = xPoly';
yPoly = yPoly';
xPolyOrg = xPoly;
yPolyOrg = yPoly;
% move points of mask to new location
w = 1;
while w==1
    % find closest point
    [x,y,w] =fastGinput(1);
    if w==1
        [~,iP] =  min((xPoly-x).^2+(yPoly-y).^2);
        % find new location
        [x,y,w] =fastGinput(1);
        
        if w==1
            % change data
            delete(hPoly)
            xPoly(iP) = x;
            yPoly(iP) = y;
            hPoly = plot([xPoly;xPoly(1)],[yPoly;yPoly(1)]); 
        end
    end
end


%warp data
% fit linear transformation
A = [xPolyOrg,yPolyOrg,ones(size(yPolyOrg))];
b = xPoly;
cX = A\b;
b = yPoly;
cY = A\b;

% recalculate data
[x,y,z] = getPointData(handles);
xOrg = x;
yOrg = y;
mask = inpoly([x y],[xPolyOrg,yPolyOrg]);
x(mask) = cX(1).*xOrg(mask)+cX(2).*yOrg(mask)+cX(3);
y(mask) = cY(1).*xOrg(mask)+cY(2).*yOrg(mask)+cY(3);

handles = setPointData(handles,x,y,z);

% update
handles = updateView(handles);
guidata(hObject,handles);

% --------------------------------------------------------------------
function MENU_isolineMesh_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_isolineMesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
% --------------------------------------------------------------------
function MENU_isolineData_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_isolineData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
% answer = inputdlg({'Give isoline values'},'Isoline values',[],{''});
% if isempty(answer)
%     return;
% end
% isoLines  = strnum(answer);
% if isempty(isoLines)
%     errordlg('Wrong input for isolines');
% end
% 
% [x,y,z] =getPointData(handles);
% mask = getMask(handles,x,y);
% x = x(mask);
% y = y(mask);
% z = z(mask);
% 
% myTri = delaunay(x,y);
% tricontourc();

% now something like contourc is needed. interpolate to regular mesh?
% or adapt tricontour.

% --------------------------------------------------------------------
function MENU_interpPoly_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_interpPoly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% select polynomial
handles = saveState(handles);
answer = inputdlg({'Order of the polynomial'},'Polynomial fit',[1],{'3'});
if isempty(answer)
    return
end
p = str2num(answer{1}); %#ok<ST2NM>
if isempty(p)
    errordlg('Wrong input for p');
    return;
end

% prepare masking
[handles,indexCon,nrCon]  = getCon(handles);
[x,y,mask,ikle] = getMaskData(handles,maskLayer(handles),false);

answer = questdlg('Click to select where to apply the polynomial');
if strcmpi(answer,'cancel')
    return
end
useClump = strcmpi(answer,'yes');

% fit data through polynomyal

% get data
[xData,yData,zData] = getPointData(handles);
xData= xData(:);
yData= yData(:);
zData= zData(:);


if useClump
    % find closest point
    while true
        [xP,yP,wP] = fastGinput(1);
        % stop on right click
        if wP~=1
            break
        end
        [~,indStart] = min((x-xP).^2+(y-yP).^2);
        % select areas
        maskMesh  =  Triangle.findClump(ikle,[x y],mask,indStart,indexCon,nrCon);
        % fist data
        
        z= polyFit_data(xData,yData,zData,p,handles,maskMesh); %#ok<AGROW>
        
        % update
        handles = setMeshData(handles,z);
        handles = updateView(handles);
        guidata(hObject,handles);
    end
    
else
    % invert and update
    z= polyFit_data(xData,yData,zData,p,handles);
    handles = setMeshData(handles,z);
    handles = updateView(handles);
    guidata(hObject,handles);
end




function z= polyFit_data(xData,yData,zData,p,handles,mask)
% fits data

% WARNING; HARD CODED COEFFICIENT

DX = 100;

if numel(p) ==1
    pX = p;
    pY = p;
else
    pX = p(1);
    pY = p(2);
end

%get mesh data
[x,y,z] = getMeshData(handles);
if nargin<6
    [~,~,mask] = getMaskData(handles);
end
if numel(mask)~=numel(x)
    errordlg('The mask is on different mesh. Remake the mask for the current mesh.');
    return;
end

xMin = min(x(mask));
xMax = max(x(mask));
yMin = min(y(mask));
yMax = max(y(mask));
% make boundingbox
maskData  = xData>= (xMin-DX) & ...
            xData<= (xMax+DX) & ...
            yData>= (yMin-DX) & ...
            yData<= (yMax+DX);

xData = xData(maskData);
yData = yData(maskData);
zData = zData(maskData);
        
%scale data
xM = mean(xData);
yM = mean(yData);

% determine matrix size. TODO look for more elegant way
n = 0;
for i=0:pX
    for j=0:(pY-i)
        n = n+1;
    end
end
nrX = length(xData);
A = zeros(nrX,n);

% mask matrix
n = 0;
for i=0:pX
    for j=0:(pY-i)
        n = n+1;
        A(:,n) = ((xData-xM).^i) .* ((yData-yM).^j);
    end
end
b = zData;
coef = A\b;

% apply polynomial
z(mask) = 0;
n = 0;
for i=0:pX
    for j=0:(pY-i)
        n = n+1;
        z(mask) = z(mask)+coef(n).*((x(mask)-xM).^i).*((y(mask)-yM).^j);
    end
end



% --------------------------------------------------------------------
function MENU_gradient_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_gradient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = saveState(handles);
[x,y,z,ikle,name] = getMeshData(handles);
name  = ['slope of ',name];

[gradX,gradY] = Triangle.gradPoin(ikle,[x,y],z);
slope = hypot(gradX,gradY);

%TODO: show as mesh instead
handles = addData(handles,x,y,slope,name);
handles = updateView(handles);
guidata(hObject,handles);


% --------------------------------------------------------------------
function MENU_edgeDetector_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_edgeDetector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = saveState(handles);
msgbox('Todo');

% --------------------------------------------------------------------
function MENU_histMesh_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_histMesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[~,~,z] = getMeshData(handles);
[~,~,mask] = getMaskData(handles);
if numel(mask)~=numel(z)
    errordlg('The mask is on different mesh. Remake the mask for the current mesh.');
    return;
end

UtilPlot.reportFigureTemplate;
z= z(mask);
hist(z,500);
mu = nanmean(z);
std = nanstd(z);
median = nanmedian(z);
minZ = min(z);
maxZ = max(z);
title(sprintf('Mean = %6.3f; Std = %6.3f;\n Median = %6.3f;\n Range = %6.3f to %6.3f ;',mu,std,median,minZ,maxZ));
grid on;

% --------------------------------------------------------------------
function MENU_histPoint_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_histPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[~,~,z] = getPointData(handles);
z = z(:);
UtilPlot.reportFigureTemplate;
hist(z,100);
mu = nanmean(z);
std = nanstd(z);
median = nanmedian(z);
minZ = min(z);
maxZ = max(z);
title(sprintf('Mean = %6.3f; Std = %6.3f;\n Median = %6.3f;\n Range = %6.3f to %6.3f ;',mu,std,median,minZ,maxZ));
grid on;


% --- Executes on button press in CB_outline.
function CB_outline_Callback(hObject, eventdata, handles)
% hObject    handle to CB_outline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_outline


function [indJ,indK] = findClosest(handles,x,y)
% finds the line closest to a point

maxDist = inf;
[xPoly,yPoly]  = getLineData(handles);
nrLines = length(x);
for j=1:nrLines
    % look for closes point
    xTmp = xPoly{j};
    yTmp = yPoly{j};
    [dist,ind] = min( (xTmp-x).^2 + (yTmp-y).^2);
    if dist<maxDist
        indJ = j;
        indK = ind;
        maxDist = dist;
    end
end

% --------------------------------------------------------------------
function MENU_movePoints_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_movePoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = saveState(handles);
w = 1;
iLayer = lineLayer(handles);
while w==1
    % find closest point
    [x,y,w] =fastGinput(1);
    if w==1
        [indJ,indK] = findClosest(handles,x,y);
        % find new location
        [x,y,w] =fastGinput(1);
        
        if w==1
            % change data
            handles.lineLayer(iLayer).x{indJ}(indK) = x;
            handles.lineLayer(iLayer).y{indJ}(indK) = y;
            % update figure
            guidata(hObject,handles);
            handles = updateView(handles,true);
            
        end
        guidata(hObject,handles);
    end
end

% --------------------------------------------------------------------
function MENU_moveSegment_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_moveSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiwait(msgbox('Click first on two points to get the segment. Then click on two points to get the new points.'));

w = 1;
iLayer = lineLayer(handles);
while w==1
    % find first segment
    [x0,y0,w] =fastGinput(1);
    if w==1
        % find segment
        [j1,k1] = findClosest(handles,x0,y0);
        [x1,y1,w] =fastGinput(1);
        [j2,k2] = findClosest(handles,x1,y1);
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
        xTmp = handles.lineLayer(iLayer).x{j1}(mask); 
        yTmp = handles.lineLayer(iLayer).y{j1}(mask);
        if abs(x1-x0)>0
            t =(xTmp-x0) /(x1-x0);
        else
            t =(yTmp-y0) /(y1-y0);
        end
        xTmp2 = t.*(x11-x01)+x01;
        yTmp2 = t.*(y11-y01)+y01;
        % update
        handles.lineLayer(iLayer).x{j1}(mask) = xTmp2;
        handles.lineLayer(iLayer).y{j1}(mask) = yTmp2;
        
       
        handles = updateView(handles,true);
        guidata(hObject,handles);
    end
end
% --------------------------------------------------------------------
function MENU_mergeData_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_mergeData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
answer  = inputdlg({'Give the numbers of the data layers to merge'},'Merge data',[1],{''});
if isempty(answer)
    return
end
layerToMerge = str2num(answer{1}); %#ok<ST2NM>
if isempty(layerToMerge) 
    errordlg('Wrong input');
    return;
end
[~,nrLayer] = dataLayer(handles);
if any(layerToMerge<1) || any(layerToMerge>nrLayer)
    errrdlg('Invalid layers selected');
    return;
end
xAll =[];
yAll =[];
zAll =[];
for iLayer = 1:length(layerToMerge)
    [x,y,z] = getPointData(handles,layerToMerge(iLayer)); 
    mask    = getMask(handles,x,y);
    xAll = [xAll;x(mask)];
    yAll = [yAll;y(mask)];
    zAll = [zAll;z(mask)];
end

name = ['Merged data from layers ',num2str(layerToMerge)];
handles = addData(handles,xAll,yAll,zAll,name);

handles = updateView(handles);
guidata(hObject,handles);

% --------------------------------------------------------------------
function MENU_deletePoint_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_deletePoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = saveState(handles);
w = 1;
iLayer = lineLayer(handles);
while w==1
    % find closest point
    [x,y,w] =fastGinput(1);
    if w==1
        [indJ,indK] = findClosest(handles,x,y);
        if w==1
            % change data
            handles.lineLayer(iLayer).x{indJ}(indK) = [];
            handles.lineLayer(iLayer).y{indJ}(indK) = [];
            % update figure
            guidata(hObject,handles);
            handles = updateView(handles,true);
            
        end
        guidata(hObject,handles);
    end
end


% --- Executes on button press in CB_hillShade.
function CB_hillShade_Callback(hObject, eventdata, handles)
% hObject    handle to CB_hillShade (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_hillShade




% --------------------------------------------------------------------
function MENU_copyZeroMesh_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_copyZeroMesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = saveState(handles);
iMesh = meshLayer(handles);
name   = [handles.meshLayer(iMesh).name,'_copy'];
indBath = getIntBath(handles);
sctTel = handles.meshLayer(iMesh).sctTel;
sctTel.RESULT(:,indBath)=0.0;
handles = addMesh(handles,sctTel,name);
guidata(hObject,handles);


% --------------------------------------------------------------------
function MENU_dataFromMesh_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_dataFromMesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = saveState(handles);
[x,y,z,~,name] = getMeshData(handles);
[~,~,mask] = getMaskData(handles);
if numel(mask)~=numel(x)
    errordlg('The mask is on different mesh. Remake the mask for the current mesh.');
    return;
end

x = x(mask);
y = y(mask);
z = z(mask);
name   = [name,'_data'];
handles = addData(handles,x,y,z,name);
guidata(hObject,handles);


% --- Executes on selection change in LB_maskLayer.
function LB_maskLayer_Callback(hObject, eventdata, handles)
% hObject    handle to LB_maskLayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LB_maskLayer contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LB_maskLayer


% --- Executes during object creation, after setting all properties.
function LB_maskLayer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LB_maskLayer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function MENU_mask_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function [mask,ok] = getMask(handles,x,y)
% gets a mask
% [mask,ok] = getMask(handles,x,y)
%
[xPoly,yPoly] = getLineData(handles);
mask = true(size(x));
if ~isempty(xPoly)
    answer  = questdlg('Use the mask?','Use mask');
    switch lower(answer)
        case 'yes'
            xPoly = xPoly{1};
            yPoly = yPoly{1};
            mask  = inpoly([x,y],[xPoly,yPoly]);
            ok = 1;
        case 'no'
            ok = 1;
        case 'cancel'
            ok = 0;
    end
end


% --------------------------------------------------------------------
function MENU_maskFromLine_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_maskFromLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = saveState(handles);
%get data and preallocate
[x,y,~,ikle] = getMeshData(handles);
[xPoly,yPoly,~,namePoly] = getLineData(handles);
mask = false(size(x));


answer = questdlg('Click to select lines?','Line select');
switch lower(answer)
    case 'yes'
        % determine area of each polygon
        for i=length(xPoly):-1:1
            areaPoly(i) = abs(polyarea(xPoly{i},yPoly{i}));
        end
        n = 0;
        while true
            n = n+1;
            % find smallest polygon that contains the data
            [xP,yP] = fastGinput(1);
            for i=length(xPoly):-1:1
                tmp(i) = inpoly([xP,yP],[xPoly{i},yPoly{i}]);
            end
            % none found, we use the inverse of all
            if ~any(tmp)
                tmpMask = false(size(x));
                for i=1:length(xPoly)
                    xP = xPoly{i};
                    yP = yPoly{i};
                    tmpMask  = tmpMask | inpoly([x,y],[xP,yP]);
                end
            else
                % find smallest mask
                indList = find(tmp);
                [~,ind] = min(areaPoly(indList));
                ind = indList(ind);
                tmpMask = inpoly([x,y],[xPoly{ind},yPoly{ind}]);
            end
            mask = mask | tmpMask;
            
            % update plot
            if n>1
                delete(hPatch);
            end
            hPatch = patch('faces',ikle,'vertices',[x,y],'FaceColor','y','EdgeColor','none','FaceVertexAlphaData',0.25.*(mask),'FaceAlpha','flat','EdgeAlpha',0);


            
            % make another
            answer = questdlg('Add another part','Add line');
            switch lower(answer)
                case 'yes'
                    continue;
                case 'no'
                    break;
                otherwise
                    return;
            end
        end
        delete(hPatch);
    case 'no'
        % select all areas in mask
        for i=1:length(xPoly)
            xP = xPoly{i};
            yP = yPoly{i};
            mask  = mask | inpoly([x,y],[xP,yP]);
        end
    otherwise
        return
end
name = ['mask of ',namePoly];
handles = addMask(handles,x,y,mask,ikle,name);
handles = updateView(handles);
guidata(hObject,handles);

% --------------------------------------------------------------------
function MENU_maskFromDataEquation_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_maskFromDataEquation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = saveState(handles);
% get data
[x,y,z,ikle,name] = getMeshData(handles); %#ok<ASGLU>

% ask equation
answer = inputdlg('Give equation that gives landwer of logical type; use ,x, y and z','Equation',[1],{''});
if isempty(answer)
    return
end
mask = eval(answer{1});

name = ['Equation of ',name];
handles = addMask(handles,x,y,mask,ikle,name);

handles = updateView(handles);
guidata(hObject,handles);




% --------------------------------------------------------------------
function MENU_maskFromDataMagic_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_maskFromDataMagic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = saveState(handles);
[x,y,z,ikle,name] = getMeshData(handles);
iLayer = meshLayer(handles);
% find connections
if ~isfield(handles.meshLayer(iLayer),'indexCon')||isempty(handles.meshLayer(iLayer).indexCon)
    [indexCon,nrCon] = Triangle.findConnection(ikle,[x,y],1);
    handles.meshLayer(iLayer).indexCon = indexCon;
    handles.meshLayer(iLayer).nrCon = nrCon;
else
    indexCon = handles.meshLayer(iLayer).indexCon;
    nrCon = handles.meshLayer(iLayer).nrCon;
end

answer = inputdlg('Give threshold [m]','Threshold',[1],{'5'});
if isempty(answer)
    return
end
threshold = str2double(answer{1});
if isnan(threshold)
    errordlg('Wriong nput');
    return
end


% find closest point
[xP,yP] = fastGinput(1);
[~,indStart] = min((x-xP).^2+(y-yP).^2);
zMin = z(indStart)-threshold;
zMax = z(indStart)+threshold;
zBin = z>zMin & z<zMax;

indClump  =  Triangle.findClump(ikle,[x y],zBin,indStart,indexCon,nrCon);

name = ['Clump of ',name];
handles = addMask(handles,x,y,indClump,ikle,name);
handles = updateView(handles);
guidata(hObject,handles);

% --------------------------------------------------------------------
function menuMaskToMask_Callback(hObject, eventdata, handles)
% hObject    handle to menuMaskToMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = saveState(handles);
msgbox('Todo');

% --------------------------------------------------------------------
function MENU_deleteMask_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_deleteMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = saveState(handles);
% delete layer containig the selected mask
iLayer = maskLayer(handles);
handles.maskLayer(iLayer) = [];
tmp = get(handles.LB_maskLayer,'String');
tmp(iLayer) = [];
set(handles.LB_maskLayer,'String',tmp);
set(handles.LB_maskLayer,'Value',1);

handles = updateView(handles);
guidata(hObject,handles);


% --------------------------------------------------------------------
function MENU_copyMask_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_copyMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = saveState(handles);
[x,y,mask,ikle,name] = getMaskData(handles);
name   = [name,'_copy'];
handles = addMask(handles,x,y,mask,ikle,name);
guidata(hObject,handles);


% --------------------------------------------------------------------
function MENU_maskInvert_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_maskInvert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = saveState(handles);
[x,y,mask,ikle] = getMaskData(handles,maskLayer(handles),false);

answer = questdlg('Click to selct where to invert');
if strcmpi(answer,'cancel')
    return
end
useClump = strcmpi(answer,'yes');

if useClump
    [handles,indexCon,nrCon]  = getCon(handles);
    % find closest point
    while true
        [xP,yP,wP] = fastGinput(1);
        % stop on right click
        if wP~=1
            break
        end
        [~,indStart] = min((x-xP).^2+(y-yP).^2);
        % select areas
        indClump  =  Triangle.findClump(ikle,[x y],mask,indStart,indexCon,nrCon);
        % invert and update
        mask(indClump) = ~mask(indClump);
        handles = setMaskData(handles,mask);
        handles = updateView(handles);
        guidata(hObject,handles);
    end
    
else
    % invert and update
    mask = ~mask;
    handles = setMaskData(handles,mask);
    handles = updateView(handles);
    guidata(hObject,handles);
end

% --------------------------------------------------------------------
function MENU_mergeMask_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_mergeMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = saveState(handles);
[~,nrLayer]  = maskLayer(handles);
answer = inputdlg({'Select layers to merge';'Select operation,[AND,OR,XOR,AND NOT]'},'Merge mask',[1;1],{'';'OR'});
if isempty(answer)
    return
end
layerToMerge = str2num(answer{1}); %#ok<ST2NM>
if isempty(layerToMerge) 
    errordlg('Wrong input');
    return;
end
if any(layerToMerge<1) || any(layerToMerge>nrLayer)
    errrdlg('Invalid layers selected');
    return;
end
typeMerge = upper(answer{2});
% apply mask
[~,~,mask] = getMaskData(handles,layerToMerge(1),false);
for i=2:length(layerToMerge)
    [~,~,tmpMask] = getMaskData(handles,layerToMerge(i),false);    
    switch typeMerge
        case 'AND'
            mask = mask & tmpMask;
        case 'OR'
            mask = mask | tmpMask;
        case 'XOR'
            mask = xor(mask,tmpMask);
        case 'AND NOT'
            mask = mask & ~tmpMask;
        otherwise
            errordlg('Wrong binary operator');
            return
    end
end


% update data
handles = setMaskData(handles,mask);
handles = updateView(handles);
guidata(hObject,handles);


function [handles,indexCon,nrCon]  = getConMesh(handles)
% find connections
iLayer = meshLayer(handles);
if ~isfield(handles.meshLayer(iLayer),'indexCon')||isempty(handles.meshLayer(iLayer).indexCon)
    [x,y,~,ikle] = getMeshData(handles,iLayer);
    [indexCon,nrCon] = Triangle.findConnection(ikle,[x,y],1);
    handles.meshLayer(iLayer).indexCon = indexCon;
    handles.meshLayer(iLayer).nrCon = nrCon;
else
    indexCon = handles.meshLayer(iLayer).indexCon;
    nrCon = handles.meshLayer(iLayer).nrCon;
end


function [handles,indexCon,nrCon]  = getCon(handles)
% find connections
iLayer = maskLayer(handles);
if ~isfield(handles.maskLayer(iLayer),'indexCon')||isempty(handles.maskLayer(iLayer).indexCon)
    [x,y,~,ikle] = getMaskData(handles,iLayer,false);
    [indexCon,nrCon] = Triangle.findConnection(ikle,[x,y],1);
    handles.maskLayer(iLayer).indexCon = indexCon;
    handles.maskLayer(iLayer).nrCon = nrCon;
else
    indexCon = handles.maskLayer(iLayer).indexCon;
    nrCon = handles.maskLayer(iLayer).nrCon;
end

% --------------------------------------------------------------------
function MENU_splitMaskMagic_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_splitMaskMagic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA).
handles = saveState(handles);
[x,y,mask,ikle,name] = getMaskData(handles);
[handles,indexCon,nrCon]  = getCon(handles);

% find closest point
[xP,yP] = fastGinput(1);
[~,indStart] = min((x-xP).^2+(y-yP).^2);

indClump  =  Triangle.findClump(ikle,[x y],mask,indStart,indexCon,nrCon);

name = ['Clump of ',name];
handles = addMask(handles,x,y,indClump,ikle,name);
handles = updateView(handles);
guidata(hObject,handles);


% --- Executes on button press in CB_plotMask.
function CB_plotMask_Callback(hObject, eventdata, handles)
% hObject    handle to CB_plotMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_plotMask


% --------------------------------------------------------------------
function MENU_editLines_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_editLines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% CONVERT DATA
handles = saveState(handles);
msgbox('Unfortunately this does not work very well. What a pity. Maybe I should try to fix it. Maybe not. Maybe after my retirement. I am counting the days.');
return;
[x,y,z,name] = getLineData(handles);
for i=length(x):-1:1
    lineIn{i} = [x{i},y{i},z{i}];
end
clear x y z;
[~,lineOut] = editLines('lineData',lineIn,'lineName',name);
for i=length(lineOut):-1:1
    x{i} = lineOut{i}(:,1);
    y{i} = lineOut{i}(:,2);
    z{i} = lineOut{i}(:,3);
end
handles = setLineData(handles,x,y,z);
handles = updateView(handles);
guidata(hObject,handles);

% --------------------------------------------------------------------
function MENU_setmeshStatistics_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_setmeshStatistics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = saveState(handles);

[~,~,mask] = getMaskData(handles);
[x,y,z,ikle] = getMeshData(handles);
if numel(mask)~=numel(x)
    errordlg('The mask is on different mesh. Remake the mask for the current mesh.');
    return;
end

[handles,indexCon,nrCon]  = getCon(handles);


% select method
statList = {'mean','median','min','max'};
[index,ok] = listdlg('PromptString','Select statistical method','ListString',statList);
if ~ok
    return
end

% find closest point
while true
    [xP,yP,wP] = fastGinput(1);
    % stop on right click
    if wP~=1
        break
    end
    [~,indStart] = min((x-xP).^2+(y-yP).^2);
    % select areas
    indClump  =  Triangle.findClump(ikle,[x y],mask,indStart,indexCon,nrCon);
    
    
    switch statList{index}
        case 'mean'
            z(indClump) = mean(z(indClump));
        case 'median'
            z(indClump) = median(z(indClump));
        case 'min'
            z(indClump) = min(z(indClump));
        case 'max'
            z(indClump) = max(z(indClump));
        otherwise
    end
    
    handles = setMeshData(handles,z);
    % update
    handles = updateView(handles);
    guidata(hObject,handles);
end

% update
handles = updateView(handles);
guidata(hObject,handles);


% --------------------------------------------------------------------
function MENU_loadMask_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_loadMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'theFile')
    defFile = handles.theFile;
else
    defFile = '';
end
theFilter = {'*.mat'};
[file,path]=uigetfile(theFilter,'Get mask file',defFile);
if ischar(file)
    theFile = fullfile(path,file);
    [~,fileName,theExt] = fileparts(theFile);
    hWait = waitbar(0.5, 'Loading mask. The bar is not updated. Sorry.', 'WindowStyle', 'modal');
    switch theExt
        case '.mat'
            tmp = load(theFile);
            try
                x = tmp.x;
                y = tmp.y;
                mask = tmp.mask;
                ikle = tmp.ikle;
            catch
                errordlg('Invalid format for .mat file');
                return;
            end
    end
    close(hWait);
    handles = addMask(handles,x,y,mask,ikle,fileName);
    handles.theFile = theFile;
end
handles = updateView(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function MENU_saveMask_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_saveMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'theFile')
    defFile = handles.theFile;
else
    defFile = '';
end
theFilter = {'*.mat';'*.slf'};
[file,path]=uiputfile(theFilter,'Get data file',defFile);
if ischar(file)
    theFile = fullfile(path,file);
    [~,~,theExt] = fileparts(theFile);
    [x,y,mask,ikle] = getMaskData(handles,maskLayer(handles),false); %#ok<ASGLU>
    switch theExt
        case '.mat'
            save(theFile,'x','y','mask','ikle');
        case '.slf'
            varNames = {'MASK                            '};
            z = double(mask);
            sct = Telemac.makeSct(ikle,[x y],z,varNames);
            fid = telheadw(sct,theFile);
            fid = telstepw(sct,fid);
            fclose(fid);
            
    end
    handles.theFile = theFile;
end
guidata(hObject,handles)


% --------------------------------------------------------------------
function MENU_setOtherMesh_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_setOtherMesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);
[~,~,mask] = getMaskData(handles);
[x,y,z,ikle] = getMeshData(handles);
if numel(mask)~=numel(x)
    errordlg('The mask is on different mesh. Remake the mask for the current mesh.');
    return;
end


[xTo,yTo,zTo,ikleTo] = getMeshData(handles,meshLayerTo(handles));

if numel(xTo)~=numel(x) ||max(hypot(xTo-x,yTo-y))>1e-3
    hWait = waitbar(0,'Interpolating data. Bar is not updated.');
    sctInterp = Triangle.interpTrianglePrepare(ikleTo,xTo,yTo,x,y,true,true);
    zTo = Triangle.interpTriangle(sctInterp,zTo);
    close(hWait);
end



% find closest point
answer = questdlg('Click to select zones');
if strcmpi(answer,'cancel')
    return;
else
    useClump = strcmpi(answer,'yes');

end
if useClump
    [handles,indexCon,nrCon]  = getCon(handles);
    while true
        [xP,yP,wP] = fastGinput(1);
        % stop on right click
        if wP~=1
            break
        end
        [~,indStart] = min((x-xP).^2+(y-yP).^2);
        % select areas
        indClump  =  Triangle.findClump(ikle,[x y],mask,indStart,indexCon,nrCon);
        
        z(indClump) = zTo(indClump);
        
        handles = setMeshData(handles,z);
        % update
        handles = updateView(handles);
        guidata(hObject,handles);
    end
else
    z(mask) = zTo(mask);
    
    handles = setMeshData(handles,z);
    % update
    handles = updateView(handles);
    guidata(hObject,handles);
end

% update
handles = updateView(handles);
guidata(hObject,handles);


% --------------------------------------------------------------------
function MENU_interpMesh_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_interpMesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles = saveState(handles);
[x,y,z,ikle,name] = getMeshData(handles);
[~,~,mask]        = getMaskData(handles);
if numel(mask) ~=numel(x)
    errordlg('Mask was made for a different mesh. Make a new mask for the correct mesh');
    return;
end

% get mask
uiwait(msgbox('Select area where to interpolate'));
pause(0.1);
[xPoly,yPoly]  = UserInput.getPoly(true);
maskPoly  = inpoly([x,y],[xPoly',yPoly']);



myInterp = makeInterpolator(x(~maskPoly&mask),y(~maskPoly&mask),z(~maskPoly&mask));


% interpolate
z(maskPoly) = myInterp(x(maskPoly),y(maskPoly));
handles = setMeshData(handles,z);

% update
handles = updateView(handles);
guidata(hObject,handles);



% --------------------------------------------------------------------
function MENU_interpMesh2Mesh_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_interpMesh2Mesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = saveState(handles);
[x,y,z,ikle,name] = getMeshData(handles);
[~,~,mask]        = getMaskData(handles);
if numel(mask) ~=numel(x)
    errordlg('Mask was made for a different mesh. Make a new mask for the correct mesh');
    return;
end

[xTo,yTo,zTo,ikleTo] = getMeshData(handles,meshLayerTo(handles));

sctInterp = Triangle.interpTrianglePrepare(ikleTo,xTo,yTo,x(mask),y(mask),true,true);
z(mask) = Triangle.interpTriangle(sctInterp,zTo);


% update
handles = setMeshData(handles,z);
handles = updateView(handles);
guidata(hObject,handles);


% --- Executes on button press in PB_undo.
function PB_undo_Callback(hObject, eventdata, handles)
% hObject    handle to PB_undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles = resetState(handles);
handles = updateView(handles);
guidata(hObject,handles);

% for UNDO
function handles = resetState(handles)
if isfield(handles,'meshLayerPrev')
    handles.meshLayer  = handles.meshLayerPrev;
end
if isfield(handles,'dataLayerPrev')
    handles.dataLayer = handles.dataLayerPrev;
end
if isfield(handles,'lineLayerPrev')
    handles.lineLayer = handles.lineLayerPrev;
end
if isfield(handles,'maskLayerPrev')
    handles.maskLayer = handles.maskLayerPrev;
end

function handles = saveState(handles)
if isfield(handles,'meshLayer')
    handles.meshLayerPrev  = handles.meshLayer;
end
if isfield(handles,'dataLayer')
    handles.dataLayerPrev = handles.dataLayer;
end
if isfield(handles,'lineLayer')
    handles.lineLayerPrev = handles.lineLayer;
end
if isfield(handles,'maskLayer')
    handles.maskLayerPrev = handles.maskLayer;
end


% --- Executes on selection change in PU_colorbar.
function PU_colorbar_Callback(hObject, eventdata, handles)
% hObject    handle to PU_colorbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PU_colorbar contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PU_colorbar


% --- Executes during object creation, after setting all properties.
function PU_colorbar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PU_colorbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PU_shading.
function PU_shading_Callback(hObject, eventdata, handles)
% hObject    handle to PU_shading (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PU_shading contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PU_shading


% --- Executes during object creation, after setting all properties.
function PU_shading_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PU_shading (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function MENU_rubberStamp_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_rubberStamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



handles = saveState(handles);

%ask filter size 
answer = inputdlg({'Give the window size in m'},'Window size',1,{'200'});
if isempty(answer)
     return
end
windSize = str2double(answer{1});
if isnan(windSize)
     errordlg('Invalid input');
     return;
end
% 
% get data
[x,y,z,ikle,name,sctTel] = getMeshData(handles);
%[handles,indexCon,nrCon]  = getConMesh(handles);
%filter
uiwait(msgbox('Click to select value to use.'));
[xP,yP,w] = fastGinput(1);
if w~=1 
    return
end
mask = x>(xP-windSize) & x<(xP+windSize) & y>(yP-windSize) & y<(yP+windSize);
if sum(mask)<3
    errordlg('not enough data');
end
xTmp = x(mask) - xP;
yTmp = y(mask) - yP;
zTmp = z(mask);
myInterp = makeInterpolator(xTmp,yTmp,zTmp);

uiwait(msgbox('Mask selected. Now click to apply'));

while true
    
    [xP,yP,w] = fastGinput(1);
    if w~=1
        break
    end
    mask = x>(xP-windSize) & x<(xP+windSize) & y>(yP-windSize) & y<(yP+windSize);
    if sum(mask)>0
        xTmp = x(mask) - xP;
        yTmp = y(mask) - yP;
        z(mask) = myInterp(xTmp,yTmp);
        
        % update data
        handles = setMeshData(handles,z);
        handles = updateView(handles);
    end
end

guidata(hObject,handles);


% --------------------------------------------------------------------
function MENU_statStamp_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_statStamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles = saveState(handles);

%ask filter size 
answer = inputdlg({'Give the operation to perform. Options are MIN, MAX, MEAN, MEDIAN'},'Stat type',1,{'MIN'});
if isempty(answer)
     return
end
statType = answer{1};
% 
% get data
[x,y,z,ikle,name,sctTel] = getMeshData(handles);
[handles,indexCon,nrCon]  = getConMesh(handles);
%filter


while true
    
    [xP,yP,w] = fastGinput(1);
    [~,i]  = min(hypot(x-xP,y-yP));
    if w~=1
        break
    end
    ind = (indexCon(i,1:nrCon(i)));
    
    switch lower(statType)
        case 'min'
            z(i) = min(z(ind));
        case 'max'
            z(i) = max(z(ind));
        case 'mean'
            z(i) = mean(z(ind));
        case 'median'
            z(i) = median(z(ind));
        otherwise
            errrodlg('Invalid input');
            return
    end
    
    handles = setMeshData(handles,z);
    handles = updateView(handles);
    guidata(hObject,handles);
end


% --------------------------------------------------------------------
function MENU_addLine2Line_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_addLine2Line (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = saveState(handles);

[x,y,z] = getLineData(handles);

%uiwait(msgbox('Select start and end point of each line you want to use for extracting data. Finish with right mouse button.','Extract data','modal'));
answer = questdlg('Is the line closed','Closed line');
switch lower(answer)
    case 'yes'
        isClosed = true;
    case 'no'
        isClosed = false;
    otherwise
        return;
end
while true
    [xPoly,yPoly]  = UserInput.getPoly(isClosed);
    clipboard('copy',[xPoly',yPoly']);
    x{end+1} = xPoly'; %#ok<AGROW>
    y{end+1} = yPoly'; %#ok<AGROW>
    z{end+1} = ones(size(xPoly))';  %#ok<AGROW>
    
    
    handles  = setLineData(handles,x,y,z);
    updateView(handles);
    answer = questdlg('Add another line');
    if strcmpi(answer,'no')
        break;
    end
end

guidata(hObject,handles);
% --------------------------------------------------------------------
function MENU_changeName_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_changeName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% TODO; only ask if layer exist (i.e not empty)
[~,~,~,~,maskName] = getMaskData(handles);
[~,~,~,lineName] = getLineData(handles);
[~,~,~,~,meshName] = getMeshData(handles);
[~,~,~,pointName] = getPointData(handles);

defaultName = {meshName;lineName;pointName;maskName};
answer = inputdlg({'Mesh layer name';'Line layer name';'Data layer name';'Mask layer name'},'Change names',[1 1 1 1]',defaultName);
if isempty(answer)
    return
end
%
meshName = answer{1};
if ~isempty(meshName)
    iLayer = meshLayer(handles);
    handles.meshLayer(iLayer).name = meshName;
    handles.LB_meshLayer.String{iLayer} = meshName;
    handles.LB_layerTo.String{iLayer} = meshName;
end

% and so for the others
msgbox('Only implemented for the mesh name.');

% set varaibles names
guidata(hObject,handles);


% --------------------------------------------------------------------
function MENU_fieldName_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_fieldName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


iLayer = meshLayer(handles);
sctTel = handles.meshLayer(iLayer).sctTel;

% make listbox to ask
[indexVar,trueFalse] = listdlg('PromptString','Select a variable',...
                           'SelectionMode','single',...
                           'ListString',sctTel.RECV);
if ~trueFalse || isempty(indexVar)
    return
end
varName = sctTel.RECV{indexVar};
varName = strtrim(varName(1:16));

%set value
handles.fieldName = varName;
handles = updateView(handles);
guidata(hObject,handles);
