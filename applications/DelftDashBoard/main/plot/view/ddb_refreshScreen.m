function ddb_refreshScreen(varargin)

handles=getHandles;

if nargin==1
    tabpanel(gcf,'tabpanel2','delete');
    handles.ScreenParameters.ActiveTab=varargin{1};
    handles.ScreenParameters.ActiveSecondTab='';
elseif nargin==2
    handles.ScreenParameters.ActiveTab=varargin{1};
    handles.ScreenParameters.ActiveSecondTab=varargin{2};
end
setHandles(handles);

h=findobj(gcf,'Tag','UIControl');
if ~isempty(h)
    delete(h);
end

ddb_setWindowButtonUpDownFcn;
ddb_setWindowButtonMotionFcn;
set(gcf, 'KeyPressFcn',[]);
set(gcf, 'Pointer', 'arrow');
ddb_zoomOff;

for j=1:length(handles.Model)
    f=handles.Model(j).PlotFcn;
    feval(f,handles,'deactivate');
end

for j=1:length(handles.Toolbox)
    f=handles.Toolbox(j).PlotFcn;
    feval(f,handles,'deactivate');
end
