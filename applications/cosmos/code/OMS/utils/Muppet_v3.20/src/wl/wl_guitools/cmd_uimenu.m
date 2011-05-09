function outh=cmd_uimenu(fig,cmd)
%CMD_UIMENU execute a GUI_UIMENU command
%      CMD_UIMENU(GuiHandle,Command)
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
if ~(hname(1:4)=='uime'),
  fprintf(1,'* The first parameter is not a gui UIMENU handle\n');
  return;
end;

% fig is almost surely a GUITOOLS UIMENU handle
handles=get(fig,'userdata');

h=get(handles{1}(3),'userdata');
h_BackUp=handles{1}(2);
if ~ishandle(h),
  Str='The uimenu object has been deleted.';
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
    fig=get(h,'parent');
    while ~strcmp(get(fig,'type'),'figure'),
      fig=get(fig,'parent');
    end;
    figure(fig);
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

case 1, % UIMENU ATTRIBUTES
  switch(cmd(2)),
  case 1, % edit of label
    str=get(handles{2}(2),'string');
    set(h,'label',str);
  case 2, % edit of position
    pos=eval(get(handles{2}(4),'string'),gui_str(get(h,'position')));
    set(h,'position',pos);
  case 3, % color
    clr=md_color(get(h,'foregroundcolor'));
    set(h,'foregroundcolor',clr);
    set(handles{2}(6),'backgroundcolor',clr);
  case 4, % enable
    enab=logicalswitch(strcmp(get(h,'enable'),'on'),'off','on');
    set(h,'enable',enab);
    set(handles{2}(8),'string',enab);
  case 5, % checked
    chck=logicalswitch(strcmp(get(h,'checked'),'on'),'off','on');
    set(h,'checked',chck);
    set(handles{2}(10),'string',chck);
  case 6, % separator
    sep=logicalswitch(strcmp(get(h,'separator'),'on'),'off','on');
    set(h,'separator',sep);
    set(handles{2}(12),'string',sep);
  case 7, % accelerator
    str=get(handles{2}(14),'string');
    set(h,'accelerator',str);
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 2, % CHILDREN
  switch(cmd(2)),
  case 1, % refresh list of children
    [chld,names]=childlist(h);
    set(handles{3}(2),'string',names,'userdata',chld,'value',1,'listboxtop',1);
    set(handles{3}(3),'enable',logicalswitch(isempty(chld),'off','on'));
    
  case 2, % open gui for selected child
    object=get(handles{3}(2),'value');
    handle=get(handles{3}(2),'userdata');
    handle=handle(object);
    if ishandle(handle),
      eval(['gui_',get(handle,'type'),'(handle)']);
    else, % refresh
      cmd_uimenu(fig,[2 1]);
    end;

  case 3, % create child
    newh=uimenu('parent',h);
    gui_uimenu(newh);
    cmd_uimenu(fig,[2 1]);

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
  case 11, % edit Callback
    fcn=get(h,'Callback');
    fcn=md_edit(fcn,'specmode','multiline');
    set(h,'Callback',fcn);
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
