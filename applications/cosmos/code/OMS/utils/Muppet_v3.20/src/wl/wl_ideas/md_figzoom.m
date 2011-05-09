function Out=md_figzoom(cmd,fig),
% md_figzoom creates a menu

if nargin==0,
  fig=get(0,'children');
  if isempty(fig),
    return;
  end;
  fig=gcf;
  cmd='initialize';
elseif ~ischar(cmd),
  fig=cmd;
  if isempty(fig),
    fig=get(0,'children');
    if isempty(fig),
      return;
    end;
    fig=gcf;
  end;
  cmd='initialize';
end;

switch cmd,
case 'initialize',
  if ~ishandle(fig),
    return;
  end;
  UIM=findobj(fig,'tag','md_figzoom main');
  if ~isempty(UIM),
    if nargout>0, Out=UIM; end;
    return;
  end;
  UIM=uimenu('parent',fig,'label','Figure &zoom','tag','md_figzoom main');
  uimenu('parent',UIM,'label','&suspend','enable','on','checked','on','callback','md_figzoom suspend');
  uimenu('parent',UIM,'label','&move','enable','off','separator','on','checked','off','callback','md_figzoom menu');
  uimenu('parent',UIM,'label','&zoom','enable','off','separator','off','checked','on','callback','md_figzoom menu');
  uimenu('parent',UIM,'label','zoom &out','enable','off','separator','off','checked','off','callback','md_figzoom menu');
  uimenu('parent',UIM,'label','&reset','enable','off','separator','off','checked','off','callback','md_figzoom menu');
  uimenu('parent',UIM,'label','&done','enable','off','separator','on','callback','md_figzoom menu');

  figmov.wbuf = '';
  figmov.wbdf = '';
  figmov.wbmf = '';
  figmov.bdf  = '';
  figmov.ViewList = [0 0 1 1];
  set(UIM,'userdata',figmov);

  if nargout>0, Out=UIM; end;

case 'is suspended',
  Out=1;
  if nargin<2,
    fig=gcbf;
  end;
  UIM=findobj(fig,'tag','md_figzoom main');
  if isempty(UIM), return; end;
  SuspendMenu=findobj(UIM,'label','&suspend');
  switch get(SuspendMenu,'checked'),
  case 'off',
    Out=0;
  case 'on',
    Out=1;
  end;

case 'suspend',
  if nargin<2,
    fig=gcbf;
  end;
  UIM=findobj(fig,'tag','md_figzoom main');
  if isempty(UIM), return; end;
  figmov=get(UIM,'userdata');
  SuspendMenu=findobj(UIM,'label','&suspend');
  switch get(SuspendMenu,'checked'),
  case 'off',
    set(fig,'WindowButtonUpFcn',    figmov.wbuf);
    set(fig,'WindowButtonDownFcn',  figmov.wbdf);
    set(fig,'WindowButtonMotionFcn',figmov.wbmf);
    set(fig,'ButtonDownFcn',        figmov.bdf);
    set(allchild(UIM),'enable','off');
    set(SuspendMenu,'checked','on','enable','on');
  case 'on',
    if ~md_camera('is suspended',fig),
      md_camera('suspend',fig);
    end;
    figmov.wbuf = get(fig,'WindowButtonUpFcn');
    figmov.wbdf = get(fig,'WindowButtonDownFcn');
    figmov.wbmf = get(fig,'WindowButtonMotionFcn');
    figmov.bdf  = get(fig,'ButtonDownFcn');
    set(UIM,'userdata',figmov);
  
    set(fig,'WindowButtonDownFcn','md_figzoom down');
    set(fig,'WindowButtonUpFcn'  ,'');
    set(fig,'WindowButtonMotionFcn','');
    set(fig,'ButtonDownFcn','');
    set(SuspendMenu,'checked','off');
    set(allchild(UIM),'enable','on');
  end;

case 'menu',
  cmd=get(gcbo,'label');
  switch cmd,
  case '&reset',
    UIM=get(gcbo,'parent');
    figmov=get(UIM,'userdata');
    CurView = figmov.ViewList(1,:);
    remapfig([0 0 1 1],CurView,gcbf);
    figmov.ViewList=[0 0 1 1];
    set(UIM,'userdata',figmov);
  case '&done',
    UIM=get(gcbo,'parent');
    figmov=get(UIM,'userdata');
    set(gcbf,'WindowButtonUpFcn',    figmov.wbuf);
    set(gcbf,'WindowButtonDownFcn',  figmov.wbdf);
    set(gcbf,'WindowButtonMotionFcn',figmov.wbmf);
    set(gcbf,'ButtonDownFcn',        figmov.bdf);
    CurView = figmov.ViewList(1,:);
    remapfig([0 0 1 1],CurView,gcbf);
    delete(UIM);
  otherwise,
    set(findobj(get(gcbo,'parent')),'checked','off');
    set(gcbo,'checked','on');
