function winmngr(cmd)
% WINMNGR Windows manager

if nargin==0
   cmd='initialize';
end

H1=findobj(allchild(0),'tag','Window manager for Matlab (c)');
if isempty(H1),
   H1=ui_winmngr;
else
   figure(H1);
end

switch(lower(cmd))
case 'resize'
   sz=get(H1,'position');
   width=sz(3)-20;
   hwidth=(width-10)/2;
   height=sz(4);
   %
   obj=findobj(H1,'Tag','hvis');
   set(obj,'position',[10 height-30 hwidth 20])
   obj=findobj(H1,'Tag','print');
   set(obj,'position',[20+hwidth height-30 hwidth 20])
   %
   obj=findobj(H1,'Tag','delete');
   set(obj,'position',[10 height-50 hwidth 20])
   obj=findobj(H1,'Tag','edit');
   set(obj,'position',[20+hwidth height-50 hwidth 20])
   %
   obj=findobj(H1,'Tag','figlist');
   set(obj,'position',[10 55 width height-110])
   %
   obj=findobj(H1,'Tag','refresh');
   set(obj,'position',[10 30 width 20])
   %
   obj=findobj(H1,'Tag','close');
   set(obj,'position',[10 10 width 20])
case 'initialize'
   % nothing to do
case 'hvis',
  set(findobj(H1,'tag','hvis'),'Visible','on');
case 'listbox',
  if strcmp(get(H1,'selectiontype'),'open'),
    figlist=findobj(H1,'tag','figlist');
    options=get(figlist,'userdata');
    if isempty(options.fighandles),
      return;
    end;
    fig=get(figlist,'value');
    H=options.fighandles(fig(ishandle(options.fighandles(fig))));
    for i=1:length(H),
      figure(H(i));
    end;
    figure(H1);
  end;
case 'moveto',
  figlist=findobj(H1,'tag','figlist');
  options=get(figlist,'userdata');
  if isempty(options.fighandles),
    return;
  end;
  fig=get(figlist,'value');
  H=options.fighandles(fig(ishandle(options.fighandles(fig))));
  if isempty(H),
    winmngr refresh
    return;
  end;
  set(allchild(H1),'enable','inactive');
  displist=findobj(H1,'tag','displist');
  seldisp=get(displist,'value');
  set(displist,'enable','on','callback','winmngr moveto2','userdata',seldisp);
case 'moveto2',
  % get todisp
  displist=findobj(H1,'tag','displist');
  DISPLAYS=get(displist,'string');
  todisp=DISPLAYS{get(displist,'value')};
  
  % reset interface behaviour
  seldisp=get(displist,'userdata');
  set(allchild(H1),'enable','on');
  set(displist,'callback','winmngr refresh','value',seldisp);
  
  % move figures
  figlist=findobj(gcbf,'tag','figlist');
  options=get(figlist,'userdata');
  fig=get(figlist,'value');
  H=options.fighandles(fig(ishandle(options.fighandles(fig))));
  if isempty(H),
    winmngr refresh
    return;
  end;
  set(H,'xdisplay',todisp);
  winmngr refresh
case 'refresh',
  if ~isunix,
    figlist=findobj(H1,'tag','figlist');
    options.fighandles=setdiff(allchild(0),H1);
    fignames=listnames(options.fighandles);
    set(figlist,'string',fignames,'userdata',options,'value',1);
  else,
    displist=findobj(H1,'tag','displist');
    DISPLAYS=get(displist,'string');
    seldisp=get(displist,'value');
    seldisp=DISPLAYS{seldisp};
    if isempty(seldisp),
      figs=allchild(0); % never empty since at least the winmngr is active
      DISPLAYS=get(figs,'xdisplay');
      if ~iscell(DISPLAYS),
        DISPLAYS={DISPLAYS};
      end;
      DISPLAYS=unique(DISPLAYS);
      seldisp=get(H1,'xdisplay');
      set(displist,'string',DISPLAYS,'value',strmatch(seldisp,DISPLAYS,'exact'));
        % always a scalar due to unique and the xdisplay of H1 has been used
        % in determining DISPLAYS
    else,
      DISPLAYS=get(displist,'string');
      seldisp=DISPLAYS{get(displist,'value')};
      figs=allchild(0); % never empty since at least the winmngr is active
      actDISPLAYS=get(figs,'xdisplay');
      if ~iscell(actDISPLAYS),
        actDISPLAYS={actDISPLAYS};
      end;
      DISPLAYS={DISPLAYS{:} actDISPLAYS{:}};
      DISPLAYS=unique(DISPLAYS);
      set(displist,'string',DISPLAYS,'value',strmatch(seldisp,DISPLAYS,'exact'));
    end;
    figlist=findobj(H1,'tag','figlist');
    options.fighandles=setdiff(findobj(allchild(0),'flat','xdisplay',seldisp),H1);
    fignames=listnames(options.fighandles);
    set(figlist,'string',fignames,'userdata',options,'value',1);
  end;
case 'new',
  newdisp=inputdlg('Enter display name:','DISPLAY DIALOG',1,{''});
  if isempty(newdisp),
    return;
  end;
  newdisp=newdisp{1};
  displist=findobj(H1,'tag','displist');
  DISPLAYS=get(displist,'string');
  seldisp=get(displist,'value');
  newDISPLAYS=DISPLAYS;
  newDISPLAYS{end+1}=newdisp;
  newDISPLAYS=unique(newDISPLAYS);
  newdisp=strmatch(newdisp,newDISPLAYS,'exact');
  if isequal(DISPLAYS,newDISPLAYS),
    return; % nothing really added
  end;
  if newdisp<=seldisp,
    seldisp=seldisp+1;
  end;
  set(displist,'string',newDISPLAYS,'value',seldisp);
  winmngr refresh
case 'delete',
  figlist=findobj(H1,'tag','figlist');
  options=get(figlist,'userdata');
  if isempty(options.fighandles),
    return;
  end;
  fig=get(figlist,'value');
  H=options.fighandles(fig(ishandle(options.fighandles(fig))));
  if ~isempty(H),
    close(H,'force');
  end;
  winmngr('refresh');
case 'print',
  figlist=findobj(gcbf,'tag','figlist');
  options=get(figlist,'userdata');
  if isempty(options.fighandles),
    return;
  end;
  fig=get(figlist,'value');
  H=options.fighandles(fig(ishandle(options.fighandles(fig))));
  md_print(H);
case 'close',
  close(H1);
case 'togglehvis',
  figlist=findobj(H1,'tag','figlist');
  options=get(figlist,'userdata');
  if isempty(options.fighandles),
    return;
  end;
  fig=get(figlist,'value');
  for i=1:length(fig),
    if ishandle(options.fighandles(fig(i))),
      if strcmp(get(options.fighandles(fig(i)),'handlevisibility'),'on'),
        set(options.fighandles(fig(i)),'handlevisibility','off');
      else,
        set(options.fighandles(fig(i)),'handlevisibility','on');
      end;
    end;
  end;
  winmngr('refresh');
case 'edit',
  figlist=findobj(H1,'tag','figlist');
  options=get(figlist,'userdata');
  if isempty(options.fighandles),
    return;
  end;
  fig=get(figlist,'value');
  if length(fig)>1,
    uiwait(msgbox('Please select just one figure to edit.','modal'));
    return;
  end;
  if ishandle(options.fighandles(fig)),
    try,
      gui_figure(options.fighandles(fig));
    catch,
      propedit(options.fighandles(fig));
    end;
  else,
    winmngr('refresh');
  end;
end;
