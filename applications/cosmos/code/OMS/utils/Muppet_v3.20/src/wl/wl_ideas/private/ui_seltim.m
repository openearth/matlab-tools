function tnr=ui_seltim(timestr),
% UI_SELTIM
%          TimeNr=UI_SELTIM(TimeStr)

tnr=1;

if iscell(timestr),
  timestr=str2mat(timestr{:});
elseif ~ischar(timestr), % time vector;
  timestr=timestr(:); % make column vector
  timestr=datestr(timestr);
end;

if isempty(timestr), % nothing to be selected
  tnr=[];
  return;
elseif size(timestr,1)==1, % just one thing to be selected
  return;
end;

XX=xx_constants;

ListWidth=200;
ListHeight=100;
Fig_Width=ListWidth+2*XX.Margin;
Fig_Height=3*XX.Margin+ListHeight+1*XX.Txt.Height+1*XX.But.Height;

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
          'enable','off', ...
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
          'string',timestr, ...
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
    tnr=[];
    break;
  case 0, % continue
    tnr=get(ListBox,'value');
    break;
  case 1, % listbox
  end;
end;
delete(fig);