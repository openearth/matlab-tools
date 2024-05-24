function varargout = prosol(varargin)
% PROSOL M-file for prosol.fig
%      PROSOL, by itself, creates a new PROSOL or raises the existing
%      singleton*.
%
%      sliderH = PROSOL returns the handle to a new PROSOL or the handle to
%      the existing singleton*.
%
%      PROSOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROSOL.M with the given input arguments.
%
%      PROSOL('Property','Value',...) creates a new PROSOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before prosol_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to prosol_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help prosol

% Last Modified by GUIDE v2.5 27-Dec-2010 15:39:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @prosol_OpeningFcn, ...
    'gui_OutputFcn',  @prosol_OutputFcn, ...
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


% --- Executes just before prosol is made visible.
function prosol_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prosol (see VARARGIN)

% Choose default command line output for prosol
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

set(handles.sliderH,'Min',0.05);
set(handles.sliderH,'Max',10);
set(handles.sliderH,'Value',0.05);
set(handles.editH,'String','0.05');

set(handles.sliderRH,'Min',get(handles.sliderH,'Value')*5);
set(handles.sliderRH,'Max',get(handles.sliderH,'Value')*1000);
set(handles.sliderRH,'Value',4.1);
set(handles.editRH,'String','4.1');

set(handles.sliderU,'Min',0.05);
set(handles.sliderU,'Max',1);
set(handles.sliderU,'Value',0.2);
set(handles.editU,'String','0.2');

set(handles.sliderks,'Min',0);
set(handles.sliderks,'Max',0.2*get(handles.sliderH,'Value'));
set(handles.sliderks,'Value',0);
set(handles.editks,'String',0);

H = get(handles.sliderH,'Value');
R = get(handles.sliderRH,'Value');
U = get(handles.sliderU,'Value');
ks = get(handles.sliderks,'Value');
ps = get(handles.plotscaled,'Value');

%set(handles.editR,'String',num2str(R));

updateaxes12(hObject, eventdata, handles, H, R, U, ks, ps)
%%updateaxes3(hObject, eventdata, handles)


% UIWAIT makes prosol wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prosol_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function sliderH_Callback(hObject, eventdata, handles)
% hObject    handle to sliderH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

H = get(handles.sliderH,'Value');
set(handles.editH,'String',num2str(H));
set(handles.sliderks,'Max',0.2*H);
set(handles.sliderRH,'Max',1000*H);
set(handles.sliderRH,'Min',5*H);
if (get(handles.sliderks,'Value') > 0.2*H);
    set(handles.sliderks,'Value',0.2*H);
    set(handles.editks,'String',num2str(0.2*H));
end
if (get(handles.sliderRH,'Value') > 1000*H);
    set(handles.sliderRH,'Value',1000*H);
    set(handles.editRH,'String',num2str(1000*H));
end
if (get(handles.sliderRH,'Value') < 5*H);
    set(handles.sliderRH,'Value',5*H);
    set(handles.editRH,'String',num2str(5*H));
end
H = get(handles.sliderH,'Value');
R = get(handles.sliderRH,'Value');
U = get(handles.sliderU,'Value');
ks = get(handles.sliderks,'Value');
ps = get(handles.plotscaled,'Value');

%set(handles.editR,'String',num2str(R));
%set(handles.slideralphas,'Value',-1);
%set(handles.editalphas,'String','-1');
updateaxes12(hObject, eventdata, handles, H, R, U, ks, ps)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderRH_Callback(hObject, eventdata, handles)
% hObject    handle to sliderRH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.editRH,'String',num2str(get(handles.sliderRH,'Value')))
%set(handles.slideralphas,'Value',-1);
%set(handles.editalphas,'String','-1');
%updateaxes3(hObject, eventdata, handles)
H = get(handles.sliderH,'Value');
R = get(handles.sliderRH,'Value');
U = get(handles.sliderU,'Value');
ks = get(handles.sliderks,'Value');
ps = get(handles.plotscaled,'Value');

