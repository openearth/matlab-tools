function [seltype,selname,selnr]=ui_typeandname(types,deftype,defname),
% UI_TYPEANDNAME 
%          [SelectedType,SelectedName,SelectedNr]
%             =UI_TYPEANDNAME(Types)
%             =UI_TYPEANDNAME(Types,DefaultType,DefaultName)

seltype='';
selname='';
selnr=[];

switch nargin,
case 1, % =UI_TYPEANDNAME(Types)
  deftype='';
  defname='';
case {0,2},
  warning('Incorrect number of input arguments.');
  return;
case 3, % =UI_TYPEANDNAME(Types,DefaultType,DefaultName)
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

XX=xx_constants;

ListWidth=200;
ListHeight=100;
Fig_Width=ListWidth+2*XX.Margin;
Fig_Height=4*XX.Margin+ListHeight+2*XX.Txt.Height+2*XX.But.Height;

ss = get(0,'ScreenSize');
swidth = ss(3);
sheight = ss(4);
left = (swidth-Fig_Width)/2;
bottom = (sheight-Fig_Height)/2;
rect = [left bottom Fig_Width Fig_Height];

fig=xx_ui_ini('position',rect);

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
Edit=uicontrol('style','edit', ...
          'position',rect, ...
          'horizontalalignment','left', ...
          'string',types{1}, ...
          'parent',fig, ...
          'backgroundcolor',XX.Clr.White, ...
          'callback','set(gcbf,''userdata'',2)');

rect(2) = rect(2)+rect(4);
rect(4) = XX.Txt.Height;
uicontrol('style','text', ...
          'position',rect, ...
          'horizontalalignment','left', ...
          'string','specify name ...', ...
          'parent',fig);

rect(2) = rect(2)+rect(4)+XX.Margin;
rect(4) = ListHeight;
ListBox=uicontrol('style','listbox', ...
          'position',rect, ...
          'parent',fig, ...
          'string',types, ...
          'backgroundcolor',XX.Clr.White, ...
          'callback',['set(gcbf,''userdata'',1)'], ...
          'enable','on');

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
    selname=get(Edit,'string');
    break;
  case 1, % listbox
    set(Edit,'string',types{get(ListBox,'value')});
  end;
end;
delete(fig);