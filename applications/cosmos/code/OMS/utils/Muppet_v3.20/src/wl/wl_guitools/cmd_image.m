function outh=cmd_image(fig,cmd)
%CMD_IMAGE execute a GUI_IMAGE command
%      CMD_IMAGE(GuiHandle,Command)
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
if ~strcmp(hname(1:4),'imag'),
  fprintf(1,'* The first parameter is not a gui IMAGE handle\n');
  return;
end;

% fig is almost surely a GUITOOLS IMAGE handle
handles=get(fig,'userdata');

h=get(handles{1}(3),'userdata');
h_BackUp=handles{1}(2);
if ~ishandle(h),
  Str='The image object has been deleted.';
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

case 1, % IMAGE ATTRIBUTES
  switch(cmd(2)),
  case 1, % maximum x
    xdata=get(h,'xdata');
    xdata=[min(min(xdata)) max(max(xdata))];
    xmax=eval(get(handles{2}(2),'string'),gui_str(xdata(2)));
    if xmax==xdata(1),
      xdata(2)=xmax+1;
    elseif xmax<xdata(1),
      xdata=[xmax xdata(1)];
    else,
      xdata(2)=xmax;
    end;
    set(h,'xdata',xdata);
    set(handles{2}(2),'string',gui_str(xdata(2)));
    set(handles{2}(4),'string',gui_str(xdata(1)));
  case 2, % minimum x
    xdata=get(h,'xdata');
    xdata=[min(min(xdata)) max(max(xdata))];
    xmin=eval(get(handles{2}(4),'string'),gui_str(xdata(1)));
    if xmin==xdata(2),
      xdata(1)=xmin-1;
    elseif xmin>xdata(2),
      xdata=[xdata(2) xmin];
    else,
      xdata(1)=xmin;
    end;
    set(h,'xdata',xdata);
    set(handles{2}(2),'string',gui_str(xdata(2)));
    set(handles{2}(4),'string',gui_str(xdata(1)));
  case 3, % maximum y
    ydata=get(h,'ydata');
    ydata=[min(min(ydata)) max(max(ydata))];
    ymax=eval(get(handles{2}(6),'string'),gui_str(ydata(2)));
    if ymax==ydata(1),
      ydata(2)=ymax+1;
    elseif ymax<ydata(1),
      ydata=[ymax ydata(1)];
    else,
      ydata(2)=ymax;
    end;
    set(h,'ydata',ydata);
    set(handles{2}(6),'string',gui_str(ydata(2)));
    set(handles{2}(8),'string',gui_str(ydata(1)));
  case 4, % minimum y
    ydata=get(h,'ydata');
    ydata=[min(min(ydata)) max(max(ydata))];
    ymin=eval(get(handles{2}(8),'string'),gui_str(ydata(1)));
    if ymin==ydata(2),
      ydata(1)=ymin-1;
    elseif ymin>ydata(2),
      ydata=[ydata(2) ymin];
    else,
      ydata(1)=ymin;
    end;
    set(h,'ydata',ydata);
    set(handles{2}(6),'string',gui_str(ydata(2)));
    set(handles{2}(8),'string',gui_str(ydata(1)));
  case 5, % edit color data
    cdata=get(h,'cdata');
    set(fig,'visible','off');
    cdata=md_edit(cdata, ...
       'dimlabel',{'row' 'column'}, ...
       'label',{'123' '123'});
    set(h,'cdata',cdata);
    set(fig,'visible','on');
  case 6, % cdatamapping
    dmap=logicalswitch(strcmp(get(h,'cdatamapping'),'direct'),'scaled','direct');
    set(h,'cdatamapping',dmap);
    set(handles{2}(11),'string',dmap);
  case 7, % erasemode
    ermodtypes=str2mat('normal','background','xor','none');
    ermod=row(ermodtypes,get(handles{2}(13),'value'));
    set(h,'erasemode',ermod);
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 2, % OTHER ATTRIBUTES
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
    set(handles{14}(5),'string',selon);
  case 5, % selectionhighlight
    selon=logicalswitch(strcmp(get(h,'selectionhighlight'),'on'),'off','on');
    set(h,'selectionhighlight',selon);
    set(handles{14}(7),'string',selon);
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
    set(handles{14}(11),'string',busac);
  case 9, % toggle of clipping
    clipping=logicalswitch(strcmp(get(h,'clipping'),'on'),'off','on');
    set(h,'clipping',clipping);
    set(handles{14}(13),'string',clipping);
  case 10, % toggle of interruptible
    interrupt=logicalswitch(strcmp(get(h,'interruptible'),'on'),'off','on');
    set(h,'interruptible',interrupt);
    set(handles{14}(15),'string',interrupt);
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