%set(handles.editR,'String',num2str(R));
updateaxes12(hObject, eventdata, handles, H, R, U, ks, ps)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderRH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderRH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderU_Callback(hObject, eventdata, handles)
% hObject    handle to sliderU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.editU,'String',num2str(get(handles.sliderU,'Value')))
%set(handles.slideralphas,'Value',-1);
%set(handles.editalphas,'String','-1');
%updateaxes3(hObject, eventdata, handles)
H = get(handles.sliderH,'Value');
R = get(handles.sliderRH,'Value');
U = get(handles.sliderU,'Value');
ks = get(handles.sliderks,'Value');
ps = get(handles.plotscaled,'Value');

updateaxes12(hObject, eventdata, handles, H, R, U, ks, ps)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function sliderU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderks_Callback(hObject, eventdata, handles)
% hObject    handle to sliderks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.editks,'String',num2str(get(handles.sliderks,'Value')))
%set(handles.slideralphas,'Value',-1);
%set(handles.editalphas,'String','-1');
H = get(handles.sliderH,'Value');
R = get(handles.sliderRH,'Value');
U = get(handles.sliderU,'Value');
ks = get(handles.sliderks,'Value');
ps = get(handles.plotscaled,'Value');

updateaxes12(hObject, eventdata, handles, H, R, U, ks, ps)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slideralphas_Callback(hObject, eventdata, handles)
% hObject    handle to slideralphas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.editalphas,'String',num2str(get(handles.slideralphas,'Value')))
%updateaxes3(hObject, eventdata, handles)
H = get(handles.sliderH,'Value');
R = get(handles.sliderRH,'Value');
U = get(handles.sliderU,'Value');
ks = get(handles.sliderks,'Value');
ps = get(handles.plotscaled,'Value');

updateaxes12(hObject, eventdata, handles, H, R, U, ks, ps)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slideralphas_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slideralphas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editH_Callback(hObject, eventdata, handles)
% hObject    handle to editH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

H = str2double(get(handles.editH,'String'));
set(handles.sliderH,'Value',H);
set(handles.sliderks,'Max',0.2*H);
set(handles.sliderRH,'Max',1000*H);
set(handles.sliderRH,'Min',5*H);

if (get(handles.sliderks,'Value') > 0.2*H);
    set(handles.sliderks,'Value',0.2*H);
    set(handles.editks,'String',num2str(0.2*H));
end
if (get(handles.sliderRH,'Value') > 1000*H);
    set(handles.sliderRH,'Value',1000*H);
    set(handles.editRH,'String',num2str(1000*H));
end
if (get(handles.sliderRH,'Value') < 5*H);
    set(handles.sliderRH,'Value',5*H);
    set(handles.editRH,'String',num2str(5*H));
end



%set(handles.slideralphas,'Value',-1);
%set(handles.editalphas,'String','-1');
H = get(handles.sliderH,'Value');
R = get(handles.sliderRH,'Value');
U = get(handles.sliderU,'Value');
ks = get(handles.sliderks,'Value');
ps = get(handles.plotscaled,'Value');

%set(handles.editR,'String',num2str(R));
updateaxes12(hObject, eventdata, handles, H, R, U, ks, ps)

% (error catching)?
% if (str2double(get(handles.editH,'String') < get(handles.sliderH,'Min'))
%         set(handles.editH,'String',num2str(get(handles.sliderH,'Min')));

% Hints: get(hObject,'String') returns contents of editH as text
%        str2double(get(hObject,'String')) returns contents of editH as a double


% --- Executes during object creation, after setting all properties.
function editH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editRH_Callback(hObject, eventdata, handles)
% hObject    handle to editRH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Rfromstr = str2double(get(handles.editRH,'String'));
H = get(handles.sliderH,'Value');
Rfromstr = max(5*H, Rfromstr);
Rfromstr = min(1000*H, Rfromstr);
set(handles.editRH,'String',num2str(Rfromstr))
set(handles.sliderRH,'Value',Rfromstr);
%set(handles.slideralphas,'Value',-1);
%set(handles.editalphas,'String','-1');
%H = get(handles.sliderH,'Value');
R = get(handles.sliderRH,'Value');
U = get(handles.sliderU,'Value');
ks = get(handles.sliderks,'Value');
set(handles.editks,'String',num2str(ks));
%set(handles.slideralphas,'Value',-1);
%set(handles.editalphas,'String','-1');
%updateaxes3(hObject, eventdata, handles)
H = get(handles.sliderH,'Value');
R = get(handles.sliderRH,'Value');
U = get(handles.sliderU,'Value');
ks = get(handles.sliderks,'Value');
ps = get(handles.plotscaled,'Value');

%set(handles.editR,'String',num2str(R));
updateaxes12(hObject, eventdata, handles, H, R, U, ks, ps)
% Hints: get(hObject,'String') returns contents of editRH as text
%        str2double(get(hObject,'String')) returns contents of editRH as a double


% --- Executes during object creation, after setting all properties.
function editRH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editU_Callback(hObject, eventdata, handles)
% hObject    handle to editU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.sliderU,'Value',str2double(get(handles.editU,'String')));
%set(handles.slideralphas,'Value',-1);
%set(handles.editalphas,'String','-1');
%updateaxes3(hObject, eventdata, handles)
H = get(handles.sliderH,'Value');
R = get(handles.sliderRH,'Value');
U = get(handles.sliderU,'Value');
ks = get(handles.sliderks,'Value');
ps = get(handles.plotscaled,'Value');

