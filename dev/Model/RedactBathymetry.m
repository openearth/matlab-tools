function varargout = RedactBathymetry(varargin)
% REDACTBATHYMETRY MATLAB code for RedactBathymetry.fig
%      REDACTBATHYMETRY, by itself, creates a new REDACTBATHYMETRY or raises the existing
%      singleton*.
%
%      H = REDACTBATHYMETRY returns the handle to a new REDACTBATHYMETRY or the handle to
%      the existing singleton*.
%
%      REDACTBATHYMETRY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REDACTBATHYMETRY.M with the given input arguments.
%
%      REDACTBATHYMETRY('Property','Value',...) creates a new REDACTBATHYMETRY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RedactBathymetry_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RedactBathymetry_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RedactBathymetry

% Last Modified by GUIDE v2.5 05-Jun-2018 18:16:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RedactBathymetry_OpeningFcn, ...
                   'gui_OutputFcn',  @RedactBathymetry_OutputFcn, ...
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


% --- Executes just before RedactBathymetry is made visible.
function RedactBathymetry_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RedactBathymetry (see VARARGIN)

% Choose default command line output for RedactBathymetry
handles.output = hObject;

handles.metaData.hClosedPolygon = -99.9;
handles.metaData.colorContour1 = [0 0 0]; 
handles.metaData.colorContour2 = [1 0 0]; 
handles.metaData.hContour1 = -99;
handles.metaData.hContour2 = -99;
handles.metaData.min = -100;
handles.metaData.dx = 1;
handles.metaData.max = 0;
set(handles.min, 'String', num2str(handles.metaData.min));
set(handles.dx, 'String', num2str(handles.metaData.dx)); 
set(handles.max, 'String', num2str(handles.metaData.max));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RedactBathymetry wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RedactBathymetry_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushSmooth.
function pushSmooth_Callback(hObject, eventdata, handles)
% hObject    handle to pushSmooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    indvar = get(handles.Fields, 'Value');     
    x    = handles.Data.XYZ(:,1)/1000;
    y    = handles.Data.XYZ(:,2)/1000;
    z    = handles.Data.RESULT(:,indvar);  
    ikle = handles.Data.IKLE;
