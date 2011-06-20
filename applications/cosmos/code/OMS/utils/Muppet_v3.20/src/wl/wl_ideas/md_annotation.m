function it=md_annotation(cmd,varargin),

if nargout>0,
  it=[];
end;
AnnotHandle=[];
if nargin==0,
  error('One input argument expected: handle of figure or axes.');
elseif ~ischar(cmd),
  if nargin>1,
    it=Local_create_annotation(cmd,varargin{:});
    return;
  end;
  if ~ishandle(cmd),
    error('Handle of figure or axes expected as argument.');
  else,
    switch get(cmd,'type'),
    case 'figure',
      AnnotHandle=findobj(fig,'tag','annotation layer');
      if isempty(AnnotHandle),
        warning('No annotation layer found in specified figure.');
        % OPTION: Create an annotation layer?
        return;
      end;
    case 'axes',
      AnnotHandle=cmd;
    otherwise,
      error('Handle of figure or axes expected as argument.');
    end;
    cmd='initialize';
  end;
else, % ischar(cmd)
  if isempty(gcbf),
    error('Handle of figure or axes expected as argument.');
  end;
end;

itoptions=[];
itoptions.Editable=1;
itoptions.Name='[unknown item]';
itoptions.Animation=[];
itoptions.UserData=[];

if ~isempty(AnnotHandle),
  fig=get(AnnotHandle(1),'parent');
elseif ~isempty(gcbf),
  fig=gcbf;
end;

%disp(['<',cmd,'>'])

switch cmd,
case 'initialize',
  UIM=findobj(fig,'tag','md_annotation annotation uimenu');
  if ~isempty(UIM),
    uiwait(msgbox('Annotation menu is already active.','modal'));
    return;
  end;
  UIM=uimenu('parent',fig,'label','&Annotation','tag','md_annotation annotation uimenu');
  uimenu('parent',UIM,'label','new &line','checked','on','callback','md_annotation menu');
  AnnotationOptions.New='line';
  uimenu('parent',UIM,'label','new &patch','checked','off','callback','md_annotation menu');
  uimenu('parent',UIM,'label','new &text','checked','off','callback','md_annotation menu');
  uimenu('parent',UIM,'label','&done','separator','on','checked','off','callback','md_annotation menu');

  AnnotationOptions.AnnotationList = AnnotHandle;
  AnnotationOptions.ActiveAnnotation = AnnotHandle(1);
  AnnotationOptions.wbuf    = get(fig,'WindowButtonUpFcn');
  AnnotationOptions.wbdf    = get(fig,'WindowButtonDownFcn');
  AnnotationOptions.wbmf    = get(fig,'WindowButtonMotionFcn');
  AnnotationOptions.bdf     = get(fig,'ButtonDownFcn');
  AnnotationOptions.pointer = get(fig,'Pointer');
  set(UIM,'userdata',AnnotationOptions);

  set(fig,'WindowButtonDownFcn','md_annotation new');
  set(fig,'WindowButtonUpFcn'  ,'');
  set(fig,'WindowButtonMotionFcn','');
  set(fig,'ButtonDownFcn','');
  set(fig,'Pointer','fullcrosshair');

case 'menu',
  cmd=get(gcbo,'label');
  switch cmd,
  case '&done',
    UIM=get(gcbo,'parent');
    AnnotationOptions=get(UIM,'userdata');
    set(gcbf,'WindowButtonUpFcn',    AnnotationOptions.wbuf);
    set(gcbf,'WindowButtonDownFcn',  AnnotationOptions.wbdf);
    set(gcbf,'WindowButtonMotionFcn',AnnotationOptions.wbmf);
    set(gcbf,'ButtonDownFcn',        AnnotationOptions.bdf);
    set(gcbf,'Pointer',              AnnotationOptions.pointer);
    delete(UIM);
  case {'new &line','new &patch','new &text'}
    UIM=get(gcbo,'parent');
    AnnotationOptions=get(UIM,'userdata');
    AnnotationOptions.New=cmd(6:end);
    set(UIM,'userdata',AnnotationOptions);
    set(findobj(get(gcbo,'parent')),'checked','off');
    set(gcbo,'checked','on');
  otherwise,
    uiwait(msgbox(['Unknown menu option: ',cmd,'.'],'modal'));
  end;

