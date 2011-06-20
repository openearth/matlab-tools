function outh=cmd_line(fig,cmd)
%CMD_LINE execute a GUI_LINE command
%      CMD_LINE(GuiHandle,Command)
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
if ~(hname(1:4)=='line'),
  fprintf(1,'* The first parameter is not a gui LINE handle\n');
  return;
end;

% fig is almost surely a GUITOOLS LINE handle
handles=get(fig,'userdata');

h=get(handles{1}(3),'userdata');
h_BackUp=handles{1}(2);
if ~ishandle(h),
  Str='The line object has been deleted.';
  uiwait(msgbox(Str,'modal'));
  delete(h_BackUp);
  guix(fig,'close');
  return;
end;

switch cmd(1),
case 0, % GENERAL PROPERTIES
  switch cmd(2),
%  case 0, % reserved for quit gui_main
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
  
case 1,
  switch cmd(2),
  case 1, % linestyle
    lsttypes=str2mat('-','--',':','-.','none');
    lst=row(lsttypes,get(handles{2}(2),'value'));
    set(h,'linestyle',lst);
  case 2, % line width
    set(h,'linewidth',eval(get(handles{2}(4),'string'),gui_str(get(h,'linewidth'))));
    set(handles{2}(4),'string',gui_str(get(h,'linewidth')));
  case 3, % marker size
    set(h,'markersize',eval(get(handles{2}(6),'string'),gui_str(get(h,'markersize'))));
    set(handles{2}(6),'string',gui_str(get(h,'markersize')));
  case 4, % new data
    ax=get(h,'parent');
    [xdata,ydata,zdata]=ginput3d(ax,'xyz');
    set(h,'xdata',xdata,'ydata',ydata,'zdata',zdata);
    figure(fig);
  case 5, % edit data
    xdata=get(h,'xdata')';
    ydata=get(h,'ydata')';
    zdata=get(h,'zdata')';
    if (size(xdata)==size(ydata)),
      if (size(ydata)==size(zdata)),
        set(fig,'visible','off');
        [xdata,ydata,zdata]=md_edit(xdata,ydata,zdata,'multiple',{'x','y','z'}, ...
            'dimlabel',{'line' 'point'}, ...
            'label',{'123' '123'});
        set(h,'xdata',xdata,'ydata',ydata,'zdata',zdata);
        set(fig,'visible','on');
      elseif isempty(zdata),
        set(fig,'visible','off');
        [xdata,ydata]=md_edit(xdata,ydata,'multiple',{'x','y'}, ...
            'dimlabel',{'line' 'point'}, ...
            'label',{'123' '123'});
        set(h,'xdata',xdata,'ydata',ydata);
        set(fig,'visible','on');
      else,
        fprintf(1,'* Length of X, Y and Z data not identical.\n');
      end;
    else,
      fprintf(1,'* Length of X and Y data not identical.\n');
    end;
  case 6, % erasemode
    ermodtypes=str2mat('normal','background','xor','none');
    ermod=row(ermodtypes,get(handles{2}(10),'value'));
    set(h,'erasemode',ermod);
  case 7, % marker symbol
    msttypes=str2mat('+','o','*','.','x','square','diamond','v','^','>','<','pentagram','hexagram','none');
    mst=row(msttypes,get(handles{2}(12),'value'));
    set(h,'marker',mst);
  case 8, % marker edge color
    coltyp=str2mat('none','auto','colorspec');
    colspec=row(coltyp,get(handles{2}(14),'value'));
    if strcmp(colspec,'colorspec'),
      while any(size(colspec)~=[1 3])
        colspec=md_color;
      end;
      set(h,'markeredgecolor',colspec);
      set(handles{2}(16),'facecolor',colspec);
    else,
      set(h,'markeredgecolor',colspec);
      set(handles{2}(16),'facecolor','none');
    end;
  case 9, % marker face color
    coltyp=str2mat('none','auto','colorspec');
    colspec=row(coltyp,get(handles{2}(18),'value'));
    if strcmp(colspec,'colorspec'),
      while any(size(colspec)~=[1 3])
        colspec=md_color;
      end;
      set(h,'markerfacecolor',colspec);
      set(handles{2}(20),'facecolor',colspec);
    else,
      set(h,'markerfacecolor',colspec);
      set(handles{2}(20),'facecolor','none');
    end;
  case 10, % select color
    set(handles{2}(22),'backgroundcolor',md_color(h));
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
    set(handles{3}(5),'string',selon);
  case 5, % selectionhighlight
    selon=logicalswitch(strcmp(get(h,'selectionhighlight'),'on'),'off','on');
    set(h,'selectionhighlight',selon);
    set(handles{3}(7),'string',selon);
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
    set(handles{3}(11),'string',busac);
  case 9, % toggle of clipping
    clipping=logicalswitch(strcmp(get(h,'clipping'),'on'),'off','on');
    set(h,'clipping',clipping);
    set(handles{3}(13),'string',clipping);
  case 10, % toggle of interruptible
    interrupt=logicalswitch(strcmp(get(h,'interruptible'),'on'),'off','on');
    set(h,'interruptible',interrupt);
    set(handles{3}(15),'string',interrupt);
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