%     IN = inpolygon(x, y, handles.Data.ActiveClosedPolygon.x*1000, handles.Data.ActiveClosedPolygon.y*1000);
    sctOptions.xyPoly = [handles.Data.ActiveClosedPolygon.x' handles.Data.ActiveClosedPolygon.y']; 
    filtVar = Triangle.filterTri(ikle,[x y], z,sctOptions);
    
    NBV = size(handles.Data.RESULT,2)+1;
    handles.Data.NBV = NBV;
    handles.Data.RESULT(:,NBV) = filtVar;
    handles.Data.RECV{NBV} = pad(sprintf('new %s', strtrim(handles.Data.RECV{indvar})),80);
    set(handles.Fields,'String', handles.Data.RECV)
    set(handles.Fields, 'Value', NBV); 
    set(handles.popContour1,'String', handles.Data.RECV)
    set(handles.popContour2,'String', handles.Data.RECV)
    set(handles.popContour2, 'Value', NBV); 
    set(handles.popBackground, 'String', handles.Data.RECV)
    
    set(handles.chkContour2, 'Value', 1)
    handles = plotContour2(handles);
    
    TXT = get(handles.txtMessage, 'String');
    set(handles.txtMessage, 'String', {sprintf('done smoothing of %s', strtrim(handles.Data.RECV{indvar})),TXT{:}}')
guidata(hObject,handles);   
    
    

% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
% hObject    handle to menuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuLoad_Callback(hObject, eventdata, handles)
% hObject    handle to menuLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    cFiles ={'*.slf','Selafin file (*.slf)';...
        '*.*','all files (*.*)'};

    if isfield(handles,'file')
        [file,path] = uigetfile(cFiles,'Select File',handles.file);
    else
        [file,path] = uigetfile(cFiles,'Select File');
    end
    if ischar(file)
        theFile = fullfile(path,file);
        handles.metaData.file = theFile;
        guidata(hObject,handles);
        [~,~,ext] = fileparts(theFile);

        handles.Data = telheadr(theFile);
        
        if handles.Data.NBV>1
            indval = find(cellfun(@(x) strcmp(strtrim(x), 'BOTTOM'), handles.Data.RECV)); 
            if isempty(indval)
            end
        else
            indval = 1; 
        end
        set(handles.Fields,'String', handles.Data.RECV)
        set(handles.Fields, 'Value', indval); 
        set(handles.popContour1, 'String', handles.Data.RECV) 
        set(handles.popContour1, 'Value', indval)
        set(handles.popContour2, 'String', handles.Data.RECV)
        set(handles.popBackground, 'String', handles.Data.RECV)
        set(handles.popBackground, 'Value', indval); 
        
%         handles = updateData(handles,1);
        set(handles.chkBack, 'Value',1) 
        handles = plotData(handles);
    end
    TXT = get(handles.txtMessage, 'String');
    set(handles.txtMessage, 'String', {sprintf('loaded :  %s', theFile), TXT{:}}')
    
    guidata(hObject,handles);

function handles = plotData(handles)

    if get(handles.chkBack, 'Value'); 
        hcp = ishandle(handles.metaData.hClosedPolygon);
        if hcp 
            XData = handles.metaData.hClosedPolygon.XData; 
            YData = handles.metaData.hClosedPolygon.YData;
        end
        delete(get(handles.axes1, 'children')); 

        indvar = get(handles.Fields, 'Value'); 
        x    = handles.Data.XYZ(:,1);
        y    = handles.Data.XYZ(:,2);
        z    = handles.Data.RESULT(:,indvar); 
        ikle = handles.Data.IKLE;

    %     if get(handles.CB_m2km,'Value')
            x = x/1000;
            y = y/1000;
    %     end

        set(gcf,'currentaxes',handles.axes1)
        handles.metaData.hPlot = Plot.plotTriangle(x,y,z,ikle);
        shading interp;
        axis equal
        hold on 

        if hcp
            handles.metaData.hClosedPolygon = plot(XData, YData,'Marker','o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'c', 'MarkerSize', 6, 'Linestyle', '-','Color', 'k', 'linewidth', .5); 
        end
        handles = plotContour1(handles);
        handles = plotContour2(handles);
    end
    

    
% --------------------------------------------------------------------
function menuSave_Callback(hObject, eventdata, handles)
% hObject    handle to menuSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName, PathName] = uiputfile('New version.slf', 'Save as selafin file');
FileName = fullfile(PathName, FileName); 
fid = telheadw(handles.Data,FileName);
handles.Data.AT = 0; 
fid = telstepw(handles.Data,fid);
fclose(fid);

% --- Executes on selection change in Fields.
function Fields_Callback(hObject, eventdata, handles)
% hObject    handle to Fields (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Fields contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Fields


guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Fields_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Fields (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

    


% --------------------------------------------------------------------
function drawClosedPolygon_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to drawClosedPolygon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function drawClosedPolygon_OffCallback(hObject, eventdata, handles)
% hObject    handle to drawClosedPolygon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.axes1,'buttondownfcn',[])
    if ishandle(handles.metaData.hClosedPolygon)
        XData = get(handles.metaData.hClosedPolygon, 'XData'); 
        YData = get(handles.metaData.hClosedPolygon, 'YData'); 
        handles.Data.ActiveClosedPolygon.x = [XData XData(1)]; 
        handles.Data.ActiveClosedPolygon.y = [YData YData(1)];
        set(handles.metaData.hClosedPolygon, 'XData', XData, 'YData', YData)
    end
    guidata(hObject,handles);

% --------------------------------------------------------------------
function drawClosedPolygon_OnCallback(hObject, eventdata, handles)
% hObject    handle to drawClosedPolygon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    set(get(handles.axes1, 'children'), 'HitTest', 'off')
    set(handles.axes1,'buttondownfcn',@getGinput)
    guidata(hObject,handles);

function getGinput(src,evnt)
    handles = guidata(src);
    switch evnt.Button
        case{1}
            cp = get(handles.axes1,'CurrentPoint');  
            x = cp(1,1);y = cp(1,2);
            if ishandle(handles.metaData.hClosedPolygon)
                XData = [get(handles.metaData.hClosedPolygon, 'XData') x]; 
                YData = [get(handles.metaData.hClosedPolygon, 'YData') y]; 
                set(handles.metaData.hClosedPolygon, 'XData', XData, 'YData', YData)
            else
                hold on 
                handles.metaData.hClosedPolygon = plot(x,y,'Marker','o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'm', 'MarkerSize', 6, 'Linestyle', '-','Color', 'k', 'linewidth', .5); 
            end
        case{2}
            if ishandle(handles.metaData.hClosedPolygon)
                delete(handles.metaData.hClosedPolygon) % Start over.
            end
        case{3}
            if ishandle(handles.metaData.hClosedPolygon)
                XData = get(handles.metaData.hClosedPolygon, 'XData'); 
                YData = get(handles.metaData.hClosedPolygon, 'YData'); 
                handles.Data.ActiveClosedPolygon.x = [XData]; 
                handles.Data.ActiveClosedPolygon.y = [YData];
                set(handles.metaData.hClosedPolygon, 'XData', [XData XData(1)], 'YData', [YData YData(1)])
                set(handles.drawClosedPolygon, 'State', 'off')
            end
        otherwise
            % actually, I don't know.
    end
    guidata(src,handles);


% --- Executes on button press in chkContour1.
function chkContour1_Callback(hObject, eventdata, handles)
% hObject    handle to chkContour1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkContour1
if get(handles.chkContour1, 'Value') 
    handles = plotContour1(handles);
else
    if ishandle(handles.metaData.hContour1)
        delete(handles.metaData.hContour1); 
        handles.metaData.hContour1 = -99;
    end
end
guidata(hObject,handles);   

% --- Executes on button press in chkContour2.
function chkContour2_Callback(hObject, eventdata, handles)
% hObject    handle to chkContour2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkContour2
if get(handles.chkContour2, 'Value') 
    handles = plotContour2(handles);
else
    if ishandle(handles.metaData.hContour2)
        delete(handles.metaData.hContour2); 
        handles.metaData.hContour2 = -99;
    end
end
guidata(hObject,handles);   
    

% --- Executes on selection change in popContour1.
function popContour1_Callback(hObject, eventdata, handles)
% hObject    handle to popContour1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popContour1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popContour1
    handles = plotContour1(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function popContour1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popContour1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popContour2.
function popContour2_Callback(hObject, eventdata, handles)
% hObject    handle to popContour2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popContour2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popContour2
    handles = plotContour2(handles); 
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function popContour2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popContour2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in colorContour1.
function colorContour1_Callback(hObject, eventdata, handles)
% hObject    handle to colorContour1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    handles.metaData.colorContour1 = uisetcolor(handles.metaData.colorContour1, 'Select a color for contour 1.'); 
    handles = plotContour1(handles); 
guidata(hObject,handles);   



% --- Executes on button press in colorContour2.
function colorContour2_Callback(hObject, eventdata, handles)
% hObject    handle to colorContour2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    handles.metaData.colorContour2 = uisetcolor(handles.metaData.colorContour2, 'Select a color for contour 2.'); 
    handles = plotContour2(handles); 
guidata(hObject,handles); 

function handles = plotContour1(handles)

    if get(handles.chkContour1, 'Value')
        indvar = get(handles.popContour1, 'Value');     
        x    = handles.Data.XYZ(:,1)/1000;
        y    = handles.Data.XYZ(:,2)/1000;
        z    = handles.Data.RESULT(:,indvar);  
        ikle = handles.Data.IKLE;

        set(gcf,'currentaxes',handles.axes1)
        if ishandle(handles.metaData.hContour1)
            delete(handles.metaData.hContour1); 
        end
        range = handles.metaData.min:handles.metaData.dx:handles.metaData.max;
        nch = numel(get(gca, 'Children'));
        tricontour([x y],double(ikle),z,range,handles.metaData.colorContour1);
        ch = get(gca, 'Children');
        handles.metaData.hContour1 = ch(1:end-nch);
    end
    
function handles = plotContour2(handles)

    if get(handles.chkContour2, 'Value')
        indvar = get(handles.popContour2, 'Value');     
        x    = handles.Data.XYZ(:,1)/1000;
        y    = handles.Data.XYZ(:,2)/1000;
        z    = handles.Data.RESULT(:,indvar);  
        ikle = handles.Data.IKLE;

        set(gcf,'currentaxes',handles.axes1)
        if ishandle(handles.metaData.hContour2)
            delete(handles.metaData.hContour2); 
        end
        range = handles.metaData.min:handles.metaData.dx:handles.metaData.max;
        nch = numel(get(gca, 'Children'));
        tricontour([x y],double(ikle),z,range,handles.metaData.colorContour2);
        ch = get(gca, 'Children');
        handles.metaData.hContour2 = ch(1:end-nch);
    end
    


function min_Callback(hObject, eventdata, handles)
% hObject    handle to min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min as text
%        str2double(get(hObject,'String')) returns contents of min as a double

mn = str2double(get(hObject,'String'));
if isnumeric(mn) && isfinite(mn) 
    handles.metaData.min = mn; 
else
    set(hObject, 'String', num2str(handles.metaData.min)); 
    errordlg('Illegal value for minimum')
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dx_Callback(hObject, eventdata, handles)
% hObject    handle to dx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dx as text
%        str2double(get(hObject,'String')) returns contents of dx as a double

dx = str2double(get(hObject,'String'));
if isnumeric(dx) && isfinite(dx); 
    handles.metaData.dx = dx; 
else
    set(hObject, 'String', num2str(handles.metaData.dx)); 
    errordlg('Illegal value for interval')
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function dx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function max_Callback(hObject, eventdata, handles)
% hObject    handle to max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max as text
%        str2double(get(hObject,'String')) returns contents of max as a double

mx = str2double(get(hObject,'String'));
if isnumeric(mx) && isfinite(mx) 
    handles.metaData.max = mx; 
else
    set(hObject, 'String', num2str(handles.metaData.max)); 
    errordlg('Illegal value for maximum')
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over Fields.
function Fields_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Fields (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject,handles);


% --- Executes on selection change in popBackground.
function popBackground_Callback(hObject, eventdata, handles)
% hObject    handle to popBackground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popBackground contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popBackground

     handles = plotData(handles);
guidata(hObject,handles); 

% --- Executes during object creation, after setting all properties.
function popBackground_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popBackground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkBack.
function chkBack_Callback(hObject, eventdata, handles)
% hObject    handle to chkBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkBack
     
    if get(handles.chkBack, 'Value') 
        handles = plotData(handles);
    else
        if ishandle(handles.metaData.hPlot)
            delete(handles.metaData.hPlot); 
            handles.metaData.hPlot = -99;
        end
    end
guidata(hObject,handles); 

% --- Executes on button press in pushColorBackground.
function pushColorBackground_Callback(hObject, eventdata, handles)
% hObject    handle to pushColorBackground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
     

% --- Executes on button press in pushRename.
function pushRename_Callback(hObject, eventdata, handles)
% hObject    handle to pushRename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

indvar = get(handles.Fields, 'Value');   
varname = inputdlg(sprintf('Give new name for %s :', handles.Data.RECV{indvar}), 'RENAME', 1); 
    if ~isempty(varname)
        handles.Data.RECV(indvar) = varname; 
        set(handles.Fields,'String', handles.Data.RECV)
        set(handles.popContour1, 'String', handles.Data.RECV) 
        set(handles.popContour2, 'String', handles.Data.RECV)
        set(handles.popBackground, 'String', handles.Data.RECV)
    end
  
guidata(hObject,handles);
    


% --- Executes on button press in pushBin.
function pushBin_Callback(hObject, eventdata, handles)
% hObject    handle to pushBin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    indvar = get(handles.Fields, 'Value');   
 
    handles.Data.NBV = handles.Data.NBV-1;  
    handles.Data.RECV(indvar) = [];
    handles.Data.RESULT(:,indvar) = []; 

    set(handles.Fields,'String', handles.Data.RECV)
    set(handles.Fields,'Value', min(indvar, handles.Data.NBV))

    indval = get(handles.popContour1, 'Value'); 
    set(handles.popContour1, 'String', handles.Data.RECV)
    if indval<indvar; 
        % nothing to be done, value can stay the same.
    elseif indval==indvar && ishandle(handles.metaData.hContour1)
        delete(handles.metaData.hContour1);
        set(handles.popContour1, 'Value', min(indvar, handles.Data.NBV)); 
    else % indval > indvar
        set(handles.popContour1, 'Value', indval-1); 
        handles.metaData.hContour1 = -99.9;
    end

    indval = get(handles.popContour2, 'Value'); 
    set(handles.popContour2, 'String', handles.Data.RECV)
    if indval<indvar
        % nothing to be done, value can stay the same.
    elseif indval==indvar  && ishandle(handles.metaData.hContour2)
        delete(handles.metaData.hContour2);
        handles.metaData.hContour2 = -99;
        set(handles.popContour2, 'Value', min(indvar, handles.Data.NBV)); 
    else % indval > indvar
        set(handles.popContour2, 'Value', indval-1); 
    end

    indval = get(handles.popBackground, 'Value'); 
    set(handles.popBackground, 'String', handles.Data.RECV)
    if indval<indvar
        % nothing to be done, value can stay the same.
    elseif indval==indvar  && ishandle(handles.metaData.hPlot)
        delete(handles.metaData.hPlot);
        handles.metaData.hPlot = -99;
        set(handles.popBackground, 'Value', min(indvar, handles.Data.NBV)); 
    else % indval > indvar
        set(handles.popBackground, 'Value', indval-1); 
    end

  
guidata(hObject,handles);
