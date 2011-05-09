function outh=cmd_text(fig,cmd)
%CMD_TEXT execute a GUI_TEXT command
%      CMD_TEXT(GuiHandle,Command)
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
if ~(hname(1:4)=='text'),
  fprintf(1,'* The first parameter is not a gui TEXT handle\n');
  return;
end;

% fig is almost surely a GUITOOLS TEXT handle
handles=get(fig,'userdata');

h=get(handles{1}(3),'userdata');
h_BackUp=handles{1}(2);
if ~ishandle(h),
  Str='The text object has been deleted.';
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
    delete(h_BackUp);
    guix(fig,'close');
    figure(get(get(h,'parent'),'parent'));
  case 3, % cancel
    existed=get(handles{1}(6),'userdata');
    if ~existed,
      delete(h);
    else,
      vison=logicalswitch(strcmp(get(h_BackUp,'visible'),'on'),'off','on');
      copyprop(h_BackUp,h);
      set(h,'visible',vison);
%      set(h,'buttondownfcn',['clicked(''',num2hex(h),''');']);
    end;
    delete(h_BackUp);
    guix(fig,'close');
  case 4, % gui_editing active
    set(handles{1}(8),'string',logicalswitch(strcmp(get(handles{1}(8),'string'),'on'),'off','on'));
  case 5, % visible
    vison=logicalswitch(strcmp(get(h,'visible'),'on'),'off','on');
    set(h,'visible',vison);
    set(handles{1}(10),'string',vison);
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

case 1, % STRING ATTRIBUTES
  switch(cmd(2)),
  case 1, % display font window
    uisetfont(h);
    set(handles{2}(2),'string',get(h,'fontname'));
    set(handles{2}(4),'string',gui_str(get(h,'fontsize')));
    set(handles{2}(6),'string',get(h,'fontweight'));
    set(handles{2}(8),'string',get(h,'fontangle'));
  case 2, % direct edit of fontsize
    set(h,'fontsize',eval(get(handles{2}(4),'string'),gui_str(get(h,'fontsize'))));
    set(handles{2}(4),'string',gui_str(get(h,'fontsize')));
  case 3, % text interpreter
    interpr=logicalswitch(strcmp(get(h,'interpreter'),'tex'),'none','tex');
    set(h,'interpreter',interpr);
    set(handles{2}(10),'string',interpr);
  case 4, % fontunits
    funittypes=str2mat('inches','centimeters','normalized','points','pixels');
    lst=row(funittypes,get(handles{2}(12),'value'));
    set(h,'fontunits',lst);
    set(handles{2}(4),'string',gui_str(get(h,'fontsize')));
  case 5, % edit of string
    str=get(handles{2}(14),'string');
    set(h,'string',str);
  case 6, % color
    set(handles{2}(17),'backgroundcolor',md_color(h));
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 2, % POSITION ATTRIBUTES
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
  case 3, % update z position
    pos=get(h,'position');
    pos(3)=eval(get(handles{3}(6),'string'),gui_str(pos(3)));
    set(h,'position',pos);
    set(handles{3}(6),'string',gui_str(pos(3)));
  case 4, % graphical update position
    BUnits=get(h,'units');
    set(h,'units','data');
    ax=get(h,'parent');
    position=ginput3d(ax,1);
    set(h,'position',position);
    figure(fig);
    set(h,'units',BUnits);
    pos=get(h,'position');
    set(handles{3}(2),'string',gui_str(pos(1)));
    set(handles{3}(4),'string',gui_str(pos(2)));
    set(handles{3}(6),'string',gui_str(pos(3)));
  case 5, % center x
    BUnits=get(h,'units');
    set(h,'units','normalized');
    pos=get(h,'position');
    pos(1)=0.5;
    set(h,'position',pos);
    set(h,'units',BUnits);
    pos=get(h,'position');
    set(handles{3}(2),'string',gui_str(pos(1)));
  case 6, % center y
    BUnits=get(h,'units');
    set(h,'units','normalized');
    pos=get(h,'position');
    pos(2)=0.5;
    set(h,'position',pos);
    set(h,'units',BUnits);
     pos=get(h,'position');
    set(handles{3}(4),'string',gui_str(pos(2)));
  case 7, % center z
    BUnits=get(h,'units');
    set(h,'units','normalized');
    pos=get(h,'position');
    pos(3)=0.5;
    set(h,'position',pos);
    set(h,'units',BUnits);
    pos=get(h,'position');
    set(handles{3}(6),'string',gui_str(pos(3)));
  case 8, % unit
    unittypes=str2mat('inches','centimeters','normalized','points','pixels','data');
    lst=row(unittypes,get(handles{3}(12),'value'));
    set(h,'units',lst);
    pos=get(h,'position');
    set(handles{3}(2),'string',gui_str(pos(1)));
    set(handles{3}(4),'string',gui_str(pos(2)));
    set(handles{3}(6),'string',gui_str(pos(3)));
  case 9, % get rotation angle interactive
    set(fig,'visible','off');
    ang=getangle(get(h,'rotation'));
    set(h,'rotation',ang);
    set(handles{3}(14),'string',gui_str(ang));
    set(fig,'visible','on');
  case 10, % edited rotation angle
    ang=eval(get(handles{3}(14),'string'),gui_str(get(h,'rotation')));
    set(h,'rotation',ang);
    set(handles{3}(14),'string',gui_str(ang));
  case 11, % horizontalalignment
    horaltypes=str2mat('left','center','right');
    algn=row(horaltypes,get(handles{3}(16),'value'));
    set(h,'horizontalalignment',algn);
  case 12, % verticalalignment
    veraltypes=str2mat('top','cap','middle','baseline','bottom');
    algn=row(veraltypes,get(handles{3}(18),'value'));
    set(h,'verticalalignment',algn);
  case 13, % erasemode
    ermodtypes=str2mat('normal','background','xor','none');
    ermod=row(ermodtypes,get(handles{3}(20),'value'));
    set(h,'erasemode',ermod);
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 3, % OTHER ATTRIBUTES
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
    set(handles{4}(5),'string',selon);
  case 5, % selectionhighlight
    selon=logicalswitch(strcmp(get(h,'selectionhighlight'),'on'),'off','on');
    set(h,'selectionhighlight',selon);
    set(handles{4}(7),'string',selon);
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
    set(handles{4}(11),'string',busac);
  case 9, % toggle of clipping
    clipping=logicalswitch(strcmp(get(h,'clipping'),'on'),'off','on');
    set(h,'clipping',clipping);
    set(handles{4}(13),'string',clipping);
  case 10, % toggle of interruptible
    interrupt=logicalswitch(strcmp(get(h,'interruptible'),'on'),'off','on');
    set(h,'interruptible',interrupt);
    set(handles{4}(15),'string',interrupt);
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
