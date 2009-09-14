function SuperTrans(varargin)
%SUPERTRANS   transformation between coordinate systems
%
%See also: SuperTrans = GetCoordinateSystems > SelectCoordinateSystem > ConvertCoordinates

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% curdir=fileparts(which('SuperTrans'));
% addpath(genpath([curdir '\conversion']));
% addpath(genpath([curdir '\conversion_dlls']));
% addpath(genpath([curdir '\data']));
% addpath(genpath([curdir '\general']));

curdir=pwd;

handles.EPSG = load('EPSG.mat');
handles.OPT=[];

% if nargin>0
%     handles.CoordinateSystems=varargin{1};
%     handles.Operations       =varargin{2};
% else
%     load('CoordinateSystems.mat');
%     handles.CoordinateSystems=CoordinateSystems;
%     load('Operations.mat');
%     handles.Operations       =Operations;
% end

handles.MainWindow      = MakeNewWindow('SuperTrans',[760 550]);
handles.BackgroundColor = get(gcf,'Color');
bgc                     = handles.BackgroundColor;
handles.FilterIndex     = 1;
handles.FilePath        = curdir;

nproj=0;
ngeo=0;

% for i=1:length(handles.CoordinateSystems)
%     switch lower(handles.CoordinateSystems(i).coord_ref_sys_kind),
%         case{'projected'}
%             nproj=nproj+1;
%             handles.CSProj(nproj)=handles.CoordinateSystems(i);
%             handles.StrProj{nproj}=handles.CSProj(nproj).coord_ref_sys_name;
%         case{'geographic 2d'}
%             ngeo=ngeo+1;
%             handles.CSGeo(ngeo)=handles.CoordinateSystems(i);
%             handles.StrGeo{ngeo}=handles.CSGeo(ngeo).coord_ref_sys_name;
%     end
% end


for i=1:length(handles.EPSG.coordinate_reference_system.coord_ref_sys_kind)
    switch lower(handles.EPSG.coordinate_reference_system.coord_ref_sys_kind{i}),
        case{'projected'}
            nproj=nproj+1;
            handles.CSProj(nproj)=i;
            handles.StrProj{nproj}=handles.EPSG.coordinate_reference_system.coord_ref_sys_name{i};
        case{'geographic 2d'}
            ngeo=ngeo+1;
            handles.CSGeo(ngeo)=i;
            handles.StrGeo{ngeo}=handles.EPSG.coordinate_reference_system.coord_ref_sys_name{i};
    end
end


% menu

f = uimenu('Label','File Convert');
    uimenu(f,'Label','Convert A --> B','Callback',{@FileConvert_CallBack,1});
    uimenu(f,'Label','Convert B --> A','Callback',{@FileConvert_CallBack,2});
    uimenu(f,'Label','Exit','Callback','close(gcf)',... 
           'Separator','on');

f = uimenu('Label','Input');
    uimenu(f,'Label','Does not work yet','Callback',{@MenuInput_CallBack});
f = uimenu('Label','Output');
    uimenu(f,'Label','Does not work yet','Callback',{@MenuOutput_CallBack});

f = uimenu('Label','Manage');
    uimenu(f,'Label','Datums','Callback',{@ManageDatums_CallBack});
    uimenu(f,'Label','Coordinate Systems','Callback',{@ManageCoordinateSystems_CallBack});
  
    
% buttons

uipanel('Title','Coordinate System A','Units','pixels','Position',[ 20 215 355 325],'BackgroundColor',bgc);
uipanel('Title','Coordinate System B','Units','pixels','Position',[385 215 355 325],'BackgroundColor',bgc);

handles.ToggleXY(1)                = uicontrol(gcf,'Style','radiobutton','String','Eastings / Northings','Position',[ 30 500 120 20],'BackgroundColor',bgc,'Tag','UIControl');
handles.ToggleGeo(1)               = uicontrol(gcf,'Style','radiobutton','String','Latitude / Longitude','Position',[160 500 120 20],'BackgroundColor',bgc,'Tag','UIControl');
set(handles.ToggleXY(1),'Value',1);
set(handles.ToggleGeo(1),'Value',0);

