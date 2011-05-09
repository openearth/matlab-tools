function outh=cmd_figure(fig,cmd)
%CMD_FIGURE execute a GUI_FIGURE command
%      CMD_FIGURE(GuiHandle,Command)
%      Executes the Command corresponding to the button clicked
%      in the window indicated by the GuiHandle 

%      Copyright (c) H.R.A. Jagers  12-17-1996

if (nargin~=2),
  fprintf(1,'* Unexpected number of input arguments.\n');
  return;
end;

if isstr(fig),
  fig=hex2num(fig);
end;

if (~ishandle(fig)),
  fprintf(1,'* The first parameter is not a graphics handle\n');
  return;
end;
if ~guix(fig,'check'),
  fprintf(1,'* The first parameter is not a GUI handle\n');
  return;
end;
hname=get(fig,'name');
if ~(hname(1:4)=='figu'),
  fprintf(1,'* The first parameter is not a gui FIGURE handle\n');
  return;
end;

% fig is almost surely a GUITOOLS FIGURE handle
handles=get(fig,'userdata');

h=get(handles{1}(3),'userdata');
h_BackUp=handles{1}(2);
if ~ishandle(h),
  Str='The figure has been deleted.';
  uiwait(msgbox(Str,'modal'));
  delete(h_BackUp);
  guix(fig,'close');
  return;
end;

switch(cmd(1)),
case 0, % GENERAL COMMANDS
  switch(cmd(2)),
%  case 0, % reserved for gui_main close
  case 1, % frames
    oldvalue=get(handles{1}(4),'userdata');
    newvalue=get(handles{1}(4),'value');
    if newvalue~=oldvalue,
      set(handles{1+oldvalue},'visible','off');
      set(handles{1+newvalue},'visible','on');
      set(handles{1}(4),'userdata',newvalue);
    end;
  case 2, % accept
