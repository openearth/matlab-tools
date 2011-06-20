function outh=cmd_patch(fig,cmd)
%CMD_PATCH execute a GUI_PATCH command
%      CMD_PATCH(GuiHandle,Command)
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
if ~strcmp(hname(1:4),'patc'),
  fprintf(1,'* The first parameter is not a gui PATCH handle\n');
  return;
end;

% fig is almost surely a GUITOOLS PATCH handle
handles=get(fig,'userdata');

h=get(handles{1}(3),'userdata');
h_BackUp=handles{1}(2);
if ~ishandle(h),
  Str='The patch object has been deleted.';
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
  case 1, % face color
    coltypes=str2mat('none','flat','interp','colorspec');
    colspec=row(coltypes,get(handles{2}(2),'value'));
    if strcmp(colspec,'colorspec'),
      while any(size(colspec)~=[1 3])
        colspec=md_color;
      end;
      set(h,'facecolor',colspec);
      set(handles{2}(4),'facecolor',colspec);
    else,
      set(h,'facecolor',colspec);
      set(handles{2}(4),'facecolor','none');
    end;
  case 3, % edge color
    coltypes=str2mat('none','flat','interp','colorspec');
    colspec=row(coltypes,get(handles{2}(6),'value'));
    if strcmp(colspec,'colorspec'),
      while any(size(colspec)~=[1 3])
        colspec=md_color;
      end;
      set(h,'edgecolor',colspec);
      set(handles{2}(8),'facecolor',colspec);
    else,
      set(h,'edgecolor',colspec);
      set(handles{2}(8),'facecolor','none');
    end;
  case 6, % new data
    colr1=get(h,'facecolor');
    colr2=get(h,'edgecolor');
    ax=get(h,'parent');
    [xdata,ydata,zdata]=ginput3d(ax,'xyz');
    cdata=get(h,'cdata');
    if strcmp(colr1,'interp') | strcmp(colr2,'interp') | strcmp(colr1,'flat') | strcmp(colr2,'flat'),
      if size(cdata)~=size(xdata),
        if ~isempty(cdata),
          i=1:size(xdata,2);
          i1=size(cdata,2);
          j=1:size(xdata,1);
          j1=size(cdata,1);
          cdata=cdata(j+j1-j1*round(j/j1),i+i1-i1*round(i/i1));
        else,
          clim=get(get(h,'parent'),'clim');
          cdata=ones(size(xdata,1),1)*(clim(1)+(clim(2)-clim(1))*(1:size(xdata,2))/size(xdata,2));
        end;
        set(h,'xdata',xdata,'ydata',ydata,'zdata',zdata,'cdata',cdata);
      else,
        set(h,'xdata',xdata,'ydata',ydata,'zdata',zdata);
      end;
    else,
      if size(cdata)~=size(xdata),
        cdata=[];
        set(h,'xdata',xdata,'ydata',ydata,'zdata',zdata,'cdata',cdata);
      else,
        set(h,'xdata',xdata,'ydata',ydata,'zdata',zdata);
      end;
    end;
    figure(fig);
  case 7, % edit data
    xdata=get(h,'xdata')';
    ydata=get(h,'ydata')';
    zdata=get(h,'zdata')';
    cdata=get(h,'cdata')';
    if (size(xdata)==size(ydata)),
      if (size(xdata)==size(zdata)),
        if isempty(cdata),
          set(fig,'visible','off');
          [xdata,ydata,zdata]=md_edit(xdata,ydata,zdata, ...
            'multiple',{'x','y','z'}, ...
            'dimlabel',{'patch' 'point'}, ...
            'label',{'123' '123'});
          set(h,'xdata',xdata,'ydata',ydata,'zdata',zdata);
          set(fig,'visible','on');
        else,
          if (size(xdata)~=size(cdata)),
            i=1:size(xdata,2);
            i1=size(cdata,2);
            j=1:size(xdata,1);
            j1=size(cdata,1);
            cdata=cdata(j+j1-j1*round(j/j1),i+i1-i1*round(i/i1));
          end;
          set(fig,'visible','off');
          [xdata,ydata,zdata,cdata]=md_edit(xdata,ydata,zdata,cdata, ...
            'multiple',{'x','y','z','color'}, ...
            'dimlabel',{'patch' 'point'}, ...
            'label',{'123' '123'});
          set(h,'xdata',xdata,'ydata',ydata,'zdata',zdata,'cdata',cdata);
          set(fig,'visible','on');
        end;
      elseif isempty(zdata),
        if isempty(cdata),
          set(fig,'visible','off');
          [xdata,ydata]=md_edit(xdata,ydata, ...
            'multiple',{'x','y'}, ...
            'dimlabel',{'patch' 'point'}, ...
            'label',{'123' '123'});
          set(h,'xdata',xdata,'ydata',ydata);
          set(fig,'visible','on');
        else,
          if (size(xdata)~=size(cdata)),
            i=1:size(xdata,2);
            i1=size(cdata,2);
            j=1:size(xdata,1);
            j1=size(cdata,1);
            cdata=cdata(j+j1-j1*round(j/j1),i+i1-i1*round(i/i1));
          end;
          set(fig,'visible','off');
          [xdata,ydata,cdata]=md_edit(xdata,ydata,cdata, ...
            'multiple',{'x','y','color'}, ...
            'dimlabel',{'patch' 'point'}, ...
            'label',{'123' '123'});
          set(h,'xdata',xdata,'ydata',ydata,'cdata',cdata);
          set(fig,'visible','on');
        end;
      else,
        fprintf(1,'* Size of Z not equal to size of X and Y.\n');
      end;
    else,
      fprintf(1,'* Size of Y not equal to size of X.\n');
    end;
  case 8, % cdatamapping
    pm=logicalswitch(strcmp(get(handles{2}(14),'string'),'direct'),'scaled','direct');
    set(h,'cdatamapping',pm);
    set(handles{2}(14),'string',pm);
  case 9, % erasemode
    ermodtypes=str2mat('normal','background','xor','none');
    ermod=row(ermodtypes,get(handles{2}(16),'value'));
    set(h,'erasemode',ermod);
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 2, % LINE ATTRIBUTES
  switch(cmd(2)),
  case 1, % linestyle
    lsttypes=str2mat('-','--',':','-.','none');
    lst=row(lsttypes,get(handles{3}(2),'value'));
    set(h,'linestyle',lst);
  case 2, % line width
    set(h,'linewidth',eval(get(handles{3}(4),'string'),gui_str(get(h,'linewidth'))));
    set(handles{3}(4),'string',gui_str(get(h,'linewidth')));
  case 3, % marker size
    set(h,'markersize',eval(get(handles{3}(6),'string'),gui_str(get(h,'markersize'))));
    set(handles{3}(6),'string',gui_str(get(h,'markersize')));
  case 7, % marker symbol
    msttypes=str2mat('+','o','*','.','x','square','diamond','v','^','>','<','pentagram','hexagram','none');
    mst=row(msttypes,get(handles{3}(12),'value'));
    set(h,'marker',mst);
  case 8, % marker edge color
    coltyp=str2mat('none','auto','colorspec');
    colspec=row(coltyp,get(handles{3}(14),'value'));
    if strcmp(colspec,'colorspec'),
      while any(size(colspec)~=[1 3])
        colspec=md_color;
      end;
      set(h,'markeredgecolor',colspec);
      set(handles{3}(16),'facecolor',colspec);
    else,
      set(h,'markeredgecolor',colspec);
      set(handles{3}(16),'facecolor','none');
    end;
  case 9, % marker face color
    coltyp=str2mat('none','auto','colorspec');
    colspec=row(coltyp,get(handles{3}(18),'value'));
    if strcmp(colspec,'colorspec'),
      while any(size(colspec)~=[1 3])
        colspec=md_color;
      end;
      set(h,'markerfacecolor',colspec);
      set(handles{3}(20),'facecolor',colspec);
    else,
      set(h,'markerfacecolor',colspec);
      set(handles{3}(20),'facecolor','none');
    end;
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 3, % LIGHTING
  switch(cmd(2)),
  case 1, % facelighting
    lghtypes=str2mat('none','flat','gouraud','phong');
    lgh=row(lghtypes,get(handles{4}(2),'value'));
    set(h,'facelighting',lgh);
  case 2, % edgelighting
    lghtypes=str2mat('none','flat','gouraud','phong');
    lgh=row(lghtypes,get(handles{4}(4),'value'));
    set(h,'edgelighting',lgh);
  case 3, % backfacelighting
    bfltypes=str2mat('unlit','lit','reverselit');
    bfl=row(bfltypes,get(handles{4}(6),'value'));
    set(h,'backfacelighting',bfl);
  case 4, % ambient strength
    set(h,'ambientstrength',eval(get(handles{4}(8),'string'),gui_str(get(h,'ambientstrength'))));
    set(handles{4}(8),'string',gui_str(get(h,'ambientstrength')));
  case 5, % diffuse strength
    set(h,'diffusestrength',eval(get(handles{4}(10),'string'),gui_str(get(h,'diffusestrength'))));
    set(handles{4}(10),'string',gui_str(get(h,'diffusestrength')));
  case 6, % specular strength
    set(h,'specularstrength',eval(get(handles{4}(12),'string'),gui_str(get(h,'specularstrength'))));
    set(handles{4}(12),'string',gui_str(get(h,'specularstrength')));
  case 7, % specular exponent
    set(h,'specularexponent',eval(get(handles{4}(14),'string'),gui_str(get(h,'specularexponent'))));
    set(handles{4}(14),'string',gui_str(get(h,'specularexponent')));
  case 8, % specular color reflectance
    set(h,'specularcolorreflectance',eval(get(handles{4}(16),'string'),gui_str(get(h,'specularcolorreflectance'))));
    set(handles{4}(16),'string',gui_str(get(h,'specularcolorreflectance')));
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 4, % TRIANGULAR MESH
  switch(cmd(2)),
  case 1, % normal mode
    if strcmp(get(h,'normalmode'),'auto'),
      set(h,'normalmode','manual');
      set(handles{5}(2),'string','manual');
      set(handles{5}(3),'enable','on');
    else,
      set(h,'normalmode','auto');
      set(handles{5}(2),'string','auto');
      set(handles{5}(3),'enable','off');
    end;
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 5, % OTHER ATTRIBUTES
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
    set(handles{6}(5),'string',selon);
  case 5, % selectionhighlight
    selon=logicalswitch(strcmp(get(h,'selectionhighlight'),'on'),'off','on');
    set(h,'selectionhighlight',selon);
    set(handles{6}(7),'string',selon);
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
    set(handles{6}(11),'string',busac);
  case 9, % toggle of clipping
    clipping=logicalswitch(strcmp(get(h,'clipping'),'on'),'off','on');
    set(h,'clipping',clipping);
    set(handles{6}(13),'string',clipping);
  case 10, % toggle of interruptible
    interrupt=logicalswitch(strcmp(get(h,'interruptible'),'on'),'off','on');
    set(h,'interruptible',interrupt);
    set(handles{6}(15),'string',interrupt);
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
