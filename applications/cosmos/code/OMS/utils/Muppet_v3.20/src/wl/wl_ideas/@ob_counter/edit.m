function AcceptPressed=edit(Obj),
AcceptPressed=0;
CanLinkObjNm={'surface','trisurface'};

% define options
CntrTypes={'none','counter','analog clock','digital clock','calendar'};
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
H.CntrTLbl=uicontrol('style','text', ...
          'position',rect, ...
          'string','type', ...
          'horizontalalignment','left', ...
          'parent',fig, ...
          'enable','on');

rect=Offset+[LabelWidth+XX.Margin 2*XX.But.Height Part1Width-XX.Margin-LabelWidth XX.But.Height];
H.CntrType=uicontrol('style','popupmenu', ...
          'position',rect, ...
          'string',CntrTypes, ...
          'horizontalalignment','right', ...
          'backgroundcolor',XX.Clr.LightGray, ...
          'parent',fig, ...
          'enable','off', ...
          'callback','stackudf(gcbf,''CommandStack'',24)');

rect=Offset+[3*XX.Margin+Part1Width 2*XX.But.Height Part2Width XX.But.Height];
H.Vis=uicontrol('style','checkbox', ...
          'position',rect, ...
          'string','visible', ...
          'parent',fig, ...
          'value',0, ...
          'enable','off', ...
          'callback','stackudf(gcbf,''CommandStack'',25)');

rect=Offset+[0 XX.But.Height LabelWidth XX.Txt.Height];
H.TRef=uicontrol('style','text', ...
          'position',rect, ...
          'string','reference', ...
          'horizontalalignment','left', ...
          'parent',fig, ...
          'enable','on');

rect=Offset+[LabelWidth+XX.Margin XX.But.Height LabelWidth XX.But.Height];
H.VRef=uicontrol('style','edit', ...
          'position',rect, ...
          'string','', ...
          'horizontalalignment','right', ...
          'backgroundcolor',XX.Clr.LightGray, ...
          'parent',fig, ...
          'enable','off', ...
          'callback','stackudf(gcbf,''CommandStack'',3)');

rect=Offset+[TextWidth+LabelWidth+4*XX.Margin XX.But.Height LabelWidth XX.Txt.Height];
H.TMax=uicontrol('style','text', ...
          'position',rect, ...
          'string','maximum', ...
          'horizontalalignment','left', ...
          'parent',fig, ...
          'enable','on');

rect=Offset+[TextWidth+2*LabelWidth+5*XX.Margin XX.But.Height LabelWidth XX.But.Height];
H.VMax=uicontrol('style','edit', ...
          'position',rect, ...
          'string','', ...
          'horizontalalignment','right', ...
          'backgroundcolor',XX.Clr.LightGray, ...
          'parent',fig, ...
          'enable','off', ...
          'callback','stackudf(gcbf,''CommandStack'',4)');

rect=Offset+[TextWidth+LabelWidth+4*XX.Margin 0 LabelWidth XX.Txt.Height];
H.TMin=uicontrol('style','text', ...
          'position',rect, ...
          'string','minimum', ...
          'horizontalalignment','left', ...
          'parent',fig, ...
          'enable','on');

rect=Offset+[TextWidth+2*LabelWidth+5*XX.Margin 0 LabelWidth XX.But.Height];
H.VMin=uicontrol('style','edit', ...
          'position',rect, ...
          'string','', ...
          'horizontalalignment','right', ...
          'backgroundcolor',XX.Clr.LightGray, ...
          'parent',fig, ...
          'enable','off', ...
          'callback','stackudf(gcbf,''CommandStack'',5)');

H.Tab=add(H.Tab,'general',[H.CntrTLbl H.CntrType H.Vis H.TRef H.VRef H.TMax H.TMin H.VMax H.VMin]);

% ---

rect=Offset+[0 2*XX.But.Height LabelWidth XX.Txt.Height];
H.Link=uicontrol('style','pushbutton', ...
          'position',rect, ...
          'string','link ...', ...
          'horizontalalignment','left', ...
          'parent',fig, ...
          'enable','on', ...
          'callback','stackudf(gcbf,''CommandStack'',6)');

rect=Offset+[LabelWidth+XX.Margin 2*XX.But.Height Part1Width-XX.Margin-LabelWidth XX.But.Height];
H.LinkName=uicontrol('style','edit', ...
          'position',rect, ...
          'string','', ...
          'horizontalalignment','left', ...
          'backgroundcolor',XX.Clr.LightGray, ...
          'parent',fig, ...
          'enable','inactive');

H.Tab=add(H.Tab,'link',[H.Link H.LinkName]);

%--

% initialize edit figure

CType=strmatch(Info.CounterType,CntrTypes);
if ~isempty(CType),
  set(H.CntrType,'value',CType,'backgroundcolor',XX.Clr.White,'enable','on');
end;
set(H.Vis,'value',Info.Visible,'enable','on');