updateaxes12(hObject, eventdata, handles, H, R, U, ks, ps)
% Hints: get(hObject,'String') returns contents of editU as text
%        str2double(get(hObject,'String')) returns contents of editU as a double


% --- Executes during object creation, after setting all properties.
function editU_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editks_Callback(hObject, eventdata, handles)
% hObject    handle to editks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.sliderks,'Value',min(str2double(get(handles.editks,'String')),0.2*get(handles.sliderH,'Value')));
%set(handles.slideralphas,'Value',-1);
%set(handles.editalphas,'String','-1');
H = get(handles.sliderH,'Value');
R = get(handles.sliderRH,'Value');
U = get(handles.sliderU,'Value');
ks = get(handles.sliderks,'Value');
set(handles.editks,'String',num2str(ks));
ps = get(handles.plotscaled,'Value');

updateaxes12(hObject, eventdata, handles, H, R, U, ks, ps)
% Hints: get(hObject,'String') returns contents of editks as text
%        str2double(get(hObject,'String')) returns contents of editks as a double


% --- Executes during object creation, after setting all properties.
function editks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editalphas_Callback(hObject, eventdata, handles)
% hObject    handle to editalphas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
alphas = str2double(get(handles.editalphas,'String'));
set(handles.slideralphas,'Value',alphas);
%updateaxes3(hObject, eventdata, handles);

% Hints: get(hObject,'String') returns contents of editalphas as text
%        str2double(get(hObject,'String')) returns contents of editalphas as a double


% --- Executes during object creation, after setting all properties.
function editalphas_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editalphas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function updateaxes12(hObject, eventdata, handles, H, R, U, ks, ps)

[ust,z0] = calcz0min(H,U);
karman = 0.4;
if ks > 30*z0;
    z0  = ks/30;
    Cf  = ((log(H/z0) - (H-z0)/H)/karman)^(-2);
    ust = sqrt(Cf)*U;
else
    set(handles.editks,'String','smooth');
end
z=makegrid(200,7,z0,H);

[fse,fne] = fsfnexact(H,R,ust,z0,karman,z);

z2=makegrid(10,0,z0,H);
[fse2,fne2] = fsfnexact(H,R,ust,z0,karman,z2);
uitable1_CellEditCallback(handles.uitable1, eventdata, handles, z2, fse2, fne2)

if (ps == 1)
    axes(handles.axes4)
    set(gca,'FontSize',8);
    %set(gca,'XTick',[0,1],'XTickLabel',{'0','','1'});
    %set(gca,'YTick',[0,1],'YTickLabel',{'','U','2*U','3*U'});
    plot(fse/U,z/H,'b-');
    xlim([0, 1.3]);
    ylim([0, 1]);
    xlabel('u_s/U [-]')
    ylabel('elevation (z/H) [-]')
    set(gca,'XGrid','on','YGrid','on');
    %box on;
    
    axes(handles.axes5)
    set(gca,'FontSize',8);
    %set(gca,'XTick',[0,1],'XTickLabel',{'0','','1'});
    %set(gca,'YTick',[0,1],'YTickLabel',{'','U','2*U','3*U'});
    plot(fne*R/(U*H),z/H,'b-');
    xlim([-7.5, 7.5]);
    ylim([0, 1]);
    xlabel('u_n*R/(U*H) [-]')
    ylabel('elevation (z/H) [-]')
    set(gca,'XGrid','on','YGrid','on');
    %box on;
    
