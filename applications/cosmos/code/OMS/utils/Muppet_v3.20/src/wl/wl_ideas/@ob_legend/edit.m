function AcceptPressed=edit(Obj),
AcceptPressed=0;

% define options
BrdrTypes={'none','line','text','line and text'};
% Colormaps=xx_colormap;
% TUnits={'days','hours','minutes','seconds'};
% TUnitsNum=[1 24 24*60 24*60*60];

AllItems=handles(ob_ideas(Obj));
MainItem=AllItems(1);

UD=get(MainItem,'userdata');
Info=UD.Info;

XX=xx_constants;

% define uicontrol sizes and figure size
LabelWidth=50;
EditButton=90;
TextWidth=90;

MinMaxWidth=20;
MinMaxEWidth=(EditButton-2*XX.Margin+TextWidth-2*MinMaxWidth)/2;

SmallWidth=50;
SEditWidth=50;

Part1Width=LabelWidth+EditButton+TextWidth+2*XX.Margin;
Part2Width=SmallWidth+SEditWidth+XX.Margin;
Fig_Width=Part1Width+Part2Width+7*XX.Margin;
Fig_Height=6*XX.Margin+5*XX.But.Height+20;

ss = get(0,'ScreenSize');
swidth = ss(3);
sheight = ss(4);
left = (swidth-Fig_Width)/2;
bottom = (sheight-Fig_Height)/2;
rect = [left bottom Fig_Width Fig_Height];

fig=xx_ui_ini('position',rect);

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

H.Tab=tabs(fig,[XX.Margin, ...
         2*XX.Margin+XX.But.Height, ...
         5*XX.Margin+Part1Width+Part2Width, ...
         3*XX.But.Height+2*XX.Margin+20]);


rect(1) = 2*XX.Margin;
rect(2) = 5*XX.Margin+4*XX.But.Height+20;
rect(3) = LabelWidth;
rect(4) = XX.Txt.Height;
uicontrol('style','text', ...
          'position',rect, ...
          'string','name', ...
          'horizontalalignment','left', ...
          'parent',fig, ...
          'enable','on');

rect(1) = rect(1)+rect(3)+XX.Margin;
rect(3) = Fig_Width-XX.Margin-rect(1);
rect(4) = XX.But.Height;
H.Name=uicontrol('style','edit', ...
          'position',rect, ...
          'string',Info.Name, ...
          'horizontalalignment','left', ...
          'backgroundcolor',XX.Clr.White, ...
          'parent',fig, ...
          'enable','on', ...
          'callback','stackudf(gcbf,''CommandStack'',26)');

XOffset=2*XX.Margin;
YOffset=3*XX.Margin+XX.But.Height;
Offset=[XOffset YOffset 0 0];


% ---

rect=Offset+[0 2*XX.But.Height LabelWidth XX.Txt.Height];
H.BrdrTLbl=uicontrol('style','text', ...
          'position',rect, ...
          'string','border', ...
          'horizontalalignment','left', ...
          'parent',fig, ...
          'enable','on');

rect=Offset+[LabelWidth+XX.Margin 2*XX.But.Height Part1Width-XX.Margin-LabelWidth XX.But.Height];
H.BrdrType=uicontrol('style','popupmenu', ...
          'position',rect, ...
          'string',BrdrTypes, ...
          'horizontalalignment','right', ...
          'backgroundcolor',XX.Clr.LightGray, ...
          'parent',fig, ...
          'enable','off', ...
          'callback','stackudf(gcbf,''CommandStack'',24)');

rect=Offset+[0 XX.But.Height LabelWidth XX.Txt.Height];
H.TextLbl=uicontrol('style','text', ...
          'position',rect, ...
          'string','text', ...
          'horizontalalignment','left', ...
          'parent',fig, ...
          'enable','off');

rect=Offset+[LabelWidth+XX.Margin XX.But.Height Part1Width-XX.Margin-LabelWidth XX.But.Height];
H.TextEd=uicontrol('style','edit', ...
          'position',rect, ...
          'string','', ...
          'horizontalalignment','left', ...
          'backgroundcolor',XX.Clr.LightGray, ...
          'parent',fig, ...
          'enable','off', ...
          'callback','stackudf(gcbf,''CommandStack'',23)');

rect=Offset+[3*XX.Margin+Part1Width 2*XX.But.Height Part2Width XX.But.Height];
H.Vis=uicontrol('style','checkbox', ...
          'position',rect, ...
          'string','visible', ...
          'parent',fig, ...
          'value',0, ...
          'enable','off', ...
          'callback','stackudf(gcbf,''CommandStack'',25)');

H.Tab=add(H.Tab,'general',[H.BrdrTLbl H.BrdrType H.TextLbl H.TextEd H.Vis]);

% ---

% initialize edit figure

BType=strmatch(Info.Border,BrdrTypes,'exact');
if ~isempty(BType),
  set(H.BrdrType,'value',BType,'backgroundcolor',XX.Clr.White,'enable','on');
  switch Info.Border,
  case {'text','line and text'},
    set(H.TextEd,'string',Info.BorderText,'backgroundcolor',XX.Clr.White,'enable','on');
    set(H.TextLbl,'enable','on');
  % otherwise % by default enable off
  end;
end;
set(H.Vis,'value',Info.Visible,'enable','on');


% process events

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
    case 3, % ...
    case 23, % bordertext
      Info.BorderText=get(H.TextEd,'string');
    case 24, % type
      Info.Border=BrdrTypes{get(H.BrdrType,'value')};
      switch Info.Border,
      case {'text','line and text'},
        set(H.TextEd,'string',Info.BorderText,'backgroundcolor',XX.Clr.White,'enable','on');
        set(H.TextLbl,'enable','on');
      otherwise,
        set(H.TextEd,'string',Info.BorderText,'backgroundcolor',XX.Clr.LightGray,'enable','off');
        set(H.TextLbl,'enable','off');
      end;
    case 25, % visible
      Info.Visible=get(H.Vis,'value');
    case 26, % name
      Info.Name=get(H.Name,'string');
    otherwise,
      uiwait(msgbox(num2str(Cmd),'modal'));
      keyboard
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