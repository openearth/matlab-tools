function varargout = getCoordinates(varargin)
% GETCOORDINATES MATLAB code for getCoordinates.fig
%      GETCOORDINATES, by itself, creates a new GETCOORDINATES or raises the existing
%      singleton*.
%
%      H = GETCOORDINATES returns the handle to a new GETCOORDINATES or the handle to
%      the existing singleton*.
%
%      GETCOORDINATES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GETCOORDINATES.M with the given input arguments.
%
%      GETCOORDINATES('Property','Value',...) creates a new GETCOORDINATES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before getCoordinates_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to getCoordinates_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help getCoordinates

% Last Modified by GUIDE v2.5 30-Jun-2013 13:44:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @getCoordinates_OpeningFcn, ...
    'gui_OutputFcn',  @getCoordinates_OutputFcn, ...
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


% --- Executes just before getCoordinates is made visible.
function getCoordinates_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to getCoordinates (see VARARGIN)

% Choose default command line output for getCoordinates
handles.output = hObject;

set(handles.uitable1,'ColumnFormat',{'char','numeric','numeric','numeric','numeric'})
set(handles.uitable1,'data',{});

% look for type of plot
%plotInd = strcmpi('plotType',varargin);
plotType = varargin{2};

% look for dataset 
%dataInd = strcmpi('dataset',varargin);
dataset = varargin{1};


set(gcf,'CurrentAxes',handles.axes1);

switch plotType
    case 'line'
        plot(dataset.X.data,dataset.Y.data)
    case  'pcolor'
        pcolor(dataset.X.data,dataset.Y.data,squeeze(dataset.BotDep.data(1,:,:)))
        shading flat;axis equal;
end;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes getCoordinates wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = getCoordinates_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
    close(handles.figure1)


% --- Executes on button press in PBpoint.
function PBpoint_Callback(hObject, eventdata, handles)
% hObject    handle to PBpoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

w = 1;
while w==1
    [x,y,w] = ginput(1);
    if w==1
        % plot point
        hold on;
        plot(handles.axes1,x,y,'or')
        hold off;
        % add data to the table
        cData = get(handles.uitable1,'data');
        nrData = size(cData,1);
        cData{nrData+1,1} = 'point';
        cData{nrData+1,2} = x;
        cData{nrData+1,3} = y;
        
        set(handles.uitable1,'data',cData);
        guidata(hObject, handles);
    end;
end;

% --- Executes on button press in PBtransect.
function PBtransect_Callback(hObject, eventdata, handles)
% hObject    handle to PBtransect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

w = 1;
xList = [];
yList = [];
i = 0;
while w==1
    [x,y,w] = ginput(1);
    xList = [xList,x];
    yList = [yList,y];
    if w==1
        i = i + 1;
        % delete old line
        if i>1
            delete(hTrans);
        end;
        % plot transect
        hold on;
        hTrans = plot(handles.axes1,xList,yList,'-ob');
        hold off;
        % add data to the table
        cData = get(handles.uitable1,'data');
        nrData = size(cData,1);
        cData{nrData+1,1} = ['transect ',num2str(i)];
        cData{nrData+1,2} = x;
        cData{nrData+1,3} = y;
        
        set(handles.uitable1,'data',cData);
        guidata(hObject, handles);
    end;
end;

% --- Executes on button press in PBrectangle.
function PBrectangle_Callback(hObject, eventdata, handles)
% hObject    handle to PBrectangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

k = waitforbuttonpress;
point1 = get(handles.axes1,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(handles.axes1,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);             % calculate locations
offset = abs(point1-point2);         % and dimensions
x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
hold on

plot(x,y,'-g')                            % redraw in dataspace units

 % add data to the table
        cData = get(handles.uitable1,'data');
        nrData = size(cData,1);
        cData{nrData+1,1} = 'rectangle';
        cData{nrData+1,2} = point1(1);
        cData{nrData+1,3} = point1(2);
                cData{nrData+1,4} = point2(1);
        cData{nrData+1,5} = point2(2);
        
        set(handles.uitable1,'data',cData);
        guidata(hObject, handles);


% --- Executes on button press in PBsave.
function PBsave_Callback(hObject, eventdata, handles)
% hObject    handle to PBsave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = get(handles.uitable1,'data');
 guidata(hObject, handles);
    uiresume(handles.figure1);

% --- Executes on button press in PBcancel.
function PBcancel_Callback(hObject, eventdata, handles)
% hObject    handle to PBcancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

choice = questdlg('Are you sure you want to quit? Your data will not be saved.', ...
    'Cancel', ...
    'Yes','No','No');
if strcmpi(choice,'Yes')
    handles.output = [];
    uiresume(handles.figure1);

end;
