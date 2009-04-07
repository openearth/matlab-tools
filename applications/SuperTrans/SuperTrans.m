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

curdir=fileparts(which('SuperTrans'));
addpath(genpath([curdir '\conversion']));
addpath(genpath([curdir '\conversion_dlls']));
addpath(genpath([curdir '\data']));
addpath(genpath([curdir '\general']));

if nargin>0
    handles.CoordinateSystems=varargin{1};
    handles.Operations       =varargin{2};
else
    load('CoordinateSystems.mat');
    handles.CoordinateSystems=CoordinateSystems;
    load('Operations.mat');
    handles.Operations       =Operations;
end

handles.MainWindow      = MakeNewWindow('SuperTrans',[760 550]);
handles.BackgroundColor = get(gcf,'Color');
bgc                     = handles.BackgroundColor;
handles.FilterIndex     = 1;
handles.FilePath        = curdir;

nproj=0;
ngeo=0;

for i=1:length(handles.CoordinateSystems)
    switch lower(handles.CoordinateSystems(i).coord_ref_sys_kind),
        case{'projected'}
            nproj=nproj+1;
            handles.CSProj(nproj)=handles.CoordinateSystems(i);
            handles.StrProj{nproj}=handles.CSProj(nproj).coord_ref_sys_name;
        case{'geographic 2d'}
            ngeo=ngeo+1;
            handles.CSGeo(ngeo)=handles.CoordinateSystems(i);
            handles.StrGeo{ngeo}=handles.CSGeo(ngeo).coord_ref_sys_name;
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

handles.CSType{1}     = 'xy';
handles.CSType{2}     = 'geo';
handles.XYNr{1}       = 2457;
handles.XYNr{2}       = 2457;
handles.GeoNr{1}      = 239;
handles.GeoNr{2}      = 239;

set(handles.SelectCS(1),'Value',handles.XYNr{1});
set(handles.SelectCS(2),'Value',handles.GeoNr{2});

handles.CS(1)=handles.CSProj(handles.XYNr{1});
handles.CS(2)=handles.CSGeo(handles.GeoNr{2});

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

datumcode=handles.CS(ii).datum_code;
datumname=handles.CS(ii).datum_name;
set(handles.TextDatum(ii),'String',['Datum : ' datumname]);
ell=handles.CS(ii).ellipsoid.ellipsoid_name;
set(handles.TextEllipsoid(ii),'String',['Ellipsoid : ' ell]);

