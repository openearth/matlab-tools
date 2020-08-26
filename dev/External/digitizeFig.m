function varargout = digitizeFig(varargin)
% DIGITIZEFIG MATLAB code for digitizeFig.fig
%      DIGITIZEFIG, by itself, creates a new DIGITIZEFIG or raises the existing
%      singleton*.
%
%      H = DIGITIZEFIG returns the handle to a new DIGITIZEFIG or the handle to
%      the existing singleton*.
%
%      DIGITIZEFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIGITIZEFIG.M with the given input arguments.
%
%      DIGITIZEFIG('Property','Value',...) creates a new DIGITIZEFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before digitizeFig_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to digitizeFig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help digitizeFig

% Last Modified by GUIDE v2.5 28-Sep-2015 17:55:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @digitizeFig_OpeningFcn, ...
                   'gui_OutputFcn',  @digitizeFig_OutputFcn, ...
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


% --- Executes just before digitizeFig is made visible.
function digitizeFig_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to digitizeFig (see VARARGIN)

% Choose default command line output for digitizeFig
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes digitizeFig wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = digitizeFig_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in PB_Load1.
function PB_Load1_Callback(hObject, eventdata, handles)
% hObject    handle to PB_Load1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load data
if ~isfield(handles,'thePath')
    handles.thePath = 'k:\projects\';
end
[fileName,pathName] = uigetfile('*.png','Load image',handles.thePath);


if ischar(fileName)
    handles.theFile = fullfile(pathName,fileName);
	handles.thePath = pathName;
	imageData = imread(handles.theFile);

% show data
	set(gcf,'currentaxes',handles.axes1);
	image(imageData); axis equal;
    
% update text
    set(handles.TextCommand,'String',handles.theFile);

% reset data
    handles.x0 = [];
    handles.x1 = [];
    handles.x  = [];
    handles.y  = [];
end

% save
guidata(hObject,handles)


% --- Executes on button press in PB_Save.
function PB_Save_Callback(hObject, eventdata, handles)
% hObject    handle to PB_Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% save data
if ~isfield(handles,'thePath')
    handles.thePath = 'k:\projects';
end
[fileName,pathName] = uiputfile('*.txt','Save data',handles.thePath);
if ischar(fileName)
	theFile = fullfile(pathName,fileName);
	data1(:,1) = handles.x;
	data1(:,2) = handles.y; %#ok<NASGU>
	save(theFile,'data1','-ascii')
end




% --- Executes on button press in PB_Calibrate.
function PB_Calibrate_Callback(hObject, eventdata, handles)
% hObject    handle to PB_Calibrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Calibrate

set(gcf,'currentaxes',handles.axes1);
handles.theText = get(handles.TextCommand,'String');

set(handles.TextCommand,'String','Click on lower left calibration point.');
[imX0,imY0,w] = ginput(1);
if w~=1
    set(handles.TextCommand,'String',handles.theText);
    guidata(hObject,handles)
    return;
end
answer = inputdlg({'Give x value first coordinate','Give y value first coordinate'},'First coordinate',2);

if isempty(answer)
    set(handles.TextCommand,'String',handles.theText);
    guidata(hObject,handles)
    return;
end
x0 = str2double(answer{1});
y0 = str2double(answer{2});

set(handles.TextCommand,'String','Click on upper right calibration point.');
[imX1,imY1,w] = ginput(1);
if w~=1
    set(handles.TextCommand,'String',handles.theText);
    guidata(hObject,handles)
    return;
end

answer = inputdlg({'Give x value second coordinate','Give y value first coordinate'},'Second coordinate',2);

if isempty(answer)
    set(handles.TextCommand,'String',handles.theText);
    guidata(hObject,handles)
    return;
end

x1 = str2double(answer{1});
y1 = str2double(answer{2});

handles.x0 = [x0,y0];
handles.x1 = [x1,y1];
handles.im0 = [imX0,imY0];
handles.im1 = [imX1,imY1];
set(handles.TextCommand,'String',handles.theText);

% save
guidata(hObject,handles)



% --- Executes on button press in PB_Digitize.
function PB_Digitize_Callback(hObject, eventdata, handles)
% hObject    handle to PB_Digitize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(gcf,'currentaxes',handles.axes1);
handles.theText = get(handles.TextCommand,'String');
set(handles.TextCommand,'String','Click on points to digitize. Stop with right mouse button.');

% input coordinates
if isempty(handles.x0)
    set(handles.TextCommand,'String',handles.theText);
    guidata(hObject,handles)    
    errordlg('You need to calibrate the image first.');
    return;
end

[imX,imY] = UserInput.digitize;

% get data
x0 = handles.x0(1);
y0 = handles.x0(2);
x1 = handles.x1(1);
y1 = handles.x1(2);
imX0 = handles.im0(1);
imY0 = handles.im0(2);
imX1 = handles.im1(1);
imY1 = handles.im1(2);


% calculate values
x = x0 + (imX-imX0)./(imX1-imX0).*(x1-x0);
y = y0 + (imY-imY0)./(imY1-imY0).*(y1-y0);

% save
handles.x = [handles.x;x];
handles.y = [handles.y;y];
guidata(hObject,handles)




% --- Executes on button press in PB_Zoom.
function PB_Zoom_Callback(hObject, eventdata, handles)
% hObject    handle to PB_Zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Toggle zoom on or off

if strcmpi(get(handles.PB_Zoom,'String'),'Zoom')
    handles.theText = get(handles.TextCommand,'String');
    set(handles.TextCommand,'String','Zoom is on.')
    set(handles.PB_Zoom,'String','Zoom off');
    zoom on;
else
    if isfield(handles,'theText')
        set(handles.TextCommand,'String',handles.theText)
    end
    set(handles.PB_Zoom,'String','Zoom');
    zoom off;
end

% save
guidata(hObject,handles)


% --- Executes on button press in PB_Reset.
function PB_Reset_Callback(hObject, eventdata, handles)
% hObject    handle to PB_Reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% delete data
handles.x0 = [];
handles.x1 = [];
handles.x  = [];
handles.y  = [];

% save
guidata(hObject,handles)
