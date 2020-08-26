% TODO:

%1) INTERPOLATION FORA differenc eplots
%2) improve guiver in case multiple view have the same extend (now double vectors)

% 1.) test two plots + saving
% 2.) interpolation of profiles in case two different meshes are used
% 3.) less used functionalities (histogram ellips)
% 4.) vertical profilesd
% 5.) time series
% 6.) check of the time is comparible
% 7.) finsih zoom problem i.e using     setAllowAxesZoom(handles.figure1,handles.hMap2,false)
% 8.) make useGretel array such that not all files need to have gretel



function varargout = viewModel(varargin)
% VIEWMODEL MATLAB code for viewModel.fig
%      VIEWMODEL, by itself, creates a new VIEWMODEL or raises the existing
%      singleton*.
%
%      H = VIEWMODEL returns the handle to a new VIEWMODEL or the handle to
%      the existing singleton*.
%
%      VIEWMODEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWMODEL.M with the given input arguments.
%
%      VIEWMODEL('Property','Value',...) creates a new VIEWMODEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before viewModel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to viewModel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help viewModel

% Last Modified by GUIDE v2.5 18-Jun-2020 16:51:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @viewModel_OpeningFcn, ...
    'gui_OutputFcn',  @viewModel_OutputFcn, ...
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


% --- Executes just before viewModel is made visible.
function viewModel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to viewModel (see VARARGIN)

% Choose default command line output for viewModel
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes viewModel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = viewModel_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in PB_forward.
function PB_forward_Callback(hObject, eventdata, handles)
% hObject    handle to PB_forward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global play;
play = true;

[speed, step, stride] = getSpeed(handles);

tmpHandles = handles;
while play
    step = step+stride;
    if step>handles.sctData.NSTEPS
        break
    end
    tmpHandles = updateData(tmpHandles,step);
    tmpHandles = plotData(tmpHandles);
    drawnow;
    pause(speed)
    
end
handles = tmpHandles;
guidata(hObject,handles);

function [totStr,varStr,unitStr] = getVarString(handles,varName,isZ)
% get variable name
if isZ
    ind = handles.indZ;
else
    ind = handles.ind;
end

varStr  = strtrim(handles.(varName).RECV{ind}(1:16));
unitStr = strtrim(handles.(varName).RECV{ind}(17:32));
totStr =  [lower(varStr),' [',lower(unitStr),']'];

% TODO: replace with nice looking string


function handles = getLayer(handles)
% get the number of the layer
global play;
tmp = str2double(get(handles.ET_Layer,'String'));
if isnan(tmp)
    errordlg('Invalid input for layer nr');
    play = false;
    return
end
handles.layerNr = round(tmp);
if handles.layerNr<1 || handles.layerNr>handles.sctData.NPLAN
    handles.layerNr = nan;
    errordlg(['Invalid input for layer nr. Must be between 1 and ',num2str(handles.sctData.NPLAN)]);
    play = false;
    return
end

function [speed, step, stride] = getSpeed(handles)
% get data from gui

% get data
global play;
speed  = 0.5;
step   = 1;
stride = 1;

tmp = str2double(get(handles.ET_speed,'String'));
if isnan(tmp)
    errordlg('Invalid input for speed');
    play = false;
    return
end
speed = tmp;

tmp = str2double(get(handles.ET_timeStep,'String'));
if isnan(tmp)
    errordlg('Invalid input for step');
    play = false;
    return
end
step = round(tmp);

tmp = str2double(get(handles.ET_stride,'String'));
if isnan(tmp)
    errordlg('Invalid input for stride');
    play = false;
    return
end
stride = round(tmp);



% --- Executes on button press in PB_back.
function PB_back_Callback(hObject, eventdata, handles)
% hObject    handle to PB_back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get data

global play;
play = true;

[speed, step, stride] = getSpeed(handles);

tmpHandles = handles;
while play
    step = step-stride;
    if step<1
        break
    end
    tmpHandles = updateData(tmpHandles,step);
    tmpHandles = plotData(tmpHandles);
    drawnow;
    pause(speed)
    
end
handles = tmpHandles;
guidata(hObject,handles);

