function [seltype,selnr]=ui_type(Title,types,deftype),
% UI_TYPE 
%          SelectedType=
%             UI_TYPE(Title,Types)
%             UI_TYPE(Title,Types,DefaultType)

XX.Clr.LightGray=[.8 .8 .8];
XX.Clr.White=[1 1 1];

XX.Margin=10;
XX.Txt.Height=18;
XX.But.Height=20;
XX.Slider=20;

if (nargin==2) & ishandle(Title) & strcmp(types,'resize'),
  fig=Title;
  FP=get(fig,'position');
  Fig_Width=FP(3);
  Fig_Height=FP(4);
  ListWidth=max(40,Fig_Width-2*XX.Margin);
  ListHeight=max(2*XX.Txt.Height,Fig_Height-(3*XX.Margin+XX.Txt.Height+XX.But.Height));
  Fig_Width=ListWidth+2*XX.Margin;
  Fig_Height=ListHeight+3*XX.Margin+XX.Txt.Height+XX.But.Height;
  FP(3)=Fig_Width;
  FP(2)=FP(2)+FP(4)-Fig_Height;
  FP(4)=Fig_Height;
  set(fig,'position',FP)
  
  cancel=findobj(fig,'string','cancel');
  rect = [XX.Margin XX.Margin (Fig_Width-3*XX.Margin)/2 XX.But.Height];
  set(cancel,'position',rect)
  
  contin=findobj(fig,'string','continue');
  rect(1) = (Fig_Width+XX.Margin)/2;
  set(contin,'position',rect)
  
  listbx=findobj(fig,'tag','listbox');
  rect(1) = XX.Margin;
  rect(2) = rect(2)+rect(4)+XX.Margin;
  rect(3) = Fig_Width-2*XX.Margin;
  rect(4) = ListHeight;
  set(listbx,'position',rect)
  
  uitext=findobj(fig,'string','select ...');
  rect(2) = rect(2)+rect(4);
  rect(4) = XX.Txt.Height;
  set(uitext,'position',rect)
  
  return;
end;

seltype='';
selnr=[];

switch nargin,
case 2, % =UI_TYPE(Title,Types)
  deftype='';
case {0,1},
  warning('Incorrect number of input arguments.');
  return;
case 3, % =UI_TYPE(Title,Types,DefaultType)
end;

if ischar(types),
  types=cellstr(types);
elseif iscellstr(types),
else,
  warning('Invalid list supplied.');
  return;
end;

if isempty(types), % nothing to be selected
  return;
end;


Fig_Width=300;
Fig_Height=300;
ListWidth=Fig_Width-2*XX.Margin;
ListHeight=Fig_Height-(3*XX.Margin+XX.Txt.Height+XX.But.Height);

ss = get(0,'ScreenSize');
swidth = ss(3);
sheight = ss(4);
left = (swidth-Fig_Width)/2;
bottom = (sheight-Fig_Height)/2;
rect = [left bottom Fig_Width Fig_Height];

fig=figure('visible','off', ...
           'menu','none', ...
           'units','pixels', ...
           'color',XX.Clr.LightGray, ...
           'renderer','zbuffer', ...
           'inverthardcopy','off', ...
           'closerequestfcn','', ...
           'integerhandle','off', ...
           'numbertitle','off', ...
           'handlevisibility','off', ...
           'tag','IDEAS - GUI', ...
           'defaultuicontrolbackgroundcolor',XX.Clr.LightGray, ...
           'resize','on', ...
           'resizefcn','ui_type(gcbo,''resize'')', ...
           'position',rect, ...
           'name',Title);

rect = [XX.Margin XX.Margin (Fig_Width-3*XX.Margin)/2 XX.But.Height];
uicontrol('style','pushbutton', ...
          'position',rect, ...
          'string','cancel', ...
          'parent',fig, ...
          'callback','set(gcbf,''userdata'',-1)');

rect(1) = (Fig_Width+XX.Margin)/2;
uicontrol('style','pushbutton', ...
          'position',rect, ...
          'string','continue', ...
          'parent',fig, ...
          'callback','set(gcbf,''userdata'',0)');

rect(1) = XX.Margin;
rect(2) = rect(2)+rect(4)+XX.Margin;
rect(3) = Fig_Width-2*XX.Margin;
rect(4) = ListHeight;
ListBox=uicontrol('style','listbox', ...
          'position',rect, ...
          'parent',fig, ...
          'string',types, ...
          'backgroundcolor',XX.Clr.White, ...
          'callback',['set(gcbf,''userdata'',1)'], ...
          'tag','listbox', ...
          'enable','on');
default=strmatch(deftype,types,'exact');
if ~isempty(default),
  if length(default(:))>1,
    default=default(1);
  end;
  set(ListBox,'value',default);
end;


rect(2) = rect(2)+rect(4);
rect(4) = XX.Txt.Height;
uicontrol('style','text', ...
          'position',rect, ...
          'horizontalalignment','left', ...
          'string','select ...', ...
          'parent',fig);

set(fig,'visible','on');
while 1,
  waitfor(fig,'userdata');
  Cmd=get(fig,'userdata');
  set(fig,'userdata',[]);
  switch Cmd,
  case -1, % cancel
    break;
  case 0, % continue
    selnr=get(ListBox,'value');
    seltype=types{selnr};
    break;
  case 1, % listbox
    % nothing to do
  end;
end;
delete(fig);