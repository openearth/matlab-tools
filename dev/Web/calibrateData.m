function varargout = calibrateData(varargin)
% CALIBRATEDATA M-file for calibrateData.fig
%      CALIBRATEDATA, by itself, creates a new CALIBRATEDATA or raises the existing
%      singleton*.
%
%      H = CALIBRATEDATA returns the handle to a new CALIBRATEDATA or the handle to
%      the existing singleton*.
%
%      CALIBRATEDATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALIBRATEDATA.M with the given input arguments.
%
%      CALIBRATEDATA('Property','Value',...) creates a new CALIBRATEDATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before calibrateData_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to calibrateData_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help calibrateData

% Last Modified by GUIDE v2.5 12-May-2014 15:34:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @calibrateData_OpeningFcn, ...
    'gui_OutputFcn',  @calibrateData_OutputFcn, ...
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


% --- Executes just before calibrateData is made visible.
function calibrateData_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to calibrateData (see VARARGIN)

% Choose default command line output for calibrateData
handles.output = hObject;

handles.data = varargin{1};

% Update handles structure
guidata(hObject, handles);

%plot de approximation
% plot(handles.axes1,handles.data.x(handles.data.newIndexes),handles.data.newY(handles.data.newIndexes),'-', handles.data.x(handles.data.indexes), handles.data.y(handles.data.indexes), 'o');
% title({['Equation: ' handles.data.equation] ; ['R2: ' num2str(handles.data.r2)]});

plot(handles.axes1,handles.data.x,handles.data.y,'o');
title('Selected data');
xlabel(handles.data.xName);
ylabel(handles.data.yName);


% UIWAIT makes calibrateData wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = calibrateData_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnSelectData.
function btnSelectData_Callback(hObject, eventdata, handles)
% hObject    handle to btnSelectData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom off;
%set(handles.axes1,'ButtonDownFcn',@Util.selectDataPlot);

[a ~] = WebCalibrate.selectDataPlot(handles.axes1);
if ~isfield(handles,'setDataInRect')
    handles.setDataInRect = [];
end
handles.setDataInRect = vertcat(a,handles.setDataInRect);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in btnRemoveData.
function btnRemoveData_Callback(hObject, eventdata, handles)
% hObject    handle to btnRemoveData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.setDataInRect)
    handles.data.cleanX = handles.data.x;
    handles.data.cleanY = handles.data.y;
    for i=1:length(handles.setDataInRect)
        index = find(handles.data.cleanX  == handles.setDataInRect(i));
        handles.data.cleanX(index) = [];
        handles.data.cleanY(index) = [];
    end;

    cla(handles.axes1);
    plot(handles.axes1, handles.data.cleanX, handles.data.cleanY,'o');
    title('Data removed');
end;

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in btnZoomIn.
function btnZoomIn_Callback(hObject, eventdata, handles)
% hObject    handle to btnZoomIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% h = msgbox('Zoom in: Click on the plot or Zoom Out: Shift + Click on the plot','Zoom Options','help');
% uiwait(h);
zoom on;

% --- Executes on button press in btnZoomOut.
function btnZoomOut_Callback(hObject, eventdata, handles)
% hObject    handle to btnZoomOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom out;
zoom off;




% --- Executes on button press in btnCalibrate.
function btnCalibrate_Callback(hObject, eventdata, handles)
% hObject    handle to btnCalibrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles.data, 'cleanX') && ~isempty(handles.data.cleanX)
    x = handles.data.cleanX;
    y = handles.data.cleanY;
else
    x = handles.data.x;
    y = handles.data.y;
end;
options = handles.data.options;

% x data
% y data
% options: structure. Posible values:
%       method(String)
%       order(Integer) if method = 'polinomial'
%       throughZero(boolean: 1 - 0) if method = 'p
 options = Util.setDefaultNumberField(options, 'order');
 options = Util.setDefaultNumberField(options, 'throughzero');

if isfield(options,'method')
    try
        switch options.method
            case 'polynomial'
                coef     = Fit.fitPolynomial(x,y,options);
                equation = Fit.equationPolynomial(coef,options);
                newY     = Fit.applyPolynomial(x,coef);
                r2       = Fit.rSquared(y,newY);
            case 'log'
                coef     = Fit.fitLog(x,y);
                equation = Fit.equationLog(coef,options);
                newY     = Fit.applyLog(x,coef);
                r2       = Fit.rSquared(y,newY);
            case 'exp'
                coef     = Fit.fitExp(x,y);
                equation = Fit.equationExp(coef,options);
                newY     = Fit.applyExp(x,coef);
                r2       = Fit.rSquared(y,newY);
            case 'power'
                coef     = Fit.fitPower(x,y);
                equation = Fit.equationPower(coef,options);
                newY     = Fit.applyPower(x,coef);
                r2       = Fit.rSquared(y,newY);
            case 'lowess'
                %[yNew,yMin,yMax] = Calculate.lowess(x, y, xNew, options)
            otherwise
                errordlg('Error!. The method selected is invalid');
                return;
        end
    catch
        sct = lasterror;
        errordlg(sct.message);
        return;
    end;
else
    errordlg('You have to specify the method');
    return;
end;
[~, indexes]    = sort(y);
[~, newIndexes] = sort(newY);

plot(handles.axes1,x(newIndexes),newY(newIndexes),'-',x(indexes), y(indexes), 'o');
title({['Equation: ' equation] ; ['R2: ' num2str(r2)]});

options = Util.setDefault(options,'Xscale','linear');
options = Util.setDefault(options,'Yscale','linear');

set(handles.axes1,'XScale',options.Xscale);
set(handles.axes1,'YScale',options.Yscale);

handles.newY       = newY;
handles.indexes    = indexes;
handles.newIndexes = newIndexes;
handles.equation   = equation;
handles.r2         = r2;

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in btnSave.
function btnSave_Callback(hObject, eventdata, handles)
% hObject    handle to btnSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selectedVar = handles.data.yName;


[dataset, loadOk] = Dataset.loadData(handles.data.fileToApply,0);

try
    dataset.(selectedVar).data = handles.newY;
    dataset.(selectedVar).equation = handles.equation;
    dataset.(selectedVar).r2 = handles.r2;
catch
    sct = lasterror;
    errordlg('Error. The calibration is not complete. Please verify the data');
    return;
end;

saveOk = Dataset.saveData(dataset,handles.data.fileToApply);

if ~saveOk
    errordlg('Error. The file could not been saved');
    return;
else
    msgbox('Your data has been saved sucessfully', 'Message','help');
end;




% --- Executes on button press in btnRecorver.
function btnRecorver_Callback(hObject, eventdata, handles)
% hObject    handle to btnRecorver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla(handles.axes1);
handles.setDataInRect = [];
handles.data.cleanX = [];
handles.data.cleanY = [];
plot(handles.axes1,handles.data.x,handles.data.y,'o');
title('Selected data');

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
%This is a hack to see the buttons in the compiled script
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
myDbStack = dbstack();
if length(myDbStack) > 1 && any(strcmp(myDbStack(2).file, 'hgloadStructDbl.m'))
    % don't force visibility when GUIs are opened
else
    set(hObject, 'Visible', 'on');
    drawnow();
end