% --- Executes on button press in PB_last.
function PB_last_Callback(hObject, eventdata, handles)
% hObject    handle to PB_last (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global play;
play = false;
handles = updateData(handles,handles.sctData.NSTEPS);
handles = plotData(handles);
guidata(hObject,handles);

% --- Executes on button press in PB_first.
function PB_first_Callback(hObject, eventdata, handles)
% hObject    handle to PB_first (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global play;
play = false;
handles = updateData(handles,1);
handles = plotData(handles);
guidata(hObject,handles);


function ET_speed_Callback(hObject, eventdata, handles)
% hObject    handle to ET_speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ET_speed as text
%        str2double(get(hObject,'String')) returns contents of ET_speed as a double


% --- Executes during object creation, after setting all properties.
function ET_speed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ET_speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ET_timeStep_Callback(hObject, eventdata, handles)
% hObject    handle to ET_timeStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ET_timeStep as text
%        str2double(get(hObject,'String')) returns contents of ET_timeStep as a double


% --- Executes during object creation, after setting all properties.
function ET_timeStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ET_timeStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ET_min_Callback(hObject, eventdata, handles)
% hObject    handle to ET_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ET_min as text
%        str2double(get(hObject,'String')) returns contents of ET_min as a double


% --- Executes during object creation, after setting all properties.
function ET_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ET_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ET_max_Callback(hObject, eventdata, handles)
% hObject    handle to ET_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ET_max as text
%        str2double(get(hObject,'String')) returns contents of ET_max as a double


% --- Executes during object creation, after setting all properties.
function ET_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ET_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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

% --- Executes on button press in PB_apply.

function PB_apply_Callback(hObject, eventdata, handles)
% hObject    handle to PB_apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = applyH(handles);
guidata(hObject,handles);

function [step,ok] = getStep(handles)
% get time step
tmp = str2double(get(handles.ET_timeStep,'String'));
if isnan(tmp)
    errordlg('Invalid input for time step');
    ok = false;
    return
end
step = round(tmp);
ok = true;


function handles = applyH(handles)

[step,ok] = getStep(handles);

global play;
play = false;
if ok
    [handles,ok] = updateData(handles,step);
    if ok
        handles = plotData(handles);
    end
end


function [ind,xyProf,handles] = getLoc(handles,isClosed)
% select nearest node based on list of coordinates or clicking
%
% getLoc(handles,isClosed)
%
% INPUT:
% - handles: gui data structure
% - isClosed: if true the polygon is closed
%
% OUTPUT
% - ind: node number of nearest nodes
% - xyProf: x and y coordinates of the clicked points

if nargin ==1
    isClosed = false;
end

buttonName = questdlg('Click to select locations?', 'Select by clicking');
ind = [];
xyProf = [];
switch upper(buttonName)
    case 'YES'
        % get locations from clicking
        xprof = [];
        yprof = [];
        i = 1;
        
        set(handles.figure1,'CurrentAxes',handles.hMap);
        hold on;
        while 1
            [x0,y0,w] = fastGinput(1);
            if w~=1
                break;
            end
            xprof(i)=x0; %#ok<AGROW>
            yprof(i)=y0; %#ok<AGROW>
            % temporary plot
            plot(x0,y0,'mo');
            text(x0,y0,num2str(i));
            i = i+1;
        end
        
    case 'NO'
        % get xy and y coordinates from a dialog
        if isfield(handles,'xyPoin')
            defAns = {num2str(handles.xyPoin)};
        else
            defAns = {''};
        end
        cTmp = inputdlg({'Give x and y coordinates of time series (each line should contain one x and y coordinate)'},'Time series coordinates',10,defAns);
        if isempty(cTmp)
            return
        end
        xy   = str2num(cTmp{1}); %#ok<ST2NM>
        if isempty(xy)
            errordlg('Invalid coordinates!');
            return
        end
        xprof = xy(:,1)';
        yprof = xy(:,2)';
        % temporary plot
        if get(handles.CB_m2km,'Value')
            plot(xprof/1000,yprof/1000,'mo');
            text(xprof/1000,yprof/1000,num2str((1:length(xprof))'));
        else
            plot(xprof,yprof,'mo');
            text(xprof,yprof,num2str((1:length(xprof))'));
        end
        
        
    case 'CANCEL'
        return;
end

xyProf = [xprof' yprof'];
if ~isClosed
    clipboard('copy',[xprof' yprof' ind]);
    handles.xyPoin = xyProf;
else
    % close polygon
    xyProf = [xyProf; xyProf(1,:)];
end
ind = getNearestNode(handles,xprof,yprof);
if any(isnan(ind))
    errordlg('Some points are outside the domain. Click better next time.');
end

function ind = getNearestNode(handles,xprof,yprof,varName2D)
% find nearest neigbour
%
%ind = getNearestNode(handles,xprof,yprof,varName2D)
%
%

if nargin<4
    varName2D = 'sctData2D';
end

tri = handles.(varName2D).IKLE;
x   = handles.(varName2D).XYZ(:,1);
y   = handles.(varName2D).XYZ(:,2);
myTri = triangulation(double(tri), x,y);

if ~isempty(xprof)
    xprof = Util.makeColVec(xprof);
    yprof = Util.makeColVec(yprof);
    ind = nearestNeighbor(myTri,[xprof,yprof]);
else
    ind = 0;
    return;
end

% delete points outside the domain
% first is complete domain
[~, xObc,yObc] = Telemac.getBoundary(handles.(varName2D),true);
xyObc   = [xObc{1},yObc{1}];
mask = inpoly([xprof,yprof],xyObc);
ind(~mask) = nan;
% rest are islands
for i=2:length(xObc)
    xyObc   = [xObc{i},yObc{i}];
    mask = inpoly([xprof,yprof],xyObc);
    ind(mask) = nan;
end



function [handles,indList,indEq,nrStride] = getIndA(handles)
% helper to get variable index
handles.ind = get(handles.LB_var,'Value');
handles = getLayer(handles);
nbv = handles.sctData.NBV;
if handles.ind>nbv
    indList = handles.sctData.indList{handles.ind};
    indEq   = handles.sctData.indEq{handles.ind};
else
    indList = handles.ind;
    indEq = @(x) x{1};
end
tmp = str2double(get(handles.ET_stride,'String'));
if isnan(tmp)
    errordlg('Invalid input for stride');
    return
end
nrStride = round(tmp);

function newList = getIndB(handles,oldList)
% helper to get variable index second variable

oldVar = handles.sctData.RECV(oldList);
newVars= handles.sctData2.RECV;
for i=length(oldVar):-1:1
    tmp = find(strcmpi(oldVar{i},newVars));
    if length(tmp)<1
        newList = [];
        errordlg(['Variable ',oldVar{i},' not found']);
        return;
    elseif length(tmp)>1
        msgbox(['Duplicate variable ',oldVar{i}]);
    end
    newList(i) = tmp(1);
end

function ind = getIndC(handles,iPlot)
% wrapper to get index value for all cases
if iPlot>1
    ind = getIndB(handles,handles.ind);
    if isempty(ind)
        return;
    end
else
    ind = handles.ind;
end

function [startDate,endDate] = getDate(handles)
% gets start and end date
startDate = datenum(handles.sctData.IDATE);
if isempty(startDate)
    startDate = 0;
end
endDate   = startDate + handles.sctData.DT*(handles.sctData.NSTEPS-1)/86400;
endDate = datenum(datestr(endDate,'yyyy-mm-dd HH:MM:SS'),'yyyy-mm-dd HH:MM:SS'); % round off




% --- Executes on button press in PB_time_series.
function PB_time_series_Callback(hObject, eventdata, handles)
% hObject    handle to PB_time_series (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if handles.useGretel
%     errordlg('Not yet implnmented for unimplemented data. Please buy me a beer if you need this.');
%     return;
% end

[handles,indList1,indEq,nrStride] = getIndA(handles);

% get data points


[indNode,xyProf,handles] = getLoc(handles);
if isempty(indNode) || any(indNode==0) || any(isnan(indNode))
    return
end
guidata(hObject,handles);


% select start and end date
[startDate,endDate] = getDate(handles);

is3D = handles.sctData.NPLAN>1;

if is3D
    prompt{4}    = 'Plot all layers as colormap? [1 = yes] [0 = no]';
    initAns{4}   = '1';
end
prompt{3}    = 'Select plot type. 1: time series; 2: histogram; 3: polar plot (ellips)';
prompt{2}    = ['Select the end date between ',datestr(startDate),' and ',datestr(endDate),' in the format yyyy-mm-dd HH:MM:SS'];
prompt{1}    = ['Select the start date between ',datestr(startDate),' and ',datestr(endDate),' in the format yyyy-mm-dd HH:MM:SS'];
initAns{1} = datestr(startDate,'yyyy-mm-dd HH:MM:SS');
initAns{2} = datestr(endDate,'yyyy-mm-dd HH:MM:SS');
initAns{3} = '1';
cTmp      = inputdlg(prompt,'Period',1,initAns);
if isempty(cTmp)
    return
end
try
    startTs = datenum(cTmp{1},'yyyy-mm-dd HH:MM:SS');
catch
    errordlg('Invalid start date');
    return;
end
try
    endTs = datenum(cTmp{2},'yyyy-mm-dd HH:MM:SS');
catch
    errordlg('Invalid end date');
    return;
end
tsType = str2double(cTmp{3});
if isnan(tsType) || ~any(tsType==1:3)
    errordlg('Invalid plot type');
    return;
end
if is3D
    plotAll = str2double(cTmp{4});
    if isnan(plotAll) || ~any(plotAll==[0 1])
        errordlg('Invalid input for plot all layers');
        return;
    end
    % only data per layer for tidal plots
    if tsType==3
        plotAll = 0;
    end
else
    plotAll = 0;
end

%make sure that MAGNITDUE is slected for tidal plor
if tsType==3
    if isempty(regexp(handles.sctData.RECV{handles.ind},' MAG'))
        errordlg('Select a magnitude in order to use a polar plot');
        return;
    end
    if ~isempty(get(handles.ET_equation,'String'))
        msgbox('Equations are ignored for polar plots');
    end
end


if startTs<startDate || startTs>endDate
    errordlg(['The start date must be between ',datestr(startDate),' and ',datestr(endDate)]);
    return;
end

if endTs<startDate || endTs>endDate
    errordlg(['The end date must be between ',datestr(startDate),' and ',datestr(endDate)]);
    return;
end


lineStyle = {'-','--'};
%legend text
for i=1:length(indNode)
    cLeg{i} = ['Point ',num2str(i)];
end

% loop over all plots if needed
if handles.CB_compare.Value
    nrPlot = 2;
else
    nrPlot = 1;
end
allVar = {'sctData','sctData2'};
for iPlot=1:nrPlot
    
    if iPlot>1
        indList = getIndB(handles,indList1);
        indName = getIndB(handles,handles.ind);
    else
        indList = indList1;
        indName = handles.ind;
    end
    varName = allVar{iPlot};
    varName2d = [varName,'2D'];
    parName = [varName,'Partial'];
    if iPlot>1
        indNode = getNearestNode(handles,xyProf(:,1),xyProf(:,2),varName2d);
    end
    
    hWait = waitbar(0,'extracting data');
    
    startInd = round((startTs-startDate)*86400/handles.(varName).DT +1);
    endInd   = round((endTs-startDate)*86400/handles.(varName).DT+1);
    
    
    
    % extract data
    waitbar(0.1,hWait);
    tStart = datenum(handles.(varName).IDATE);
    if isempty(tStart)
        tStart = 0;
    end
    t    = tStart+Telemac.getTime(handles.(varName),startInd:nrStride:endInd)/86400;
    if length(t)<2
        errordlg('Not enough time steps are selected');
        return
    end
    waitbar(0.3,hWait);
    
    
    if is3D && plotAll
        handles.indZ = Telemac.findVar({'ELEVATION Z'},handles.(varName));
        t = repmat(t,1,handles.(varName).NPLAN);
        for i = length(indNode):-1:1
            pointList = indNode(i) + (0:handles.(varName).NPLAN-1).*handles.(varName).NPOIN/handles.(varName).NPLAN;
            for iInd = length(indList):-1:1
                if handles.useGretel(iPlot)
                    tmp{iInd}  = Telemac.getDataGretel(handles.(parName),startInd:nrStride:endInd,pointList,indList(iInd),handles.procNr{iPlot},handles.locNr{iPlot});
                else
                    tmp{iInd}  = Telemac.getData(handles.(varName),startInd:nrStride:endInd,pointList,indList(iInd));
                end
            end
            tmp  = indEq(tmp);
            if handles.useGretel(iPlot)
                z{i} = Telemac.getDataGretel(handles.(parName),startInd:nrStride:endInd,pointList,handles.indZ,handles.procNr{iPlot},handles.locNr{iPlot});
            else
                z{i} = Telemac.getData(handles.(varName),startInd:nrStride:endInd,pointList,handles.indZ );
            end
            c{i} = applyEq(handles,tmp);
            clear tmp;
        end
    else
        if is3D
            indNode = indNode + (handles.layerNr-1).*handles.(varName).NPOIN/handles.(varName).NPLAN;
        end
        for iInd = length(indList):-1:1
            if handles.useGretel(iPlot)
                tmp{iInd}  = Telemac.getDataGretel(handles.(parName),startInd:nrStride:endInd,indNode,indList(iInd),handles.procNr{iPlot},handles.locNr{iPlot});
            else
                tmp{iInd}  = Telemac.getData(handles.(varName),startInd:nrStride:endInd,indNode,indList(iInd));
            end
        end
        tmpEq  = indEq(tmp);
        data = applyEq(handles,tmpEq);
    end
    close(hWait);
    
    
    % plot
    
    switch tsType
        case 1
            % time series
            if handles.(varName).NPLAN>1&& plotAll
                % 3d contourplot
                UtilPlot.reportFigureTemplate('portrait',22);
                for i = length(indNode):-1:1
                    hAx(i) = subplot(length(indNode),1,i);
                    pcolor(t,z{i},c{i})
                    shading(handles.shading);
                    colorbar;
                    dynamicDateTicks();
                    ylabel(getVarString(handles,varName,true));
                    if (i==length(indNode))
                        xlabel('Time');
                    end
                end
                linkaxes(hAx,'x');
                
            else
                % 2d plot
                % TODO: add plot number
                if iPlot==1
                    UtilPlot.reportFigureTemplate
                    hold on
                    cLegAll = cLeg;
                else
                    cLegAll = [cLegAll,cLeg];
                end
                plot(t,data,lineStyle{iPlot});
                
                if iPlot==nrPlot
                    legend(cLegAll,'location','best');
                    
                    grid on
                    dynamicDateTicks
                    xlabel('Time')
                    ylabel(getVarString(handles,varName,false));
                    if is3D
                        title(num2str(handles.layerNr,'Layer %d'));
                    end
                end
            end
        case 2
            % histogram
            for i = 1:length(indNode)
                nrBin = 100;
                UtilPlot.reportFigureTemplate
                grid on
                if handles.(varName).NPLAN>1&& plotAll
                    hist(c{i}(:),nrBin);
                else
                    hist(data(:,i),nrBin);
                end
                xlabel('Nr of occurances')
                ylabel(getVarString(handles,varName,false));
                if is3D
                    title(num2str(handles.layerNr,'Layer %d'));
                end
            end
        case 3
            % tidal plot
            myC = 'rgbcymk';
            UtilPlot.reportFigureTemplate
            hold on;
            plotOptions.plotAxis = 1;
            
            plotOptions.unitString = getVarString(handles,varName,false);%
            plotOptions.unitString = plotOptions.unitString(17:end);%
            plotOptions.thetaLimitTic = 45;
            plotOptions.rLimit = handles.cLim(2);
            plotOptions.rLimitTick = 0.25*round(plotOptions.rLimit);
            Plot.plotPolar([], [], plotOptions);
            plotOptions.plotAxis = 0;
            for i=1:size(tmp{1},2)
                [theta,radius] = Calculate.calcDir(tmp{1}(:,i),tmp{2}(:,i));
                Plot.plotPolar(theta, radius, plotOptions);
                ii = mod(i-1,length(myC))+1;
                plotOptions.lineStyle = myC(ii);
            end
    end
    title(handles.(varName).RECV{indName});
end

function [handles, ok] = extractProf(handles)
% handles gui to extract a profile
%

ok = false;
set(0,'CurrentFigure',handles.figure1);
set(handles.figure1,'CurrentAxes',handles.hMap);
hold on;
handles.ind = get(handles.LB_var,'Value');

% see if exisiting propfile if used

if isfield(handles,'i2s')
    buttonName = questdlg('Use loaded i2s; Note that you have to extract again if you change the i2s. File This is not yet automatic. sorry.', 'Select by i2s');
    switch upper(buttonName)
        case 'YES'
            usei2s = true;
        case 'NO'
            usei2s = false;
        case 'CANCEL'
            return;
    end
else
    usei2s = false;
end

if usei2s
    % use loaded profile
    % TODO show all
    tmp = handles.LB_i2s.Value;
    if ~isempty(tmp)
        ind =tmp(1);
        handles.xprof = handles.i2s{ind}{1}(:,1);
        handles.yprof = handles.i2s{ind}{1}(:,2);
    else
        errordlg('No i2s file selected');
        ok = false;
        return;
    end
else
    % select profile
    buttonName = questdlg('Click to select locations?', 'Select by clicking');
    switch upper(buttonName)
        case 'YES'
            %uiwait(msgbox('Select start and end point of each line you want to use for extracting data. Finish with right mouse button.','Extract data','modal'));
            [xPoly,yPoly]  = UserInput.getPoly();
            handles.xyPoly = [xPoly',yPoly'];
            clipboard('copy',[xPoly',yPoly']);
        case 'NO'
            % get xy and y coordinates from a dialog
            
            if isfield(handles,'xyPoly')
                defaulInp = {num2str(handles.xyPoly)};
            else
                defaulInp = {''};
            end
            cTmp = inputdlg({'Give x and y coordinates of polyline (each line should contain one x and y coordinate)'},'Profile coordinates',20,defaulInp);
            if isempty(cTmp)
                return
            end
            xy   = str2num(cTmp{1});
            if isempty(xy)
                errordlg('Invalid coordinates!');
                return
            end
            handles.xyPoly = xy;
            xPoly = xy(:,1)';
            yPoly = xy(:,2)';
            % temporary plot
            if get(handles.CB_m2km,'Value')
                plot(xPoly/1000,yPoly/1000,'m-o');
            else
                plot(xPoly,yPoly,'m-o');
            end
        case 'CANCEL'
            return;
    end
    
    handles.xprof = xPoly;
    handles.yprof = yPoly;
end


cellAns = inputdlg('Enter resampling distance.','Resample',1,{'10'});
if isempty(cellAns)
    return
end
dx = (str2double(cellAns{1}));
if isnan(dx) || dx<=0.0
    errordlg('Distance is invalid');
    return
end

% delete old data if neede
if isfield(handles,'sctInterp')
    handles = rmfield(handles,'sctInterp');
    handles = rmfield(handles,'dist');
end


% store data
handles.dx = dx;
ok = true;

function handles = resInterp(handles,varName2d,iPlot)
% resample and interpolate


dx    = handles.dx;
xPoly = handles.xprof;
yPoly = handles.yprof;

ikle = handles.(varName2d).IKLE;
x    = handles.(varName2d).XYZ(:,1);
y    = handles.(varName2d).XYZ(:,2);
[xTmp,yTmp] = Resample.resamplePolyline(xPoly,yPoly,dx);
if length(xTmp)<10
    errordlg('Too large value for the resampling distance');
    return;
end
handles.sctInterp(iPlot)  = Triangle.interpTrianglePrepare(ikle,x,y,xTmp,yTmp);
handles.dist{iPlot} = [0;cumsum(sqrt(diff(xTmp).^2 + diff(yTmp).^2 ))];
handles.distXy{iPlot} = [xTmp,yTmp];
tmp = atan2(diff(yTmp),diff(xTmp))';
tmp = [tmp,tmp(end)];
handles.dirprof{iPlot} = tmp;


% --- Executes on button press in PB_extract.
function PB_extract_Callback(hObject, eventdata, handles)
% hObject    handle to PB_extract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



[handles,ok] = extractProf(handles);
if ~ok
    return;
end

if handles.CB_compare.Value
    nrPlot = 2;
else
    nrPlot = 1;
end
allVar = {'sctData','sctData2'};
for iPlot=1:nrPlot
    varName = allVar{iPlot};
    varName2d = [varName,'2D'];
    handles   = resInterp(handles,varName2d,iPlot);
end

handles = plotData(handles);

guidata(hObject,handles);


function plotProfLoc(handles)
% plot the locations of the profiles

if isfield(handles,'xprof')
    hold on
    if get(handles.CB_m2km,'Value')
        handles.xprof =  handles.xprof/1000;
        handles.yprof =  handles.yprof/1000;
    end
    
    x = handles.xprof;
    y = handles.yprof;
    plot(x,y,'m-o','linewidth',1.5);
    % TODO: check numering
    text(x(1),y(1),num2str(1),'fontsize',6,'color','k');
    
end


function handles = plotProfile(handles,hAx,varName,iPlot)
% plots a profile in the top

if ~isfield(handles,'sctInterp')
    return
end

[x,y,z,u,v] = extractProfData(handles,varName,iPlot);



set(get(hAx,'parent'),'currentaxes',hAx)
cla(hAx);

if handles.(varName).NPLAN>1 
    % 3d plot
    xProf = handles.dist{iPlot};
    ind = getIndC(handles,iPlot);
    if (~handles.CB_transectLine.Value)
        pcolor(x,y,z);
        set(handles.hProf,'xlim',[min(x(:)) max(x(:))])
        set(handles.hProf,'ylim',[min(y(:)) max(y(:))])
        caxis(handles.cLim)
        
        handles.indZ = Telemac.findVar({'ELEVATION Z'},handles.(varName));
        ylabel(getVarString(handles,varName,true));

        title(strtrim(handles.(varName).RECV{ind}));
        colorbar('tag',['cbProf',num2str(iPlot)]);
        shading(handles.shading);
        
        % add indictation of the layer
        yProf = y(:,handles.layerNr);
        hold on;
        plot(xProf,yProf,'k-');
        
        % add quiver if needed
        if get(handles.CB_quiver,'Value')
            % TODO: make separate scaling
            % TODO: add stride to GUI
            st = 3;
            % plot
            hold on
            quiver(x(1:st:end,:),y(1:st:end,:),u(1:st:end,:),v(1:st:end,:),0,'k','ShowArrowHead','on','MaxHeadSize',0.0005);
        end
        % set vertical limit if needed
        if ~isempty(handles.zLim)
            ylim(handles.zLim);
        end
    else
        set(gca,'colorOrderIndex',1)
        plot(x,z(:,handles.layerNr),'b');
        ylim(handles.cLim);
        grid on;
        ylabel(strtrim(handles.(varName).RECV{ind}));
        title('');
    end
    xlabel('Distance [m]')
else
    %2d plot
    i = iPlot;
    x = handles.dist{i};
    y = z;
    hold on;
    plot(x,y)
    % remainder of old code
    cLeg{1} = ['Transect ',num2str(1)];
    
    xRange = [min(x) max(x)];
    xlim(xRange)
    ylim(handles.cLim)
    legend(cLeg);
    grid on
    xlabel('Distance [m]')
    ylabel(getVarString(handles,varName,false));
end


function [x,y,z,u,v] = extractProfData(handles,varName,iPlot)
% extracts profile data
varName2d = [varName,'2D'];

y = [];
u = [];
v = [];

if handles.(varName).NPLAN>1
    % 3d plot
    handles.indZ = Telemac.findVar({'ELEVATION Z'},handles.(varName));
    ind = getIndC(handles,iPlot);
    
    
    % only firts point is plotted. others are ignored
    i = iPlot;
    xProf = handles.dist{i};
    x = repmat(xProf,1,handles.(varName).NPLAN);
    % get data
    yTmp  = Telemac.convertTelemac3Ddata(handles.(varName2d),handles.indZ);
    zTmp  = Telemac.convertTelemac3Ddata(handles.(varName2d),ind);
    % interpolate
    y = Triangle.interpTriangle(handles.sctInterp(i),yTmp);
    z = Triangle.interpTriangle(handles.sctInterp(i),zTmp);
    z = applyEq(handles,z);
    
    % add indictation of the layer
    yProf = y(:,handles.layerNr);
    hold on;
    plot(xProf,yProf,'k-');
    
    % add quiver if needed
    if get(handles.CB_quiver,'Value')
        
        % get variables
        try
            tmpInd = get(handles.LB_quiver,'Value') ;
            indUv = handles.indQuiver(tmpInd,:);
        catch
            indUv = [];
        end
        if ~isempty(indUv) && iPlot>1
            indUv  = getIndB(handles,indUv);
        end
        try
            indW    = Telemac.findVar({'VELOCITY W'},handles.(varName));
        catch
            indW = [];
        end
        % get data
        if ~isempty(indUv) %&& indW>0
            uTmp = Telemac.convertTelemac3Ddata(handles.(varName2d),indUv(1));
            vTmp = Telemac.convertTelemac3Ddata(handles.(varName2d),indUv(2));
            if ~isempty(indW) && indW>0
                wTmp = Telemac.convertTelemac3Ddata(handles.(varName2d),indW);
            else
                wTmp = zeros(size(uTmp));
            end
            % interpolate
            uInt = handles.vecScale.*Triangle.interpTriangle(handles.sctInterp(i),uTmp);
            vInt = handles.vecScale.*Triangle.interpTriangle(handles.sctInterp(i),vTmp);
            v    = handles.vecScale.*Triangle.interpTriangle(handles.sctInterp(i),wTmp);
            % project on line
            u = Calculate.rotateVector(uInt,vInt,handles.dirprof{iPlot}','radian');
        end
    end
else
    %2d data
    ind = getIndC(handles,iPlot);
    x = handles.dist{iPlot};
    z = Triangle.interpTriangle(handles.sctInterp(iPlot),handles.(varName).RESULT(:,ind));
    z = applyEq(handles,z);
end





% --- Executes on selection change in LB_var.
function LB_var_Callback(hObject, eventdata, handles)
% hObject    handle to LB_var (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LB_var contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LB_var


% --- Executes during object creation, after setting all properties.
function LB_var_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LB_var (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in LB_quiver.
function LB_quiver_Callback(hObject, eventdata, handles)
% hObject    handle to LB_quiver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LB_quiver contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LB_quiver


% --- Executes during object creation, after setting all properties.
function LB_quiver_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LB_quiver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ET_vec_scale_Callback(hObject, eventdata, handles)
% hObject    handle to ET_vec_scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ET_vec_scale as text
%        str2double(get(hObject,'String')) returns contents of ET_vec_scale as a double


% --- Executes during object creation, after setting all properties.
function ET_vec_scale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ET_vec_scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function [quiverVar,indList] = getQuiverVar(sctTel)
% gets variable that can be used in a quiver plot
quiverList =  {'VELOCITY U','VELOCITY V'
    'WIND VELOCITY U','WIND VELOCITY V'
    'WIND ALONG X','WIND ALONG Y'
    'COS MEAN DIR','SIN MEAN DIR'
    'SOLID DISCH XAVG','SOLID DISCH YAVG'
    'SOLID DISCH X','SOLID DISCH Y'
    'FORCE FX','FORCE FY'
    
    };

quiverVar = {};
indList   = [];
n = 0;
for i=1:length(quiverList)
    varListInd = Telemac.findVar(quiverList(i,:),sctTel);
    if all(varListInd>0)
        n = n + 1;
        indList(n,:) = varListInd';
        quiverVar{n} = quiverList{i,1};
    end
end

% --- Executes on button press in PB_load.
function PB_load_Callback(hObject, eventdata, handles)
% hObject    handle to PB_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%

% open file

cFiles ={'*.slf','Selafin file (*.slf)';...
    '*.*','all files (*.*)'};

if (~handles.CB_diff.Value)&& (~handles.CB_compare.Value)
    iFile = 1;
else
    iFile = 2;
end

fileTitle   = 'Select File';
masterTitle = 'Select the masterfile (i.e. the geometry file)';

if isfield(handles,'file')
    [file,path] = uigetfile(cFiles,fileTitle,handles.file);
else
    [file,path] = uigetfile(cFiles,fileTitle);
end
if ischar(file)
    clearFileData(handles,iFile);
    guidata(hObject,handles);
    theFile = fullfile(path,file);
    handles.file = theFile;
    
    tmp = regexp(file,'\d*','match');
    
    if length(tmp)>=2 && length(tmp{end-1})==5 && length(tmp{end})==5
        handles.useGretel(iFile) = true;
    else
        handles.useGretel(iFile) = false;
    end
    if handles.useGretel(iFile)
        % note processor number not allowed. therefore deleted here
        theFile = theFile(1:end-6);
        [file,path] = uigetfile(cFiles,masterTitle,handles.file);
        masterFile = fullfile(path,file);
    end
    guidata(hObject,handles);
    
    if (~handles.CB_diff.Value)&& (~handles.CB_compare.Value)
        % load file
        if handles.useGretel(iFile)
            [handles.sctData, handles.sctDataPartial] = Telemac.telheadrGretel(theFile,masterFile);
        else
            handles.sctData = telheadr(theFile);
        end
        handles = updateData(handles,1);
        % set variables for list bar
        set(handles.LB_var,'Value',1);
        set(handles.LB_contour,'Value',1);
        
        set(handles.LB_var,'String',handles.sctData.RECV)
        set(handles.LB_contour,'String',handles.sctData.RECV)
        [quiverVar,handles.indQuiver] = getQuiverVar(handles.sctData);
        set(handles.LB_quiver,'String',quiverVar)
        
        
        % plot data
        handles.keepLim = false;
        handles = plotData(handles,gcf,{handles.hMap;handles.hProf});
        handles.keepLim = true;
    else
        % load file
        if handles.useGretel(iFile)
            [handles.sctData2, handles.sctData2Partial] = Telemac.telheadrGretel(theFile,masterFile);
        else
            handles.sctData2 = telheadr(theFile);
        end
        % check that they have the same mesh and variables
        if  handles.CB_diff.Value
            if handles.sctData2.NELEM~=handles.sctData.NELEM || handles.sctData2.NPOIN~=handles.sctData.NPOIN
                errordlg('Second mesh has a different mesh topology.');
                return;
            end
            if ~all(strcmpi(handles.sctData2.RECV,handles.sctData.RECV))
                errordlg('Second mesh has different variables.');
                return;
            end
        end
        
      
        handles = updateData(handles,1);
        % plot file
        handles = plotData(handles);
        
    end
    
end

guidata(hObject,handles);


function handles = clearFileData(handles,iVar)
% called on opening

switch iVar
    case 1
        varName = 'sctData';
        parName = 'sctDataPartial';
    case 2
        varName = 'sctData2';
        parName = 'sctData2Partial';
end

%TODO
% if isfield(handles,'sctInterp')
%     handles = rmfield(handles,'sctInterp);
%     handles.dist{iVar} = [];
%     handles.dirprof{iVar} = [];
% end

% close file handles
if isfield(handles,parName)
    for i = 1:length(handles.(parName))
        try
            fclose(handles.(parName)(i).fid);
        catch
        end
    end
end
if isfield(handles,varName)
    try
        fclose(handles.(varName).fid);
    catch
    end
end
if isfield(handles,'sctInterpDiff')
     handles = rmfield(handles,'sctInterpDiff');
end
   





function [handles,ok] = updateData(handles,step)
% updates data

DT = 0.1;
ok = false;

% first file
if step>handles.sctData.NSTEPS
    errordlg('Time step not available in file');
    return
end
% only update if needed
if step ~= handles.sctData.timestep
    handles = updateDataVar(handles,step,'sctData');
end
%file to compare
if handles.CB_diff.Value || handles.CB_compare.Value
    
    % match the times in the two files (assuming the same startdate!);
    if handles.sctData.DT~=handles.sctData2.DT
        hWait = waitbar(0,'Processing times');
        if ~isfield(handles.sctData2,'allTime')
            handles.sctData2.allTime = Telemac.getTime(handles.sctData2);
        end
        waitbar(0,hWait);
        if ~isfield(handles.sctData,'allTime')
            handles.sctData.allTime = Telemac.getTime(handles.sctData);
        end
        close(hWait);
        
        theTime = handles.sctData.allTime(step);
        step2 = find(abs(theTime - handles.sctData2.allTime)<DT);
        if isempty(step2)
            errordlg(['Time ',num2str(theTime),'not found in second file']);
        end
    else
        step2 = step;
        if step2>handles.sctData2.NSTEPS
            errordlg('Time step not available in file2');
            return
        end
    end
    if step2 ~= handles.sctData2.timestep
        handles = updateDataVar(handles,step,'sctData2');
    end
end
ok = true;

function varNr  = varNumber(varName)
% get the number of the variable from a variable name
tmp = str2double(varName(end));
if  isnan(tmp)
    varNr = 1;
else
    varNr = tmp;
end

function handles = updateDataVar(handles,step,varName)
% updates data from telemac file

% read data
varNr = varNumber(varName);
if  handles.useGretel(varNr)
    parName = [varName,'Partial'];
    varNr   = varNumber(varName);
    [handles.(varName),handles.(parName),handles.procNr{varNr},handles.locNr{varNr}] = Telemac.telsteprGretel(handles.(varName),handles.(parName),step);
else
    handles.(varName) = telstepr(handles.(varName),step);
end
% add extra variables

% velocity
ind  = Telemac.findVar({'VELOCITY U','VELOCITY V'},handles.(varName));
nbv = handles.(varName).NBV;
if ind~=0
    u = handles.(varName).RESULT(:,ind(1));
    v = handles.(varName).RESULT(:,ind(2));
    [uDir,uMag]= Calculate.calcDir(u,v);
    
    handles.(varName).RESULT(:,nbv+1) = uMag;
    handles.(varName).RESULT(:,nbv+2) = uDir;
    handles.(varName).RECV{nbv+1} = 'VELOCITY MAG    M/S             ';
    handles.(varName).RECV{nbv+2} = 'VELOCITY DIR    DEG             ';
    handles.(varName).indList{nbv+1} = ind;
    handles.(varName).indEq{nbv+1} = @(z) sqrt(z{1}.^2+z{2}.^2);
    handles.(varName).indList{nbv+2} = ind;
    handles.(varName).indEq{nbv+2} = @(z) Calculate.calcDir(z{1},z{2});
    nbv = nbv + 2;
end

ind  = Telemac.findVar({'SOLID DISCH XAVG','SOLID DISCH YAVG'},handles.(varName));
if ind~=0
    u = handles.(varName).RESULT(:,ind(1));
    v = handles.(varName).RESULT(:,ind(2));
    [uDir,uMag]= Calculate.calcDir(u,v);
    
    handles.(varName).RESULT(:,nbv+1) = uMag;
    handles.(varName).RESULT(:,nbv+2) = uDir;
    handles.(varName).RECV{nbv+1} = 'SOLID DIAVG MAG M2/S            ';
    handles.(varName).RECV{nbv+2} = 'SOLID DIACG DIR DEG             ';
    handles.(varName).indList{nbv+1} = ind;
    handles.(varName).indEq{nbv+1} = @(z) sqrt(z{1}.^2+z{2}.^2);
    handles.(varName).indList{nbv+2} = ind;
    handles.(varName).indEq{nbv+2} = @(z) Calculate.calcDir(z{1},z{2});
    nbv = nbv + 2;
end

ind  = Telemac.findVar({'SOLID DISCH X','SOLID DISCH Y'},handles.(varName));
if ind~=0
    u = handles.(varName).RESULT(:,ind(1));
    v = handles.(varName).RESULT(:,ind(2));
    [uDir,uMag]= Calculate.calcDir(u,v);
    
    handles.(varName).RESULT(:,nbv+1) = uMag;
    handles.(varName).RESULT(:,nbv+2) = uDir;
    handles.(varName).RECV{nbv+1} = 'SOLID DISCH MAG M2/S            ';
    handles.(varName).RECV{nbv+2} = 'SOLID DISCH DIR DEG             ';
    handles.(varName).indList{nbv+1} = ind;
    handles.(varName).indEq{nbv+1} = @(z) sqrt(z{1}.^2+z{2}.^2);
    handles.(varName).indList{nbv+2} = ind;
    handles.(varName).indEq{nbv+2} = @(z) Calculate.calcDir(z{1},z{2});
    nbv = nbv + 2;
end

% wind
ind  = Telemac.findVar({'WIND VELOCITY U','WIND VELOCITY V'},handles.(varName));
if ind == 0
    ind  = Telemac.findVar({'WIND ALONG X','WIND ALONG Y'},handles.(varName));
end
if ind~=0
    u = handles.(varName).RESULT(:,ind(1));
    v = handles.(varName).RESULT(:,ind(2));
    [uDir,uMag]= Calculate.calcDir(u,v);
    
    handles.(varName).RESULT(:,nbv+1) = uMag;
    handles.(varName).RESULT(:,nbv+2) = uDir;
    handles.(varName).RECV{nbv+1} = 'WIND VEL MAG    M/S             ';
    handles.(varName).RECV{nbv+2} = 'WIND VEL DIR    DEG             ';
    handles.(varName).indList{nbv+1} = ind;
    handles.(varName).indEq{nbv+1} = @(z) sqrt(z{1}.^2+z{2}.^2);
    handles.(varName).indList{nbv+2} = ind;
    handles.(varName).indEq{nbv+2} = @(z) Calculate.calcDir(z{1},z{2});
    nbv = nbv + 2;
end


% direction MEAN DIRECTION
ind  = Telemac.findVar({'MEAN DIRECTION'},handles.(varName));
if ind~=0
    cosDir = cosd(90-handles.(varName).RESULT(:,ind(1)));
    sinDir = sind(90-handles.(varName).RESULT(:,ind(1)));
    
    handles.(varName).RESULT(:,nbv + 1:nbv + 2) = [cosDir,sinDir];
    handles.(varName).RECV{nbv+1} = 'COS MEAN DIR    M/S             ';
    handles.(varName).RECV{nbv+2} = 'SIN MEAN DIR    M/S             ';
    handles.(varName).indList{nbv+1} = ind;
    handles.(varName).indList{nbv+2} = ind;
    handles.(varName).indEq{nbv+1}   = @(x) cosd(90-x{1});
    handles.(varName).indEq{nbv+2}   = @(x) sind(90-x{1});
    nbv = nbv + 2;
end

% add numbered variables to get total

% find numbered variables
theVars = handles.(varName).RECV;
iAll = 0;
for i=1:length(theVars)
    tmp  = strtrim(theVars{i}(1:16));
    tmp2 = regexp(tmp,'\d*','match');
    if ~isempty(tmp2)
        iAll = iAll +1;
        tmp2 = regexp(tmp,'\D*','match');
        varList{iAll}=tmp2{1}; %#ok<AGROW>
        unitList{iAll}=strtrim(theVars{i}(17:end)); %#ok<AGROW>
    end
end
if iAll>0
    [varList,indVar] = unique(varList);
    unitList = unitList(indVar);
    % add numbered variables to get the total
    for i=1:length(varList)
        tmp = 0;
        handles.(varName).RECV{nbv+1} = [pad(varList{i},16),pad(unitList{i},16)];
        indList = [];
        theEq ='@(x) ';
        indVars = find(strncmpi(varList{i},theVars,length(varList{i})));
        for j=1:length(indVars)
            tmp2 = regexp(theVars{indVars(j)}(1:16),'\d*','match');
            if isempty(tmp2)
                continue;
            end
            tmp = tmp+handles.(varName).RESULT(:,indVars(j));
            theEq =  [theEq,' + x{',num2str(j),'}']; %#ok<AGROW>
            indList = [indList,indVars(j)]; %#ok<AGROW>
        end
        handles.(varName).RESULT(:,nbv + 1) = tmp;
        handles.(varName).indList{nbv+1} = indList;
        handles.(varName).indEq{nbv+1}   = str2func(theEq);
        nbv = nbv + 1;
    end
end



% VARIABLES ENDING WITH XY
% TODO

if ~isempty(handles.(varName).IDATE)
    handles.time    = datenum(handles.(varName).IDATE)+handles.(varName).AT/86400;
else
    handles.time    = handles.(varName).AT/86400;
end
set(handles.ET_timeStep,'String',num2str(step));


function [z,u,v] = extractData(handles,ind,isContour,varName3D)
% extracts map data to plot
%
% [z,u,v] = extractData(handles,ind,isContour,varName3D)

varName2D = [varName3D,'2D'];

if ~isContour
    indZ = handles.ind;
else
    indZ = handles.indContour;
end


if varName3D(end)~='a'
    indZ = getIndB(handles,indZ);
    if isempty(indZ)
        z = [];
        u = [];
        v = [];
        return
    end
end


%extract data; convert3D won't harm for 2D data
z    = Telemac.convertTelemac3Ddata(handles.(varName2D),indZ);

if ~isempty(ind) && all(ind>0)
    u    = handles.vecScale.*Telemac.convertTelemac3Ddata(handles.(varName2D),ind(1));
    v    = handles.vecScale.*Telemac.convertTelemac3Ddata(handles.(varName2D),ind(2));
else
    u = [];
    v = [];
end
% extract plane for 3d
if handles.(varName3D).NPLAN>1
    z = z(:,handles.layerNr);
    % todo check if field
    if ~isempty(ind) &&all(ind>0)
        u = u(:,handles.layerNr);
        v = v(:,handles.layerNr);
    end
end
% apply equation only for data in map;
if ~isContour
    z = applyEq(handles,z);
end

function z = applyEq(handles,z)
% applies the equation to the data
theEquation = get(handles.ET_equation,'String');
if ~isempty(theEquation)
    z = eval(theEquation);
end

function [handles,ok] = getcLim(handles)
% get and checks the minimum and maximum limits

global play;
ok = false;

%minimum
tmp = str2double(get(handles.ET_min,'String'));
if isnan(tmp)
    errordlg('Invalid input for mimimum');
    play = false;
    return
end
handles.cLim(1) = tmp;

% maximum
tmp = str2double(get(handles.ET_max,'String'));
if isnan(tmp)
    errordlg('Invalid input for maximum');
    play = false;
    return
end
handles.cLim(2) = tmp;

% check
if handles.cLim(2)<=handles.cLim(1)
    errordlg('Lower limits must be lower than the higher limit.');
    play = false;
    return
end

% same for zLimits % but may be empty

% only check for 3d data
if handles.sctData.NPLAN>1
    
    tmpStrMin = get(handles.ET_zMin,'String');
    tmpStrMax = get(handles.ET_zMax,'String');
    if ~isempty(tmpStrMin)&& ~isempty(tmpStrMin)
        tmp = str2double(tmpStrMin);
        if isnan(tmp)
            errordlg('Invalid input for mimimum z');
            play = false;
            return
        end
        handles.zLim(1) = tmp;
        
        % maximum
        tmp = str2double(tmpStrMax);
        if isnan(tmp)
            errordlg('Invalid input for maximum z');
            play = false;
            return
        end
        handles.zLim(2) = tmp;
        
        % check
        if handles.zLim(2)<=handles.zLim(1)
            errordlg('Lower z limit must be lower than the higher z limit.');
            play = false;
            return
        end
    else
        handles.zLim = [];
    end
end
ok = true;


function handles = plotData(handles,hPlot,hAx)
% wrapper around the plot function, in order to do multiple plots

if nargin < 2
    hPlot = gcf;
end
if nargin < 3
    if handles.CB_compare.Value
        hAx2 = {handles.hMap2,handles.hProf2};
    end
    hAx = {handles.hMap,handles.hProf};
else
    if handles.CB_compare.Value
        hAx2 = hAx(:,2);
    end
    hAx =  hAx(:,1);
end

handles.ind = get(handles.LB_var,'Value');
if handles.CB_compare.Value
    if length(hPlot) == 1
        hPlot = [hPlot,hPlot];
    end
    handles = plotDataOne(handles,hPlot(1),hAx,'sctData');
    zStore = handles.zStore;
    handles = plotDataOne(handles,hPlot(2),hAx2,'sctData2');
    handles.zStore = zStore;
else
    handles = plotDataOne(handles,hPlot,hAx);
end





function [handles,ok,x,y,ikle,z,u,v] = getData(handles,varName)
% extract data for plotting
ok = true;
varName2d = [varName,'2D'];
% get layer (3d only)
handles = getLayer(handles);
if isnan(handles.layerNr)
    return;
end

% select quiver data
tmpInd = get(handles.LB_quiver,'Value') ;
if ~isempty(handles.indQuiver)
    indUv = handles.indQuiver(tmpInd,:);
else
    indUv = [];
end

% convert 3D data
handles.(varName2d) = Telemac.convertTelemac3Dgrid(handles.(varName));

[z,u,v] = extractData(handles,indUv,false,varName);
if isempty(z)
    ok = false;
    return
end
% for difference maps
if handles.CB_diff.Value
    handles.sctData22D = Telemac.convertTelemac3Dgrid(handles.sctData2);
    z2 = extractData(handles,indUv,false,'sctData2');
    % interpolate differences in case
    if numel(z) ~=numel(z2)
        if ~isfield(handles,'sctInterpDiff')
            handles.sctInterpDiff = Triangle.interpTrianglePrepare(handles.sctData2.IKLE,handles.sctData2.XYZ(:,1),handles.sctData2.XYZ(:,2),handles.sctData.XYZ(:,1),handles.sctData.XYZ(:,2));
        end
        z2 = Triangle.interpTriangle(handles.sctInterpDiff,z2);
    end
    z = z-z2;
end
handles.zStore = z;

x    = handles.(varName2d).XYZ(:,1);
y    = handles.(varName2d).XYZ(:,2);
ikle = handles.(varName2d).IKLE;


function handles = plotDataOne(handles,hPlot,hAx,varName)
% plots data in the figure
% INPUT:
%
% hPlot = handle to the figure
% hAx: cell array with handles to axis

% get data
global play;

if nargin >=3
    plotMap  = ~isempty(hAx{1});
    plotProf = ~isempty(hAx{2});
else
    plotMap  = true;
    plotProf = true;
end
if nargin <4
    varName = 'sctData';
end
varName2d = [varName,'2D'];
if varName(end)=='2'
    iPlot  = 2;
else
    iPlot  = 1;
end


if nargin ==1
    hPlot = handles.figure1;
end
set(0,'CurrentFigure',hPlot);

if get(handles.CB_faceted,'Value')
    handles.shading = 'faceted';
else
    handles.shading = 'interp';
end


[handles,ok] = getcLim(handles);
if ~ok
    return;
end


tmp = str2double(get(handles.ET_vec_scale,'String'));
if isnan(tmp)
    errordlg('Invalid input for vector scale');
    play = false;
    return
end
handles.vecScale = tmp;



if plotMap
    set(hPlot,'currentaxes',hAx{1})
    %     if hPlot==handles.figure1
    %         set(hPlot,'currentaxes',handles.hMap)
    %     else
    %         set(hPlot,'currentaxes',hAx{1})
    %     end
end

if handles.keepLim
    xLim = get(handles.hMap,'xlim');
    yLim = get(handles.hMap,'ylim');
end
cla(hAx{1});

%select data

[handles,ok,x,y,ikle,z,u,v] = getData(handles,varName);
if ~ok
    return;
end

if get(handles.CB_m2km,'Value')
    x = x/1000;
    y = y/1000;
end

plotScatter = get(handles.CB_scatter,'value');
if plotMap
    
    %     if hPlot==handles.figure1
    %         set(hPlot,'currentaxes',handles.hMap)
    %     end
    set(hPlot,'currentaxes',hAx{1})
    
    % set colormap
    nrColor = 64;
    indCmap  = get(handles.PU_colorbar,'Value');
    cMapNames = get(handles.PU_colorbar,'String');
    cMap = UtilPlot.colormapIMDC(cMapNames{indCmap},nrColor);
    if get(handles.CB_invertColor,'Value')
        cMap = flipud(cMap);
    end
    
    if plotScatter
        plotOptions.minZ = handles.cLim(1);
        plotOptions.maxZ = handles.cLim(2);
        plotOptions.colorMap = cMap;
        plotOptions.nrBins = nrColor;
        Plot.scatterFast(x,y,z,plotOptions);
    else
        

        if get(handles.CB_showHalo,'Value')
            varNr   = varNumber(varName);
            z = handles.procNr{varNr};
        end
        
        Plot.plotTriangle(x,y,z,ikle);
        shading(handles.shading);
        colormap(cMap);
    end
    
    
    colormap(cMap);
    
    colorbar('tag',['cbMap',num2str(iPlot)]);
    grid on;
    axis equal;
    if handles.keepLim
        set(gca,'xlim',xLim);
        set(gca,'ylim',yLim);
    end
    
    % add quiver plot
    if get(handles.CB_quiver,'Value')
        if isempty(u) || isempty(v)
            errordlg('No data for quiver plot');
            return;
        end
        hold on
        if get(handles.CB_quiver_interp,'Value')
            if isfield(handles,'xLimAll')
                xInt = [];
                yInt = [];
                nrXlim = size(handles.xLimAll,1);
                for i =1:nrXlim
                    x1 = handles.xLimAll(i,1);
                    x2 = handles.xLimAll(i,2);
                    y1 = handles.yLimAll(i,1);
                    y2 = handles.yLimAll(i,2);
                    [xTmp,yTmp] = meshgrid(x1:handles.dxQuiver:x2,y1:handles.dxQuiver:y2);
                    xInt = [xInt;xTmp(:)]; %#ok<AGROW>
                    yInt = [yInt;yTmp(:)]; %#ok<AGROW>
                end
            else
                if handles.keepLim
                    x1 = xLim(1);
                    x2 = xLim(2);
                    y1 = yLim(1);
                    y2 = yLim(2);
                else
                    tmp = get(gca,'xlim');
                    x1 =tmp(1);
                    x2 =tmp(2);
                    tmp = get(gca,'ylim');
                    y1 =tmp(1);
                    y2 =tmp(2);
                end
                [xInt,yInt] = meshgrid(x1:handles.dxQuiver:x2,y1:handles.dxQuiver:y2);
            end
            xInt = xInt(:);
            yInt = yInt(:);
            sctInterp = Triangle.interpTrianglePrepare(handles.(varName2d).IKLE,x,y,xInt,yInt);
            uInt      = Triangle.interpTriangle(sctInterp,u);
            vInt      = Triangle.interpTriangle(sctInterp,v);
            if get(handles.CB_quiverEqual,'Value')
                uTot = max(hypot(uInt,vInt),1e-16);
                mask = uTot < handles.quiverThreshold*handles.vecScale;
                uInt = handles.vecScale.*uInt./uTot;
                vInt = handles.vecScale.*vInt./uTot;
                uInt(mask) = 0;
                vInt(mask) = 0;
            end
            quiver(xInt,yInt,uInt,vInt,0,'k');
            
        else
            if get(handles.CB_quiverEqual,'Value')
                uTot = max(hypot(u,v),1e-16);
                mask = uTot < handles.quiverThreshold*handles.vecScale;
                u = handles.vecScale.*u./uTot;
                v = handles.vecScale.*v./uTot;
                u(mask) = 0;
                v(mask) = 0;
            end
            quiver(x,y,u,v,0,'k');
        end
    end
    
    %add mesh
    if get(handles.CB_addMesh,'Value')
        hold on
        triplot(double(ikle),x,y,'k');
    end
    
    % add i2s
    
    if isfield(handles,'i2s')
        hold on
        indPlot = get(handles.LB_i2s,'Value');
        for i=indPlot
            Plot.plotCell(handles.i2s{i},'-k');
        end
    end
    
    % add polygons
    if isfield(handles,'volPoly')
        hold on
        Plot.plotCell(handles.volPoly,'-bx');
    end
    
    
    
    
    % plot values
    if get(handles.CB_text,'Value')
        if handles.keepLim
            x1 = xLim(1);
            x2 = xLim(2);
            y1 = yLim(1);
            y2 = yLim(2);
        else
            tmp = get(gca,'xlim');
            x1 =tmp(1);
            x2 =tmp(2);
            tmp = get(gca,'ylim');
            y1 =tmp(1);
            y2 =tmp(2);
        end
        
        showNodeNr = false;
        tmp = (x2-x1)/50;
        mask = x>x1 & x<x2 & y>y1 & y<y2;
        if sum(mask)>1000
            errordlg('Too many text values in view. Skipping.');
            mask = false(size(mask));
        end
        if showNodeNr
            id = (1:length(x))';
            text(x(mask)+tmp,y(mask)+tmp,num2str(id(mask)),'fontsize',6);
        else
            text(x(mask)+tmp,y(mask)+tmp,num2str(z(mask)),'fontsize',6);
        end
        
    end
    
    
    % add contour plot
    if get(handles.CB_contour,'Value')
        % TODO ADD NUMBER OF COURTOURS IN GUI
        
        %   get variable
        tmp = (get(handles.LB_contour,'Value'));
        handles.indContour = tmp;
        
        % plot
        z = extractData(handles,[],true,varName);
        hold on
        tricontour([x y],double(ikle),z,handles.contours,'k')
        
    end
    
    if get(handles.CB_m2km,'Value')
        xlabel('x [km]')
        ylabel('y [km]')
    else
        xlabel('x [m]')
        ylabel('y [m]')
    end
    
    
    title(datestr(handles.time))%,'Units','normalized','position',[0.5 1.0]);
    caxis([handles.cLim]);
    
    if isfield(handles,'outliersMin')
        plot(handles.outliersMin(:,1),handles.outliersMin(:,2),'vb');
        plot(handles.outliersMax(:,1),handles.outliersMax(:,2),'^r');
    end
    
    
end

if plotProf
    plotProfLoc(handles);
    
    set(hPlot,'currentaxes',hAx{2})
    handles = plotProfile(handles,hAx{2},varName,iPlot);
end

% plot extracted profiles




% --- Executes on button press in PB_stop.
function PB_stop_Callback(hObject, eventdata, handles)
% hObject    handle to PB_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global play;
play = false;
guidata(hObject,handles);



function ET_stride_Callback(hObject, eventdata, handles)
% hObject    handle to ET_stride (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ET_stride as text
%        str2double(get(hObject,'String')) returns contents of ET_stride as a double


% --- Executes during object creation, after setting all properties.
function ET_stride_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ET_stride (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CB_quiver.
function CB_quiver_Callback(hObject, eventdata, handles)
% hObject    handle to CB_quiver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_quiver


% --- Executes on button press in CB_addMesh.
function CB_addMesh_Callback(hObject, eventdata, handles)
% hObject    handle to CB_addMesh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_addMesh


% --- Executes on button press in CB_m2km.
function CB_m2km_Callback(hObject, eventdata, handles)
% hObject    handle to CB_m2km (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_m2km

handles.keepLim = false;
guidata(hObject,handles);


% --- Executes on button press in PB_vertProf.
function PB_vertProf_Callback(hObject, eventdata, handles)
% hObject    handle to PB_vertProf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (handles.sctData.NPLAN<=1)
    errordlg('Only possible for 3D data');
    return;
end

lineStyle = {'-','--',':','.-'};
% select the type
[handles,indList1,indEq] = getIndA(handles);

cTmp = inputdlg('Select type of graph. 1: profile; 2 hodograph','Select vert prof',1,{'1'});
switch strtrim(cTmp{1})
    case '1'
        plotProf = true;
    case '2'
        if isempty(regexp(handles.sctData.RECV{handles.ind},' MAG'))
            errordlg('Select a magnitude in order to use a polar plot');
            return;
        end
        if ~isempty(get(handles.ET_equation,'String'))
            msgbox('Equations are ignored for hodograph plots');
        end
        plotProf = false;
    otherwise
        errordlg('Unknown option');
        return;
end


% multiple plots
allVar = {'sctData','sctData2'};
if handles.CB_compare.Value
    nrPlot = 2;
else
    nrPlot = 1;
end

% get points
[indPoin,~,handles] = getLoc(handles);
if isempty(indPoin)
    return;
end
guidata(hObject,handles);


UtilPlot.reportFigureTemplate;
for iPlot=1:nrPlot
    if iPlot>1
        indList = getIndB(handles,indList1);
    else
        indList = indList1;
    end
    varName = allVar{iPlot};
    varName2d = [varName,'2D'];
    
    indZ = Telemac.findVar({'ELEVATION Z'},handles.(varName));
    
    % get data
    
    for i = length(indList):-1:1
        tmp = Telemac.convertTelemac3Ddata(handles.(varName2d),indList(i));
        tmpX{i} = tmp(indPoin,:);
    end
    % profile
    if plotProf
        tmpX  = indEq(tmpX);
        x  = applyEq(handles,tmpX);
        y = Telemac.convertTelemac3Ddata(handles.(varName2d),indZ);
        y = y(indPoin,:);
    else
        % hodograph
        x = tmpX{1};
        y = tmpX{2};
        z = Telemac.convertTelemac3Ddata(handles.(varName2d),indZ);
        z = z(indPoin,:);
        z = z';
    end
    x = x';
    y = y';
    clear tmpX;
    
    
    guidata(hObject,handles);
    % make figure
    for i= size(x,2):-1:1
        cLeg{i} = ['Loc ',num2str(i,'%2.0f')];
    end
    
    if nrPlot>1 && ~plotProf
        subplot(nrPlot,1,iPlot)
    end
    %profile
    if plotProf
        hold on;
        set(gca,'colororderindex',1);
        plot(x,y,lineStyle{iPlot});
        xlabel(handles.(varName).RECV{handles.ind});
        ylabel(handles.(varName).RECV{indZ});
    else
        % hodograph
        plot(x,y,'-o');
        mask = 1:round(length(y)/10):length(y);
        text(x(mask),y(mask),num2str(z(mask),'%6.1f'),'fontsize',6);
        xlabel(handles.(varName).RECV{indList(1)});
        ylabel(handles.(varName).RECV{indList(2)});
    end
    legend(cLeg,'location','best');
    grid on;
    title(datestr(handles.time));
end





function ET_Layer_Callback(hObject, eventdata, handles)
% hObject    handle to ET_Layer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ET_Layer as text
%        str2double(get(hObject,'String')) returns contents of ET_Layer as a double


% --- Executes during object creation, after setting all properties.
function ET_Layer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ET_Layer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% % --------------------------------------------------------------------
% function uipushtool1_ClickedCallback(hObject, eventdata, handles)
% % hObject    handle to uipushtool1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PB_PAUSE.
function PB_PAUSE_Callback(hObject, eventdata, handles)
% hObject    handle to PB_PAUSE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global play;
play = false;


% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Extra_Callback(hObject, eventdata, handles)
% hObject    handle to Extra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function IDATE_Callback(hObject, eventdata, handles)
% hObject    handle to IDATE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tmp = inputdlg('Start date? (yyyy/mm/dd HH:MM)', 'IDATE', 1);
if isempty(tmp{1}); return; end

token = regexp(tmp{1}, '(?<year>\d+)/(?<month>\d+)/(?<day>\d+) (?<hour>\d+):(?<minute>\d+)', 'names');
bOke = checkDate(token);
if ~bOke; warningdlg('Failed to replace Start date (IDATE)'); return; end
handles.sctData.IDATE = datenum(tmp, 'yyyy/mm/dd HH:MM');

guidata(hObject,handles);

function bOke = checkDate(sctDate)
% sctData.year
if isstr(sctDate.year)
    fn = fieldnames(sctDate);
    for ii = 1:5; sctDate.(fn{ii}) = str2double(sctDate.(fn{ii})); end
end

bOke = sctDate.month>0 & sctDate.month<13;
if ~bOke; return; end
switch sctDate.month
    case{1,    3,    5,    7, 8,    10,    12}
        bOke = sctDate.day > 0 & sctDate.day < 32;
    case{         4,    6,       9,     11   }
        bOke = sctDate.day > 0 & sctDate.day < 31;
    case{   2                                }
        if mod(sctDate.year,4)==0 && (mod(sctDate.year,400)==0 || mod(sctDate.year,100)>0) % leap year
            bOke = sctDate.day > 0 & sctDate.day < 30;
        else
            bOke = sctDate.day > 0 & sctDate.day < 30;
        end
end
if ~bOke; return; end
bOke = sctDate.hour >=0 & sctDate.hour <24;
if ~bOke; return; end
bOke = sctDate.minute >=0 & sctDate.minute <60;


% --- Executes on button press in PB_autoScale.
function PB_autoScale_Callback(hObject, eventdata, handles)
% hObject    handle to PB_autoScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% select data
handles.ind = get(handles.LB_var,'Value');
tmp = handles.sctData.RESULT(:,handles.ind);
tmp = applyEq(handles,tmp);
% maximum is limited to prevent crashes; also there is always a minimum
% difference
minV = max(min(min(tmp),1e16),-1e16);
maxV = max(min(max(tmp),1e16),-1e16);
if maxV==minV
    maxV = maxV.*1.1;
end

% set
set(handles.ET_max,'String',num2str(maxV))
set(handles.ET_min,'String',num2str(minV))
handles = applyH(handles);
guidata(hObject,handles);


% --- Executes on selection change in LB_contour.
function LB_contour_Callback(hObject, eventdata, handles)
% hObject    handle to LB_contour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LB_contour contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LB_contour


% --- Executes during object creation, after setting all properties.
function LB_contour_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LB_contour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CB_contour.
function CB_contour_Callback(hObject, eventdata, handles)
% hObject    handle to CB_contour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_contour


% sets contour levels, similar as doen for a quiver

if get(hObject,'Value')
    % get dx from input
    tmp = inputdlg({'Give the contourlevels to plot; MATLAB syntax can be used. In order to plot a single contour, repeat the value twice.'},'Contour input',1,{'250'});
    try
        contours  = eval(['[',tmp{1},']']);
    catch
        errordlg('Invalid input.');
        set(hObject,'Value',0);
        guidata(hObject,handles);
        return
    end
    if any(isnan(contours))
        errordlg('Invalid value for the contour levels');
        set(hObject,'Value',0);
        guidata(hObject,handles);
        return
    end
    handles.contours = contours;
    guidata(hObject,handles);
end

% --- Executes on button press in CB_diff.
function CB_diff_Callback(hObject, eventdata, handles)
% hObject    handle to CB_diff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_diff





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


% --- Executes on button press in CB_invertColor.
function CB_invertColor_Callback(hObject, eventdata, handles)
% hObject    handle to CB_invertColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_invertColor


% --- Executes on button press in PB_xylim.
function PB_xylim_Callback(hObject, eventdata, handles)
% hObject    handle to PB_xylim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% maximum is limited to prevent crashes

% set
x = handles.sctData2D.XYZ(:,1);
y = handles.sctData2D.XYZ(:,2);
yLim = [min(y),max(y)];
xLim = [min(x),max(x)];
set(handles.hMap,'xlim',xLim);
set(handles.hMap,'ylim',yLim);
handles = applyH(handles);
guidata(hObject,handles);


% --------------------------------------------------------------------
function MENU_LOADi2s_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_LOADi2s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% open i2s file and add

cFiles ={'*.i2s','Blue Kenue line file (*.i2s)';...
    '*.*','all files (*.*)'};

if isfield(handles,'file')
    [file,path] = uigetfile(cFiles,'Select File',handles.file);
else
    [file,path] = uigetfile(cFiles,'Select File');
end
% open file and replot
if ischar(file)
    theFile     = fullfile(path,file);
    tmp = get(handles.LB_i2s,'String');
    nrI2s = length(tmp);
    handles.LB_i2s.String = [tmp;{file}];
    handles.i2s{nrI2s+1} = Telemac.readKenue(theFile);
    handles     = plotData(handles);
end
guidata(hObject,handles);

% --------------------------------------------------------------------
function MENU_SAVE_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_SAVE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

% save figures as png
% handles    structure with handles and user data (see GUIDATA)

%msgbox('Not yet implemented');

handles = saveImage(handles,'fig');
    guidata(hObject,handles);

function handles = saveImage(handles,typeSave)

global play;
play = false;

% get filenames to save
switch typeSave
    case 'fig'
        cFiles ={'*.png','Png file (*.png)';
            '*.fig','Matlab figure (*.fig)'
            };
    case 'movie'
        cFiles ={'*.avi','avi file (*.avi)'};
        
end

if isfield(handles,'file')
    [file,path] = uiputfile(cFiles,'Select File',handles.file(1:end-4));
else
    [file,path] = uiputfile(cFiles,'Select File');
end



if ischar(file)
    
    step = getStep(handles);
    
    % options for files
    answer = inputdlg({'Figure to save [1 = map; 2 = transect; 3= both]';
        'First output time step';
        'Last  output time step';
        'User defined function (absolute path). Inputs are handles to the figure and the colorbar. function handle_movie(hTmp, hAx, hBar) ';
        },...
        'Save figure options',1,{'1',num2str(step),num2str(handles.sctData.NSTEPS),''});
    
    % error checking
    if isempty(answer)
        return
    end
    plotNr = str2double(answer(1));
    if ~any(plotNr==[1 2 3])
        errordlg('');
        return
    end
    iStart = str2double(answer(2));
    if isnan(iStart)
        errordlg('Invalid input for start time step');
        return
    end
    iEnd = str2double(answer(3));
    if isnan(iEnd)
        errordlg('Invalid input for end time step');
        return
    end
    if ~isempty(answer{4})
        tmp = answer{4};
        [thePath,theFun] = fileparts(tmp);
        if exist(thePath,'dir')
            addpath(thePath);
        else
            errordlg('Invalid function.')
            return;
        end
        useUdf = true;
    else
        useUdf = false;
    end
    
    
    % get stride
    [speed,~, stride] = getSpeed(handles);
    
    % process filename
    theFile      = fullfile(path,file);
    handles.file = theFile;
    [path,file,ext] = fileparts(theFile);
    
    nrPlot = 1;
    if handles.CB_compare.Value
        nrPlot = 2;
    end
    % make figure;
    for iPlot = 1:nrPlot
        switch plotNr
            case 1
                hTmp(iPlot) = UtilPlot.reportFigureTemplate('portrait'); %#ok<AGROW>
            case 2
                hTmp(iPlot) = UtilPlot.reportFigureTemplate; %#ok<AGROW>
            case 3
                hTmp(iPlot) =UtilPlot.reportFigureTemplate('portrait',12); %#ok<AGROW>
        end
    end
    
    % loop over all files
    play = true;
    tmpHandles = handles;
    
    switch typeSave
        case 'fig'
            % do nothing
        case 'movie'
            outFile = fullfile(path,file);
            %outFile = fullfile(path,[file,'_Zoom',num2str(iExt,'%02.0f')]);
            myVideo = VideoWriter(outFile);
            myVideo.FrameRate  = round(1/speed);
            myVideo.Quality    = 90;
            open(myVideo);
            %TODO make multiple viedeos for differnt zooms

    end
    
    for i = iStart:stride:iEnd
        
        % animate as usual
        if ~play
            break
        end
        if i>handles.sctData.NSTEPS
            break
        end
        
        % set axes right
        for iPlot = 1:nrPlot
            set(0, 'currentfigure', hTmp(iPlot));
            switch plotNr
                case 1
                    hAx{1,iPlot}  = gca;
                    hAx{2,iPlot}  = [];
                case 2
                    hAx{2,iPlot}  = gca;
                    hAx{1,iPlot}  = [];
                case 3
                    hAx{1,iPlot} = subplot(2,1,1);
                    hAx{2,iPlot} = subplot(2,1,2);
            end
        end
        
        tmpHandles = updateData(tmpHandles,i);
        tmpHandles = plotData(tmpHandles,hTmp,hAx);
        if useUdf
            hBar = findobj(hTmp,'Tag','Colorbar');
            feval(theFun,hTmp, hAx, hBar);
        end
        drawnow;
        
        
        % copy data to export figure
        switch plotNr
            case {1,3}
                %copyobj(handles.hMap,hTmp);
                %                colorbar;
            case {2,3} %#ok<MDUPC>
                %               copyobj(handles.hProf,hTmp);
        end
        %save file
        if isfield(handles,'xLimAll')
            xLimAll = handles.xLimAll;
            yLimAll = handles.yLimAll;
            nrXlim  = size(handles.yLimAll,1);
        else
            nrXlim = 1;
        end
        switch typeSave
            case 'fig'
                for iPlot = 1:nrPlot
                    for iExt = 1:nrXlim
                        % use different zooms
                        if nrXlim>1
                            set(0,'CurrentFigure',hTmp(iPlot));
                            xlim(xLimAll(iExt,:));
                            ylim(yLimAll(iExt,:));
                        end
                        outFile = fullfile(path,[file,num2str(iPlot,'%02.0f'),'_Time',num2str(i,'%04.0f'),'_Zoom',num2str(iExt,'%02.0f')]);
                        switch ext
                            case '.png'
                                UtilPlot.saveFig(outFile,'hfig',hTmp(iPlot),'cropFig',true,'addFig',false);
                            case '.fig'
                                saveas(hTmp(iPlot),[outFile,ext]);
                        end
                    end
                end
            case 'movie'
                for iPlot = 1:nrPlot
                    for iExt = 1:1 %nrXlim  % TODO movie for multiple extrends
                        % use different zooms
                        set(0,'CurrentFigure',hTmp(iPlot));
                        if nrXlim>1
                            xlim(xLimAll(iExt,:));
                            ylim(yLimAll(iExt,:));
                        end
                        frame = getframe(gcf);
                        writeVideo(myVideo,frame);
                    end
                end
        end
        
        if i~=iEnd
            for iPlot = 1:nrPlot
                clf(hTmp(iPlot));
            end
        end
    end
    switch typeSave
        case 'movie'
            close (myVideo);
    end
    handles = tmpHandles;
end




function ET_equation_Callback(hObject, eventdata, handles)
% hObject    handle to ET_equation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ET_equation as text
%        str2double(get(hObject,'String')) returns contents of ET_equation as a double


% --- Executes during object creation, after setting all properties.
function ET_equation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ET_equation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CB_quiver_interp.
function CB_quiver_interp_Callback(hObject, eventdata, handles)
% hObject    handle to CB_quiver_interp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_quiver_interp

if get(hObject,'Value')
    % get dx from input
    tmp = inputdlg({'Give the distance between the vectors'},'Quiver input',1,{'250'});
    if isempty(tmp)
        set(handles.CB_quiver_interp,'Value',false);
        guidata(hObject,handles);
        return
    end
    dx  = str2double(tmp{1});
    if isnan(dx)
        errordlg('Invalid value for the distance');
        set(handles.CB_quiver_interp,'Value',false);
        guidata(hObject,handles);
        return
    end
    handles.dxQuiver = dx;
    guidata(hObject,handles);
end


% --------------------------------------------------------------------
function TS_opt_Callback(hObject, eventdata, handles)
% hObject    handle to TS_opt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function TS_plot_Callback(hObject, eventdata, handles)
% hObject    handle to TS_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function TS_hist_Callback(hObject, eventdata, handles)
% hObject    handle to TS_hist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function TS_polar_Callback(hObject, eventdata, handles)
% hObject    handle to TS_polar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PB_ellips.
function PB_ellips_Callback(hObject, eventdata, handles)
% hObject    handle to PB_ellips (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%TODO: two figures

[handles,indList,indEq,nrStride] = getIndA(handles);
handles = getLayer(handles);

if isempty(regexp(handles.sctData.RECV{handles.ind},' MAG'))
    errordlg('Select a magnitude in order to use a polar plot');
    return;
end
if ~isempty(get(handles.ET_equation,'String'))
    msgbox('Equations are ignored for polar plots');
end

[startDate,endDate] = getDate(handles);

xLim = get(handles.hMap,'xlim');
yLim = get(handles.hMap,'ylim');


% get date and time resolution etc
quest{4} = 'Give scaling of the ellipses';
quest{3} = 'Give distance between ellipses [m]';
quest{2} = 'Give duration [h]';
quest{1} = 'Give start date [yyyy-mm-dd hh:mm:ss]';

dx = Calculate.roundToVal((max(xLim)-min(xLim))/10,100);
tmpAns{4} = num2str(dx/2);
tmpAns{3} = num2str(dx);
tmpAns{2} = '13';
tmpAns{1} = datestr(startDate,'yyyy-mm-dd HH:MM:SS');

cTmp = inputdlg(quest,'Ellipses data',1,tmpAns);
if isempty(cTmp)
    return;
end
%check answers
tmp = str2double(cTmp{4});
if isnan(tmp) || tmp<=0
    errordlg('Wrong value for the scaling');
    return
end
nScale = tmp;
tmp = str2double(cTmp{3});
if isnan(tmp) || tmp<=0
    errordlg('Wrong value for the distance');
    return
end
nDist = tmp;
tmp = str2double(cTmp{2});
if isnan(tmp) || tmp<=0
    errordlg('Wrong value for the duration');
    return
end
nTime = tmp/24;
try
    startEl = datenum(cTmp{1},'yyyy-mm-dd HH:MM:SS');
catch
    errordlg('Wrong value for the startdate');
    return
end
if startEl<startDate || startEl>endDate-nTime
    errordlg(['Selected period not in the range of the measurements.', datestr (startDate),' to ', datestr(endDate)]);
    return
end
startInd = round((startEl-startDate)*86400/handles.sctData.DT +1);
endInd   = round((startEl+nTime-startDate)*86400/handles.sctData.DT+1);



% make mesh

[xInt,yInt] = meshgrid(xLim(1):nDist:xLim(2),yLim(1):nDist:yLim(2));
xInt = xInt(:);
yInt = yInt(:);

% find closest points
indNode = getNearestNode(handles,xInt,yInt);
mask = isnan(indNode);
xInt(mask) = [];
yInt(mask) = [];
indNode(mask) = [];
is3D = handles.sctData.NPLAN>1;

% extract time series
if is3D
    indNode = indNode + (handles.layerNr-1).*handles.sctData.NPOIN/handles.sctData.NPLAN;
end
clear tmp;
for iInd = length(indList):-1:1
    if handles.useGretel(1)
        tmp{iInd}  = Telemac.getDataGretel(handles.sctDataPartial,startInd:nrStride:endInd,indNode,indList(iInd),handles.procNr{1},handles.locNr{1});
    else
        tmp{iInd}  = Telemac.getData(handles.sctData,startInd:nrStride:endInd,indNode,indList(iInd));
    end
end



%plot
for i =1:length(indNode)
    % determine coordinates of the ellips
    xTmp  = xInt(i)+nScale.*tmp{1}(:,i);
    yTmp  = yInt(i)+nScale.*tmp{2}(:,i);
    % plot;
    set(gcf,'CurrentAxes',handles.hMap);
    hold on
    plot(handles.hMap,xTmp,yTmp,'-k');
end


% --- Executes on button press in PB_outlier.
function PB_outlier_Callback(hObject, eventdata, handles)
% hObject    handle to PB_outlier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% get min and max
[handles,ok] = getcLim(handles);
if ~ok
    return;
end
% plot points below and above

maskMin = handles.zStore<handles.cLim(1);
maskMax = handles.zStore>handles.cLim(2);

x    = handles.sctData2D.XYZ(:,1);
y    = handles.sctData2D.XYZ(:,2);
if   sum(maskMin)>0 ||sum(maskMax)>0
    set(gcf,'currentAxes',handles.hMap);
    hold on;
    plot(x(maskMin),y(maskMin),'vb',x(maskMax),y(maskMax),'^r');
    handles.outliersMin =[x(maskMin),y(maskMin)];
    handles.outliersMax =[x(maskMax),y(maskMax)];
    guidata(hObject,handles);
    axis equal;
else
    msgbox('No outliers in this layer');
end


% --- Executes on button press in CB_faceted.
function CB_faceted_Callback(hObject, eventdata, handles)
% hObject    handle to CB_faceted (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_faceted


% --- Executes on button press in PB_ruler.
function PB_ruler_Callback(hObject, eventdata, handles)
% hObject    handle to PB_ruler (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

UtilPlot.ruler(false);


function ET_zMin_Callback(hObject, eventdata, handles)
% hObject    handle to ET_zMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ET_zMin as text
%        str2double(get(hObject,'String')) returns contents of ET_zMin as a double


% --- Executes during object creation, after setting all properties.
function ET_zMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ET_zMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ET_zMax_Callback(hObject, eventdata, handles)
% hObject    handle to ET_zMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ET_zMax as text
%        str2double(get(hObject,'String')) returns contents of ET_zMax as a double


% --- Executes during object creation, after setting all properties.
function ET_zMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ET_zMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CB_text.
function CB_text_Callback(hObject, eventdata, handles)
% hObject    handle to CB_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_text


% --- Executes on button press in CB_compare.
function CB_compare_Callback(hObject, eventdata, handles)
% hObject    handle to CB_compare (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_compare


if (handles.CB_compare.Value)
    % make two plots
    
    % set second map visible
    
    %properties for map plot
    set(handles.hMap2,'Visible',true);
    allChild = get(handles.hMap2,'children');
    for i=1:length(allChild)
        set(allChild(i),'visible','on');
    end
    allChild = findobj('tag','cbMap2');
    if ~isempty(allChild)
        set(allChild,'visible','on');
    end
    set(handles.hMap,'Position',[0.18 0.297 0.35 0.65]);
    
    %properties for profile plot
    set(handles.hProf2,'Visible',true);
    allChild = get(handles.hProf2,'children');
    for i=1:length(allChild)
        set(allChild(i),'visible','on');
    end
    allChild = findobj('tag','cbProf2');
    if ~isempty(allChild)
        set(allChild,'visible','on');
    end
    set(handles.hProf,'Position',[0.207 0.052 0.30 0.204]);
    
    % link axes
    linkaxes([handles.hMap,handles.hMap2],'xy');
    linkaxes([handles.hProf,handles.hProf2],'xy');
    
    % prepare interpolation if needed
    if isfield (handles,'sctInterp')
        varName2d = 'sctData2D';
        iPlot     = 2;
        handles   = resInterp(handles,varName2d,iPlot);
    end
    
else
    % change axis; set invisble
    
    % map plot
    set(handles.hMap2,'Visible',false);
    allChild = get(handles.hMap2,'children');
    for i=1:length(allChild)
        set(allChild(i),'visible','off');
    end
    set(handles.hMap,'Position',[0.18 0.297 0.75 0.65]);
    allChild = findobj('tag','cbMap2');
    if ~isempty(allChild)
        set(allChild,'visible','off');
    end
    
    % profile plot
    set(handles.hProf2,'Visible',false);
    allChild = get(handles.hProf2,'children');
    for i=1:length(allChild)
        set(allChild(i),'visible','off');
    end
    allChild = findobj('tag','cbProf2');
    if ~isempty(allChild)
        set(allChild,'visible','off');
    end
    set(handles.hProf,'Position',[0.207 0.052 0.722 0.204]);
    % switch off link axes
    linkaxes([handles.hMap,handles.hMap2],'off');
    linkaxes([handles.hProf,handles.hProf2],'off');
    
end

guidata(hObject,handles);


% --------------------------------------------------------------------
function uitoggletool1_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% make sure zooming only occurs on visible access
hZoom = zoom;
if (handles.CB_compare.Value)
    setAllowAxesZoom(hZoom,handles.hMap2,true);
    setAllowAxesZoom(hZoom,handles.hProf2,true);
else
    setAllowAxesZoom(hZoom,handles.hMap2,false);
    setAllowAxesZoom(hZoom,handles.hProf2,false);
end
hZoom.Direction = 'in';
hZoom.Enable = 'on';


% --------------------------------------------------------------------
function uitoggletool2_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hZoom = zoom;
if (handles.CB_compare.Value)
    setAllowAxesZoom(hZoom,handles.hMap2,true);
    setAllowAxesZoom(hZoom,handles.hProf2,true);
else
    setAllowAxesZoom(hZoom,handles.hMap2,false);
    setAllowAxesZoom(hZoom,handles.hProf2,false);
end
hZoom.Direction = 'out';
hZoom.Enable = 'on';
% --------------------------------------------------------------------
function uitoggletool3_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hPan = pan;
if (handles.CB_compare.Value)
    setAllowAxesPan(hPan,handles.hMap2,true);
    setAllowAxesPan(hPan,handles.hProf2,true);
else
    setAllowAxesPan(hPan,handles.hMap2,false);
    setAllowAxesPan(hPan,handles.hProf2,false);
end
hPan.Enable = 'on';


% --------------------------------------------------------------------
function TB_copy_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to TB_copy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% copy lines from prof to a new figure

hFig = UtilPlot.reportFigureTemplate;
hAx  = subplot(1,1,1);
hLines = findobj(handles.hProf,'Type','line');
copyobj(hLines,hAx);

if (handles.CB_compare.Value)
    hLines = findobj(handles.hProf2,'Type','line');
    set(hLines,'LineStyle','--');
    copyobj(hLines,hAx);
end
xlabel( handles.hProf.XLabel.String);
ylabel( handles.hProf.YLabel.String);
legend('Left','Right');
grid on;


% --------------------------------------------------------------------
function MENU_saveProf_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_saveProf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% save data from prof ile and save as .mat file

% save as .mat file

global play;
play = false;

% get filenames to save
cFiles ={'*.mat','Matlab file (*.mat)';
    };

if isfield(handles,'file')
    [file,path] = uiputfile(cFiles,'Select File',handles.file(1:end-4));
else
    [file,path] = uiputfile(cFiles,'Select File');
end

if ischar(file)
    step = getStep(handles);
    
    % options for files
    answer = inputdlg({
        'First output time step';
        'Last  output time step';
        },...
        'Save figure options',1,{num2str(step),num2str(handles.sctData.NSTEPS)});
    
    % error checking
    if isempty(answer)
        return
    end
    iStart = str2double(answer(1));
    if isnan(iStart)
        errordlg('Invalid input for start time step');
        return
    end
    iEnd = str2double(answer(2));
    if isnan(iEnd)
        errordlg('Invalid input for end time step');
        return
    end
    % get stride
    [~,~, stride] = getSpeed(handles);
    
    % process filename
    theFile      = fullfile(path,file);
    handles.file = theFile;
    [thePath,theFile,theExt]   =  fileparts(theFile);
    
    % loop over all files
    play = true;
    varName = 'sctData';
    for i = iStart:stride:iEnd
        % animate as usual
        if ~play
            break
        end
        if i>handles.sctData.NSTEPS
            break
        end
        handles = updateData(handles,i);
        %  TODO: save multiple plots; add 3D variables; add x and y coodinates;
        %  etc
        for iPlot =1:1
            [x,y,z,u,v] = extractProfData(handles,varName,iPlot);
            sctData.dist = x;
            sctData.val  = y;
        end
        outFile = fullfile(thePath,[theFile,num2str(i,'%04.0f'),theExt]);
        save(outFile,'sctData');
    end
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

%close all open TELEMAC files
fclose all;
delete(hObject);


% --------------------------------------------------------------------
function MENU_volume_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MENU_STATISTICS_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_STATISTICS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_16_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MENU_gradVorticity_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_gradVorticity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

msgbox('Please buy me a beer');
return;


[gradUx,gradUy] = Triangle.gradPoin(connection,XY,u);
[gradVx,gradVy] = Triangle.gradPoin(connection,XY,v);
vort = gradVx-gradUy;

% --------------------------------------------------------------------
function MENU_gradSwirl_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_gradSwirl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

msgbox('Please buy me a beer');
return;


[gradUx,gradUy] = Triangle.gradPoin(connection,XY,u);
[gradVx,gradVy] = Triangle.gradPoin(connection,XY,v);
swirl = max(gradVx.*gradUy-gradUx.*gradVy,0);

% --------------------------------------------------------------------
function MENU_gradX_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_gradX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

msgbox('Please buy me a beer');
return;


% calculate gradient
[gradX,gradY] = Triangle.gradPoin(connection,XY,F);

% plot

% --------------------------------------------------------------------
function MENU_gradY_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_gradY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

msgbox('Please buy me a beer');
return;


[gradX,gradY] = Triangle.gradPoin(connection,XY,F);

% --------------------------------------------------------------------
function MENU_gradMag_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_gradMag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

msgbox('Please buy me a beer');
return;

[gradX,gradY] = Triangle.gradPoin(connection,XY,F);
gradmag       = hypot(gradX,gradY);

% --------------------------------------------------------------------
function MENU_avgTime_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_avgTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

msgbox('Please buy me a beer');
return;


% --------------------------------------------------------------------
function MENU_timeMax_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_timeMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



varName   = 'sctData';
varName2D = 'sctData2D';

% TODO: select correct file
sctData = handles.(varName2D);


% selectd times
[tSteps,ok] = selectTimeSteps(sctData);
if ~ok
    return
end
nrTime = length(tSteps);

% load data

tmpHandles = handles;
[tmpHandles,ok,x,y,ikle] = getData(tmpHandles,varName);
if ~ok
    return
end
% preallocate
dataMin  = 1e9*ones(sctData.NPOIN,1);
dataMax  = -1e9*zeros(sctData.NPOIN,1);
dataMean = zeros(sctData.NPOIN,1);
dataM2   = zeros(sctData.NPOIN,1);
dataM3   = zeros(sctData.NPOIN,1);
dataM4   = zeros(sctData.NPOIN,1);
nrData   = zeros(sctData.NPOIN,1);


hWait = waitbar(0,'Determining  statistics');

for iTime = tSteps
    hWait = waitbar(iTime/nrTime,hWait);
    
    % load data
    tmpHandles = updateData(tmpHandles,iTime);
    [tmpHandles,ok,x,y,ikle,z] = getData(tmpHandles,varName);
    if ~ok
        return
    end
    
    dataMin = min(dataMin,z);
    dataMax = max(dataMax,z);
    dataMean = dataMean+z;
    dataM2 = dataM2+z.^2;
    dataM3 = dataM3+z.^3;
    dataM4 = dataM4+z.^4;
    nrData = nrData+ ~isnan(z);
end
close(hWait);
dataMean = dataMean./nrData;
dataM2 = dataMean./nrData;
dataM3 = dataMean./nrData;
dataM4 = dataMean./nrData;

standardDev = (dataM2 - dataMean.^2).^0.5;
%TODO
% skewness    =
% kurtosis    =

% show data in separate figure

xLim = get(handles.hMap,'xlim');
yLim = get(handles.hMap,'ylim');


UtilPlot.reportFigureTemplate
Plot.plotTriangle(x,y,dataMean,ikle);
shading interp;
colorbar;
axis equal;
grid on;
xlim(xLim);
ylim(yLim);
caxis(handles.cLim);
xlabel('x [m]');
ylabel('y [m]');
title(['Average of ',sctData.RECV{handles.ind}]);

UtilPlot.reportFigureTemplate
Plot.plotTriangle(x,y,dataMin,ikle);
shading interp;
colorbar;
axis equal;
grid on;
xlim(xLim);
ylim(yLim);
caxis(handles.cLim);
xlabel('x [m]');
ylabel('y [m]');
title(['Minimum of ',sctData.RECV{handles.ind}]);


UtilPlot.reportFigureTemplate
Plot.plotTriangle(x,y,dataMax,ikle);
shading interp;
colorbar;
axis equal;
xlim(xLim);
ylim(yLim);

grid on;
caxis(handles.cLim);
xlabel('x [m]');
ylabel('y [m]');
title(['Maximum of ',sctData.RECV{handles.ind}]);


guidata(hObject,handles);

return;


% --------------------------------------------------------------------
function MENU_timeMin_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_timeMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

msgbox('Please buy me a beer');
return;


function [handles,ok] = selectPoly(handles)
% selects a closed polygon


ok = true;
% check whether to reload
if isfield(handles,'volPoly')
    buttonName = questdlg('Use existing polygons', 'Exisiting polygon');
    switch upper(buttonName)
        case 'YES'
            ok = true;
            return
        case 'NO'
            % contuinue to next questions
        case 'CANCEL'
            ok = false;
            return
    end
end

% only in case of NO
buttonName = questdlg('Read polygons from file', 'Read polygon');
switch upper(buttonName)
    case 'YES'
        % read i2s
        cFiles ={'*.i2s','Blue Kenue line file (*.i2s)';...
            '*.*','all files (*.*)'};
        
        % read
        if isfield(handles,'file')
            [file,path] = uigetfile(cFiles,'Select File',handles.file);
        else
            [file,path] = uigetfile(cFiles,'Select File');
        end
        % open file and replot
        if ischar(file)
            theFile     = fullfile(path,file);
            handles.volPoly = Telemac.readKenue(theFile);
        else
            ok = false;
            return;
        end
    case 'NO'
        % continue to next questions
        n = 0;
        while true
            n = n +1;
            % get polygons
            [~,xyProf,handles] = getLoc(handles,true);
            handles.volPoly{n} = xyProf;
            buttonName = questdlg('Add another polygon', 'Read polygon');
            switch upper(buttonName)
                case 'YES'
                    continue;
                case 'NO'
                    ok = true;
                    return
                case 'CANCEL'
                    ok = false;
                    return
            end
        end
    case 'CANCEL'
        ok = false;
        return
end
% make sure polygons are closed


% replot
handles     = plotData(handles);



function [tSteps,ok] = selectTimeSteps(sctData)
%select time steps to check
ok = false;
tSteps  =  [];
tmp = inputdlg({'Give time steps to process. Use Matlab stile input, e.g. 1:10'},'get volume data',1,{sprintf('1:%8.0f',sctData.NSTEPS)});
if isempty(tmp)
    return
end
try
    tSteps = eval(tmp{1});
catch
    errordlg('Not valid matlab input');
    return;
end
if min(tSteps)<1
    errordlg('Time step must be at least 1');
    return;
end
if max(tSteps)>sctData.NSTEPS
    errordlg(['Time step must be at most ',num2str(sctData.NSTEPS)]);
    return;
end
if any(abs(tSteps-floor(tSteps))>1e-5)
    errordlg('Time step must be integer');
    return;
end
ok = true;



% --------------------------------------------------------------------
function MENU_vol_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_vol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% calculate volumes in a polygon

% select polygon(s)_
[handles,ok] = selectPoly(handles);
if ~ok
    return;
end

varName   = 'sctData';
varName2D = 'sctData2D';

% TODO: select correct file
sctData = handles.(varName2D);


% selectd times
[tSteps,ok] = selectTimeSteps(sctData);
if ~ok
    return
end
nrTime = length(tSteps);

% calculate volume

tmpHandles = handles;
[tmpHandles,ok,x,y,ikle] = getData(tmpHandles,varName);
if ~ok
    return
end
xy   = [x,y];
xyC = Triangle.centerGravity(xy,ikle);

% make mask
nrVol = length(handles.volPoly);
for iPoly=nrVol:-1:1
    mask{iPoly} = inpoly(xyC,handles.volPoly{iPoly}(:,1:2));
    polyLines{iPoly} = sprintf('polyline %02.0f',iPoly);
end
% loop over time
volData = zeros(nrTime,nrVol);
volDataPos = zeros(nrTime,nrVol);
volDataNeg = zeros(nrTime,nrVol);
t       = zeros(nrTime,1);
hWait = waitbar(0,'Determining volumes');

for iTime = 1:nrTime
    hWait = waitbar(iTime/nrTime,hWait);
    
    % load data
    tmpHandles = updateData(tmpHandles,tSteps(iTime));
    [tmpHandles,ok,x,y,ikle,z] = getData(tmpHandles,varName);
    xy = [x,y];
    if ~ok
        return
    end
    % calculate volumes
    t(iTime) = tmpHandles.time;
    
    tmpVol = Triangle.triangleVolume(ikle,xy,z);
    isPos = z>=0;
    isNeg = z<=0;
    tmpVolPos= Triangle.triangleVolume(ikle,xy,z.*isPos);
    tmpVolNeg= Triangle.triangleVolume(ikle,xy,z.*isNeg);
    % apply mask per zone
    for iPoly=nrVol:-1:1
        volData(iTime,iPoly) = sum(tmpVol(mask{iPoly}));
        volDataPos(iTime,iPoly) = sum(tmpVolPos(mask{iPoly}));
        volDataNeg(iTime,iPoly) = sum(tmpVolNeg(mask{iPoly}));
    end
end
close(hWait);

%determine areas
tmpArea = Triangle.triangleArea(ikle,xy);
for iPoly=nrVol:-1:1
    areaData(iPoly) = sum(tmpArea(mask{iPoly}));
end

avgData = volData./areaData;
avgDataPos = volDataPos./areaData;
avgDataNeg = volDataNeg./areaData;

% calculate

% show table
hFig1   = figure;
hFig2   = figure;
hFig3   = figure;
hFig4   = figure;
hFig5   = figure;
hFig6   = figure;
hFig7   = figure;

volTable =[num2cell(datestr(t),2),num2cell(volData)];
avgTable =[num2cell(datestr(t),2),num2cell(avgData)];
volTablePos =[num2cell(datestr(t),2),num2cell(volDataPos)];
avgTablePos =[num2cell(datestr(t),2),num2cell(avgDataPos)];
volTableNeg =[num2cell(datestr(t),2),num2cell(volDataNeg)];
avgTableNeg =[num2cell(datestr(t),2),num2cell(avgDataNeg)];


areaTable = num2cell(areaData);

hTable1 = uitable(hFig1,'Data',volTable,'ColumnName', polyLines);
title('Volume');
hTable2 = uitable(hFig2,'Data',avgTable,'ColumnName', polyLines);
title('Average');
hTable3 = uitable(hFig3,'Data',areaTable,'ColumnName', polyLines);
title('Area');
hTable4 = uitable(hFig4,'Data',volTablePos,'ColumnName', polyLines);
title('Volume (postive parts)');
hTable5 = uitable(hFig5,'Data',avgTablePos,'ColumnName', polyLines);
title('Average (postive parts)');
hTable6 = uitable(hFig6,'Data',volTableNeg,'ColumnName', polyLines);
title('Volume (negative parts)');
hTable7 = uitable(hFig7,'Data',avgTableNeg,'ColumnName', polyLines);
title('Average (negative parts)');


% show figures

UtilPlot.reportFigureTemplate
subplot(3,1,1)
plot(t,avgData);
grid on
dynamicDateTicks
legend(polyLines);
xlabel('Time');
ylabel(['Average of ',getVarString(handles,varName,false)]);
subplot(3,1,2)
plot(t,avgDataPos);
grid on
dynamicDateTicks
legend(polyLines);
xlabel('Time');
ylabel(['Average (positive values)) of ',getVarString(handles,varName,false)]);
subplot(3,1,3)
plot(t,avgDataNeg);
grid on
dynamicDateTicks
legend(polyLines);
xlabel('Time');
ylabel(['Average (negative) of ',getVarString(handles,varName,false)]);

set(gcf,'UserData',polyLines);


guidata(hObject,handles);

% --------------------------------------------------------------------
function Menu_area_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --------------------------------------------------------------------
function MENU_spaceAvg_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_spaceAvg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MENU_max_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[handles,ok] = selectPoly(handles);
if ~ok
    return;
end

varName   = 'sctData';
varName2D = 'sctData2D';

% TODO: select correct file
sctData = handles.(varName2D);


% selectd times
[tSteps,ok] = selectTimeSteps(sctData);
if ~ok
    return
end
nrTime = length(tSteps);

% calculate volume

tmpHandles = handles;
[tmpHandles,ok,x,y,ikle] = getData(tmpHandles,varName);
if ~ok
    return
end
xy   = [x,y];

% make mask
nrVol = length(handles.volPoly);
for iPoly=nrVol:-1:1
    mask{iPoly} = inpoly(xy,handles.volPoly{iPoly}(:,1:2));
    polyLines{iPoly} = sprintf('polyline %02.0f',iPoly);
end
% loop over time
minData = zeros(nrTime,nrVol);
maxData = zeros(nrTime,nrVol);
t       = zeros(nrTime,1);
hWait = waitbar(0,'Determining volumes');

for iTime = 1:nrTime
    hWait = waitbar(iTime/nrTime,hWait);
    
    % load data
    tmpHandles = updateData(tmpHandles,tSteps(iTime));
    [tmpHandles,ok,x,y,ikle,z] = getData(tmpHandles,varName);
    xy = [x,y];
    if ~ok
        return
    end
    % calculate volumes
    t(iTime) = tmpHandles.time;
    
    % apply mask per zone
    for iPoly=nrVol:-1:1
        minData(iTime,iPoly) = min(z(mask{iPoly}));
        maxData(iTime,iPoly) = max(z(mask{iPoly}));
    end
end
close(hWait);

% calculate

% show table
hFig1   = figure;
hFig2   = figure;
minTable =[num2cell(datestr(t),2),num2cell(minData)];
maxTable =[num2cell(datestr(t),2),num2cell(maxData)];


hTable1 = uitable(hFig1,'Data',minTable,'ColumnName', polyLines);
hTable2 = uitable(hFig2,'Data',maxTable,'ColumnName', polyLines);

% show figures

UtilPlot.reportFigureTemplate
plot(t,minData);
grid on
dynamicDateTicks
legend(polyLines);
xlabel('Time');
ylabel(['Minimum of ',getVarString(handles,varName,false)]);
set(gcf,'UserData',polyLines);

UtilPlot.reportFigureTemplate
plot(t,maxData);
grid on
dynamicDateTicks
legend(polyLines);
xlabel('Time');
ylabel(['Maximum of ',getVarString(handles,varName,false)]);
set(gcf,'UserData',polyLines);


guidata(hObject,handles);


guidata(hObject,handles);



% --------------------------------------------------------------------
function MENU_min_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_17_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MENU_3d_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_3d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% make a 3d view


% select part of the mesh

[handles,ok] = selectPoly(handles);
if ~ok
    return
end

varName   = 'sctData';
varName2D = 'sctData2D';


% get data
tmpHandles = handles;
[tmpHandles,ok,x,y,ikle,z] = getData(tmpHandles,varName);
if ~ok
    return
end
xyz   = [x,y,z];

xyTri = Triangle.centerGravity(xyz(:,1:2),ikle);
mask  = inpoly(xyTri,handles.volPoly{1}(:,1:2));

[ikle,xyz] = Triangle.getSubset(ikle,xyz,mask);

% TODO; ask for input
aFac = 1;
% apply mask


% make 3D plot
z = xyz(:,3);
xy = xyz(:,1:2);
UtilPlot.reportFigureTemplate
trisurf(ikle,xy(:,1),xy(:,2),aFac.*z,z);
axis
colorbar;
shading interp;
% todo scaling; colormap etc
%title();


% --------------------------------------------------------------------
function Untitled_18_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MENU_timeseries_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_timeseries (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MENU_transect_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_transect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MENU_profile_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_profile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MENU_histSpace_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_histSpace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MENU_ellips_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_ellips (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MENU_table_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% get data points
[indNode,xyProf,handles] = getLoc(handles);
if isempty(indNode) || any(indNode==0) || any(isnan(indNode))
    errordlg('Invalid data points');
    return
end
guidata(hObject,handles);



% loop over number of plots
if handles.CB_compare.Value
    nrPlot = 2;
else
    nrPlot = 1;
end
allVar = {'sctData','sctData2'};
z = nan(size(xyProf,1),nrPlot);

for iPlot=1:nrPlot
    %prepare interpolation
    varName = allVar{iPlot};
    varName2d = [varName,'2D'];
    ikle = handles.(varName2d).IKLE;
    x    = handles.(varName2d).XYZ(:,1);
    y    = handles.(varName2d).XYZ(:,2);
    sctInterp = Triangle.interpTrianglePrepare(ikle,x,y,xyProf(:,1),xyProf(:,2));
    % load data
    [handles,ok,~,~,~,zTmp] = getData(handles,varName);
    if ~ok
        return
    end
    guidata(hObject,handles);
    z(:,iPlot) = Triangle.interpTriangle(sctInterp,zTmp);
    varStr{iPlot} = getVarString(handles,varName,false);
end
hFig1   = figure;
zTable  = num2cell([xyProf z]);
colName = [{'x [m]', 'y [m]' },varStr];
hTable  = uitable(hFig1,'Data',zTable,'ColumnName', colName);



% --- Executes on button press in CB_scatter.
function CB_scatter_Callback(hObject, eventdata, handles)
% hObject    handle to CB_scatter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_scatter


% --------------------------------------------------------------------
function MENU_extend_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_extend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


xLim = get(handles.hMap,'xlim');
yLim = get(handles.hMap,'ylim');
clipboard('copy',[xLim yLim]);


% --------------------------------------------------------------------
function MENU_setExtend_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_setExtend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

xLim = round(get(handles.hMap,'xlim'));
yLim = round(get(handles.hMap,'ylim'));

tmpXy = {num2str([xLim,yLim])};

tmp = inputdlg({'Specify xmin xmax ymin and ymax. Each line is one view. '},'Figure lims',[20],tmpXy);

if isempty(tmp)
    return;
end
tmp = tmp{1};
tmp = str2num(tmp); %#ok<ST2NM>
if size(tmp,2)~=4
    errordlg('Invalid input');
end
xLim = tmp(1,1:2);
yLim = tmp(1,3:4);
handles.xLimAll = tmp(:,1:2);
handles.yLimAll = tmp(:,3:4);

set(handles.hMap,'xlim',xLim);
set(handles.hMap,'ylim',yLim);

guidata(hObject,handles);

% --------------------------------------------------------------------
function MENU_loadSettings_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_loadSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


msgbox('To be implemented. Buy me a beer.');

% --------------------------------------------------------------------
function MENU_saveSettings_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_saveSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

msgbox('To be implemented. Buy me a beer.');


% --- Executes on button press in PB_autoScaleView.
function PB_autoScaleView_Callback(hObject, eventdata, handles)
% hObject    handle to PB_autoScaleView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% select data
handles.ind = get(handles.LB_var,'Value');
tmp = handles.sctData.RESULT(:,handles.ind);
tmp = applyEq(handles,tmp);
% maximum is limited to prevent crashes; also there is always a minimum
% difference

xLim = round(get(handles.hMap,'xlim'));
yLim = round(get(handles.hMap,'ylim'));
x = handles.sctData.XYZ(:,1);
y = handles.sctData.XYZ(:,2);
mask = x>=xLim(1) &  x<=xLim(2) &  y>=yLim(1) &  y<=yLim(2);

if sum(mask)==0
    return;
end
minV = max(min(min(tmp(mask)),1e16),-1e16);
maxV = max(min(max(tmp(mask)),1e16),-1e16);
if maxV==minV
    maxV = maxV.*1.1;
end

% set
set(handles.ET_max,'String',num2str(maxV))
set(handles.ET_min,'String',num2str(minV))
handles = applyH(handles);
guidata(hObject,handles);


% --- Executes on button press in CB_quiverEqual.
function CB_quiverEqual_Callback(hObject, eventdata, handles)
% hObject    handle to CB_quiverEqual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_quiverEqual

tmp = inputdlg({'Give the threshold'},'Threshold',1,{'0.01'});
threshold = str2double(tmp);
if isnan(threshold)
    errordlg('Invalid input');
    return;
end

handles.quiverThreshold = threshold;
guidata(hObject,handles);


% --------------------------------------------------------------------
function MENU_colorMap_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_colorMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


inputDlg


% --------------------------------------------------------------------
function TB_preview_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to TB_preview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function TB_movie_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to TB_movie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% make movie
handles = saveImage(handles,'movie');
guidata(hObject,handles);


% --- Executes on button press in CB_transectLine.
function CB_transectLine_Callback(hObject, eventdata, handles)
% hObject    handle to CB_transectLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_transectLine


% --------------------------------------------------------------------
function MENU_findPointTransect_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_findPointTransect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'dist')
    return;
end

% get point
set(gcf,'CurrentAxes',handles.hMap);
[x,y,w] = fastGinput(1);
% error checking
if w~=1
    return
end


% handle comparison
hProf(1) = handles.hProf;
if handles.CB_compare.Value
    nrPlot = 2;
    hProf(2) = handles.hProf2;
else
    nrPlot = 1;
end

for iPlot = 1:nrPlot
    % find closest point
    [~,ind] = PolyLine.dist2poly([x y],handles.distXy{iPlot});
    xTmp = handles.distXy{iPlot}(1:ind,1);
    yTmp = handles.distXy{iPlot}(1:ind,2);
    dist = sum(hypot(diff(xTmp),diff(yTmp)));
    % adapth plot    
    yLim  = get(hProf(iPlot),'ylim');
    plot(hProf(iPlot),[dist dist],yLim,'k:')
end


% --------------------------------------------------------------------
function MENU_findMap_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_findMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'dist')
    return;
end

% get point
set(gcf,'CurrentAxes',handles.hProf);
[dist,~,w] = fastGinput(1);
% error checking
if w~=1
    return
end

% handle comparison
hMap(1) = handles.hMap;
if handles.CB_compare.Value
    nrPlot = 2;
    hMap(2) = handles.hMap;
else
    nrPlot = 1;
end

for iPlot = 1:nrPlot
    % find closest point
    x = interp1(handles.dist{iPlot},handles.distXy{iPlot}(:,1),dist);
    y = interp1(handles.dist{iPlot},handles.distXy{iPlot}(:,2),dist);
    % adapth plot    
    plot(hMap(iPlot),x,y,'pk','markersize',15);
end


% --- Executes on selection change in LB_i2s.
function LB_i2s_Callback(hObject, eventdata, handles)
% hObject    handle to LB_i2s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LB_i2s contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LB_i2s


% --- Executes during object creation, after setting all properties.
function LB_i2s_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LB_i2s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function MENU_deleteLine_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_deleteLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if isfield(handles,'i2s')
    tmp = handles.LB_i2s.String;
    nrI2s = length(tmp);
    ind = handles.LB_i2s.Value;
    handles.i2s(ind) = [];
    ind = setdiff(1:nrI2s,ind);    
    handles.LB_i2s.String = tmp(ind);
    guidata(hObject,handles);
end


% --- Executes on button press in CB_showHalo.
function CB_showHalo_Callback(hObject, eventdata, handles)
% hObject    handle to CB_showHalo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CB_showHalo


% --- Executes on button press in PB_histSpace.
function PB_histSpace_Callback(hObject, eventdata, handles)
% hObject    handle to PB_histSpace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[z,ok] = getZ(handles);
if ok
    for i=1:size(z,2)
        plotHist(z(:,i));
    end
end

% --------------------------------------------------------------------
function MENU_histDiff_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_histDiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[z,ok] = getZ(handles);
if ok && size(z,2)==2 
        plotHist(z(:,1)-z(:,2));
end

function plotHist(z)
% plot a histogram
UtilPlot.reportFigureTemplate;

histogram(z,500);
mu = nanmean(z);
std = nanstd(z);
median = nanmedian(z);
minZ = min(z);
maxZ = max(z);
title(sprintf('Mean = %6.3e; Std = %6.3e;\n Median = %6.3e;\n Range = %6.3e to %6.3e ;',mu,std,median,minZ,maxZ));
grid on;

function [z,ok] = getZ(handles)
% extracts z Data
if handles.CB_compare.Value
    nrPlot = 2;
else
    nrPlot = 1;
end
allVar = {'sctData','sctData2'};
z =[];
for iPlot=nrPlot:-1:1
    %prepare interpolation
    varName = allVar{iPlot};
    varName2d = [varName,'2D'];
    % load data
    [handles,ok,~,~,~,zTmp] = getData(handles,varName);
    if ~ok
        return
    end
    % TODO: DIFFERENT MESH SIZES
    z(:,iPlot) = zTmp; 
end


% --------------------------------------------------------------------
function MENU_mpadata_Callback(hObject, eventdata, handles)
% hObject    handle to MENU_mpadata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if handles.CB_compare.Value &&~handles.CB_diff.Value
    nrPlot = 2;
else
    nrPlot = 1;
end
varName = {'sctData','sctData2'};
theName = inputdlg({'Give the name '},'Variable name',1,{'sctData'});

for i=1:nrPlot

    tmpName = [theName{1},num2str(i)];
    if evalin('base',['exist(''',tmpName,''',''var'')'])
        errordlg('Variable already exists')
        return;
    end

    %get data
    [handles,ok,x,y,ikle,z,u,v] = getData(handles,varName{i});
    if ~ok
        return;
    end
    % add to structure
    mapData.x = x;
    mapData.y = y;
    mapData.z = z;
    mapData.ikle = ikle;
    mapData.u = u;
    mapData.v = v;
    
    % check for a new name
    
    
    assignin('base',tmpName,mapData)
    
end