else
    
    axes(handles.axes4)
    set(gca,'FontSize',8);
    %set(gca,'XTick',[0,1],'XTickLabel',{'0','','1'});
    %set(gca,'YTick',[0,1],'YTickLabel',{'','U','2*U','3*U'});
    plot(fse,z,'b-');
    %ylim('auto');
    %axis tight
    xlim('auto')
    ylim([0, H]);
    Ax2 = get(gca,'Xlim');%,[0,1],'XTickLabel',{'0','','1'});
    set(gca,'Xlim',max(abs(Ax2))*[0 1]);
    %xlim([0 U*1.3]);
    xlabel('u_s [m/s]')
    ylabel('elevation (z) [m]')
    set(gca,'XGrid','on','YGrid','on');
    %box on;
    
    axes(handles.axes5)
    set(gca,'FontSize',8);
    %set(gca,'XTick',[0,1],'XTickLabel',{'0','','1'});
    %set(gca,'YTick',[0,1],'YTickLabel',{'','U','2*U','3*U'});
    plot(fne,z,'b-');
    %ylim('auto');
    %axis tight
    ylim([0, H]);
    xlim('auto');
    Ax2 = get(gca,'Xlim');%,[0,1],'XTickLabel',{'0','','1'});
    set(gca,'Xlim',max(abs(Ax2))*[-1 1]);
    %xlim([-H/R*U*7.5 H/R*U*7.5]);
    xlabel('u_n [m/s]')
    ylabel('elevation (z) [m]')
    set(gca,'XGrid','on','YGrid','on');
    %box on;
    
end

% function %updateaxes3(hObject, eventdata, handles)
% axes(handles.axes3)
% set(gca,'FontSize',8);
% R = get(handles.sliderRH,'Value')*H;
% U = get(handles.sliderU,'Value');
% alphas = str2double(get(handles.editalphas,'String'));
% plot(([-0.9:0.1:0.9]+R),U*((([-0.9:0.1:0.9]+R)/R)).^alphas,R,U,'ro');
% set(gca,'XTick',[R-1,R-0.5,R,R+0.5,R+1],'XTickLabel',{'-1','','0','','1'});
% set(gca,'YTick',[0,U,2*U,3*U],'YTickLabel',{'','U','2*U','3*U'});
% xlim([R-1,R+1]);
% ylim([0,U*3]);
% xlabel('Distance from channel centre (m)')
% grid on;
% box on;


% --- Executes during object creation, after setting all properties.
%function editR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



%function editR_Callback(hObject, eventdata, handles)
% hObject    handle to editR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editR as text
%        str2double(get(hObject,'String')) returns contents of editR as a double


% --- Executes on button press in plotscaled.
function plotscaled_Callback(hObject, eventdata, handles)
% hObject    handle to plotscaled (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

H = get(handles.sliderH,'Value');
R = get(handles.sliderRH,'Value');
U = get(handles.sliderU,'Value');
ks = get(handles.sliderks,'Value');
ps = get(handles.plotscaled,'Value');
updateaxes12(hObject, eventdata, handles, H, R, U, ks, ps)

%get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of plotscaled


% --------------------------------------------------------------------
function menu_about_Callback(hObject, eventdata, handles)
% hObject    handle to menu_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
about


% --- Executes during object deletion, before destroying properties.
function editRH_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to editRH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function uitable1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Data','')


% --- Executes during object deletion, before destroying properties.
function uitable1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when entered data in editable cell(s) in uitable1.
%updateaxes12(hObject, eventdata, handles, H, R, U, ks, ps)
function uitable1_CellEditCallback(hObject, eventdata, handles, z, fse, fne)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE) 
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
%get(hObject,'Data')
for k = 1:length(z);
    str = sprintf('%6.3g',z(k));
    str = strrep(str, '.', ',');
    A{k,1} = str;
    if abs(fse(k))<eps 
        fse(k) = 0;
    end
    str = sprintf('%6.3g',fse(k));
    str = strrep(str, '.', ',');
    A{k,2} = str;
    if abs(fne(k))<eps 
        fne(k) = 0;
    end
    str = sprintf('%6.3g',fne(k));
    str = strrep(str, '.', ',');
    A{k,3} = str;
end
set(hObject,'Data',A)
