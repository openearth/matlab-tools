function ddb_editD3DFlowOpenBoundaries

ddb_refreshScreen('Boundaries');
handles=getHandles;

handles.Model(md).Input(ad).NrOpenBoundaries;

uipanel('Title','','Units','pixels','Position',[180 20 300 150],'Tag','UIControl');

handles.GUIHandles.ListOpenBoundaries     = uicontrol(gcf,'Style','listbox','Position',[50 20 120 140],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextListOpenBoundaries = uicontrol(gcf,'Style','text','String','Open Boundaries', 'Position',[50 160 120 15],'HorizontalAlignment','center','Tag','UIControl');
set(handles.GUIHandles.ListOpenBoundaries,'Max',1000);

handles.GUIHandles.EditBndName  = uicontrol(gcf,'Style','edit','Position',[220 140  95 20],'HorizontalAlignment','left', 'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditBndM1    = uicontrol(gcf,'Style','edit','Position',[220 115  35 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditBndN1    = uicontrol(gcf,'Style','edit','Position',[280 115  35 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditBndM2    = uicontrol(gcf,'Style','edit','Position',[220  90  35 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditBndN2    = uicontrol(gcf,'Style','edit','Position',[280  90  35 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextBndName  = uicontrol(gcf,'Style','text','String','Name',    'Position',[185 136 30 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextBndM1    = uicontrol(gcf,'Style','text','String','M1',      'Position',[195 111 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextBndN1    = uicontrol(gcf,'Style','text','String','N1',      'Position',[255 111 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextBndM2    = uicontrol(gcf,'Style','text','String','M2',      'Position',[195  86 20 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextBndN2    = uicontrol(gcf,'Style','text','String','N2',      'Position',[255  86 20 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIData.BoundaryTypes={'Water Level','Current','Neumann','Total Discharge','Discharge per Cell','Riemann'};
handles.GUIHandles.SelectBoundaryType     = uicontrol(gcf,'Style','popupmenu','Position',[370 140 100 20],'String',handles.GUIData.BoundaryTypes,'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditAlpha  = uicontrol(gcf,'Style','edit','Position',[370 115 100 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIData.ForcingTypes={'Astronomic','Harmonic','Time Series','QH-relation'};
handles.GUIHandles.SelectForcingType      = uicontrol(gcf,'Style','popupmenu','Position',[370 90 100 20],'String',handles.GUIData.ForcingTypes,'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.SelectProfile  = uicontrol(gcf,'Style','popupmenu','Position',[370 65 100 20],'String','Uniform','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextBndType  = uicontrol(gcf,'Style','text','String','Type',   'Position',[320 136 45 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextAlpha    = uicontrol(gcf,'Style','text','String','Alpha',  'Position',[320 111 45 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextForcing  = uicontrol(gcf,'Style','text','String','Forcing','Position',[320  86 45 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextProfile  = uicontrol(gcf,'Style','text','String','Profile','Position',[320  61 45 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.PushFlowConditions = uicontrol(gcf,'Style','pushbutton','String','Flow Conditions',   'Position',[205 30 120 20],'Tag','UIControl');
handles.GUIHandles.PushTransportConditions = uicontrol(gcf,'Style','pushbutton','String','Transport Conditions',   'Position',[335 30 120 20],'Tag','UIControl');

handles.GUIHandles.PushAddOpenBoundary    = uicontrol(gcf,'Style','pushbutton','String','Add',   'Position',[490 140 50 20],'Tag','UIControl');
handles.GUIHandles.PushDeleteOpenBoundary = uicontrol(gcf,'Style','pushbutton','String','Delete','Position',[490 115 50 20],'Tag','UIControl');
handles.GUIHandles.PushChangeOpenBoundary = uicontrol(gcf,'Style','pushbutton','String','Change','Position',[490  90 50 20],'Tag','UIControl');
handles.GUIHandles.PushSelectOpenBoundary = uicontrol(gcf,'Style','pushbutton','String','Select','Position',[490  65 50 20],'Tag','UIControl');

uipanel('Title','','Units','pixels','Position',[575 20 430 155],'Tag','UIControl');

handles.GUIHandles.PushOpenBoundaryDefinitions   = uicontrol(gcf,'Style','pushbutton','String','Open','Position',[710 150 50 20],'Tag','UIControl');
handles.GUIHandles.PushOpenAstronomicConditions  = uicontrol(gcf,'Style','pushbutton','String','Open','Position',[710 125 50 20],'Tag','UIControl');
handles.GUIHandles.PushOpenAstronomicCorrections = uicontrol(gcf,'Style','pushbutton','String','Open','Position',[710 100 50 20],'Tag','UIControl');
handles.GUIHandles.PushOpenHarmonicConditions    = uicontrol(gcf,'Style','pushbutton','String','Open','Position',[710  75 50 20],'Tag','UIControl');
%handles.GUIHandles.PushOpenQHRelation            = uicontrol(gcf,'Style','pushbutton','String','Open','Position',[710  60 50 20],'Tag','UIControl');
handles.GUIHandles.PushOpenTimeSeriesConditions  = uicontrol(gcf,'Style','pushbutton','String','Open','Position',[710  50 50 20],'Tag','UIControl');
handles.GUIHandles.PushOpenTransportConditions   = uicontrol(gcf,'Style','pushbutton','String','Open','Position',[710  25 50 20],'Tag','UIControl');

handles.GUIHandles.PushSaveBoundaryDefinitions   = uicontrol(gcf,'Style','pushbutton','String','Save','Position',[770 150 50 20],'Tag','UIControl');
handles.GUIHandles.PushSaveAstronomicConditions  = uicontrol(gcf,'Style','pushbutton','String','Save','Position',[770 125 50 20],'Tag','UIControl');
handles.GUIHandles.PushSaveAstronomicCorrections = uicontrol(gcf,'Style','pushbutton','String','Save','Position',[770 100 50 20],'Tag','UIControl');
handles.GUIHandles.PushSaveHarmonicConditions    = uicontrol(gcf,'Style','pushbutton','String','Save','Position',[770  75 50 20],'Tag','UIControl');
%handles.GUIHandles.PushSaveQHRelation            = uicontrol(gcf,'Style','pushbutton','String','Save','Position',[770  60 50 20],'Tag','UIControl');
handles.GUIHandles.PushSaveTimeSeriesConditions  = uicontrol(gcf,'Style','pushbutton','String','Save','Position',[770  50 50 20],'Tag','UIControl');
handles.GUIHandles.PushSaveTransportConditions   = uicontrol(gcf,'Style','pushbutton','String','Save','Position',[770  25 50 20],'Tag','UIControl');

handles.GUIHandles.TextBoundaryDefinitions   = uicontrol(gcf,'Style','text','String','Boundary Definitions'   ,'Position',[580 147 115 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextAstronomicConditions  = uicontrol(gcf,'Style','text','String','Astronomic Conditions'  ,'Position',[580 122 115 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextAstronomicCorrections = uicontrol(gcf,'Style','text','String','Astronomic Corrections' ,'Position',[580  97 115 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextHarmonicConditions    = uicontrol(gcf,'Style','text','String','Harmonic Conditions'    ,'Position',[580  72 115 20],'HorizontalAlignment','right','Tag','UIControl');
%handles.GUIHandles.TextQHRelation            = uicontrol(gcf,'Style','text','String','Q-H Relation',         'Position',[580  60 115 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextTimeSeriesConditions  = uicontrol(gcf,'Style','text','String','Time Series Conditions' ,'Position',[580  47 115 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextTransportConditions   = uicontrol(gcf,'Style','text','String','Transport Conditions'   ,'Position',[580  22 115 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.TextBoundaryDefinitionsFile   = uicontrol(gcf,'Style','text','String',['File : ' handles.Model(md).Input(ad).BndFile],'Position',[830 147 170 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextAstronomicConditionsFile  = uicontrol(gcf,'Style','text','String',['File : ' handles.Model(md).Input(ad).BcaFile],'Position',[830 122 170 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextAstronomicCorrectionsFile = uicontrol(gcf,'Style','text','String',['File : ' handles.Model(md).Input(ad).CorFile],'Position',[830  97 170 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextHarmonicConditionsFile    = uicontrol(gcf,'Style','text','String',['File : ' handles.Model(md).Input(ad).BchFile],'Position',[830  72 170 20],'HorizontalAlignment','left','Tag','UIControl');
%handles.GUIHandles.TextQHRelationFile            = uicontrol(gcf,'Style','text','String','Q-H Relation',           'Position',[830  60 170 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextTimeSeriesConditionsFile  = uicontrol(gcf,'Style','text','String',['File : ' handles.Model(md).Input(ad).BctFile],'Position',[830  47 170 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextTransportConditionsFile   = uicontrol(gcf,'Style','text','String',['File : ' handles.Model(md).Input(ad).BccFile],'Position',[830  22 170 20],'HorizontalAlignment','left','Tag','UIControl');

set(handles.GUIHandles.ListOpenBoundaries,'CallBack',{@ListOpenBoundaries_CallBack});
set(handles.GUIHandles.SelectBoundaryType,'CallBack',{@SelectBoundaryType_CallBack});
set(handles.GUIHandles.SelectForcingType, 'CallBack',{@SelectForcingType_CallBack});
set(handles.GUIHandles.SelectProfile,     'CallBack',{@SelectProfile_CallBack});
set(handles.GUIHandles.EditAlpha,  'CallBack',{@EditAlpha_CallBack});
set(handles.GUIHandles.EditBndM1,  'CallBack',{@EditBndM1_CallBack});
set(handles.GUIHandles.EditBndN1,  'CallBack',{@EditBndN1_CallBack});
set(handles.GUIHandles.EditBndM2,  'CallBack',{@EditBndM2_CallBack});
set(handles.GUIHandles.EditBndN2,  'CallBack',{@EditBndN2_CallBack});
set(handles.GUIHandles.EditBndName,'CallBack',{@EditBndName_CallBack});
set(handles.GUIHandles.PushAddOpenBoundary,'CallBack',{@PushAddOpenBoundary_CallBack});
set(handles.GUIHandles.PushDeleteOpenBoundary,'CallBack',{@PushDeleteOpenBoundary_CallBack});
set(handles.GUIHandles.PushSelectOpenBoundary,'CallBack',{@PushSelectOpenBoundary_CallBack});
set(handles.GUIHandles.PushChangeOpenBoundary,'CallBack',{@PushChangeOpenBoundary_CallBack});
set(handles.GUIHandles.PushFlowConditions,    'CallBack',{@PushFlowConditions_CallBack});
set(handles.GUIHandles.PushTransportConditions,    'CallBack',{@PushTransportConditions_CallBack});
set(handles.GUIHandles.PushSaveBoundaryDefinitions,'CallBack',{@PushSaveBoundaryDefinitions_CallBack});
set(handles.GUIHandles.PushOpenBoundaryDefinitions,'CallBack',{@PushOpenBoundaryDefinitions_CallBack});
set(handles.GUIHandles.PushSaveAstronomicConditions,'CallBack',{@PushSaveAstronomicConditions_CallBack});
set(handles.GUIHandles.PushOpenAstronomicConditions,'CallBack',{@PushOpenAstronomicConditions_CallBack});
set(handles.GUIHandles.PushSaveAstronomicCorrections,'CallBack',{@PushSaveAstronomicCorrections_CallBack});
set(handles.GUIHandles.PushOpenAstronomicCorrections,'CallBack',{@PushOpenAstronomicCorrections_CallBack});
set(handles.GUIHandles.PushSaveHarmonicConditions,'CallBack',{@PushSaveHarmonicConditions_CallBack});
set(handles.GUIHandles.PushOpenHarmonicConditions,'CallBack',{@PushOpenHarmonicConditions_CallBack});
set(handles.GUIHandles.PushSaveTimeSeriesConditions,'CallBack',{@PushSaveTimeSeriesConditions_CallBack});
set(handles.GUIHandles.PushOpenTimeSeriesConditions,'CallBack',{@PushOpenTimeSeriesConditions_CallBack});
set(handles.GUIHandles.PushSaveTransportConditions,'CallBack',{@PushSaveTransportConditions_CallBack});
set(handles.GUIHandles.PushOpenTransportConditions,'CallBack',{@PushOpenTransportConditions_CallBack});

%set(handles.GUIHandles.PushTransportConditions,'Enable','off');
set(handles.GUIHandles.PushChangeOpenBoundary, 'Enable','off');

handles.GUIData.ActiveOpenBoundary=1;

setHandles(handles);

RefreshOpenBoundaries(handles);
if handles.Model(md).Input(ad).NrOpenBoundaries>0
    ddb_plotFlowAttributes(handles,'OpenBoundaries','activate',ad,0,handles.GUIData.ActiveOpenBoundary);
end

SetUIBackgroundColors;

%%
function ListOpenBoundaries_CallBack(hObject,eventdata)
handles=getHandles;
if handles.Model(md).Input(ad).NrOpenBoundaries>0
    handles.GUIData.ActiveOpenBoundary=max(get(hObject,'Value'));
    handles.DeleteSelectedOpenBoundary=1;
    setHandles(handles);
    RefreshOpenBoundaries(handles);
    ddb_plotFlowAttributes(handles,'OpenBoundaries','activate',ad,0,handles.GUIData.ActiveOpenBoundary);
end

%%
function SelectBoundaryType_CallBack(hObject,eventdata)
handles=getHandles;
ii=get(hObject,'Value');
tps={'Z','C','N','T','Q','R'};
isel=get(handles.GUIHandles.ListOpenBoundaries,'Value');
for k=1:length(isel)
    n=isel(k);
    handles.Model(md).Input(ad).OpenBoundaries(n).Type=tps{ii};
    switch handles.Model(md).Input(ad).OpenBoundaries(n).Type
        case{'Z','N'}
            handles.Model(md).Input(ad).OpenBoundaries(n).Profile='Uniform';
        case{'T'}
            if strcmpi(handles.Model(md).Input(ad).OpenBoundaries(n).Profile,'3D-Profile')
                handles.Model(md).Input(ad).OpenBoundaries(n).Profile='Uniform';
            end
    end
end
handles.DeleteSelectedOpenBoundary=0;
RefreshOpenBoundaries(handles);
setHandles(handles);

%%
function SelectForcingType_CallBack(hObject,eventdata)
handles=getHandles;
ii=get(hObject,'Value');
frs={'A','H','T','Q'};
isel=get(handles.GUIHandles.ListOpenBoundaries,'Value');
for k=1:length(isel)
    n=isel(k);
    handles.Model(md).Input(ad).OpenBoundaries(n).Forcing=frs{ii};
end
handles.DeleteSelectedOpenBoundary=0;
RefreshOpenBoundaries(handles);
setHandles(handles);

%%
function SelectProfile_CallBack(hObject,eventdata)
handles=getHandles;
str=get(hObject,'String');
ii=get(hObject,'Value');
handles.DeleteSelectedOpenBoundary=0;
isel=get(handles.GUIHandles.ListOpenBoundaries,'Value');
for k=1:length(isel)
    n=isel(k);
    switch lower(str{ii})
        case{'uniform'}
            handles.Model(md).Input(ad).OpenBoundaries(n).Profile='Uniform';
        case{'logarithmic'}
            switch handles.Model(md).Input(ad).OpenBoundaries(n).Type
                case{'Z','N'}
                    handles.Model(md).Input(ad).OpenBoundaries(n).Profile='Uniform';
                otherwise
                    handles.Model(md).Input(ad).OpenBoundaries(n).Profile='Logarithmic';
            end
        case{'per layer'}
            switch handles.Model(md).Input(ad).OpenBoundaries(n).Type
                case{'C','Q','R'}
                    handles.Model(md).Input(ad).OpenBoundaries(n).Profile='3D-Profile';
                    kmax=handles.Model(md).Input(ad).KMax;
                    nr=handles.Model(md).Input(ad).OpenBoundaries(n).NrTimeSeries;
                    if size(handles.Model(md).Input(ad).OpenBoundaries(n).TimeSeriesA,2)~=kmax
                        handles.Model(md).Input(ad).OpenBoundaries(n).TimeSeriesA=zeros(nr,kmax);
                        handles.Model(md).Input(ad).OpenBoundaries(n).TimeSeriesB=zeros(nr,kmax);
                        guidata(gcf,handles);
                    end
            end
    end
end
RefreshOpenBoundaries(handles);
setHandles(handles);

%%
function EditAlpha_CallBack(hObject,eventdata)
handles=getHandles;
isel=get(handles.GUIHandles.ListOpenBoundaries,'Value');
for k=1:length(isel)
    n=isel(k);
    handles.Model(md).Input(ad).OpenBoundaries(n).Alpha=str2double(get(hObject,'String'));
end
handles.DeleteSelectedOpenBoundary=0;
setHandles(handles);

%%
function EditBndM1_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListOpenBoundaries,'Value');
handles.Model(md).Input(ad).OpenBoundaries(n).M1=str2num(get(hObject,'String'));
[xb,yb,zb,side,orientation]=ddb_getBoundaryCoordinates(handles,ad,n);
handles.Model(md).Input(ad).OpenBoundaries(n).X=xb;
handles.Model(md).Input(ad).OpenBoundaries(n).Y=yb;
handles.Model(md).Input(ad).OpenBoundaries(n).Depth=zb;
handles.DeleteSelectedOpenBoundary=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'OpenBoundaries','plot',ad,n,n);

%%
function EditBndN1_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListOpenBoundaries,'Value');
handles.Model(md).Input(ad).OpenBoundaries(n).N1=str2num(get(hObject,'String'));
[xb,yb,zb,side,orientation]=ddb_getBoundaryCoordinates(handles,ad,n);
handles.Model(md).Input(ad).OpenBoundaries(n).X=xb;
handles.Model(md).Input(ad).OpenBoundaries(n).Y=yb;
handles.Model(md).Input(ad).OpenBoundaries(n).Depth=zb;
handles.DeleteSelectedOpenBoundary=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'OpenBoundaries','plot',ad,n,n);

%%
function EditBndM2_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListOpenBoundaries,'Value');
handles.Model(md).Input(ad).OpenBoundaries(n).M2=str2num(get(hObject,'String'));
[xb,yb,zb,side,orientation]=ddb_getBoundaryCoordinates(handles,ad,n);
handles.Model(md).Input(ad).OpenBoundaries(n).X=xb;
handles.Model(md).Input(ad).OpenBoundaries(n).Y=yb;
handles.Model(md).Input(ad).OpenBoundaries(n).Depth=zb;
handles.DeleteSelectedOpenBoundary=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'OpenBoundaries','plot',ad,n,n);

%%
function EditBndN2_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListOpenBoundaries,'Value');
handles.Model(md).Input(ad).OpenBoundaries(n).N2=str2num(get(hObject,'String'));
[xb,yb,zb,side,orientation]=ddb_getBoundaryCoordinates(handles,ad,n);
handles.Model(md).Input(ad).OpenBoundaries(n).X=xb;
handles.Model(md).Input(ad).OpenBoundaries(n).Y=yb;
handles.Model(md).Input(ad).OpenBoundaries(n).Depth=zb;
handles.DeleteSelectedOpenBoundary=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'OpenBoundaries','plot',ad,n,n);

%%
function EditBndName_CallBack(hObject,eventdata)
handles=getHandles;
n=get(handles.GUIHandles.ListOpenBoundaries,'Value');
handles.Model(md).Input(ad).OpenBoundaries(n).Name=get(hObject,'String');
RefreshOpenBoundaries(handles);
handles.DeleteSelectedOpenBoundary=0;
setHandles(handles);
ddb_plotFlowAttributes(handles,'OpenBoundaries','plot',ad,n,n);

%%
function PushAddOpenBoundary_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.Mode='a';
setHandles(handles);
set(gcf, 'windowbuttondownfcn',{@DragLine,@AddOpenBoundary,'gridline'});

%%
function PushDeleteOpenBoundary_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.Mode='d';
setHandles(handles);
if handles.DeleteSelectedOpenBoundary==1 && handles.Model(md).Input(ad).NrOpenBoundaries>0
    handles=DeleteOpenBoundary(handles);
    setHandles(handles);
end
ddb_deleteDelft3DFLOWObject(ad,'OpenBoundary',@DeleteObject);

%%
function DeleteObject(ii)
handles=getHandles;
handles.GUIData.ActiveOpenBoundary=ii;
set(handles.GUIHandles.ListOpenBoundaries,'Value',ii);
handles=DeleteOpenBoundary(handles);
setHandles(handles);

%%
function PushChangeOpenBoundary_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.Mode='c';
setHandles(handles);
set(gcf, 'windowbuttondownfcn',   {@SelectOpenBoundary});

%%
function PushSelectOpenBoundary_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
handles.Mode='s';
setHandles(handles);
set(gcf, 'windowbuttondownfcn',   {@SelectOpenBoundary});

%%
function PushFlowConditions_CallBack(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;
i=handles.GUIData.ActiveOpenBoundary;
frc=handles.Model(md).Input(ad).OpenBoundaries(i).Forcing;
switch frc,
    case{'A'}
        ddb_editD3DFlowConditionsAstronomic;
    case{'H'}
        ddb_editD3DFlowConditionsHarmonic;
    case{'T'}
        ddb_editD3DFlowConditionsTimeSeries;
    case{'Q'}
        EditD3DFlowConditionsQHRelation;
end
set(gcf, 'windowbuttondownfcn',   []);

%%
function PushTransportConditions_CallBack(hObject,eventdata)
ddb_zoomOff;
ddb_editD3DFlowTransportConditionsTimeSeries;
set(gcf, 'windowbuttondownfcn',   []);

%%
function PushSaveBoundaryDefinitions_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.bnd', 'Select Boundary Definition File',handles.Model(md).Input(ad).BndFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).BndFile=filename;
    ddb_saveBndFile(handles,ad);
    set(handles.GUIHandles.TextBoundaryDefinitionsFile,'String',['File : ' filename]);
    handles.DeleteSelectedOpenBoundary=0;
    setHandles(handles);
end

%%
function PushOpenBoundaryDefinitions_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.bnd', 'Select Boundary Definition File');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).BndFile=filename;
    handles=ddb_readBndFile(handles);
    set(handles.GUIHandles.TextBoundaryDefinitionsFile,'String',['File : ' filename]);
    setHandles(handles);
    RefreshOpenBoundaries(handles);
    ddb_plotFlowAttributes(handles,'OpenBoundaries','plot',ad,0,1);
end

%%
function PushSaveAstronomicConditions_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.bca', 'Select Astronomical Conditions File',handles.Model(md).Input(ad).BcaFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).BcaFile=filename;
    ddb_saveBcaFile(handles,ad);
    set(handles.GUIHandles.TextAstronomicConditionsFile,'String',['File : ' filename]);
    handles.DeleteSelectedOpenBoundary=0;
    setHandles(handles);
end

%%
function PushOpenAstronomicConditions_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.bca', 'Select Astronomical Conditions File');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).BcaFile=filename;
    handles=ddb_readBcaFile(handles);
    set(handles.GUIHandles.TextAstronomicConditionsFile,'String',['File : ' filename]);
    setHandles(handles);
    RefreshOpenBoundaries(handles);
end

%%
function PushSaveAstronomicCorrections_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.cor', 'Select Astronomical Corrections File',handles.Model(md).Input(ad).CorFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).CorFile=filename;
    ddb_saveCorFile(handles,ad);
    set(handles.GUIHandles.TextAstronomicCorrectionsFile,'String',['File : ' filename]);
    handles.DeleteSelectedOpenBoundary=0;
    setHandles(handles);
end

%%
function PushOpenAstronomicCorrections_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.cor', 'Select Astronomical Corrections File');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).CorFile=filename;
    handles=ddb_readCorFile(handles);
    set(handles.GUIHandles.TextAstronomicCorrectionsFile,'String',['File : ' filename]);
    setHandles(handles);
    RefreshOpenBoundaries(handles);
end

%%
function PushSaveHarmonicConditions_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.bch', 'Select Harmonic Conditions File',handles.Model(md).Input(ad).BchFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).BchFile=filename;
    ddb_saveBchFile(handles,ad);
    set(handles.GUIHandles.TextHarmonicConditionsFile,'String',['File : ' filename]);
    handles.DeleteSelectedOpenBoundary=0;
    setHandles(handles);
end

%%
function PushOpenHarmonicConditions_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.bch', 'Select Harmonic Conditions File');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).BchFile=filename;
    handles=ddb_readBchFile(handles);
    set(handles.GUIHandles.TextHarmonicConditionsFile,'String',['File : ' filename]);
    setHandles(handles);
    RefreshOpenBoundaries(handles);
end

%%
function PushSaveTimeSeriesConditions_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.bct', 'Select Time Series File',handles.Model(md).Input(ad).BctFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).BctFile=filename;
    ddb_saveBctFile(handles,ad);
    set(handles.GUIHandles.TextTimeSeriesConditionsFile,'String',['File : ' filename]);
    handles.DeleteSelectedOpenBoundary=0;
    setHandles(handles);
end

%%
function PushOpenTimeSeriesConditions_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.bct', 'Select Time Series File');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).BctFile=filename;
    handles=ddb_readBctFile(handles);
    set(handles.GUIHandles.TextTimeSeriesConditionsFile,'String',['File : ' filename]);
    setHandles(handles);
    RefreshOpenBoundaries(handles);
end

%%
function PushSaveTransportConditions_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.bcc', 'Select Transport Conditions File',handles.Model(md).Input(ad).BccFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).BccFile=filename;
    ddb_saveBccFile(handles,ad);
    set(handles.GUIHandles.TextTransportConditionsFile,'String',['File : ' filename]);
    handles.DeleteSelectedOpenBoundary=0;
    setHandles(handles);
end

%%
function PushOpenTransportConditions_CallBack(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.bcc', 'Select Transport Conditions File');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).BccFile=filename;
    handles=ddb_readBccFile(handles);
    set(handles.GUIHandles.TextTransportConditionsFile,'String',['File : ' filename]);
    setHandles(handles);
    RefreshOpenBoundaries(handles);
end

%%
function addOpenBoundary(x,y)

x1=x(1);x2=x(2);
y1=y(1);y2=y(2);
handles=getHandles;
id=ad;
[m1,n1]=FindCornerPoint(x1,y1,handles.Model(md).Input(id).GridX,handles.Model(md).Input(id).GridY);
[m2,n2]=FindCornerPoint(x2,y2,handles.Model(md).Input(id).GridX,handles.Model(md).Input(id).GridY);
[m1,n1,m2,n2,ok]=CheckBoundaryPoints(m1,n1,m2,n2,1);

if ok==1
    
    if handles.Model(md).Input(ad).changeOpenBoundary
        iac=handles.Model(md).Input(ad).activeOpenBoundary;
    else
        % Add mode
        handles.Model(md).Input(ad).nrOpenBoundaries=handles.Model(md).Input(ad).nrOpenBoundaries+1;
        iac=handles.Model(md).Input(ad).nrOpenBoundaries;
    end
    
    handles.Model(md).Input(ad).openBoundaries(iac).M1=m1;
    handles.Model(md).Input(ad).openBoundaries(iac).N1=n1;
    handles.Model(md).Input(ad).openBoundaries(iac).M2=m2;
    handles.Model(md).Input(ad).openBoundaries(iac).N2=n2;

    handles=ddb_initializeBoundary(handles,iac);
  
    handles.Model(md).Input(ad).openBoundaries(iac).Name=['(' num2str(m1) ',' num2str(n1) ')...(' num2str(m2) ',' num2str(n2) ')'];
    handles.Model(md).Input(ad).openBoundaryNames{iac}=handles.Model(md).Input(ad).openBoundaries(iac).Name;
    handles.Model(md).Input(ad).activeOpenBoundary=iac;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','openboundaries');
    
    if handles.Model(md).Input(ad).changeOpenBoundary
        ddb_clickObject('tag','openboundary','callback',@changeOpenBoundaryFromMap);
        setInstructions({'','','Select open boundary'});
    else
        ddb_dragLine(@addThinDam,'free');
        setInstructions({'','','Drag new open boundary'});
    end
end
setHandles(handles);
refreshOpenBoundaries;

%%
function handles=DeleteOpenBoundary(handles)

id=ad;
nrbnd=handles.Model(md).Input(id).NrOpenBoundaries;

isel=get(handles.GUIHandles.ListOpenBoundaries,'Value');
isel=fliplr(isel);

for k=1:length(isel)
    iac0=isel(k);
    iacnew=iac0;

    if iacnew==nrbnd
        iacnew=nrbnd-1;
    end
    ddb_plotFlowAttributes(handles,'OpenBoundaries','delete',id,iac0,iacnew);

    if nrbnd>1
        for j=iac0:nrbnd-1
            handles.Model(md).Input(id).OpenBoundaries(j)=handles.Model(md).Input(id).OpenBoundaries(j+1);
        end
        handles.Model(md).Input(id).OpenBoundaries=handles.Model(md).Input(id).OpenBoundaries(1:end-1);
    else
        handles.Model(md).Input(id).OpenBoundaries(1).M1=[];
        handles.Model(md).Input(id).OpenBoundaries(1).M2=[];
        handles.Model(md).Input(id).OpenBoundaries(1).N1=[];
        handles.Model(md).Input(id).OpenBoundaries(1).N2=[];
        handles.Model(md).Input(id).OpenBoundaries(1).Name=[];
    end
    handles.Model(md).Input(id).NrOpenBoundaries=handles.Model(md).Input(id).NrOpenBoundaries-1;
    if handles.Model(md).Input(id).NrOpenBoundaries>0
        if handles.GUIData.ActiveOpenBoundary==handles.Model(md).Input(id).NrOpenBoundaries+1
            handles.GUIData.ActiveOpenBoundary=handles.GUIData.ActiveOpenBoundary-1;
        end
    end
    nrbnd=handles.Model(md).Input(id).NrOpenBoundaries;
end
if length(isel)>1
    handles.GUIData.ActiveOpenBoundary=1;
    set(handles.GUIHandles.ListOpenBoundaries,'Value',1);
    if nrbnd>0
        ddb_plotFlowAttributes(handles,'OpenBoundaries','activate',id,1,1);
    end
end
RefreshOpenBoundaries(handles);

%%
function SelectOpenBoundary(hObject,eventdata)

handles=getHandles;
if strcmp(get(gco,'Tag'),'OpenBoundary')
    id=ad;
    ud=get(gco,'UserData');
    handles.GUIData.ActiveOpenBoundary=ud(2);
    RefreshOpenBoundaries(handles);
    setHandles(handles);
    if handles.Mode=='c'
        ddb_plotFlowAttributes(handles,'OpenBoundaries','activate',id,0,handles.GUIData.ActiveOpenBoundary);
        set(gcf,'windowbuttondownfcn',{@DragLine,@AddOpenBoundary});
    elseif handles.Mode=='s'
        ddb_plotFlowAttributes(handles,'OpenBoundaries','activate',id,0,handles.GUIData.ActiveOpenBoundary);
    elseif handles.Mode=='d'
        handles=DeleteOpenBoundary(handles);
    end
end

%%
function RefreshOpenBoundaries(handles)

nb=handles.Model(md).Input(ad).NrOpenBoundaries;
n=handles.GUIData.ActiveOpenBoundary;
id=ad;

if nb>0
    set(handles.GUIHandles.EditBndM1,   'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditBndN1,   'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditBndM2,   'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditBndN2,   'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditBndName, 'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.EditAlpha,   'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.TextBndM1,   'Enable','on');
    set(handles.GUIHandles.TextBndN1,   'Enable','on');
    set(handles.GUIHandles.TextBndM2,   'Enable','on');
    set(handles.GUIHandles.TextBndN2,   'Enable','on');
    set(handles.GUIHandles.TextBndName, 'Enable','on');
    set(handles.GUIHandles.TextAlpha,   'Enable','on');
    set(handles.GUIHandles.TextBndType, 'Enable','on');
    set(handles.GUIHandles.TextForcing, 'Enable','on');
    set(handles.GUIHandles.TextProfile, 'Enable','on');

    set(handles.GUIHandles.SelectBoundaryType,     'Enable','on');
    set(handles.GUIHandles.SelectForcingType,      'Enable','on');
    set(handles.GUIHandles.SelectProfile,          'Enable','on');

    set(handles.GUIHandles.PushSelectOpenBoundary, 'Enable','on');

    set(handles.GUIHandles.PushFlowConditions,     'Enable','on');
    if handles.Model(md).Input(id).Salinity.Include || handles.Model(md).Input(id).Temperature.Include || handles.Model(md).Input(id).Sediments || ...
            handles.Model(md).Input(id).Tracers
        set(handles.GUIHandles.PushTransportConditions,'Enable','on');
    else
        set(handles.GUIHandles.PushTransportConditions,'Enable','off');
    end
    
    set(handles.GUIHandles.EditBndM1,   'String',num2str(handles.Model(md).Input(id).OpenBoundaries(n).M1));
    set(handles.GUIHandles.EditBndN1,   'String',num2str(handles.Model(md).Input(id).OpenBoundaries(n).N1));
    set(handles.GUIHandles.EditBndM2,   'String',num2str(handles.Model(md).Input(id).OpenBoundaries(n).M2));
    set(handles.GUIHandles.EditBndN2,   'String',num2str(handles.Model(md).Input(id).OpenBoundaries(n).N2));
    set(handles.GUIHandles.EditBndName, 'String',num2str(handles.Model(md).Input(id).OpenBoundaries(n).Name));
    Names='';
    for i=1:nb
        Names{i}=handles.Model(md).Input(id).OpenBoundaries(i).Name;
    end

    if length(get(handles.GUIHandles.ListOpenBoundaries,'Value'))==1
        set(handles.GUIHandles.ListOpenBoundaries,'Value',1);
    end
    set(handles.GUIHandles.ListOpenBoundaries,'String',Names);
    if length(get(handles.GUIHandles.ListOpenBoundaries,'Value'))==1
        set(handles.GUIHandles.ListOpenBoundaries,'Value',n);
    end

    tp=handles.Model(md).Input(id).OpenBoundaries(n).Type;
    tps={'Z','C','N','T','Q','R'};
    ii=strmatch(tp,tps,'exact');
    set(handles.GUIHandles.SelectBoundaryType,'Value',ii);
    switch tp,
        case{'Z','C','T','Q'}
            set(handles.GUIHandles.EditAlpha,'Enable','on','BackgroundColor',[1 1 1]);
            set(handles.GUIHandles.TextAlpha,'Enable','on');
            set(handles.GUIHandles.EditAlpha,'String',num2str(handles.Model(md).Input(id).OpenBoundaries(n).Alpha));
        otherwise
            set(handles.GUIHandles.EditAlpha,'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
            set(handles.GUIHandles.TextAlpha,'Enable','off');
            set(handles.GUIHandles.EditAlpha,'String','');
    end
    fr=handles.Model(md).Input(id).OpenBoundaries(n).Forcing;
    frs={'A','H','T','Q'};
    ii=strmatch(fr,frs,'exact');
    set(handles.GUIHandles.SelectForcingType,'Value',ii);

    prf={'uniform','logarithmic','3d-profile'};
    ii=strmatch(lower(handles.Model(md).Input(id).OpenBoundaries(n).Profile),prf,'exact');
    set(handles.GUIHandles.SelectProfile,'Value',1);
    switch handles.Model(md).Input(id).OpenBoundaries(n).Type
        case{'Z','N'}
            str={'Uniform'};
        case{'T'}
            str={'Uniform','Logarithmic'};            
        case{'C','Q','R'}
            str={'Uniform','Logarithmic','Per Layer'};
    end
    set(handles.GUIHandles.SelectProfile,'String',str);
    set(handles.GUIHandles.SelectProfile,'Value',ii);
       
    handles=ddb_countOpenBoundaries(handles,id);

    set(handles.GUIHandles.PushSaveBoundaryDefinitions,  'Enable','on');
    if handles.Model(md).Input(id).NrAstro>0
        set(handles.GUIHandles.PushOpenAstronomicConditions, 'Enable','on');
        set(handles.GUIHandles.PushOpenAstronomicCorrections,'Enable','on');
        set(handles.GUIHandles.PushSaveAstronomicConditions, 'Enable','on');
        set(handles.GUIHandles.TextAstronomicConditionsFile,'String', ['File : ' handles.Model(md).Input(id).BcaFile]);
        if handles.Model(md).Input(id).NrCor>0
            set(handles.GUIHandles.PushSaveAstronomicCorrections,'Enable','on');
            set(handles.GUIHandles.TextAstronomicCorrectionsFile,'String',['File : ' handles.Model(md).Input(id).CorFile]);
        else
            set(handles.GUIHandles.PushSaveAstronomicCorrections,'Enable','off');
            set(handles.GUIHandles.TextAstronomicCorrectionsFile,'String','File : ');
        end
    else
        set(handles.GUIHandles.PushOpenAstronomicConditions, 'Enable','off');
        set(handles.GUIHandles.PushOpenAstronomicCorrections,'Enable','off');
        set(handles.GUIHandles.PushSaveAstronomicConditions, 'Enable','off');
        set(handles.GUIHandles.PushSaveAstronomicCorrections,'Enable','off');
        set(handles.GUIHandles.TextAstronomicConditionsFile,'String','File : ');
        set(handles.GUIHandles.TextAstronomicCorrectionsFile,'String','File : ');
    end
    if handles.Model(md).Input(id).NrHarmo>0
        set(handles.GUIHandles.PushOpenHarmonicConditions, 'Enable','on');
        set(handles.GUIHandles.PushSaveHarmonicConditions, 'Enable','on');
        set(handles.GUIHandles.TextHarmonicConditionsFile, 'String',['File : ' handles.Model(md).Input(id).BchFile]);
    else
        set(handles.GUIHandles.PushOpenHarmonicConditions, 'Enable','off');
        set(handles.GUIHandles.PushSaveHarmonicConditions, 'Enable','off');
        set(handles.GUIHandles.TextHarmonicConditionsFile, 'String','File : ');
    end
    if handles.Model(md).Input(id).NrTime>0
        set(handles.GUIHandles.PushOpenTimeSeriesConditions, 'Enable','on');
        set(handles.GUIHandles.PushSaveTimeSeriesConditions, 'Enable','on');
        set(handles.GUIHandles.TextTimeSeriesConditionsFile, 'String',['File : ' handles.Model(md).Input(id).BctFile]);
    else
        set(handles.GUIHandles.PushOpenTimeSeriesConditions, 'Enable','off');
        set(handles.GUIHandles.PushSaveTimeSeriesConditions, 'Enable','off');
        set(handles.GUIHandles.TextTimeSeriesConditionsFile, 'String','File : ');
    end
    if handles.Model(md).Input(id).Salinity.Include || handles.Model(md).Input(id).Temperature.Include || handles.Model(md).Input(id).Tracers || handles.Model(md).Input(id).Sediments
        set(handles.GUIHandles.PushOpenTransportConditions, 'Enable','on');
        set(handles.GUIHandles.PushSaveTransportConditions, 'Enable','on');
    else
        set(handles.GUIHandles.PushOpenTransportConditions, 'Enable','off');
        set(handles.GUIHandles.PushSaveTransportConditions, 'Enable','off');
    end

    nsel=length(get(handles.GUIHandles.ListOpenBoundaries,'Value'));
    if nsel>1
        set(handles.GUIHandles.EditBndM1,   'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
        set(handles.GUIHandles.EditBndN1,   'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
        set(handles.GUIHandles.EditBndM2,   'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
        set(handles.GUIHandles.EditBndN2,   'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
        set(handles.GUIHandles.EditBndName, 'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
        set(handles.GUIHandles.TextBndM1,   'Enable','off');
        set(handles.GUIHandles.TextBndN1,   'Enable','off');
        set(handles.GUIHandles.TextBndM2,   'Enable','off');
        set(handles.GUIHandles.TextBndN2,   'Enable','off');
        set(handles.GUIHandles.TextBndName, 'Enable','off');
        set(handles.GUIHandles.PushFlowConditions,     'Enable','off');
        set(handles.GUIHandles.PushTransportConditions,'Enable','off');
        set(handles.GUIHandles.PushSelectOpenBoundary, 'Enable','off');
    end
    
else
    set(handles.GUIHandles.EditBndM1,   'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
    set(handles.GUIHandles.EditBndN1,   'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
    set(handles.GUIHandles.EditBndM2,   'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
    set(handles.GUIHandles.EditBndN2,   'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
    set(handles.GUIHandles.EditBndName, 'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
    set(handles.GUIHandles.EditAlpha,   'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
    set(handles.GUIHandles.TextBndM1,   'Enable','off');
    set(handles.GUIHandles.TextBndN1,   'Enable','off');
    set(handles.GUIHandles.TextBndM2,   'Enable','off');
    set(handles.GUIHandles.TextBndN2,   'Enable','off');
    set(handles.GUIHandles.TextBndName, 'Enable','off');
    set(handles.GUIHandles.TextAlpha,   'Enable','off');
    set(handles.GUIHandles.TextBndType, 'Enable','off');
    set(handles.GUIHandles.TextForcing, 'Enable','off');
    set(handles.GUIHandles.TextProfile, 'Enable','off');

    set(handles.GUIHandles.PushSelectOpenBoundary, 'Enable','off');

    set(handles.GUIHandles.SelectBoundaryType,     'Enable','off');
    set(handles.GUIHandles.SelectForcingType,      'Enable','off');
    set(handles.GUIHandles.SelectProfile,          'Enable','off');
    set(handles.GUIHandles.PushFlowConditions,     'Enable','off');
    set(handles.GUIHandles.PushTransportConditions,'Enable','off');

    set(handles.GUIHandles.ListOpenBoundaries,'String',[]);
    set(handles.GUIHandles.EditBndM1,   'String',[]);
    set(handles.GUIHandles.EditBndN1,   'String',[]);
    set(handles.GUIHandles.EditBndM2,   'String',[]);
    set(handles.GUIHandles.EditBndN2,   'String',[]);
    set(handles.GUIHandles.EditBndName, 'String',[]);
    set(handles.GUIHandles.EditAlpha,   'String',[]);

    set(handles.GUIHandles.PushSaveBoundaryDefinitions,  'Enable','off');
    set(handles.GUIHandles.PushOpenAstronomicConditions, 'Enable','off');
    set(handles.GUIHandles.PushOpenAstronomicCorrections,'Enable','off');
    set(handles.GUIHandles.PushOpenHarmonicConditions,   'Enable','off');
    set(handles.GUIHandles.PushOpenTimeSeriesConditions, 'Enable','off');
    set(handles.GUIHandles.PushOpenTransportConditions,  'Enable','off');

    set(handles.GUIHandles.PushSaveAstronomicConditions, 'Enable','off');
    set(handles.GUIHandles.PushSaveAstronomicCorrections,'Enable','off');
    set(handles.GUIHandles.PushSaveHarmonicConditions,   'Enable','off');
    set(handles.GUIHandles.PushSaveTimeSeriesConditions, 'Enable','off');
    set(handles.GUIHandles.PushSaveTransportConditions,  'Enable','off');

    set(handles.GUIHandles.TextBoundaryDefinitionsFile, 'String','File : ');
    set(handles.GUIHandles.TextAstronomicConditionsFile,'String','File : ');
    set(handles.GUIHandles.TextHarmonicConditionsFile,  'String','File : ');
    set(handles.GUIHandles.TextTimeSeriesConditionsFile,'String','File : ');
    set(handles.GUIHandles.TextTransportConditionsFile, 'String','File : ');
       
end

%%
function [m1,n1,m2,n2,ok]=CheckBoundaryPoints(m1,n1,m2,n2,icp)

handles=getHandles;

kcs=handles.Model(md).Input(ad).kcs;

ok=0;

if m1~=m2 && n1~=n2
    return
end

if icp==1
    
    if m1==m2 && n1==n2
        return
    end
    
    if m2~=m1
        if m2>m1
            m1=m1+1;
            mm1=m1;
            mm2=m2;
        else
            m2=m2+1;
            mm1=m2;
            mm2=m1;
        end
        sumkcs1=sum(kcs(mm1:mm2,n1));
        sumkcs2=sum(kcs(mm1:mm2,n1+1));
        if sumkcs1==mm2-mm1+1 && sumkcs2==0
            % upper
            ok=1;
            n1=n1+1;
            n2=n1;
        elseif sumkcs2==mm2-mm1+1 && sumkcs1==0
            % lower
            ok=1;
        else
            ok=0;
        end
        if mm2==mm1 && (kcs(mm2+1,n1)==1 || kcs(mm2-1,n1)==1)
            ok=0;
        end
    else
        if n2>n1
            n1=n1+1;
            nn1=n1;
            nn2=n2;
        else
            n2=n2+1;
            nn1=n2;
            nn2=n1;
        end
        sumkcs1=sum(kcs(m1,nn1:nn2));
        sumkcs2=sum(kcs(m1+1,nn1:nn2));
        if sumkcs1==nn2-nn1+1 && sumkcs2==0
            % right
            ok=1;
            m1=m1+1;
            m2=m1;
        elseif sumkcs2==nn2-nn1+1 && sumkcs1==0
            % left
            ok=1;
        else
            ok=0;
        end
        if nn2==nn1 && (kcs(m1,nn2+1)==1 || kcs(m1,nn2-1)==1)
            ok=0;
        end
    end
end
    


