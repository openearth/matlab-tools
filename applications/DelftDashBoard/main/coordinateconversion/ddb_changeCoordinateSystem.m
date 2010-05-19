function ddb_changeCoordinateSystem

handles=getHandles;

NewSystem=handles.ScreenParameters.CoordinateSystem;
OldSystem=handles.ScreenParameters.OldCoordinateSystem;

xl=get(gca,'XLim');
yl=get(gca,'YLim');

[xl1,yl1]=ddb_coordConvert(xl,yl,OldSystem,NewSystem);

lngth=length(NewSystem.Name);
nsys=lower(NewSystem.Name(1:min(lngth,12)));

if strcmpi(NewSystem.Type,'Cartesian')
    set(handles.GUIHandles.TextCoordinateSystem,'String',[NewSystem.Name ' - Projected']);
else
    set(handles.GUIHandles.TextCoordinateSystem,'String',[NewSystem.Name ' - Geographic']);
end

switch nsys,
    case{'wgs 84'}
        handles.ScreenParameters.XMaxRange=[-180 180];
        handles.ScreenParameters.YMaxRange=[-90 90];
    case{'wgs 84 / utm'}
%         utmzone1=str2num(NewSystem(4:5));
%         utmzone2=NewSystem(6);
        utmzone1=handles.ScreenParameters.UTMZone{1};
        utmzone2=handles.ScreenParameters.UTMZone{2};
        zn={'C','D','E','F','G','H','J','K','L','M','N','P','Q','R','S','T','U','V','W','X'};
        ii=strmatch(utmzone2,zn,'exact');
        dy=10000000*8/90;
        if ii>10
            % Northern Hemispere
            yutm1=(ii-11)*dy;
            yutm2=yutm1+dy;
        else
            % Southern Hemispere
            yutm1=(ii-11)*dy+10000000;
            yutm2=(ii-10)*dy+10000000;
        end
        xutm1=0;
        xutm2=1000000;
        handles.ScreenParameters.XMaxRange=[-2000000 3000000];
        handles.ScreenParameters.YMaxRange=[-2000000 10000000];
        if yl1(1)<yutm1 || yl1(1)>yutm2 || yl1(2)<yutm1 || yl1(2)>yutm2
            yl1(1)=yutm1;
            yl1(2)=yutm2;
        end
        if xl1(1)<xutm1 || xl1(1)>xutm2 || xl1(2)<xutm1 || xl1(2)>xutm2
            xl1(1)=xutm1;
            xl1(2)=xutm2;
        end
    otherwise
        handles.ScreenParameters.XMaxRange=[-2000000 2000000];
        handles.ScreenParameters.YMaxRange=[0 2000000];
end

[xl,yl]=CompXYLim(xl1,yl1,handles.ScreenParameters.XMaxRange,handles.ScreenParameters.YMaxRange);

handles.ScreenParameters.XLim=xl;
handles.ScreenParameters.YLim=yl;

set(gca,'XLim',xl,'YLim',yl);

setHandles(handles);


%% Source Bathymetry
ddb_updateDataInScreen;
handles=getHandles;

% Models
for i=1:length(handles.Model)
    f=handles.Model(i).CoordConvertFcn;
    try
        handles=f(handles);
    end
end

% Toolboxes
for i=1:length(handles.Toolbox)
    f=handles.Toolbox(i).CoordConvertFcn;
    try
        handles=f(handles);
    end
end

setHandles(handles);
