function outh=cmd_uicontrol(fig,cmd)
%CMD_UICONTROL execute a GUI_UICONTROL command
%      CMD_UICONTROL(GuiHandle,Command)
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
if ~(hname(1:4)=='uico'),
  fprintf(1,'* The first parameter is not a gui UICONTROL handle\n');
  return;
end;

% fig is almost surely a GUITOOLS UICONTROL handle
handles=get(fig,'userdata');

h=get(handles{1}(3),'userdata');
h_BackUp=handles{1}(2);
if ~ishandle(h),
  Str='The uicontrol object has been deleted.';
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
    figure(get(h,'parent'));
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

case 1, % FONT ATTRIBUTES
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
  case 4, % fontunits
    funittypes=str2mat('inches','centimeters','normalized','points','pixels');
    lst=row(funittypes,get(handles{2}(12),'value'));
    set(h,'fontunits',lst);
    set(handles{2}(4),'string',gui_str(get(h,'fontsize')));
  case 5, % edit of string
    str=get(handles{2}(14),'string');
    set(h,'string',str);
  case 6, % color
    clr=md_color(get(h,'foregroundcolor'));
    set(h,'foregroundcolor',clr);
    set(handles{2}(17),'backgroundcolor',clr);
  case 7, % horizontalalignment
    horaltypes=str2mat('left','center','right');
    algn=row(horaltypes,get(handles{2}(19),'value'));
    set(h,'horizontalalignment',algn);
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
  case 5, % graphical update position lower left
    BUnits=get(h,'units');
    set(h,'units','pixel');
    figure(get(h,'parent'));
    lowerleft=ginput3d(1,'fig');
    position=get(h,'position');
    dimension=position(3:4);
    set(h,'position',[lowerleft dimension]);
    figure(fig);
    set(h,'units',BUnits);
    pos=get(h,'position');
    set(handles{3}(2),'string',gui_str(pos(1)));
    set(handles{3}(4),'string',gui_str(pos(2)));
    set(handles{3}(6),'string',gui_str(pos(3)));
    set(handles{3}(8),'string',gui_str(pos(4)));
  case 6, % graphical update position upper right
    BUnits=get(h,'units');
    set(h,'units','pixel');
    figure(get(h,'parent'));
    position=get(h,'position');
    lowerleft=position(1:2);
    upperright=ginput3d(1,'fig');
    dimension=upperright-lowerleft;
    set(h,'position',[lowerleft dimension]);
    figure(fig);
    set(h,'units',BUnits);
    pos=get(h,'position');
    set(handles{3}(2),'string',gui_str(pos(1)));
    set(handles{3}(4),'string',gui_str(pos(2)));
    set(handles{3}(6),'string',gui_str(pos(3)));
    set(handles{3}(8),'string',gui_str(pos(4)));
  case 7, % graphical update position change both
    BUnits=get(h,'units');
    set(h,'units','pixel');
    figure(get(h,'parent'));
    lowerleft=ginput3d(1,'fig');
    upperright=ginput3d(1,'fig');
    dimension=upperright-lowerleft;
    set(h,'position',[lowerleft dimension]);
    figure(fig);
    set(h,'units',BUnits);
    pos=get(h,'position');
    set(handles{3}(2),'string',gui_str(pos(1)));
    set(handles{3}(4),'string',gui_str(pos(2)));
    set(handles{3}(6),'string',gui_str(pos(3)));
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
    unittypes=str2mat('inches','centimeters','normalized','points','pixels','characters');
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

case 3, % STYLE PROPERTIES
  switch(cmd(2)),
  case 1, % style
    styles=str2mat('pushbutton','radiobutton','checkbox','edit','text','slider','frame','listbox','popupmenu');
    stl=deblank(row(styles,get(handles{4}(2),'value')));
    set(h,'style',stl);
  case 2, % background color
    clr=md_color(get(h,'backgroundcolor'));
    set(h,'backgroundcolor',clr);
    set(handles{4}(4),'backgroundcolor',clr);
  case 3, % min
    minval=eval(get(handles{4}(6),'string'),'NaN');
    if isnan(minval), minval=get(h,'min'); end;
    maxval=get(h,'max');
    if minval>maxval,
      tempval=minval;
      minval=maxval;
      maxval=tempval;
    elseif minval==maxval,
      maxval=maxval+1;
    end;
    set(h,'min',minval,'max',maxval);
    set(handles{4}(6),'string',gui_str(minval));
    set(handles{4}(8),'string',gui_str(maxval));
  case 4, % max
    minval=get(h,'min');
    maxval=eval(get(handles{4}(8),'string'),'NaN');
    if isnan(maxval), maxval=get(h,'max'); end;
    if minval>maxval,
      tempval=minval;
      minval=maxval;
      maxval=tempval;
    elseif minval==maxval,
      maxval=maxval+1;
    end;
    set(h,'min',minval,'max',maxval);
    set(handles{4}(6),'string',gui_str(minval));
    set(handles{4}(8),'string',gui_str(maxval));
  case 5, % sliderstep min
    minval=eval(get(handles{4}(10),'string'),'NaN');
    sls=get(h,'sliderstep');
    if ~isnan(minval),
      sls(1)=minval;
    end;
    if sls(1)>sls(2),
      sls=fliplr(sls);
    elseif sls(1)==sls(2),
      sls(2)=2*sls(1);
    end;
    set(h,'sliderstep',sls);
    set(handles{4}(10),'string',gui_str(sls(1)));
    set(handles{4}(12),'string',gui_str(sls(2)));
  case 6, % sliderstep max
    maxval=eval(get(handles{4}(12),'string'),'NaN');
    sls=get(h,'sliderstep');
    if ~isnan(maxval),
      sls(2)=maxval;
    end;
    if sls(1)>sls(2),
      sls=fliplr(sls);
    elseif sls(1)==sls(2),
      sls(1)=0.5*sls(2);
    end;
    set(h,'sliderstep',sls);
    set(handles{4}(10),'string',gui_str(sls(1)));
    set(handles{4}(12),'string',gui_str(sls(2)));
  case 7, % listbox top
    lbt=eval(get(handles{4}(14),'string'),'1');
    set(h,'listboxtop',lbt);
    set(handles{4}(14),'string',gui_str(lbt));
  case 8, % value
    val=eval(get(handles{4}(16),'string'),'1');
    set(h,'value',val);
    set(handles{4}(16),'string',gui_str(val));
  case 9, % enable
    enabtypes=str2mat('on','inactive','off');
    enab=deblank(row(enabtypes,get(handles{4}(18),'value')));
    set(h,'enable',enab);
    figure(fig)
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 4, % OTHER ATTRIBUTES
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
    set(handles{5}(5),'string',selon);
  case 5, % selectionhighlight
    selon=logicalswitch(strcmp(get(h,'selectionhighlight'),'on'),'off','on');
    set(h,'selectionhighlight',selon);
    set(handles{5}(7),'string',selon);
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
    set(handles{5}(11),'string',busac);
  case 9, % toggle of clipping
    clipping=logicalswitch(strcmp(get(h,'clipping'),'on'),'off','on');
    set(h,'clipping',clipping);
    set(handles{5}(13),'string',clipping);
  case 10, % toggle of interruptible
    interrupt=logicalswitch(strcmp(get(h,'interruptible'),'on'),'off','on');
    set(h,'interruptible',interrupt);
    set(handles{5}(15),'string',interrupt);
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