case 'new',
  UIM=findobj(fig,'tag','md_annotation annotation uimenu');
  AnnotationOptions=get(UIM,'userdata');
  AnnotHandle=AnnotationOptions.ActiveAnnotation;
  if isempty(AnnotHandle),
    return;
  end;
  TempPointer=get(fig,'pointer');
  TempHVis=get(fig,'handlevisibility');
  set(fig,'windowbuttondownfcn','', ...
          'handlevisibility','on');
  %  axes(AnnotHandle);
  switch AnnotationOptions.New,
  case 'line',
    NumPoints=0;
    while 1,
      X=get(AnnotHandle,'currentpoint');
      X=X(1,1:2);
      if strcmp(get(fig,'selectiontype'),'normal'),
        if NumPoints==0,
          Line=line(X(1),X(2), ...
            'parent',AnnotHandle, ...
            'marker','.', ...
            'tag','TMP Annot Line', ...
            'erasemode','xor', ...
            'clipping','off');
        else,
          Line=findobj(AnnotHandle,'tag','TMP Annot Line');
          XData=get(Line,'xdata');
          YData=get(Line,'ydata');
          set(Line,'xdata',[XData X(1)],'ydata',[YData X(2)]);
        end;
        NumPoints=NumPoints+1;
      else,
        break;
      end;
      waitforbuttonpress;
    end;
    if NumPoints>0,
      Line=findobj(AnnotHandle,'tag','TMP Annot Line');
      itoptions.Name='line';
      itoptions.Type='line';
      set(Line,'tag',num2hex(Line),'erasemode','normal','userdata',itoptions);
      try, gc(Line); end;
    end;
    set(fig,'windowbuttondownfcn','md_annotation new', ...
      'handlevisibility',TempHVis);
  case 'patch',
    NumPoints=0;
    while 1,
      X=get(AnnotHandle,'currentpoint');
      X=X(1,1:2);
      if strcmp(get(fig,'selectiontype'),'normal'),
        if NumPoints==0,
          Patch=patch(X(1),X(2),1, ...
            'facecolor','none', ...
            'parent',AnnotHandle, ...
            'marker','.', ...
            'tag','TMP Annot Patch', ...
            'erasemode','xor', ...
            'clipping','off');
        else,
          Patch=findobj(AnnotHandle,'tag','TMP Annot Patch');
          XData=get(Patch,'xdata');
          YData=get(Patch,'ydata');
          set(Patch,'xdata',[XData;X(1)],'ydata',[YData;X(2)]);
        end;
        NumPoints=NumPoints+1;
      else,
        break;
      end;
      waitforbuttonpress;
    end;
    if NumPoints>0,
      Patch=findobj(AnnotHandle,'tag','TMP Annot Patch');
      itoptions.Name='patch';
      itoptions.Type='patch';
      set(Patch,'tag',num2hex(Patch),'erasemode','normal','userdata',itoptions);
      try, gc(Patch); end;
    end;
    set(fig,'windowbuttondownfcn','md_annotation new', ...
      'handlevisibility',TempHVis);
  case 'text',
    X=get(AnnotHandle,'currentpoint');
    X=X(1,1:2);
    Str=inputdlg({'string:'},'input',1,{''});
    if isempty(Str), % cancel pressed?
      return;
    end;
    itoptions.Name=['text: ',Str{1}];
    itoptions.Type='text';
    Text=text(X(1),X(2),Str(1), ...
      'parent',AnnotHandle, ...
      'erasemode','normal', ...
      'clipping','off', ...
      'userdata',itoptions, ...
      'tag','TMP Annot Text'); % assign cell to string for best alignment when editing multiple lines
    set(Text,'tag',num2hex(Text));
    try, gc(Text); end;
  otherwise,
    uiwait(msgbox(['Don''t know how to create a new ',AnnotationOptions.New,'.'],'modal'));
  end;
  set(fig,'windowbuttondownfcn','md_annotation new', ...
    'handlevisibility',TempHVis);
otherwise,
  uiwait(msgbox(['Unknown command: ',cmd],'modal'));
end;


function it=Local_create_annotation(ax,itoptions,CommandStruct);
% LOCAL_CREATE_ANNOTATION is an interface for the annotation layer
%
%      Two different calls to this function can be expected:
% 
%      1. it=...(Axes,ItemOptionsDefault)
%         To create the item interactively
%      2. it=...(Axes,ItemOptionsDefault,CommandStruct)
%         To create the item from a scriptfile
%
%      Annotation objects cannot be animated.

it=[];

uiwait(msgbox({'Not implemented yet.','Select the ''add annotation item'' option from ''edit axes'' menu'},'modal'));
return;

if nargin==2, % Possibility 1: it=...(Axes,ItemOptionsDefault)
  Option=1;

  plottypes= ...
      {'text'                                   ;
       'line'                                   ;
       'patch'                                  };
  labels=str2mat(plottypes{:,1});
  itoptions.ReproData.Type=ui_type('object',labels);
  if isempty(itoptions.ReproData.Type),
    return;
  end;
else, % Possibility 2: it=...(Axes,ItemOptionsDefault,CommandStruct)
  Option=2;
  itoptions.ReproData=CommandStruct;
end;

switch(itoptions.ReproData.Type),
case 'text', % -------------------------------------------------------------------------------
  Str=inputdlg({'string:'},'input',1,{''});
  if isempty(Str), % cancel pressed?
    return;
  end;
  [x,y]=ginput3d(ax,'xy',1);
  it=text('parent',ax,'string',Str(1)); % assign cell to string for best alignment when editing multiple lines
  set(it,'tag',num2hex(it));
  itoptions.Name=['text: ',Str{1}];
  itoptions.Type='text';
  set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
  gui_text(it);
case 'line', % -------------------------------------------------------------------------------
  [x,y]=ginput3d(ax,'xy');
  it=line(x,y,'parent',ax);
  set(it,'tag',num2hex(it));
  itoptions.Name='line';
  itoptions.Type='line';
  set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
  gui_line(it);
case 'patch', % -------------------------------------------------------------------------------
  [x,y]=ginput3d(ax,'xy');
  it=patch(x,y,'k','parent',ax);
  set(it,'tag',num2hex(it));
  itoptions.Name='patch';
  itoptions.Type='patch';
  set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
  gui_patch(it);
end;