handles.ToggleXY(2)                = uicontrol(gcf,'Style','radiobutton','String','Eastings / Northings','Position',[400 500 120 20],'BackgroundColor',bgc,'Tag','UIControl');
handles.ToggleGeo(2)               = uicontrol(gcf,'Style','radiobutton','String','Latitude / Longitude','Position',[530 500 120 20],'BackgroundColor',bgc,'Tag','UIControl');
set(handles.ToggleXY(2),'Value',0);
set(handles.ToggleGeo(2),'Value',1);

handles.SelectCS(1)                = uicontrol(gcf,'Style','popupmenu','String',handles.StrProj,'Position', [ 30 470 250 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.SelectCS(2)                = uicontrol(gcf,'Style','popupmenu','String',handles.StrGeo, 'Position',[395 470 250 20],'BackgroundColor',[1 1 1],'Tag','UIControl');

handles.TextDatum(1)               = uicontrol(gcf,'Style','text','String','Datum : ',    'Position',[ 30 440 330 20],'BackgroundColor',bgc,'HorizontalAlignment','left','Tag','UIControl');
handles.TextDatum(2)               = uicontrol(gcf,'Style','text','String','Datum : ',    'Position',[395 440 330 20],'BackgroundColor',bgc,'HorizontalAlignment','left','Tag','UIControl');
handles.TextEllipsoid(1)           = uicontrol(gcf,'Style','text','String','Ellipsoid : ','Position',[ 30 420 330 20],'BackgroundColor',bgc,'HorizontalAlignment','left','Tag','UIControl');
handles.TextEllipsoid(2)           = uicontrol(gcf,'Style','text','String','Ellipsoid : ','Position',[395 420 330 20],'BackgroundColor',bgc,'HorizontalAlignment','left','Tag','UIControl');
handles.TextCoordinateOperation(1) = uicontrol(gcf,'Style','text','String','Operation : ','Position',[ 30 400 330 20],'BackgroundColor',bgc,'HorizontalAlignment','left','Tag','UIControl');
handles.TextCoordinateOperation(2) = uicontrol(gcf,'Style','text','String','Operation : ','Position',[395 400 330 20],'BackgroundColor',bgc,'HorizontalAlignment','left','Tag','UIControl');

for i=1:7
    handles.TextConversionParameters(1,i) = uicontrol(gcf,'Style','text','String','','Position',[ 30 400-i*25-4 170 20],'BackgroundColor',bgc,'HorizontalAlignment','left','Tag','UIControl');
    handles.TextConversionParameters(2,i) = uicontrol(gcf,'Style','text','String','','Position',[395 400-i*25-4 170 20],'BackgroundColor',bgc,'HorizontalAlignment','left','Tag','UIControl');
    handles.EditConversionParameters(1,i) = uicontrol(gcf,'Style','edit','String','','Position',[200 400-i*25    80 20],'BackgroundColor',[1 1 1],'HorizontalAlignment','right','Tag','UIControl');
    handles.EditConversionParameters(2,i) = uicontrol(gcf,'Style','edit','String','','Position',[565 400-i*25    80 20],'BackgroundColor',[1 1 1],'HorizontalAlignment','right','Tag','UIControl');
    handles.TextConversionUnits(1,i)      = uicontrol(gcf,'Style','text','String','','Position',[285 400-i*25-4  80 20],'BackgroundColor',bgc,'HorizontalAlignment','left','Tag','UIControl');
    handles.TextConversionUnits(2,i)      = uicontrol(gcf,'Style','text','String','','Position',[650 400-i*25-4  80 20],'BackgroundColor',bgc,'HorizontalAlignment','left','Tag','UIControl');
end
set(handles.EditConversionParameters,'Enable','off');

uipanel('Title','Datum Transformation','Units','pixels','Position',[20 60 720 150],'BackgroundColor',bgc);

handles.SelectDatumTransformationMethod=uicontrol(gcf,'Style','popupmenu','String','datums','Position',[ 30 170 300 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.TextTransformationMethod=uicontrol(gcf,'Style','text','String','','Position',[ 30 145 400 15],'BackgroundColor',bgc,'HorizontalAlignment','left','Tag','UIControl');
for i=1:3
    handles.TextTransformationParameters(i)   = uicontrol(gcf,'Style','text','String','','Position',[ 25 145-i*25-4  90 20],'BackgroundColor',bgc,'HorizontalAlignment','right','Tag','UIControl');
    handles.EditTransformationParameters(i)   = uicontrol(gcf,'Style','edit','String','','Position',[120 145-i*25    80 20],'BackgroundColor',[1 1 1],'HorizontalAlignment','right','Tag','UIControl');
    handles.TextTransformationUnits(i)        = uicontrol(gcf,'Style','text','String','','Position',[205 145-i*25-4  50 20],'BackgroundColor',bgc,'HorizontalAlignment','left','Tag','UIControl');
end
for i=1:3
    handles.TextTransformationParameters(i+3) = uicontrol(gcf,'Style','text','String','','Position',[260 145-i*25-4  90 20],'BackgroundColor',bgc,'HorizontalAlignment','right','Tag','UIControl');
    handles.EditTransformationParameters(i+3) = uicontrol(gcf,'Style','edit','String','','Position',[355 145-i*25    80 20],'BackgroundColor',[1 1 1],'HorizontalAlignment','right','Tag','UIControl');
    handles.TextTransformationUnits(i+3)      = uicontrol(gcf,'Style','text','String','','Position',[440 145-i*25-4  50 20],'BackgroundColor',bgc,'HorizontalAlignment','left','Tag','UIControl');
end
for i=1:3
    handles.TextTransformationParameters(i+6) = uicontrol(gcf,'Style','text','String','','Position',[505 145-i*25-4  90 20],'BackgroundColor',bgc,'HorizontalAlignment','right','Tag','UIControl');
    handles.EditTransformationParameters(i+6) = uicontrol(gcf,'Style','edit','String','','Position',[600 145-i*25    80 20],'BackgroundColor',[1 1 1],'HorizontalAlignment','right','Tag','UIControl');
    handles.TextTransformationUnits(i+6)      = uicontrol(gcf,'Style','text','String','','Position',[685 145-i*25-4  50 20],'BackgroundColor',bgc,'HorizontalAlignment','left','Tag','UIControl');
end
set(handles.EditTransformationParameters,'Enable','off');

handles.EditX(1)      = uicontrol(gcf,'Style','edit','String','200000.0','Position',[ 35 20 80 20],'BackgroundColor',[1 1 1],'HorizontalAlignment','right','Tag','UIControl');
handles.EditY(1)      = uicontrol(gcf,'Style','edit','String','500000.0','Position',[155 20 80 20],'BackgroundColor',[1 1 1],'HorizontalAlignment','right','Tag','UIControl');
handles.EditX(2)      = uicontrol(gcf,'Style','edit','String','0.0','Position',[540 20 80 20],'BackgroundColor',[1 1 1],'HorizontalAlignment','right','Tag','UIControl');
handles.EditY(2)      = uicontrol(gcf,'Style','edit','String','0.0','Position',[660 20 80 20],'BackgroundColor',[1 1 1],'HorizontalAlignment','right','Tag','UIControl');
		        
handles.TextX(1)      = uicontrol(gcf,'Style','text','String','x','Position',[  0 16 30 20],'HorizontalAlignment','right','BackgroundColor',bgc,'Tag','UIControl');
handles.TextY(1)      = uicontrol(gcf,'Style','text','String','y','Position',[120 16 30 20],'HorizontalAlignment','right','BackgroundColor',bgc,'Tag','UIControl');
handles.TextX(2)      = uicontrol(gcf,'Style','text','String','lon','Position',[505 16 30 20],'HorizontalAlignment','right','BackgroundColor',bgc,'Tag','UIControl');
handles.TextY(2)      = uicontrol(gcf,'Style','text','String','lat','Position',[625 16 30 20],'HorizontalAlignment','right','BackgroundColor',bgc,'Tag','UIControl');

handles.PushConvert(1)= uicontrol(gcf,'Style','pushbutton','String','<-- Convert','Position',[310 20 65 20],'Tag','UIControl');
handles.PushConvert(2)= uicontrol(gcf,'Style','pushbutton','String','Convert -->','Position',[385 20 65 20],'Tag','UIControl');

handles.PushFile(1)   = uicontrol(gcf,'Style','pushbutton','String','File ...','Position',[260 20 40 20],'Tag','UIControl');
handles.PushFile(2)   = uicontrol(gcf,'Style','pushbutton','String','File ...','Position',[460 20 40 20],'Tag','UIControl');

handles.PushTrans(1)  = uicontrol(gcf,'Style','pushbutton','String','A','Position',[350 170 20 20],'Tag','UIControl');
handles.PushTrans(2)  = uicontrol(gcf,'Style','pushbutton','String','B','Position',[370 170 20 20],'Tag','UIControl');


handles.CSName{1}     = 'Amersfoort / RD New';
handles.CSName{2}     = 'WGS 84';

handles.CSType{1}     = 'xy';
handles.CSType{2}     = 'geo';

handles.XYNr{1}       = strmatch(handles.CSName{1},handles.StrProj,'exact');
handles.XYNr{2}       = handles.XYNr{1};
handles.GeoNr{1}      = strmatch(handles.CSName{2},handles.StrGeo,'exact');
handles.GeoNr{2}      = handles.GeoNr{1};

set(handles.SelectCS(1),'Value',handles.XYNr{1});
set(handles.SelectCS(2),'Value',handles.GeoNr{2});

handles.CS(1)=handles.CSProj(handles.XYNr{1});
handles.CS(2)=handles.CSGeo(handles.GeoNr{2});

handles.OPT = FindCSOptions(handles.OPT,handles.EPSG,'CS1.name',handles.CSName{1},'CS1.type',handles.CSType{1},'CS2.name',handles.CSName{2},'CS2.type',handles.CSType{2});
handles.OPT = ConvertCoordinatesFindDatumTransOpt(handles.OPT,handles.EPSG);

set(handles.SelectCS(1),     'CallBack',{@SelectCS_CallBack,1});
set(handles.SelectCS(2),     'CallBack',{@SelectCS_CallBack,2});
set(handles.ToggleXY(1),     'CallBack',{@ToggleXY_CallBack,1});
set(handles.ToggleXY(2),     'CallBack',{@ToggleXY_CallBack,2});
set(handles.ToggleGeo(1),    'CallBack',{@ToggleGeo_CallBack,1});
set(handles.ToggleGeo(2),    'CallBack',{@ToggleGeo_CallBack,2});
set(handles.SelectDatumTransformationMethod,'CallBack',{@SelectDatumTransformationMethod_CallBack});
set(handles.PushConvert(1),  'CallBack',{@PushConvert_CallBack,2});
set(handles.PushConvert(2),  'CallBack',{@PushConvert_CallBack,1});
set(handles.PushTrans(1),    'CallBack',{@PushTrans_CallBack,1});
set(handles.PushTrans(2),    'CallBack',{@PushTrans_CallBack,2});

handles=RefreshInput(handles,1);
handles=RefreshInput(handles,2);
handles=RefreshDatumTransformation(handles);

guidata(gcf,handles);

%%
function handles=RefreshInput(handles,ii)

OPT=handles.OPT;

if ii==1
    CS=OPT.CS1;
    proj_conv=OPT.proj_conv1;
else
    CS=OPT.CS2;
    proj_conv=OPT.proj_conv2;
end

set(handles.TextDatum(ii),'String',['Datum : ' CS.datum.name]);
set(handles.TextEllipsoid(ii),'String',['Ellipsoid : ' CS.ellips.name]);

if strcmpi(CS.type,'projected')

    % Projection
    set(handles.TextCoordinateOperation(ii),'String',['Operation : ' proj_conv.method.name]);
    set(handles.TextCoordinateOperation(ii),'Visible','on');

    n=length(proj_conv.param.codes);
    
    switch proj_conv.method.code
        case{9802,9803}
            pars{1}='Longitude of false origin';
            pars{2}='Easting at false origin';
            pars{3}='Latitude of false origin';
            pars{4}='Northing at false origin';
            pars{5}='Latitude of 1st standard parallel';
            pars{6}='Latitude of 2nd standard parallel';
        case{9807,9808,9809}
            pars{1}='Longitude of natural origin';
            pars{2}='Latitude of natural origin';
            pars{3}='False easting';
            pars{4}='False northing';
            pars{5}='Scale factor at natural origin';
    end

    for k=1:n
        jj=strmatch(lower(pars{k}),lower(proj_conv.param.name),'exact');
        flds{k}=proj_conv.param.name{jj};
        units{k}=proj_conv.param.UoM.name{jj};
        units{k}=ConvertUnitString(units{k});
        val(k)=proj_conv.param.value(k);
    end

    for k=1:n
        set(handles.TextConversionParameters(ii,k),'String',flds{k});
        if ~strcmp(units{k},'deg')
            set(handles.EditConversionParameters(ii,k),'String',num2str(val(k),'%0.9g'));
        else
            dms=d2dms(rad2deg(pi*val(k)/180));
            dms=d2dms(rad2deg(pi*val(k)/180));
            degstr=[num2str(dms.dg) ' ' num2str(dms.mn) ''' ' num2str(dms.sc) '"'];
            set(handles.EditConversionParameters(ii,k),'String',degstr);
        end            
        set(handles.TextConversionUnits(ii,k),'String',units{k});
        set(handles.TextConversionParameters(ii,k),'Visible','on');
        set(handles.EditConversionParameters(ii,k),'Visible','on');
        set(handles.TextConversionUnits(ii,k),'Visible','on');
    end
    for k=n+1:7
        set(handles.TextConversionParameters(ii,k),'Visible','off');
        set(handles.EditConversionParameters(ii,k),'Visible','off');
        set(handles.TextConversionUnits(ii,k),'Visible','off');
    end
    
else
    set(handles.TextCoordinateOperation(ii),'Visible','off');
    set(handles.TextConversionParameters(ii,:),'Visible','off');
    set(handles.EditConversionParameters(ii,:),'Visible','off');
    set(handles.TextConversionUnits(ii,:),'Visible','off');
end

%%
function handles=RefreshDatumTransformation(handles)

if ~strcmpi('no datum transformation needed',handles.OPT.datum_trans)

%    if ~isnan(transcodes1(1))

         if ~isfield(handles.OPT,'datum_trans_from_WGS84') %only exists when tranforming via WGS 84
             handles.DoubleTransformation=0;
             idoub=0;
         else
             handles.DoubleTransformation=1;
             idoub=1;
         end

         handles.ActiveTransformationMethod=1;

         handles.Trans1=1;
         handles.Trans2=1;
         
         set(handles.PushTrans,'Visible','on');
         set(handles.PushTrans(1),'Enable','on');
         
         if idoub
             set(handles.PushTrans(2),'Enable','on');
         else
             set(handles.PushTrans(2),'Enable','off');
         end

         RefreshDatumTransformationOptions(handles);
         RefreshDatumTransformationParameters(handles);
         set(handles.PushConvert,'Enable','on');
%     else
%         set(handles.TextTransformationMethod,'String','Warning! Datum Transformation Method not available','Visible','on');
%         set(handles.TextTransformationParameters,'Visible','off');
%         set(handles.EditTransformationParameters,'Visible','off');
%         set(handles.TextTransformationUnits,'Visible','off');
%         set(handles.SelectDatumTransformationMethod,'Visible','off');
%         set(handles.PushConvert,'Enable','off');
%         set(handles.PushTrans,'Visible','off');
%     end
else
    set(handles.TextTransformationMethod,'String','Datum Transformation Method : none','Visible','on');
    set(handles.TextTransformationParameters,'Visible','off');
    set(handles.EditTransformationParameters,'Visible','off');
    set(handles.TextTransformationUnits,'Visible','off');
    set(handles.SelectDatumTransformationMethod,'Visible','off');
    set(handles.PushConvert,'Enable','on');
    set(handles.PushTrans,'Visible','off');
end

%%
function SelectCS_CallBack(hObject,eventdata,ii)

handles=guidata(gcf);
i=get(hObject,'Value');

if strcmp(handles.CSType{ii},'xy')
%    handles.CS(ii)=handles.CSProj(i);
    handles.XYNr{ii}=i;
    handles.CSName{ii}=handles.StrProj{i};
    handles.CSType{ii}='xy';
else
    handles.CSName{ii}=handles.StrGeo{i};
    handles.GeoNr{ii}=i;
    handles.CSType{ii}='geo';
end

handles.OPT = FindCSOptions(handles.OPT,handles.EPSG,'CS1.name',handles.CSName{1},'CS1.type',handles.CSType{1},'CS2.name',handles.CSName{2},'CS2.type',handles.CSType{2});
handles.OPT = ConvertCoordinatesFindDatumTransOpt(handles.OPT,handles.EPSG);

handles=RefreshInput(handles,ii);
handles=RefreshDatumTransformation(handles);

guidata(gcf,handles);

%%
function ToggleXY_CallBack(hObject,eventdata,ii)
handles=guidata(gcf);
if get(hObject,'Value')
    handles.CSType{ii}='xy';
    i=handles.XYNr{ii};
    handles.CS(ii)=handles.CSProj(i);
    set(handles.SelectCS(ii),'Value',i,'String',handles.StrProj);
    set(handles.ToggleGeo(ii),'Value',0);
    set(handles.TextX(ii),'String','x');
    set(handles.TextY(ii),'String','y');
    handles=RefreshInput(handles,ii);
    handles=RefreshDatumTransformation(handles);
    guidata(gcf,handles);
else
    set(hObject,'Value',1);
end

%%
function ToggleGeo_CallBack(hObject,eventdata,ii)
handles=guidata(gcf);
if get(hObject,'Value')
    handles.CSType{ii}='geo';
    i=handles.GeoNr{ii};
    handles.CS(ii)=handles.CSGeo(i);
    set(handles.SelectCS(ii),'Value',i,'String',handles.StrGeo);
    set(handles.ToggleXY(ii),'Value',0);
    set(handles.TextX(ii),'String','lon');
    set(handles.TextY(ii),'String','lat');
    handles=RefreshInput(handles,ii);
    handles=RefreshDatumTransformation(handles);
    guidata(gcf,handles);
else
    set(hObject,'Value',1);
end

%%
function PushConvert_CallBack(hObject,eventdata,ii)
handles=guidata(gcf);
if ii==1
    i1=1;
    i2=2;
    tr1=handles.Trans1Name;
    tr2=handles.Trans2Name;
else
    i1=2;
    i2=1;
    if handles.DoubleTransformation
        tr1=handles.Trans2Name;
        tr2=handles.Trans1Name;
    else
        tr1=handles.Trans1Name;
        tr2=handles.Trans2Name;
    end
end
x1=str2num(get(handles.EditX(i1),'String'));
y1=str2num(get(handles.EditY(i1),'String'));
strs=get(handles.SelectCS(i1),'String');
k=get(handles.SelectCS(i1),'Value');
cs1=strs{k};
tp1=handles.CSType{i1};
strs=get(handles.SelectCS(i2),'String');
k=get(handles.SelectCS(i2),'Value');
cs2=strs{k};
tp2=handles.CSType{i2};

if ~isempty(x1) && ~isempty(y1)
    [x2,y2]=ConvertCoordinates(x1,y1,'CS1.name',cs1,'CS1.type',tp1,'CS2.name',cs2,'CS2.type',tp2);
    set(handles.EditX(i2),'String',num2str(x2,'%0.9g'));
    set(handles.EditY(i2),'String',num2str(y2,'%0.9g'));
end

% if ~isempty(x1) && ~isempty(y1)
%     if handles.DoubleTransformation
%         [x2,y2]=ConvertCoordinates(x1,y1,cs1,tp1,cs2,tp2,handles.CoordinateSystems,handles.Operations,tr1,tr2);
%     else
%         [x2,y2]=ConvertCoordinates(x1,y1,cs1,tp1,cs2,tp2,handles.CoordinateSystems,handles.Operations,tr1);
%     end
%     set(handles.EditX(i2),'String',num2str(x2,'%0.9g'));
%     set(handles.EditY(i2),'String',num2str(y2,'%0.9g'));
% end

%%
function RefreshDatumTransformationOptions(handles)

if handles.ActiveTransformationMethod==1
    set(handles.SelectDatumTransformationMethod,'String',handles.OPT.datum_trans.alt_name);
    set(handles.SelectDatumTransformationMethod,'Value',handles.Trans1);
    set(handles.SelectDatumTransformationMethod,'Visible','on');
else
    set(handles.SelectDatumTransformationMethod,'String',handles.OPT.datum_trans.alt_name);
    set(handles.SelectDatumTransformationMethod,'Value',handles.Trans2);
    set(handles.SelectDatumTransformationMethod,'Visible','on');
end

%%
function RefreshDatumTransformationParameters(handles)

if handles.ActiveTransformationMethod==1
    if ~isfield(handles.OPT,'datum_trans_from_WGS84')
        dtstr='datum_trans';       
    else
        dtstr='datum_trans_from_WGS84';       
    end
else
    dtstr='datum_trans_to_WGS84';       
end

datum_trans=handles.OPT.(dtstr);

params=datum_trans.params;

set(handles.TextTransformationMethod,'String',['Datum Transformation Method : ' datum_trans.method_name],'Visible','on');

switch datum_trans.method_code
    case{9603}
        pars{1}='X-axis translation';
        pars{2}='Y-axis translation';
        pars{3}='Z-axis translation';
    case{9606,9607}
        pars{1}='X-axis translation';
        pars{2}='Y-axis translation';
        pars{3}='Z-axis translation';
        pars{4}='X-axis rotation';
        pars{5}='Y-axis rotation';
        pars{6}='Z-axis rotation';
        pars{7}='Scale difference';
end

n=length(pars);

for k=1:n
    jj=strmatch(lower(pars{k}),lower(params.name),'exact');   
    flds{k}=params.name{jj};
    units{k}=params.UoM.sourceN{jj};
    units{k}=ConvertUnitString(units{k});
    val(k)=params.value(k);
end

for k=1:n
    set(handles.TextTransformationParameters(k),'String',flds{k});
    if ~strcmp(units{k},'deg')
        set(handles.EditTransformationParameters(k),'String',num2str(val(k),'%0.9g'));
    else
        dms=rad2dms(pi*val(k)/180);
        degstr=[num2str(dms(1)) ' ' num2str(dms(2)) ''' ' num2str(dms(3)) '"'];
        set(handles.EditTransformationParameters(k),'String',degstr);
    end
    set(handles.TextTransformationUnits(k),'String',units{k});
    set(handles.EditTransformationParameters(k),'Visible','on');
    set(handles.TextTransformationParameters(k),'Visible','on');
    set(handles.TextTransformationUnits(k),'Visible','on');
end
for k=n+1:9
    set(handles.TextTransformationParameters(k),'Visible','off');
    set(handles.EditTransformationParameters(k),'Visible','off');
    set(handles.TextTransformationUnits(k),'Visible','off');
end

%%
function SelectDatumTransformationMethod_CallBack(hObject,eventdata)
handles=guidata(gcf);

ii=get(hObject,'Value');
    
if handles.ActiveTransformationMethod==1
    if ~isfield(handles.OPT,'datum_trans_from_WGS84')
        datum_trans='datum_trans';       
    else
        datum_trans='datum_trans_from_WGS84';       
    end
    handles.Trans1=ii;
else
    datum_trans='datum_trans_to_WGS84';       
    handles.Trans2=ii;
end

handles.OPT.(datum_trans).name=handles.OPT.(datum_trans).alt_name{ii};
handles.OPT.(datum_trans).code=handles.OPT.(datum_trans).alt_code(ii);
handles.OPT.(datum_trans).params = ConvertCoordinatesFindDatumTransParams(handles.OPT.(datum_trans).code,handles.EPSG);
RefreshDatumTransformationParameters(handles)
guidata(gcf,handles);

%%
function PushTrans_CallBack(hObject,eventdata,ii)
handles=guidata(gcf);
handles.ActiveTransformationMethod=ii;
RefreshDatumTransformationOptions(handles);
RefreshDatumTransformationParameters(handles);
guidata(gcf,handles);

%%
function FileConvert_CallBack(hObject,eventdata,ii)
handles=guidata(gcf);
if ii==1
    i1=1;
    i2=2;
    tr1=handles.Trans1Name;
    tr2=handles.Trans2Name;
else
    i1=2;
    i2=1;
    if handles.DoubleTransformation
        tr1=handles.Trans2Name;
        tr2=handles.Trans1Name;
    else
        tr1=handles.Trans1Name;
        tr2=handles.Trans2Name;
    end
end
strs=get(handles.SelectCS(i1),'String');
k=get(handles.SelectCS(i1),'Value');
cs1=strs{k};
tp1=handles.CSType{i1};
strs=get(handles.SelectCS(i2),'String');
k=get(handles.SelectCS(i2),'Value');
cs2=strs{k};
tp2=handles.CSType{i2};

%cd(handles.FilePath);
filterindex=handles.FilterIndex;

% filterspec0= {'*.ldb;*.pol',                       'TEKAL Landboundary File (*.ldb,*.pol)'; ...
%               '*.xyz',                             'Samples file (*.xyz)'; ...
%               '*.grd',                             'Delft3D Grid (*.grd)'; ...
%               '*.map;*.tek',                       'TEKAL Map File (*.map)'; ...
%               '*.map;*.tek',                       'TEKAL Vector File (*.map)'; ...
%               '*.ann',                             'Annotation File (*.ann)'};
filterspec0= {'*.ldb;*.pol',                       'TEKAL Landboundary File (*.ldb,*.pol)'; ...
              '*.xyz',                             'Samples file (*.xyz)'; ...
              '*.grd',                             'Delft3D Grid (*.grd)'};
    
if filterindex==1
    for i=1:size(filterspec0,1)
        filterspec{i,1}=filterspec0{i,1};
        filterspec{i,2}=filterspec0{i,2};
    end
    [filename, pathname, filterindex] = uigetfile(filterspec);
else
    filterspec{1,1}=filterspec0{filterindex,1};
    filterspec{1,2}=filterspec0{filterindex,2};
    for i=1:size(filterspec0,1)
        filterspec{i+1,1}=filterspec0{i,1};
        filterspec{i+1,2}=filterspec0{i,2};
    end
    [filename, pathname, filterindex] = uigetfile(filterspec);
    if filterindex==1
        filterindex=handles.FilterIndex;
    else
        filterindex=filterindex-1;
    end
end

if pathname~=0
    handles.FilePath=pathname;

    if filterindex>0
        handles.FilterIndex=filterindex;
    end

    %cd(handles.CurrentPath);

    NewDataset=0;

    switch filterindex,
        case 1
            % Polyline
            [x,y]=landboundary('read',[pathname filename]);
        case 2
            % Samples file
            vals=load([pathname filename]);
            x=vals(:,1);
            y=vals(:,2);
            z=vals(:,3);
        case 3
            % D3D Grid
            %        [x,y]=ReadD3DGrid(pathname,filename);
            [x,y,enc]=wlgrid('read',[pathname filename]);
        case 4
            % TEKAL Map
            [x,y,varargout]=ReadTekalMap(pathname,filename);
        case 5
            % TEKAL Vector
            [x,y,varargout]=ReadTekalVector(pathname,filename);
        case 6
            % Annotation file
            [x,y,varargout]=ReadAnnotation(pathname,filename);
    end

    x1=x;
    y1=y;

    if ~isempty(x1) && ~isempty(y1)
        [x2,y2]=ConvertCoordinates(x1,y1,'CS1.name',cs1,'CS1.type',tp1,'CS2.name',cs2,'CS2.type',tp2);
    end

%     if ~isempty(x1) && ~isempty(y1)
%         if handles.DoubleTransformation
%             [x2,y2]=ConvertCoordinates(x1,y1,'CS1.name',cs1,'CS1.type',tp1,'CS2.name',cs2,'CS2.type',tp2);
%         else
%             [x2,y2]=ConvertCoordinates(x1,y1,cs1,tp1,cs2,tp2,handles.CoordinateSystems,handles.Operations,tr1);
%         end
%     end

    switch filterindex,
        case 1
            % Polyline
            [filename pathname]=uiputfile('*.ldb');
            if pathname~=0
                landboundary('write',[pathname filename],x2,y2);
            end
        case 2
            % Samples file
            [filename pathname]=uiputfile('*.xyz');
            if pathname~=0
                val=[x2 y2 z];
                save([pathname filename],'val','-ascii');
            end
        case 3
            % D3D Grid
            %        [x,y]=WriteD3DGrid(pathname,filename);
            [filename pathname]=uiputfile('*.grd');
            %        wlgrid('write',[pathname filename],x2,y2,enc);
            wlgrid_mvo('write',[pathname filename],x2,y2,enc,tp2);
        case 4
            % TEKAL Map
            [x,y,varargout]=WriteTekalMap(pathname,filename);
        case 5
            % TEKAL Vector
            [x,y,varargout]=WriteTekalVector(pathname,filename);
        case 6
            % Annotation file
            [x,y,varargout]=WriteAnnotation(pathname,filename);
    end

end

guidata(gcf,handles);


function MenuInput_CallBack(hObject,eventdata)
function MenuOutput_CallBack(hObject,eventdata)
function ManageDatums_CallBack(hObject,eventdata)
function ManageCoordinateSystems_CallBack(hObject,eventdata)