%    uiwait(msgbox(['unknown menu: ' cmd],'modal'));
  end;

case 'down',
  fig = get(0,'PointerWindow');
  UIM=findobj(fig,'tag','md_figzoom main');
  Checked=findobj(allchild(UIM),'flat','checked','on');
  cmd=get(Checked,'label');

  figmov=get(UIM,'userdata');

  if strcmp(get(fig,'selectiontype'),'alt'), % UNDO LAST
    if size(figmov.ViewList,1)==1, % In main view
      xx_beep;
      return;
    end;
    CurView = figmov.ViewList(1,:);
    NewView = figmov.ViewList(2,:);
    remapfig([0 0 1 1],CurView,fig);
    remapfig(NewView,[0 0 1 1],fig);
    figmov.ViewList(1,:)=[];
    set(UIM,'userdata',figmov);
    return;
  end;

  if ~strcmp(get(fig,'selectiontype'),'normal'), % CATCH ALL OTHER BUTTONS
    return;
  end;

  switch cmd,
  case '&move',
    TempUnits=get(fig,'units');
    set(fig,'units','pixels');
    Pos = get(fig,'position');

    TempPoint=get(fig,'pointer');
    TempHVis=get(fig,'handlevisibility');
    set(fig,'pointer','fleur','handlevisibility','on');
    Rect = dragrect([0 0 Pos(3:4)]);
    set(fig,'pointer',TempPoint,'handlevisibility',TempHVis);
    Rect = [-Rect(1:2)./Pos(3:4) 1 1];

    CurView = figmov.ViewList(1,:);
    NewView = [CurView(1)+CurView(3)*Rect(1) CurView(2)+CurView(4)*Rect(2) CurView(3)*Rect(3) CurView(4)*Rect(4)];
    remapfig([0 0 1 1],CurView,fig);
    remapfig(NewView,[0 0 1 1],fig);
    figmov.ViewList=[NewView; figmov.ViewList];

    set(fig,'units',TempUnits);
  case '&zoom',
    TempUnits=get(fig,'units');
    set(fig,'units','normalized');
    Point=get(fig,'currentpoint');

    TempHVis=get(fig,'handlevisibility');
    set(fig,'handlevisibility','on');
    Rect = rbbox([Point 0 0]);
    set(fig,'handlevisibility',TempHVis);
    Rect(3:4)=max(Rect(3:4));
    if Rect(3)<0.01,
      Rect=[max(min(Rect(1:2)-0.25,0.5),0) 0.5 0.5];
    end;
    CurView = figmov.ViewList(1,:);
    NewView = [CurView(1)+CurView(3)*Rect(1) CurView(2)+CurView(4)*Rect(2) CurView(3)*Rect(3) CurView(4)*Rect(4)];
    remapfig([0 0 1 1],CurView,fig);
    remapfig(NewView,[0 0 1 1],fig);
    figmov.ViewList=[NewView; figmov.ViewList];

    set(fig,'units',TempUnits);
  case 'zoom &out',
    TempUnits=get(fig,'units');
    set(fig,'units','normalized');
    Point=get(fig,'currentpoint'); % new center when zoomed out (if possible)

    if size(figmov.ViewList,1)==1, % In main view
      xx_beep;
      return;
    end;
    CurView = figmov.ViewList(1,:);
    Point=CurView(1:2)+Point.*CurView(3:4);
    i=2;
    NewView = figmov.ViewList(i,:);
    while any(NewView(3:4)<=CurView(3:4)) & (i<size(figmov.ViewList,1)),
      i=i+1;
      NewView = figmov.ViewList(i,:);
    end;
    if (i==size(figmov.ViewList,1)) & any(NewView(3:4)<=CurView(3:4)), % nothing appropriate found
      xx_beep;
      return;
    end;
    NewView(1:2)=min(max(0,Point-NewView(3:4)/2),1-NewView(3:4));
    remapfig([0 0 1 1],CurView,fig);
    remapfig(NewView,[0 0 1 1],fig);
    figmov.ViewList=[NewView; figmov.ViewList];

    set(fig,'units',TempUnits);
  end;

  set(UIM,'userdata',figmov);

otherwise,
  uiwait(msgbox(['unknown command: ' cmd],'modal'));

end;