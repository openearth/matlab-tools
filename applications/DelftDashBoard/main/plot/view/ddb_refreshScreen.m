function ddb_refreshScreen(varargin)

handles=getHandles;

clearInstructions;

if nargin==1
    tabpanel('delete','tag','tabpanel2');
    handles.screenParameters.activeTab=varargin{1};
    handles.screenParameters.activeSecondTab='';
elseif nargin==2
    handles.screenParameters.activeTab=varargin{1};
    handles.screenParameters.activeSecondTab=varargin{2};
end
setHandles(handles);

h=findobj(gcf,'Tag','UIControl');
if ~isempty(h)
    delete(h);
end
%drawnow;

ddb_setWindowButtonUpDownFcn;
ddb_setWindowButtonMotionFcn;
set(gcf, 'KeyPressFcn',[]);
set(gcf, 'Pointer', 'arrow');
ddb_zoomOff;

for j=1:length(handles.Model)
    f=handles.Model(j).plotFcn;
    feval(f,handles,'update',2,ad);
end

for j=1:length(handles.Toolbox)
    f=handles.Toolbox(j).plotFcn;
    feval(f,handles,'deactivate');
end