if strcmp(handles.CSType{ii},'xy')
    % Projection
    projection_conv_code=handles.CS(ii).projection_conv_code;
    j=findinstruct(handles.Operations,'coord_op_code',projection_conv_code);
    operation=handles.Operations(j);
    meth=operation.coordinate_operation_method;
    set(handles.TextCoordinateOperation(ii),'String',['Operation : ' meth]);
    set(handles.TextCoordinateOperation(ii),'Visible','on');
    pars0=operation.parameters;

    n=length(pars0);
    
    pars=pars0;

    switch operation.coord_op_method_code,
        case{9802,9803}
            pars(1)=pars0(findstrinstruct(pars0,'name','Longitude_of_false_origin'));
            pars(2)=pars0(findstrinstruct(pars0,'name','Easting_at_false_origin'));
            pars(3)=pars0(findstrinstruct(pars0,'name','Latitude_of_false_origin'));
            pars(4)=pars0(findstrinstruct(pars0,'name','Northing_at_false_origin'));
            pars(5)=pars0(findstrinstruct(pars0,'name','Latitude_of_1st_standard_parallel'));
            pars(6)=pars0(findstrinstruct(pars0,'name','Latitude_of_2nd_standard_parallel'));
        case{9807,9808,9809}
            pars(1)=pars0(findstrinstruct(pars0,'name','Longitude_of_natural_origin'));
            pars(2)=pars0(findstrinstruct(pars0,'name','Latitude_of_natural_origin'));
            pars(3)=pars0(findstrinstruct(pars0,'name','False_easting'));
            pars(4)=pars0(findstrinstruct(pars0,'name','False_northing'));
            pars(5)=pars0(findstrinstruct(pars0,'name','Scale_factor_at_natural_origin'));
    end

    for k=1:n
        flds{k}=pars(k).name;
        units{k}=pars(k).unit_of_meas_name;
        units{k}=ConvertUnitString(units{k});
    end

    for k=1:n
        str=strrep(flds{k},'_',' ');
        set(handles.TextConversionParameters(ii,k),'String',str);
        val=pars(k).value;
        if ~strcmp(units{k},'deg')
            set(handles.EditConversionParameters(ii,k),'String',num2str(val,'%0.9g'));
        else
            dms=rad2dms(pi*val/180);
            degstr=[num2str(dms(1)) ' ' num2str(dms(2)) ''' ' num2str(dms(3)) '"'];
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

if handles.CS(1).source_geogcrs_code~=handles.CS(2).source_geogcrs_code
    
    [transcodes1,transnames1,ireverse1,idef1,transcodes2,transnames2,ireverse2,idef2,crscode_interm]= ...
        FindTransformationOptions(handles.CS(1).source_geogcrs_code,handles.CS(2).source_geogcrs_code, ...
        handles.CoordinateSystems,handles.Operations);

    if ~isnan(transcodes1(1))

        handles.DoubleTransformation=0;
        idoub=0;
        if ~isnan(crscode_interm)
            idoub=1;
            handles.DoubleTransformation=1;
        end

        handles.ActiveTransformationMethod=1;
        handles.TransCodes1=transcodes1;
        handles.TransCodes2=transcodes2;
        handles.TransNames1=transnames1;
        handles.TransNames2=transnames2;
        handles.Trans1=idef1;
        handles.Trans2=idef2;
        
        handles.Trans1Code=transcodes1(idef1);
        handles.Trans1Name=transnames1(idef1);
        
        set(handles.PushTrans,'Visible','on');
        set(handles.PushTrans(1),'Enable','on');
        
        if idoub
            handles.Trans2Code=transcodes2(idef2);
            handles.Trans2Name=transnames2{idef2};
            set(handles.PushTrans(2),'Enable','on');
        else
            handles.Trans2Code=[];
            handles.Trans2Name=[];
            set(handles.PushTrans(2),'Enable','off');
        end        
        RefreshDatumTransformationOptions(handles);
        RefreshDatumTransformationParameters(handles);
        set(handles.PushConvert,'Enable','on');
    else
        set(handles.TextTransformationMethod,'String','Warning! Datum Transformation Method not available','Visible','on');
        set(handles.TextTransformationParameters,'Visible','off');
        set(handles.EditTransformationParameters,'Visible','off');
        set(handles.TextTransformationUnits,'Visible','off');
        set(handles.SelectDatumTransformationMethod,'Visible','off');
        set(handles.PushConvert,'Enable','off');
        set(handles.PushTrans,'Visible','off');
    end
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
    handles.CS(ii)=handles.CSProj(i);
    handles.XYNr{ii}=i;
else
    handles.CS(ii)=handles.CSGeo(i);
    handles.GeoNr{ii}=i;
end
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

if ~isempty(x1) & ~isempty(y1)
    if handles.DoubleTransformation
        [x2,y2]=ConvertCoordinates(x1,y1,cs1,tp1,cs2,tp2,handles.CoordinateSystems,handles.Operations,tr1,tr2);
    else
        [x2,y2]=ConvertCoordinates(x1,y1,cs1,tp1,cs2,tp2,handles.CoordinateSystems,handles.Operations,tr1);
    end
    set(handles.EditX(i2),'String',num2str(x2,'%0.9g'));
    set(handles.EditY(i2),'String',num2str(y2,'%0.9g'));
end

%%
function RefreshDatumTransformationOptions(handles)
if handles.ActiveTransformationMethod==1
    set(handles.SelectDatumTransformationMethod,'String',handles.TransNames1);
    set(handles.SelectDatumTransformationMethod,'Value',handles.Trans1);
    set(handles.SelectDatumTransformationMethod,'Visible','on');
else
    set(handles.SelectDatumTransformationMethod,'String',handles.TransNames2);
    set(handles.SelectDatumTransformationMethod,'Value',handles.Trans2);
    set(handles.SelectDatumTransformationMethod,'Visible','on');
end

%%
function RefreshDatumTransformationParameters(handles)

if handles.ActiveTransformationMethod==1
    icode=handles.Trans1Code;
else
    icode=handles.Trans2Code;
end

ii=findinstruct(handles.Operations,'coord_op_code',icode);

method=handles.Operations(ii).coordinate_operation_method;
set(handles.TextTransformationMethod,'String',['Datum Transformation Method : ' method],'Visible','on');

pars0=handles.Operations(ii).parameters;
pars=pars0;

switch handles.Operations(ii).coord_op_method_code,
    case{9603}
        pars(1)=pars0(findstrinstruct(pars0,'name','X_axis_translation'));
        pars(2)=pars0(findstrinstruct(pars0,'name','Y_axis_translation'));
        pars(3)=pars0(findstrinstruct(pars0,'name','Z_axis_translation'));
    case{9606,9607}
        pars(1)=pars0(findstrinstruct(pars0,'name','X_axis_translation'));
        pars(2)=pars0(findstrinstruct(pars0,'name','Y_axis_translation'));
        pars(3)=pars0(findstrinstruct(pars0,'name','Z_axis_translation'));
        pars(4)=pars0(findstrinstruct(pars0,'name','X_axis_rotation'));
        pars(5)=pars0(findstrinstruct(pars0,'name','Y_axis_rotation'));
        pars(6)=pars0(findstrinstruct(pars0,'name','Z_axis_rotation'));
        pars(7)=pars0(findstrinstruct(pars0,'name','Scale_difference'));
end

n=length(pars);
for k=1:n
    flds{k}=pars(k).name;
    units{k}=pars(k).unit_of_meas_name;
    units{k}=ConvertUnitString(units{k});
end

for k=1:n
    str=strrep(flds{k},'_',' ');
    set(handles.TextTransformationParameters(k),'String',str);
    val=pars(k).value;
    if ~strcmp(units{k},'deg')
        set(handles.EditTransformationParameters(k),'String',num2str(val,'%0.9g'));
    else
        dms=rad2dms(pi*val/180);
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
     handles.Trans1=ii;
     handles.Trans1Name=handles.TransNames1(ii);
     handles.Trans1Code=handles.TransCodes1(ii);
else
     handles.Trans2=ii;
     handles.Trans2Name=handles.TransNames2(ii);
     handles.Trans2Code=handles.TransCodes1(ii);
end
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
        if handles.DoubleTransformation
            [x2,y2]=ConvertCoordinates(x1,y1,cs1,tp1,cs2,tp2,handles.CoordinateSystems,handles.Operations,tr1,tr2);
        else
            [x2,y2]=ConvertCoordinates(x1,y1,cs1,tp1,cs2,tp2,handles.CoordinateSystems,handles.Operations,tr1);
        end
    end

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
