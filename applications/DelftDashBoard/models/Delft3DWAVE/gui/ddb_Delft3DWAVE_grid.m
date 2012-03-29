function ddb_Delft3DWAVE_grid(varargin)

%%
if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    setUIElements('delft3dwave.grids.gridpanel.grid');
else
    opt=varargin{1};
    switch lower(opt)
        case{'selectgrid'}
            selectGrid;
        case{'selectenclosure'}
            selectEnclosure;
        case{'generatelayers'}
            generateLayers;
        case{'editkmax'}
            editKMax;
        case{'changelayers'}
            changeLayers;
        case{'loadlayers'}
            loadLayers;
        case{'savelayers'}
            saveLayers;
    end
end

%{
ddb_refreshScreen('Grids','Computational grid');

handles=getHandles;

id=handles.Model(md).Input.ActiveDomain;

% hp = uipanel('Title','Grids','Units','pixels','Position',[20 20 990 160],'Tag','UIControl');

handles.GUIHandles.TextComputationalGrids = uicontrol(gcf,'Style','text','string','Computational grids :','Position',[40 145 100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditComputationalGrids = uicontrol(gcf,'Style','listbox','Position',[40 90 200 50],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.EditComputationalGrids,'Max',3);
set(handles.GUIHandles.EditComputationalGrids,'String',handles.Model(md).Input.ComputationalGrids);
set(handles.GUIHandles.EditComputationalGrids,'CallBack',{@EditComputationalGrids_CallBack});

handles.GUIHandles.PushAdd      = uicontrol(gcf,'Style','pushbutton',  'String','Add','Position',[250 120 70 20],'Tag','UIControl');
set(handles.GUIHandles.PushAdd,'Enable','on');
set(handles.GUIHandles.PushAdd,'CallBack',{@PushAdd_CallBack});

handles.GUIHandles.PushDelete   = uicontrol(gcf,'Style','pushbutton',  'String','Delete','Position',[250 90 70 20],'Tag','UIControl');
set(handles.GUIHandles.PushDelete,'Enable','off');
set(handles.GUIHandles.PushDelete,'CallBack',{@PushDelete_CallBack});

handles.GUIHandles.TextCoordinateSystem = uicontrol(gcf,'Style','text','string',['Co-ordinate System : '],'Position',[40 70 300 15],'HorizontalAlignment','left','Tag','UIControl');

setHandles(handles);

% hp = uipanel('Title','Grid data','Units','pixels','Position',[340 25 655 140],'Tag','UIControl');

handles.GUIHandles.TextBathymetryGrid     = uicontrol(gcf,'Style','text','String',['Associated bathymetry grid : ' handles.Model(md).Input.Domain(id).GrdFile],'Position',[360 90 310 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextBathymetryDep      = uicontrol(gcf,'Style','text','String',['Associated bathymetry data : ' handles.Model(md).Input.Domain(id).DepFile],'Position',[360 70 310 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextNestedIn           = uicontrol(gcf,'Style','text','String',['Nested in : '                  handles.Model(md).Input.Domain(id).NstFile],'Position',[360 50 310 15],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.TextGridSpecifications = uicontrol(gcf,'Style','text','String','Grid specifications : ', 'Position',[680 90  100 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextMMax               = uicontrol(gcf,'Style','text','String',['Grid points in M direction : ' num2str(handles.Model(md).Input.Domain(id).MMax)],'Position',[680 70  250 15],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextNMax               = uicontrol(gcf,'Style','text','String',['Grid points in N direction : ' num2str(handles.Model(md).Input.Domain(id).NMax)],'Position',[680 50  250 15],'HorizontalAlignment','left','Tag','UIControl');

setHandles(handles);

Refresh(handles);

%%
function EditComputationalGrids_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.ActiveDomain=get(hObject,'Value');
setHandles(handles);
Refresh(handles);

%%
function PushAdd_CallBack(hObject,eventdata)
handles=getHandles;
icomp=size(handles.Model(md).Input.ComputationalGrids,2);
if isempty(handles.Model(md).Input.ComputationalGrids{1})
    handles.Model(md).Input.ActiveDomain=1;
else
    handles.Model(md).Input.ActiveDomain=icomp+1;
end
id=handles.Model(md).Input.ActiveDomain;
[filename, pathname, filterindex] = uigetfile('*.grd', 'Select Grid File');
if pathname~=0
    token = strtok(filename,'.');
    handles.Model(md).Input.ComputationalGrids{id}=token;
    handles.Model(md).Input.Domain(id).PathnameComputationalGrids=pathname;
    fid = fopen([pathname filename],'r');
    for k=1:5
        [Temp,Rest] = strtok(fgetl(fid),'=');
    end
    handles.Model(md).Input.Domain(id).Coordsyst = Rest(3:end);
    set(handles.GUIHandles.EditComputationalGrids,'String',handles.Model(md).Input.ComputationalGrids);    
    set(handles.GUIHandles.TextCoordinateSystem,'String',['Co-ordinate System : ' handles.Model(md).Input.Domain(id).Coordsyst]);
end
setHandles(handles);
Refresh(handles);

%%
function PushDelete_CallBack(hObject,eventdata)
handles=getHandles;
id=handles.Model(md).Input.ActiveDomain;
jj=find([1:size(handles.Model(md).Input.ComputationalGrids,2)] ~= id);
if ~isempty(jj)
    handles.Model(md).Input.ActiveDomain=handles.Model(md).Input.ActiveDomain-1;
    for kk = 1:size(jj,2)
        Temp{kk}=handles.Model(md).Input.ComputationalGrids{jj(kk)};
        handles.Model(md).Input.Domain(kk).Coordsyst=handles.Model(md).Input.Domain(jj(kk)).Coordsyst;
        handles.Model(md).Input.Domain(kk).GrdFile=handles.Model(md).Input.Domain(jj(kk)).GrdFile;
        handles.Model(md).Input.Domain(kk).EncFile=handles.Model(md).Input.Domain(jj(kk)).EncFile;
        handles.Model(md).Input.Domain(kk).OtherGrid=handles.Model(md).Input.Domain(jj(kk)).OtherGrid;
        handles.Model(md).Input.Domain(kk).CompGrid=handles.Model(md).Input.Domain(jj(kk)).CompGrid;
        handles.Model(md).Input.Domain(kk).DepFile=handles.Model(md).Input.Domain(jj(kk)).DepFile;
        handles.Model(md).Input.Domain(kk).CompDep=handles.Model(md).Input.Domain(jj(kk)).CompDep;
        handles.Model(md).Input.Domain(kk).Xorig=handles.Model(md).Input.Domain(jj(kk)).Xorig;
        handles.Model(md).Input.Domain(kk).Yorig=handles.Model(md).Input.Domain(jj(kk)).Yorig;
        handles.Model(md).Input.Domain(kk).Xgridsize=handles.Model(md).Input.Domain(jj(kk)).Xgridsize;
        handles.Model(md).Input.Domain(kk).Ygridsize=handles.Model(md).Input.Domain(jj(kk)).Ygridsize;
        handles.Model(md).Input.Domain(kk).MMax=handles.Model(md).Input.Domain(jj(kk)).MMax;
        handles.Model(md).Input.Domain(kk).NMax=handles.Model(md).Input.Domain(jj(kk)).NMax;
        handles.Model(md).Input.Domain(kk).NstFile=handles.Model(md).Input.Domain(jj(kk)).NstFile;
        handles.Model(md).Input.Domain(kk).GridNested=handles.Model(md).Input.Domain(jj(kk)).GridNested;
        handles.Model(md).Input.Domain(kk).NestedValue=handles.Model(md).Input.Domain(jj(jj(kk))).NestedValue;        
        handles.Model(md).Input.Domain(kk).Circle=handles.Model(md).Input.Domain(jj(kk)).Circle;
        handles.Model(md).Input.Domain(kk).Sector=handles.Model(md).Input.Domain(jj(kk)).Sector;
        handles.Model(md).Input.Domain(kk).StartDir=handles.Model(md).Input.Domain(jj(kk)).StartDir;
        handles.Model(md).Input.Domain(kk).EndDir=handles.Model(md).Input.Domain(jj(kk)).EndDir;
        handles.Model(md).Input.Domain(kk).NumberDir=handles.Model(md).Input.Domain(jj(kk)).NumberDir;
        handles.Model(md).Input.Domain(kk).LowFreq=handles.Model(md).Input.Domain(jj(kk)).LowFreq;
        handles.Model(md).Input.Domain(kk).HighFreq=handles.Model(md).Input.Domain(jj(kk)).HighFreq;
        handles.Model(md).Input.Domain(kk).NumberFreq=handles.Model(md).Input.Domain(jj(kk)).NumberFreq;
    end
    clear handles.Model(md).Input.ComputationalGrids;
    handles.Model(md).Input.ComputationalGrids=Temp;
    handles.Model(md).Input.Domain(size(jj,2)+1).Coordsyst='';
    handles.Model(md).Input.Domain(size(jj,2)+1).GrdFile='';
    handles.Model(md).Input.Domain(size(jj,2)+1).EncFile='';
    handles.Model(md).Input.Domain(size(jj,2)+1).OtherGrid='';
    handles.Model(md).Input.Domain(size(jj,2)+1).CompGrid='';
    handles.Model(md).Input.Domain(size(jj,2)+1).DepFile='';
    handles.Model(md).Input.Domain(size(jj,2)+1).CompDep='';
    handles.Model(md).Input.Domain(size(jj,2)+1).Xorig='';
    handles.Model(md).Input.Domain(size(jj,2)+1).Yorig='';
    handles.Model(md).Input.Domain(size(jj,2)+1).Xgridsize='';
    handles.Model(md).Input.Domain(size(jj,2)+1).Ygridsize='';
    handles.Model(md).Input.Domain(size(jj,2)+1).MMax='';
    handles.Model(md).Input.Domain(size(jj,2)+1).NMax='';
    handles.Model(md).Input.Domain(size(jj,2)+1).NstFile='';
    handles.Model(md).Input.Domain(size(jj,2)+1).GridNested='';
    handles.Model(md).Input.Domain(size(jj,2)+1).NestedValue='';
    handles.Model(md).Input.Domain(size(jj,2)+1).Circle='';
    handles.Model(md).Input.Domain(size(jj,2)+1).Sector='';
    handles.Model(md).Input.Domain(size(jj,2)+1).StartDir='';
    handles.Model(md).Input.Domain(size(jj,2)+1).EndDir='';
    handles.Model(md).Input.Domain(size(jj,2)+1).NumberDir='';
    handles.Model(md).Input.Domain(size(jj,2)+1).LowFreq='';
    handles.Model(md).Input.Domain(size(jj,2)+1).HighFreq='';
    handles.Model(md).Input.Domain(size(jj,2)+1).NumberFreq='';
else
    handles.Model(md).Input.ComputationalGrids={''};
    handles.Model(md).Input.Domain(id).Coordsyst='';
    handles.Model(md).Input.Domain(id).GrdFile='';
    handles.Model(md).Input.Domain(id).EncFile='';
    handles.Model(md).Input.Domain(id).OtherGrid='';
    handles.Model(md).Input.Domain(id).CompGrid='';
    handles.Model(md).Input.Domain(id).DepFile='';
    handles.Model(md).Input.Domain(id).CompDep='';
    handles.Model(md).Input.Domain(id).Xorig='';
    handles.Model(md).Input.Domain(id).Yorig='';
    handles.Model(md).Input.Domain(id).Xgridsize='';
    handles.Model(md).Input.Domain(id).Ygridsize='';
    handles.Model(md).Input.Domain(id).MMax='';
    handles.Model(md).Input.Domain(id).NMax='';
    handles.Model(md).Input.Domain(id).NstFile='';
    handles.Model(md).Input.Domain(id).GridNested='';
    handles.Model(md).Input.Domain(id).NestedValue='';
    handles.Model(md).Input.Domain(id).Circle='';
    handles.Model(md).Input.Domain(id).Sector='';
    handles.Model(md).Input.Domain(id).StartDir='';
    handles.Model(md).Input.Domain(id).EndDir='';
    handles.Model(md).Input.Domain(id).NumberDir='';
    handles.Model(md).Input.Domain(id).LowFreq='';
    handles.Model(md).Input.Domain(id).HighFreq='';
    handles.Model(md).Input.Domain(id).NumberFreq='';    
end
setHandles(handles);
Refresh(handles);

%%
function Refresh(handles)
handles=getHandles;
if ~isempty(handles.Model(md).Input.ComputationalGrids)
    id=handles.Model(md).Input.ActiveDomain;
    set(handles.GUIHandles.EditComputationalGrids,'String',handles.Model(md).Input.ComputationalGrids,'Value',id);
    set(handles.GUIHandles.PushDelete,'Enable','on');
    if ~isempty(handles.Model(md).Input.Domain(id).CompGrid)
        set(handles.GUIHandles.TextBathymetryGrid,'String',['Associated bathymetry grid : ' handles.Model(md).Input.Domain(id).CompGrid]);
    else
        set(handles.GUIHandles.TextBathymetryGrid,'String',['Associated bathymetry grid : ' handles.Model(md).Input.Domain(id).OtherGrid]);
    end
    set(handles.GUIHandles.TextBathymetryDep,'String',['Associated bathymetry data : ' handles.Model(md).Input.Domain(id).CompDep]);
    set(handles.GUIHandles.TextNestedIn,'String',['Nested in : ' handles.Model(md).Input.Domain(id).NstFile]);
    set(handles.GUIHandles.TextMMax,'String',['Grid points in M direction : ' num2str(handles.Model(md).Input.Domain(id).MMax)]);
    set(handles.GUIHandles.TextNMax,'String',['Grid points in N direction : ' num2str(handles.Model(md).Input.Domain(id).NMax)]);
    set(handles.GUIHandles.TextCoordinateSystem,'String',['Co-ordinate System : ' handles.Model(md).Input.Domain(id).Coordsyst]);
end
setHandles(handles);
%}



