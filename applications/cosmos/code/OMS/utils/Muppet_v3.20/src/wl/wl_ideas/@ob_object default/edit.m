function AcceptPressed=edit(Obj),
AcceptPressed=0;

% define options
% Colormaps=xx_colormap;
% TUnits={'days','hours','minutes','seconds'};
% TUnitsNum=[1 24 24*60 24*60*60];

AllItems=handles(ob_ideas(Obj));
MainItem=AllItems(1);

UD=get(MainItem,'userdata');
Info=UD.Info;

XX=xx_constants;

% define uicontrol sizes and figure size
Fig_Width=100;
Fig_Height=100;

ss = get(0,'ScreenSize');
swidth = ss(3);
sheight = ss(4);
left = (swidth-Fig_Width)/2;
bottom = (sheight-Fig_Height)/2;
rect = [left bottom Fig_Width Fig_Height];

fig=xx_ui_ini('position',rect);

Ax=axes( ...
   'units','pixels','position',[1 1 Fig_Width Fig_Height], ...
   'xlim',[0 Fig_Width-1],'ylim',[0 Fig_Height-1], ...
   'visible','off', ...
   'parent',fig);


rect = [XX.Margin XX.Margin (Fig_Width-4*XX.Margin)/3 XX.But.Height];
H.Cancel=uicontrol('style','pushbutton', ...
          'position',rect, ...
          'string','cancel', ...
          'parent',fig, ...
          'enable','on', ...
          'callback','stackudf(gcbf,''CommandStack'',0)');

rect(1) = rect(1)+rect(3)+XX.Margin;
H.Preview=uicontrol('style','togglebutton', ...
          'position',rect, ...
          'string','preview', ...
          'parent',fig, ...
          'enable','on', ...
          'callback','stackudf(gcbf,''CommandStack'',1)');

rect(1) = rect(1)+rect(3)+XX.Margin;
H.Accept=uicontrol('style','pushbutton', ...
          'position',rect, ...
          'string','accept', ...
          'parent',fig, ...
          'enable','on', ...
          'callback','stackudf(gcbf,''CommandStack'',2)');

% ---
% xx_border3d(min_x, ...
%         min_y, ...
%         width, ...
%         height, ...
%         'parent',Ax);

% create edit figure

% initialize edit figure

set(fig,'visible','on');
setudf(fig,'CommandStack',{});

gui_quit=0;
changed=0;
OrigInfo=Info;
while ~gui_quit,

  if ishandle(fig),
    if isempty(getudf(fig,'CommandStack')),
      waitforudf(fig,'CommandStack');
    end;
  end;
  if ishandle(fig),
    stack=getudf(fig,'CommandStack');
    setudf(fig,'CommandStack',{});
  else,
    uiwait(msgbox('Unexpected removal of Edit window!','modal'));
    gui_quit=1;
  end;

  while ~isempty(stack),
    Cmd=stack{1};
    stack=stack(2:size(stack,1),:);

    switch Cmd,
    case 0, % cancel
      if changed,
        UD.Info=OrigInfo;
        set(MainItem,'userdata',UD);
        set(fig,'pointer','watch');
        refresh(Obj);
        set(fig,'pointer','arrow');
      end;
      gui_quit=1;
    case 1, % preview
      changed=1;
      UD.Info=Info;
      set(MainItem,'userdata',UD);
      set(fig,'pointer','watch');
      refresh(Obj);
      set(fig,'pointer','arrow');
      set(H.Preview,'value',0);
    case 2, % accept
      AcceptPressed=1;
      UD.Info=Info;
      UD.Name=UD.Info.Name;
      set(MainItem,'userdata',UD);
      set(fig,'pointer','watch');
      refresh(Obj);
      set(fig,'pointer','arrow');
      gui_quit=1;
    case 3, % <other controls>
    case 27, % name
      Info.Name=get(H.Name,'string');
    otherwise,
      uiwait(msgbox(num2str(Cmd),'modal'));
    end;
  
  end;
end;
delete(fig);


function Str=StrFrames(N,Str1,Str2),
switch nargin,
case 1,
  Str1='frame';
  Str2='frames';
case 2,
  Str2=[Str1 's'];
end;
if N==1,
  Str=['1 ',Str1];
else,
  Str=[num2str(N) ' ' Str2];
end;