%    if strcmp(get(handles{1}(8),'string'),'on'),
%      set(h,'buttondownfcn',['clicked(''',num2hex(h),''');']); 
%    else,
%      set(h,'buttondownfcn',['clicked(''',num2hex(get(h,'parent')),''')']); 
%    end;
    if ishandle(h_BackUp),
      delete(h_BackUp);
    end;
    guix(fig,'close');
    figure(h);
  case 3, % cancel
    existed=get(handles{1}(6),'userdata');
    if ~existed,
      if ishandle(h),
        delete(h);
      end;
    else,
      vison=logicalswitch(strcmp(get(h_BackUp,'visible'),'on'),'off','on');
      copyprop(h_BackUp,h);
      set(h,'visible',vison);
%      set(h,'buttondownfcn',['clicked(''',num2hex(h),''');']);
    end;
    if ishandle(h_BackUp),
      delete(h_BackUp);
    end;
    guix(fig,'close');
  case 4, % gui_editing active
    set(handles{1}(8),'string',logicalswitch(strcmp(get(handles{1}(8),'string'),'on'),'off','on'));
  case 5, % visible
    vison=logicalswitch(strcmp(get(h,'visible'),'on'),'off','on');
    set(h,'visible',vison);
    set(handles{1}(10),'string',vison);
    if strcmp(vison,'on'),
      set(fig,'visible','off','visible','on');
    end;
  case 6, % delete
    if (get(handles{1}(12),'backgroundcolor')==[1,0,0]),
      delete(h,h_BackUp);
      guix(fig,'close');
    end;
  case 7, % lock of delete
    newcolor=[1,1,0]-get(handles{1}(12),'backgroundcolor');
    set(handles{1}(12),'backgroundcolor',newcolor);
    set(handles{1}(11),'enable',logicalswitch(isequal(newcolor,[1,0,0]),'on','off'));
  case 8, % handlevisibility
    hvistypes=str2mat('on','callback','off');
    hvis=deblank(row(hvistypes,get(handles{1}(18),'value')));
    set(h,'handlevisibility',hvis);
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 1, % GENERAL ATTRIBUTES
  switch(cmd(2)),
  case 1, % integerhandle
    ch=get(h,'children');
    if isempty(ch),
      chld=axes('visible','off','parent',h);
    else,
      chld=ch(1);
    end;
    ih=logicalswitch(strcmp(get(h,'integerhandle'),'on'),'off','on');
    set(h,'integerhandle',ih);
    set(handles{2}(2),'string',ih);
    nh=get(chld,'parent'); % get new handle of figure
    set(handles{1}(3),'userdata',nh);
    guix(h,'change to',nh);
    set(fig,'name',['figure - ',num2hex(nh)])
    if isempty(ch),
      delete(chld);
    end;
  case 2, % backingstore
    bs=logicalswitch(strcmp(get(h,'backingstore'),'on'),'off','on');
    set(h,'backingstore',bs);
    set(handles{2}(4),'string',bs);
  case 3, % inverthardcopy
    ihc=logicalswitch(strcmp(get(h,'inverthardcopy'),'on'),'off','on');
    set(h,'inverthardcopy',ihc);
    set(handles{2}(6),'string',ihc);
  case 4, % numbertitle
    nt=logicalswitch(strcmp(get(h,'numbertitle'),'on'),'off','on');
    set(h,'numbertitle',nt);
    set(handles{2}(8),'string',nt);
  case 5, % name
    set(h,'name',get(handles{2}(10),'string'));
  case 6, % menu bar
    mb=logicalswitch(strcmp(get(h,'menubar'),'none'),'figure','none');
    set(h,'menubar',mb);
    set(handles{2}(12),'string',mb);
  case 7, % pointer
    pointertypes=str2mat('crosshair','fullcrosshair','arrow','ibeam','watch','topl','topr','botl','botr','left','top','right','bottom','circle','cross','fleur','custom');
    pt=deblank(row(pointertypes,get(handles{2}(14),'value')));
    set(h,'pointer',pt);
    set(handles{2}(15),'enable',logicalswitch(strcmp(pt,'custom'),'on','off'));
    set(handles{2}(16),'enable',logicalswitch(strcmp(pt,'custom'),'on','off'));
  case 8, % pointershapecdata
    set(h,'pointershapecdata',md_edit(get(h,'pointershapecdata')));
  case 9, % pointershapehotspot
    set(h,'pointershapehotspot',md_edit(get(h,'pointershapehotspot')));
  case 10, % renderermode
    rm=logicalswitch(strcmp(get(h,'renderermode'),'auto'),'manual','auto');
    set(h,'renderermode',rm);
    set(handles{2}(18),'string',rm);
    set(handles{2}(20),'string',get(h,'renderer'));
    set(handles{2}(19:20),'enable',logicalswitch(strcmp(rm,'manual'),'on','off'))
  case 11, % renderer
    if strcmp(get(handles{2}(20),'enable'),'on'),
      rend=logicalswitch(strcmp(get(h,'renderer'),'painters'),'zbuffer','painters');
      set(h,'renderer',rend);
      set(handles{2}(20),'string',rend);
   end;
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 2, % PLOT AREA POSITION ATTRIBUTES
  switch(cmd(2)),
  case 1, % update x position
    pos=get(h,'position');
    pos(1)=eval(get(handles{3}(2),'string'),gui_str(pos(1)));
    set(h,'position',pos);
    set(handles{3}(2),'string',gui_str(pos(1)));
  case 2, % update y position
    pos=get(h,'position');
    pos(2)=eval(get(handles{3}(4),'string'),gui_str(pos(2)));
    set(h,'position',pos);
    set(handles{3}(4),'string',gui_str(pos(2)));
  case 3, % update width
    pos=get(h,'position');
    pos(3)=eval(get(handles{3}(6),'string'),gui_str(pos(3)));
    set(h,'position',pos);
    set(handles{3}(6),'string',gui_str(pos(3)));
  case 4, % update height
    pos=get(h,'position');
    pos(4)=eval(get(handles{3}(8),'string'),gui_str(pos(4)));
    set(h,'position',pos);
    set(handles{3}(8),'string',gui_str(pos(4)));
  case 8, % center left / right
    BUnits=get(h,'units');
    set(h,'units','normalized');
    pos=get(h,'position');
    pos(1)=(1-pos(3))/2;
    set(h,'position',pos);
    set(h,'units',BUnits);
    pos=get(h,'position');
    set(handles{3}(2),'string',gui_str(pos(1)));
  case 9, % center top / bottom
    BUnits=get(h,'units');
    set(h,'units','normalized');
    pos=get(h,'position');
    pos(2)=(1-pos(4))/2;
    set(h,'position',pos);
    set(h,'units',BUnits);
    pos=get(h,'position');
    set(handles{3}(4),'string',gui_str(pos(2)));
  case 10, % units
    unittypes=str2mat('inches','centimeters','normalized','points','pixels');
    lst=row(unittypes,get(handles{3}(17),'value'));
    set(h,'units',lst);
    pos=get(h,'position');
    set(handles{3}(2),'string',gui_str(pos(1)));
    set(handles{3}(4),'string',gui_str(pos(2)));
    set(handles{3}(6),'string',gui_str(pos(3)));
    set(handles{3}(8),'string',gui_str(pos(4)));
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 3, % PAPER COORDINATES
  switch(cmd(2)),
  case 1, % update x position
    pos=get(h,'paperposition');
    pos(1)=eval(get(handles{4}(2),'string'),gui_str(pos(1)));
    set(h,'paperposition',pos);
    set(handles{4}(2),'string',gui_str(pos(1)));
  case 2, % update y position
    pos=get(h,'paperposition');
    pos(2)=eval(get(handles{4}(4),'string'),gui_str(pos(2)));
    set(h,'paperposition',pos);
    set(handles{4}(4),'string',gui_str(pos(2)));
  case 3, % update width
    pos=get(h,'paperposition');
    pos(3)=eval(get(handles{4}(6),'string'),gui_str(pos(3)));
    set(h,'paperposition',pos);
    set(handles{4}(6),'string',gui_str(pos(3)));
  case 4, % update height
    pos=get(h,'paperposition');
    pos(4)=eval(get(handles{4}(8),'string'),gui_str(pos(4)));
    set(h,'paperposition',pos);
    set(handles{4}(8),'string',gui_str(pos(4)));
  case 5, % graphical update position lower left
  case 6, % graphical update position upper right
  case 7, % graphical update position change both
  case 8, % center left / right
    BUnits=get(h,'paperunits');
    set(h,'paperunits','normalized');
    pos=get(h,'paperposition');
    pos(1)=(1-pos(3))/2;
    set(h,'paperposition',pos);
    set(h,'paperunits',BUnits);
    pos=get(h,'paperposition');
    set(handles{4}(2),'string',gui_str(pos(1)));
  case 9, % center top / bottom
    BUnits=get(h,'paperunits');
    set(h,'paperunits','normalized');
    pos=get(h,'paperposition');
    pos(2)=(1-pos(4))/2;
    set(h,'paperposition',pos);
    set(h,'paperunits',BUnits);
    pos=get(h,'paperposition');
    set(handles{4}(4),'string',gui_str(pos(2)));
  case 10, % units
    unittypes=str2mat('inches','centimeters','normalized','points');
    lst=row(unittypes,get(handles{4}(17),'value'));
    set(h,'paperunits',lst);
    pos=get(h,'paperposition');
    set(handles{4}(2),'string',gui_str(pos(1)));
    set(handles{4}(4),'string',gui_str(pos(2)));
    set(handles{4}(6),'string',gui_str(pos(3)));
    set(handles{4}(8),'string',gui_str(pos(4)));
  case 11, % paperpositionmode
    ppm=logicalswitch(strcmp(get(h,'paperpositionmode'),'auto'),'manual','auto');
    set(h,'paperpositionmode',ppm);
    set(handles{4}(13),'string',ppm);
    if strcmp(ppm,'auto'),
      pos=get(h,'paperposition');
      set(handles{4}(2),'string',gui_str(pos(1)),'enable','off');
      set(handles{4}(4),'string',gui_str(pos(2)),'enable','off');
      set(handles{4}(6),'string',gui_str(pos(3)),'enable','off');
      set(handles{4}(8),'string',gui_str(pos(4)),'enable','off');
    else,
      pos=get(h,'paperposition');
      set(handles{4}(2),'string',gui_str(pos(1)),'enable','on');
      set(handles{4}(4),'string',gui_str(pos(2)),'enable','on');
      set(handles{4}(6),'string',gui_str(pos(3)),'enable','on');
      set(handles{4}(8),'string',gui_str(pos(4)),'enable','on');
    end;
  case 12, % papertype
    pttypes=str2mat('usletter','uslegal','a3','a4letter','a5','b4','tabloid');
    pt=deblank(row(pttypes,get(handles{4}(19),'value')));
    set(h,'papertype',pt);
    pos=get(h,'paperposition');
    set(handles{4}(2),'string',gui_str(pos(1)));
    set(handles{4}(4),'string',gui_str(pos(2)));
    set(handles{4}(6),'string',gui_str(pos(3)));
    set(handles{4}(8),'string',gui_str(pos(4)));
  case 13, % paperorientation
    po=logicalswitch(strcmp(get(h,'paperorientation'),'portrait'),'landscape','portrait');
    set(h,'paperorientation',po);
    set(handles{4}(21),'string',po);
    pos=get(h,'paperposition');
    set(handles{4}(2),'string',gui_str(pos(1)));
    set(handles{4}(4),'string',gui_str(pos(2)));
    set(handles{4}(6),'string',gui_str(pos(3)));
    set(handles{4}(8),'string',gui_str(pos(4)));
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 4, % PLOT AREA ATTRIBUTES
  switch(cmd(2)),
  case 1, % nextplot
    plottypes=str2mat('add','replace','replacechildren');
    lst=row(plottypes,get(handles{5}(2),'value'));
    set(h,'nextplot',lst);
  case 2, % resize
    rsz=logicalswitch(strcmp(get(h,'resize'),'on'),'off','on');
    set(h,'resize',rsz);
    set(handles{5}(4),'string',rsz);
    set(handles{5}(5),'enable',rsz);
  case 3, % edit resize function
    fcn=get(h,'ResizeFcn');
    fcn=md_edit(fcn,'specmode','multiline');
    set(h,'ResizeFcn',fcn);
  case 4, % edit close request function
    fcn=get(h,'CloseRequestFcn');
    fcn=md_edit(fcn,'specmode','multiline');
    set(h,'CloseRequestFcn',fcn);
  case 5, % edit key press function
    fcn=get(h,'KeyPressFcn');
    fcn=md_edit(fcn,'specmode','multiline');
    set(h,'KeyPressFcn',fcn);
  case 6, % modal
    if (get(handles{5}(9),'backgroundcolor')==[1,0,0]),
      delete(h_BackUp);
      guix(fig,'close');
%      set(h,'windowstyle','modal');
    end;
  case 7, % lock of modal
    set(handles{5}(9),'backgroundcolor',[1,1,0]-get(handles{5}(9),'backgroundcolor'));
  case 8, % edit windowbuttondown function
    fcn=get(h,'WindowButtonDownFcn');
    fcn=md_edit(fcn,'specmode','multiline');
    set(h,'WindowButtonDownFcn',fcn);
  case 9, % edit windowbuttonmotion function
    fcn=get(h,'WindowButtonMotionFcn');
    fcn=md_edit(fcn,'specmode','multiline');
    set(h,'WindowButtonMotionFcn',fcn);
  case 10, % edit windowbuttonup function
    fcn=get(h,'WindowButtonUpFcn');
    fcn=md_edit(fcn,'specmode','multiline');
    set(h,'WindowButtonUpFcn',fcn);
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 5, % COLORS
  switch(cmd(2)),
  case 1, % color
    newcolor=md_color(get(h,'color'));
    set(handles{6}(2),'backgroundcolor',newcolor);
    set(h,'color',newcolor);
  case 2, % edit colormap
    set(fig,'visible','off');
    colorm=get(h,'colormap');
    colorm=md_edit(colorm,'label',{'123' {'red';'green';'blue'}},'dimfixed',[0 1]);
    set(h,'colormap',colorm);
    set(fig,'visible','on');
  case 3, % dithermap mode
    dmm=logicalswitch(strcmp(get(h,'dithermapmode'),'auto'),'manual','auto');
    set(h,'dithermapmode',dmm);
    set(handles{6}(5),'string',dmm);
    if strcmp(dmm,'auto'),
      set(handles{6}(6),'enable','off');
    else,
      set(handles{6}(6),'enable','on');
    end;
  case 4, % edit dithermap
    set(fig,'visible','off');
    colorm=get(h,'dithermap');
    colorm=md_edit(colorm,'label',{'123' {'red';'green';'blue'}},'dimfixed',[0 1]);
    set(h,'dithermap',colorm);
    set(fig,'visible','on');
  case 5, % share colors
    sc=logicalswitch(strcmp(get(h,'sharecolors'),'on'),'off','on');
    set(h,'sharecolors',sc);
    set(handles{6}(8),'string',sc);
  case 6, % minimum colormap
    mcm=eval(get(handles{6}(10),'string'),gui_str(get(h,'mincolormap')));
    set(h,'mincolormap',mcm);
    set(handles{6}(10),'string',gui_str(get(h,'mincolormap')));
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 6, % CHILDREN
  switch(cmd(2)),
  case 1, % refresh list of children
    [chld,names]=childlist(h);
    set(handles{7}(2),'string',names,'userdata',chld,'value',1,'listboxtop',1);
    set(handles{7}(3),'enable',logicalswitch(isempty(chld),'off','on'));
    set(handles{7}(7),'enable',logicalswitch(isempty(chld),'off','on'));
    
  case 2, % open gui for selected child
    object=get(handles{7}(2),'value');
    handle=get(handles{7}(2),'userdata');
    handle=handle(object);
    if ishandle(handle),
      eval(['gui_',get(handle,'type'),'(handle)']);
    else, % refresh
      cmd_figure(fig,[6 1]);
    end;

  case 3, % create axes
    TempPointer=get(h,'pointer');
    TempUnits=get(h,'units');
    TempHVis=get(h,'handlevisibility');
    set(h,'handlevisibility','on','units','pixels','pointer','crosshair');
    figure(h);
    waitforbuttonpress;
    Rect = rbbox([get(h,'currentpoint') 0 0]);
    Rect(3:4)=max(Rect(3:4),[10 10]);
    set(h,'handlevisibility',TempHVis,'units',TempUnits,'pointer','watch');
    newh=axes('units','pixels','position',Rect,'parent',h);
    drawnow;
    gui_axes(newh);
    cmd_figure(fig,[6 1]);
    set(h,'pointer',TempPointer);

  case 4, % create uimenu
    newh=uimenu('parent',h);
    gui_uimenu(newh);
    cmd_figure(fig,[6 1]);

  case 5, % create uicontrol
    TempPointer=get(h,'pointer');
    TempUnits=get(h,'units');
    TempHVis=get(h,'handlevisibility');
    set(h,'handlevisibility','on','units','pixels','pointer','crosshair');
    figure(h);
    waitforbuttonpress;
    Rect = rbbox([get(h,'currentpoint') 0 0]);
    Rect(3:4)=max(Rect(3:4),[10 10]);
    set(h,'handlevisibility',TempHVis,'units',TempUnits,'pointer','watch');
    newh=uicontrol('units','pixels','position',Rect,'parent',h);
    drawnow;
    gui_uicontrol(newh);
    cmd_figure(fig,[6 1]);
    set(h,'pointer',TempPointer);

  case 6, % put child on top
    object=get(handles{7}(2),'value');
    handle=get(handles{7}(2),'userdata');
    handle=handle(object);
    if ishandle(handle),
      handles=allchild(h);
      J=find(handles==handle);
      NotJ=find(handles~=handle);
      handles=[handles(J); handles(NotJ)];
      set(h,'child',handles);
      cmd_figure(fig,[6 1]);
    else, % refresh
      cmd_figure(fig,[6 1]);
    end;

  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 7, % OTHER ATTRIBUTES
  switch(cmd(2)),
  case 1, % edit ButtonDownFcn
    fcn=get(h,'ButtonDownFcn');
    fcn=md_edit(fcn,'specmode','multiline');
    set(h,'ButtonDownFcn',fcn);
  case 2, %edit CreateFcn
    fcn=get(h,'CreateFcn');
    fcn=md_edit(fcn,'specmode','multiline');
    set(h,'CreateFcn',fcn);
  case 3, % edit DeleteFcn
    fcn=get(h,'DeleteFcn');
    fcn=md_edit(fcn,'specmode','multiline');
    set(h,'DeleteFcn',fcn);
  case 4, % selected
    selon=logicalswitch(strcmp(get(h,'selected'),'on'),'off','on');
    set(h,'selected',selon);
    set(handles{8}(5),'string',selon);
  case 5, % selectionhighlight
    selon=logicalswitch(strcmp(get(h,'selectionhighlight'),'on'),'off','on');
    set(h,'selectionhighlight',selon);
    set(handles{8}(7),'string',selon);
  case 6, % edit tag
    tag=get(h,'tag');
    tag=md_edit(tag,'specmode','multiline');
    set(h,'tag',tag);
  case 7, % edit user data
    usdata=get(h,'userdata');
    usdata=md_edit(usdata);
    set(h,'userdata',usdata);
  case 8, % busyaction
    busac=logicalswitch(strcmp(get(h,'busyaction'),'cancel'),'queue','cancel');
    set(h,'busyaction',busac);
    set(handles{8}(11),'string',busac);
  case 9, % toggle of clipping
    clipping=logicalswitch(strcmp(get(h,'clipping'),'on'),'off','on');
    set(h,'clipping',clipping);
    set(handles{8}(13),'string',clipping);
  case 10, % toggle of interruptible
    interrupt=logicalswitch(strcmp(get(h,'interruptible'),'on'),'off','on');
    set(h,'interruptible',interrupt);
    set(handles{8}(15),'string',interrupt);
  case 12, % edit parent
    handle=get(h,'parent');
    if ishandle(handle),
      gui_call(handle);
    end;
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

otherwise,
  fprintf(1,'* Unknown command.\n');
end;