switch Info.CounterType,
case 'none',
  Info.Visible=0;
  set(H.Vis,'value',0,'enable','off');
  set([H.VMin H.VMax H.VRef],'string','');
  set([H.TMin H.VMin H.TMax H.VMax H.TRef H.VRef], ...
    'enable','off', ...
    'backgroundcolor',XX.Clr.LightGray);
otherwise,
  set(H.VRef,'string',num2str(Info.Reference));
  set(H.VMax,'string',num2str(Info.Maximum));
  set(H.VMin,'string',num2str(Info.Minimum));
  set([H.TMin H.VMin H.TMax H.VMax H.TRef H.VRef], ...
    'enable','on');
  set([H.VMin H.VMax H.VRef], ...
    'backgroundcolor',XX.Clr.White);
end;
if ~isempty(Info.Link),
  ObjHandles=handles(ob_ideas(Info.Link));
  if isempty(ObjHandles),
    Info.Link=[];
    Info.OldLink=[];
  else,
    LinkUD=get(ObjHandles,'userdata');
    set(H.LinkName,'backgroundcolor',XX.Clr.White,'string',LinkUD.Name);
  end;
end;

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
      UD=get(MainItem,'userdata');
      Info=UD.Info;
    case 2, % accept
      AcceptPressed=1;
      UD.Info=Info;
      UD.Name=UD.Info.Name;
      set(MainItem,'userdata',UD);
      set(fig,'pointer','watch');
      refresh(Obj);
      set(fig,'pointer','arrow');
      gui_quit=1;
    case 3, % reference
      Reference=eval(get(H.VRef,'string'),'Info.Reference');
      if isnumeric(Reference) & isequal(size(Reference),[1 1]) & isfinite(Reference),
        Info.Reference=Reference;
      elseif isnumeric(Reference) & isequal(size(Reference),[1 6]) & isfinite(Reference),
        Info.Reference=datenum(Reference(1),Reference(2),Reference(3),Reference(4),Reference(5),Reference(6));
      end;
      set(H.VRef,'string',num2str(Info.Reference));
    case 4, % maximum
      Maximum=eval(get(H.VMax,'string'),'Info.Maximum');
      if isnumeric(Maximum) & isequal(size(Maximum),[1 1]) & ~isnan(Maximum),
        Info.Maximum=Maximum;
      end;
      set(H.VMax,'string',num2str(Info.Maximum));
    case 5, % minimum
      Minimum=eval(get(H.VMin,'string'),'Info.Minimum');
      if isnumeric(Minimum) & isequal(size(Minimum),[1 1]) & ~isnan(Minimum),
        Info.Minimum=Minimum;
      end;
      set(H.VMin,'string',num2str(Info.Minimum));
    case 6, % select link object
      AllItems=handles(ob_ideas(Obj));
      ObjFig=AllItems(1);
      while ~strcmp(get(ObjFig,'type'),'figure'),
        ObjFig=get(ObjFig,'parent');
      end;
      AllItems=findobj(allchild(ObjFig));
      AllItems=AllItems(strmatch('IDEAS',get(AllItems,'tag')));
      AllItems=get(AllItems,'userdata');
      if ~iscell(AllItems), AllItems={AllItems}; end;
      Objs=[];
      ObjNm={};
      for i=1:length(AllItems),
        if ~isempty(AllItems{i}),
          if isempty(Objs),
            Objs=AllItems{i}.Object;
            ObjNm={AllItems{i}.Name};
          else,
            Objs(end+1)=AllItems{i}.Object;
            ObjNm{end+1}=AllItems{i}.Name;
          end;
        end;
      end;
      Types=type(Objs);
      CanLink=ismember(Types,CanLinkObjNm);
      Objs=Objs(CanLink);
      ObjNm=ObjNm(CanLink);
      [Name,nr]=ui_type('object',ObjNm);
      if ~isempty(Name),
        Info.Link=Objs(nr);
        set(H.LinkName,'string',ObjNm{nr}, ...
            'backgroundcolor',XX.Clr.White);
      end;
    case 24, % type
      Info.CounterType=CntrTypes{get(H.CntrType,'value')};
      switch Info.CounterType,
      case 'none',
        Info.Visible=0;
        set(H.Vis,'value',0,'enable','off');
        set([H.VMin H.VMax H.VRef],'string','');
        set([H.TMin H.VMin H.TMax H.VMax H.TRef H.VRef],'enable','off');
        set([H.VMin H.VMax H.VRef],'backgroundcolor',XX.Clr.LightGray);
      otherwise,
        Info.Visible=1;
        set(H.Vis,'value',1,'enable','on');
        set(H.VRef,'string',num2str(Info.Reference));
        set(H.VMax,'string',num2str(Info.Maximum));
        set(H.VMin,'string',num2str(Info.Minimum));
        set([H.TMin H.VMin H.TMax H.VMax H.TRef H.VRef],'enable','on');
        set([H.VMin H.VMax H.VRef],'backgroundcolor',XX.Clr.White);
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