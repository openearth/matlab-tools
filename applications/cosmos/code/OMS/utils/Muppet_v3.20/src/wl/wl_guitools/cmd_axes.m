function outh=cmd_axes(fig,cmd)
%CMD_AXES execute a GUI_AXES command
%      CMD_AXES(GuiHandle,Command)
%      Executes the Command corresponding to the button clicked
%      in the window indicated by the GuiHandle 

%      Copyright (c) H.R.A. Jagers  12-17-1996

if (nargin~=2),
  fprintf(1,'* Unexpected number of input arguments.\n');
  return;
end;

if ischar(fig),
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
if ~(hname(1:4)=='axes'),
  fprintf(1,'* The first parameter is not a gui AXES handle\n');
  return;
end;

% fig is almost surely a GUITOOLS AXES handle
handles=get(fig,'userdata');

h=get(handles{1}(3),'userdata');
h_BackUp=handles{1}(2);
if ~ishandle(h),
  Str='The axes object has been deleted.';
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

case 1, % TICK ATTRIBUTES
  switch(cmd(2)),
  case 1, % display font window
    uisetfont(h);
    set(handles{2}(2),'string',get(h,'fontname'));
    set(handles{2}(4),'string',gui_str(get(h,'fontsize')));
    set(handles{2}(6),'string',get(h,'fontweight'));
    set(handles{2}(8),'string',get(h,'fontangle'));
    drawnow;
    refresh(get(h,'parent'));
  case 2, % direct edit of fontsize
    set(h,'fontsize',eval(get(handles{2}(4),'string'),gui_str(get(h,'fontsize'))));
    set(handles{2}(4),'string',gui_str(get(h,'fontsize')));
  case 3, % toggle of tickdirection
    tickdir=logicalswitch(strcmp(get(h,'tickdir'),'in'),'out','in');
    set(h,'tickdir',tickdir);
    set(handles{2}(10),'string',tickdir);
  case 4, % edit of ticklength
    v=get(h,'view');
    if (any(v(1)==[-90,0,90,180]) & any(v(2)==[-90,0,90,180])),
      tick_2d=eval(get(handles{2}(12),'string'));
      tick_3d=index(get(h,'ticklength'),2);
      set(h,'ticklength',[tick_2d tick_3d]);
      tick_2d=index(get(h,'ticklength'),1);
      set(handles{2}(12),'string',gui_str(tick_2d));
    else,
      tick_2d=index(get(h,'ticklength'),1);
      tick_3d=eval(get(handles{2}(12),'string'));
      set(h,'ticklength',[tick_2d tick_3d]);
      tick_3d=index(get(h,'ticklength'),2);
      set(handles{2}(12),'string',gui_str(tick_3d));
    end;
  case 5, % tickdir mode
    tdmode=logicalswitch(strcmp(get(h,'tickdirmode'),'auto'),'manual','auto');
    set(h,'tickdirmode',tdmode);
    set(handles{2}(14),'string',tdmode);
    if strcmp(tdmode,'auto'),
      set(handles{2}(9:10), ...
        'enable','off', ...
        'buttondownfcn','');
    else,
      set(handles{2}(9:10), ...
        'enable','on', ...
        'buttondownfcn',['cmd_axes(gcbf,[1 3])']);
    end;
  case 6, % fontunits
    funittypes=str2mat('inches','centimeters','normalized','points','pixels');
    lst=row(funittypes,get(handles{2}(16),'value'));
    set(h,'fontunits',lst);
    set(handles{2}(4),'string',gui_str(get(h,'fontsize')));
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
    axes(h);
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
    axes(h);
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
    axes(h);
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

case 3, % VIEW ATTRIBUTES
  switch(cmd(2)),
  case {1,2}, % view
    % 1 azimuth angle
    % 2 elevation angle
    vw=get(h,'view');
    az=eval(get(handles{4}(2),'string'),gui_str(vw(1)));
    az=az-360*ceil((az-180)/360);
    el=eval(get(handles{4}(4),'string'),gui_str(vw(2)));
    el=el-360*ceil((el-180)/360);
    set(h,'view',[az el]);
    vw=get(h,'view');
    az=vw(1);
    el=vw(2);
    set(handles{4}(2),'string',gui_str(az));
    set(handles{4}(4),'string',gui_str(el));
    tl=get(h,'ticklength');
    if (any(az==[-90,0,90,180]) & any(el==[-90,0,90,180]) &  strcmp(get(h,'projection'),'orthographic')),
      %2D
      set(handles{3}(12),'string',tl(1));
      set(handles{3}(10),'string',get(h,'tickdir'));
      set(handles{4}(6),'string','2D','enable','on');
    else,
      %3D
      set(handles{3}(12),'string',tl(2));
      set(handles{3}(10),'string',get(h,'tickdir'));
      set(handles{4}(6),'string','3D','enable','off');
    end;

  case 3, % edit Xform
    set(fig,'visible','off');
    xform=get(h,'xform');
    xform=md_edit(xform,'label',{{'x','y','z',' '},{'x','y','z',' '}},'dimfixed',[1 1]);
    set(h,'xform',xform);
    set(fig,'visible','on');
  case {4,5,6}, % dataaspectratio
    % 4: X
    % 5: Y
    % 5: Z
    dar=get(h,'dataaspectratio');
    dar(1)=eval(get(handles{4}(8),'string'),gui_str(dar(1)));
    dar(2)=eval(get(handles{4}(10),'string'),gui_str(dar(2)));
    dar(3)=eval(get(handles{4}(12),'string'),gui_str(dar(3)));
    set(h,'dataaspectratio',dar);
    dar=get(h,'dataaspectratio');
    set(handles{4}(8),'string',gui_str(dar(1)));
    set(handles{4}(10),'string',gui_str(dar(2)));
    set(handles{4}(12),'string',gui_str(dar(3)));
  case 7, % dataaspectratiomode
    darmode=logicalswitch(strcmp(get(h,'dataaspectratiomode'),'auto'),'manual','auto');
    set(h,'dataaspectratiomode',darmode);
    set(handles{4}(15),'string',darmode);
    if strcmp(darmode,'auto'),
      set(handles{4}(7:12),'enable','off');
    else,
      set(handles{4}(7:12),'enable','on');
    end;
  case 8, % plotboxaspectratio X
    pbar=get(h,'plotboxaspectratio');
    pbar(1)=eval(get(handles{4}(17),'string'),gui_str(pbar(1)));
    set(h,'plotboxaspectratio',pbar);
    pbar=get(h,'plotboxaspectratio');
    set(handles{4}(17),'string',gui_str(pbar(1)));
  case 9, % plotboxaspectratio Y
    pbar=get(h,'plotboxaspectratio');
    pbar(2)=eval(get(handles{4}(19),'string'),gui_str(pbar(2)));
    set(h,'plotboxaspectratio',pbar);
    pbar=get(h,'plotboxaspectratio');
    set(handles{4}(19),'string',gui_str(pbar(2)));
  case 10, % plotboxaspectratio Z
    pbar=get(h,'plotboxaspectratio');
    pbar(3)=eval(get(handles{4}(21),'string'),gui_str(pbar(3)));
    set(h,'plotboxaspectratio',pbar);
    pbar=get(h,'plotboxaspectratio');
    set(handles{4}(21),'string',gui_str(pbar(3)));
  case 11, % plotboxaspectratiomode
    pbarmode=logicalswitch(strcmp(get(h,'plotboxaspectratiomode'),'auto'),'manual','auto');
    set(h,'plotboxaspectratiomode',pbarmode);
    set(handles{4}(24),'string',pbarmode);
    if strcmp(pbarmode,'auto'),
      set(handles{4}(16:21),'enable','off');
    else,
      set(handles{4}(16:21),'enable','on');
    end;
  case 12, % projection
    proj=logicalswitch(strcmp(get(h,'projection'),'orthographic'),'perspective','orthographic');
    set(h,'projection',proj);
    set(handles{4}(26),'string',proj);
    vw=get(h,'view');
    az=vw(1);
    el=vw(2);
    set(handles{4}(2),'string',gui_str(az));
    set(handles{4}(4),'string',gui_str(el));
    tl=get(h,'ticklength');
    if (any(az==[-90,0,90,180]) & any(el==[-90,0,90,180]) &  strcmp(get(h,'projection'),'orthographic')),
      %2D
      set(handles{3}(12),'string',tl(1));
      set(handles{3}(10),'string',get(h,'tickdir'));
      set(handles{4}(6),'string','2D','enable','on');
    else,
      %3D
      set(handles{3}(12),'string',tl(2));
      set(handles{3}(10),'string',get(h,'tickdir'));
      set(handles{4}(6),'string','3D','enable','off');
    end;
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 4, % PLOT AREA ATTRIBUTES
  switch(cmd(2)),
  case 1, % toggle box
    boxst=logicalswitch(strcmp(get(h,'box'),'on'),'off','on');
    set(h,'box',boxst);
    set(handles{5}(2),'string',boxst);
  case 2, % line width
    lw=eval(get(handles{5}(4),'string'),gui_str(get(h,'linewidth')));
    set(h,'linewidth',lw);
    set(handles{5}(4),'string',gui_str(get(h,'linewidth')));
  case 3, % toggle of layer
    layer=logicalswitch(strcmp(get(h,'layer'),'top'),'bottom','top');
    set(h,'layer',layer);
    set(handles{5}(6),'string',layer);
  case 4, % toggle of drawmode
    drawmode=logicalswitch(strcmp(get(h,'drawmode'),'normal'),'fast','normal');
    set(h,'drawmode',drawmode);
    set(handles{5}(8),'string',drawmode);
  case 5, % nextplot
    plottypes=str2mat('add','replace','replacechildren');
    lst=row(plottypes,get(handles{5}(10),'value'));
    set(h,'nextplot',lst);
  case 8, % gridlinestyle
    gridstyles=str2mat('-','--',':','-.');
    lst=row(gridstyles,get(handles{5}(16),'value'));
    set(h,'gridlinestyle',lst);
  case 9, % minorgridlinestyle
    gridstyles=str2mat('-','--',':','-.');
    lst=row(gridstyles,get(handles{5}(18),'value'));
    set(h,'minorgridlinestyle',lst);
  case 10, % background color
    coltyp=str2mat('none','colorspec');
    colspec=row(coltyp,get(handles{5}(20),'value'));
    if strcmp(colspec,'colorspec'),
      while any(size(colspec)~=[1 3])
        colspec=md_color;
      end;
      set(h,'color',colspec);
      set(handles{5}(22),'facecolor',colspec);
    else,
      set(h,'color',colspec);
      set(handles{5}(22),'facecolor','none');
    end;
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 5, % COLOR ATTRIBUTES
  switch(cmd(2)),
  case 1, % climmode
    if strcmp(get(handles{6}(2),'string'),'manual'),
      set(handles{6}(2),'string','auto');
      set(h,'climmode','auto');
      set(handles{6}(3:6),'enable','off');
    else,
      set(handles{6}(2),'string','manual');
      set(h,'climmode','manual');
      clim=get(h,'clim');

      set(handles{6}(3:6),'enable','on');
      set(handles{6}(4),'string',gui_str(clim(1)));
      set(handles{6}(6),'string',gui_str(clim(2)));
    end;
  case 2, % clim min
    clim=get(h,'clim');
    climmin=eval(get(handles{6}(4),'string'),gui_str(clim(1)));
    if (climmin>clim(2)),
      clim=[clim(2) climmin];
    else,
      clim=[climmin clim(2)];
    end;
    if (clim(1)==clim(2)), clim(1)=clim(1)-1; end;
    set(h,'clim',clim);
    set(handles{6}(4),'string',gui_str(clim(1)));
    set(handles{6}(6),'string',gui_str(clim(2)));
  case 3, % clim max
    clim=get(h,'clim');
    climmax=eval(get(handles{6}(6),'string'),gui_str(clim(2)));
    if (climmax<clim(1)),
      clim=[climmax clim(1)];
    else,
      clim=[clim(1) climmax];
    end;
    if (clim(1)==clim(2)), clim(2)=clim(2)+1; end;
    set(h,'clim',clim);
    set(handles{6}(4),'string',gui_str(clim(1)));
    set(handles{6}(6),'string',gui_str(clim(2)));
  case 4, % edit colororder
    set(fig,'visible','off');
    colororder=get(h,'colororder');
    colororder=md_edit(colororder,'label',{'123' {'red';'green';'blue'}},'dimfixed',[0 1]);
    set(h,'colororder',colororder);
    set(fig,'visible','on');
  case 5, % ambient light color
    clr=md_color(get(h,'ambientlightcolor'));
    set(h,'ambientlightcolor',clr);
    set(handles{6}(9),'backgroundcolor',clr);
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 6, % X AXES PROPERTIES
  switch(cmd(2)),
  case 1, % toggle x grid
    if strcmp(get(h,'xgrid'),'on'),
      set(handles{7}(2),'string','off');
      if strcmp(get(h,'xminorgrid'),'on'),
        set(h,'xgrid','off','xminorgrid','off');
        set(handles{7}(4),'string','off');
      else,
        set(h,'xgrid','off');
      end;
    else,
      set(h,'xgrid','on');
      set(handles{7}(2),'string','on');
    end;
  case 2, % toggle x minor grid
    if strcmp(get(h,'xminorgrid'),'on'),
      set(h,'xminorgrid','off');
      set(handles{7}(4),'string','off');
    else,
      set(handles{7}(4),'string','on');
      if strcmp(get(h,'xgrid'),'off'),
        set(h,'xminorgrid','on','xgrid','on');
        set(handles{7}(2),'string','on');
      else,
        set(h,'xminorgrid','on');
      end;
    end;
  case 3, % toggle x minor ticks
    tickon=logicalswitch(strcmp(get(h,'xminortick'),'on'),'off','on');
    set(h,'xminortick',tickon);
    set(handles{7}(6),'string',tickon);
  case 4, % toggle x direction
    axdir=logicalswitch(strcmp(get(h,'xdir'),'normal'),'reverse','normal');
    set(h,'xdir',axdir);
    set(handles{7}(8),'string',axdir);
  case 5, % toggle x scale
    if strcmp(get(h,'xscale'),'linear'),
      set(h,'xscale','log');
      set(handles{7}(10),'string','log');
      set(handles{7}(3:6),'enable','off');
    else,
      set(h,'xscale','linear');
      set(handles{7}(10),'string','linear');
      set(handles{7}(3:6),'enable','on');
    end;
  case 6, % toggle x axis location
    axloc=logicalswitch(strcmp(get(h,'xaxislocation'),'bottom'),'top','bottom');
    set(h,'xaxislocation',axloc);
    set(handles{7}(12),'string',axloc);
  case 7, % x axes color
    newcolor=md_color(get(h,'xcolor'));
    set(handles{7}(14),'backgroundcolor',newcolor);
    set(h,'xcolor',newcolor);
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 7, % X LIMITS / TICKS
  switch(cmd(2)),
  case 1,
    if strcmp(get(handles{8}(2),'string'),'manual'),
      set(handles{8}(2),'string','auto');
      set(h,'xlimmode','auto');

      set(handles{8}(3:6),'enable','off');
    else,
      set(handles{8}(2),'string','manual');
      set(h,'xlimmode','manual');
      xlim=get(h,'xlim');
      set(handles{8}(3:6),'enable','on');
      set(handles{8}(4),'string',gui_str(xlim(1)));
      set(handles{8}(6),'string',gui_str(xlim(2)));
    end;
  case 2,
    xlim=get(h,'xlim');
    xlimmin=eval(get(handles{8}(4),'string'),gui_str(xlim(1)));
    if (xlimmin>xlim(2)),
      xlim=[xlim(2) xlimmin];
    else,
      xlim=[xlimmin xlim(2)];
    end;
    if (xlim(1)==xlim(2)), xlim(1)=xlim(1)-1; end;
    set(h,'xlim',xlim);
    set(handles{8}(4),'string',gui_str(xlim(1)));
    set(handles{8}(6),'string',gui_str(xlim(2)));
  case 3,
    xlim=get(h,'xlim');
    xlimmax=eval(get(handles{8}(6),'string'),gui_str(xlim(2)));
    if (xlimmax<xlim(1)),
      xlim=[xlimmax xlim(1)];
    else,
      xlim=[xlim(1) xlimmax];
    end;
    if (xlim(1)==xlim(2)), xlim(2)=xlim(2)+1; end;
    set(h,'xlim',xlim);
    set(handles{8}(4),'string',gui_str(xlim(1)));
    set(handles{8}(6),'string',gui_str(xlim(2)));
  case 4,
    if strcmp(get(handles{8}(8),'string'),'manual'),
      set(handles{8}(8),'string','auto');
      set(handles{8}(12),'string','auto');
      set(h,'xtickmode','auto');
      set(h,'xticklabelmode','auto');
      set(handles{8}(9:12),'enable','off');
    else,
      set(handles{8}(8),'string','manual');
      set(h,'xtickmode','auto');
      set(handles{8}(9:12),'enable','on');
    end;
  case 5,
    vw=get(h,'view');
    if (vw(1)==90 | vw(1)==-90) & (vw(2)==0 | vw(2)==180),
      fprintf(1,'* Command incompatible with current view.\n');
    else,  
      set(fig,'visible','off');
      axes(h);
      xtick=get(h,'xtick');
      nticks=length(xtick);
      xtick=sort(ginput3d('x'));
      if length(xtick)~=nticks,
        if strcmp(get(h,'xticklabelmode'),'manual'),
          set(handles{8}(12),'string','auto');
          set(h,'xticklabelmode','auto');
        end;
      end;
      set(h,'xtick',xtick');
      set(fig,'visible','on');
    end;
  case 6,
    set(fig,'visible','off');
    xtick=transpose(get(h,'xtick'));
    if strcmp(get(h,'xticklabelmode'),'manual'),
      xticklabel=get(h,'xticklabel');
      [xticklabel,xtick]=md_edit(xticklabel,xtick,'multiple',{'ticklabel','tickvalue'},'dimfixed',[0 1]);
      set(h,'xtick',xtick,'xticklabel',xticklabel);
    else,
      xtick=sort(md_edit(xtick,'label',{'123',{'tick'}},'dimfixed',[0 1]));
      set(h,'xtick',xtick);
    end;
    set(fig,'visible','on');
  case 7,
    labelm=logicalswitch(strcmp(get(handles{8}(12),'string'),'manual'),'auto','manual');
    set(handles{8}(12),'string',labelm);
    set(h,'xticklabelmode',labelm);
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 8, % Y AXES PROPERTIES
  switch(cmd(2)),
  case 1, % toggle y grid
    if strcmp(get(h,'ygrid'),'on'),
      set(handles{9}(2),'string','off');
      if strcmp(get(h,'yminorgrid'),'on'),
        set(h,'ygrid','off','yminorgrid','off');
        set(handles{9}(4),'string','off');
      else,
        set(h,'ygrid','off');
      end;
    else,
      set(h,'ygrid','on');
      set(handles{9}(2),'string','on');
    end;
  case 2, % toggle y minor grid
    if strcmp(get(h,'yminorgrid'),'on'),
      set(h,'yminorgrid','off');
      set(handles{9}(4),'string','off');
    else,
      set(handles{9}(4),'string','on');
      if strcmp(get(h,'ygrid'),'off'),
        set(h,'yminorgrid','on','ygrid','on');
        set(handles{9}(2),'string','on');
      else,
        set(h,'yminorgrid','on');
      end;
    end;
  case 3, % toggle y minor ticks
    tickon=logicalswitch(strcmp(get(h,'yminortick'),'on'),'off','on');
    set(h,'yminortick',tickon);
    set(handles{9}(6),'string',tickon);
  case 4, % toggle y direction
    axdir=logicalswitch(strcmp(get(h,'ydir'),'normal'),'reverse','normal');
    set(h,'ydir',axdir);
    set(handles{9}(8),'string',axdir);
  case 5, % toggle y scale
    if strcmp(get(h,'yscale'),'linear'),
      set(h,'yscale','log');
      set(handles{9}(10),'string','log');
      set(handles{9}(3:6),'enable','off');
    else,
      set(h,'yscale','linear');
      set(handles{9}(10),'string','linear');
      set(handles{9}(3:6),'enable','on');
    end;
  case 6, % toggle y axis location
    axloc=logicalswitch(strcmp(get(h,'yaxislocation'),'left'),'right','left');
    set(h,'yaxislocation',axloc);
    set(handles{7}(12),'string',axloc);
  case 7, % y axes color
    newcolor=md_color(get(h,'ycolor'));
    set(handles{9}(14),'backgroundcolor',newcolor);
    set(h,'ycolor',newcolor);
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 9, % Y LIMITS / TICKS
  switch(cmd(2)),
  case 1,
    if strcmp(get(handles{10}(2),'string'),'manual'),
      set(handles{10}(2),'string','auto');
      set(h,'ylimmode','auto');
      set(handles{10}(3:6),'enable','off');
    else,
      set(handles{10}(2),'string','manual');
      set(h,'ylimmode','manual');
      ylim=get(h,'ylim');
      set(handles{10}(3:6),'enable','on');
      set(handles{10}(4),'string',gui_str(ylim(1)));
      set(handles{10}(6),'string',gui_str(ylim(2)));
    end;
  case 2,
    ylim=get(h,'ylim');
    ylimmin=eval(get(handles{10}(4),'string'),gui_str(ylim(1)));
    if (ylimmin>ylim(2)),
      ylim=[ylim(2) ylimmin];
    else,
      ylim=[ylimmin ylim(2)];
    end;
    if (ylim(1)==ylim(2)), ylim(1)=ylim(1)-1; end;
    set(h,'ylim',ylim);
    set(handles{10}(4),'string',gui_str(ylim(1)));
    set(handles{10}(6),'string',gui_str(ylim(2)));
  case 3,
    ylim=get(h,'ylim');
    ylimmax=eval(get(handles{10}(6),'string'),gui_str(ylim(2)));
    if (ylimmax<ylim(1)),
      ylim=[ylimmax ylim(1)];
    else,
      ylim=[ylim(1) ylimmax];
    end;
    if (ylim(1)==ylim(2)), ylim(2)=ylim(2)+1; end;
    set(h,'ylim',ylim);
    set(handles{10}(4),'string',gui_str(ylim(1)));
    set(handles{10}(6),'string',gui_str(ylim(2)));
  case 4,
    if strcmp(get(handles{10}(8),'string'),'manual'),
      set(handles{10}(8),'string','auto');
      set(handles{10}(12),'string','auto');
      set(h,'ytickmode','auto');
      set(h,'yticklabelmode','auto');
      set(handles{10}(9:12),'enable','off');
    else,
      set(handles{10}(8),'string','manual');
      set(h,'ytickmode','auto');
      set(handles{10}(9:12),'enable','on');
    end;
  case 5,
    vw=get(h,'view');
    if (vw(1)==0 | vw(1)==180) & (vw(2)==0 | vw(2)==180),
      fprintf(1,'* Command incompatible with current view.\n');
    else,  
      set(fig,'visible','off');
      axes(h);
      ytick=get(h,'ytick');
      nticks=length(ytick);
      ytick=sort(ginput3d('y'));
      if length(ytick)~=nticks,
        if strcmp(get(h,'yticklabelmode'),'manual'),
          set(handles{10}(12),'string','auto');
          set(h,'yticklabelmode','auto');
        end;
      end;
      set(h,'ytick',ytick');
      set(fig,'visible','on');
    end;
  case 6,
    set(fig,'visible','off');
    ytick=transpose(get(h,'ytick'));
    if strcmp(get(h,'yticklabelmode'),'manual'),
      yticklabel=get(h,'yticklabel');
      [yticklabel,ytick]=md_edit(yticklabel,ytick,'multiple',{'ticklabel','tickvalue'},'dimfixed',[0 1]);
      set(h,'ytick',ytick,'yticklabel',yticklabel);
    else,
      ytick=sort(md_edit(ytick,'label',{'123',{'tick'}},'dimfixed',[0 1]));
      set(h,'ytick',ytick);
    end;
    set(fig,'visible','on');
  case 7,
    labelm=logicalswitch(strcmp(get(handles{10}(12),'string'),'manual'),'auto','manual');
    set(handles{10}(12),'string',labelm);
    set(h,'yticklabelmode',labelm);
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 10, % Z AXES PROPERTIES
  switch(cmd(2)),
  case 1, % toggle z grid
    if strcmp(get(h,'zgrid'),'on'),
      set(handles{11}(2),'string','off');
      if strcmp(get(h,'zminorgrid'),'on'),
        set(h,'zgrid','off','zminorgrid','off');
        set(handles{11}(4),'string','off');
      else,
        set(h,'zgrid','off');
      end;
    else,
      set(h,'zgrid','on');
      set(handles{11}(2),'string','on');
    end;
  case 2, % toggle z minor grid
    if strcmp(get(h,'zminorgrid'),'on'),
      set(h,'zminorgrid','off');
      set(handles{11}(4),'string','off');
    else,
      set(handles{11}(4),'string','on');
      if strcmp(get(h,'zgrid'),'off'),
        set(h,'zminorgrid','on','zgrid','on');
        set(handles{11}(2),'string','on');
      else,
        set(h,'zminorgrid','on');
      end;
    end;
  case 3, % toggle z minor ticks
    tickon=logicalswitch(strcmp(get(h,'zminortick'),'on'),'off','on');
    set(h,'zminortick',tickon);
    set(handles{11}(6),'string',tickon);
  case 4, % toggle z direction
    axdir=logicalswitch(strcmp(get(h,'zdir'),'normal'),'reverse','normal');
    set(h,'zdir',axdir);
    set(handles{11}(8),'string',axdir);
  case 5, % toggle z scale
    if strcmp(get(h,'zscale'),'linear'),
      set(h,'zscale','log');
      set(handles{11}(10),'string','log');
      set(handles{11}(3:6),'enable','off');
    else,
      set(h,'zscale','linear');
      set(handles{11}(10),'string','linear');
      set(handles{11}(3:6),'enable','on');
    end;
  case 7, % color z axis
    newcolor=md_color(get(h,'zcolor'));
    set(handles{11}(14),'backgroundcolor',newcolor);
    set(h,'zcolor',newcolor);
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 11, % Z LIMITS / TICKS
  switch(cmd(2)),
  case 1,
    if strcmp(get(handles{12}(2),'string'),'manual'),
      set(handles{12}(2),'string','auto');
      set(h,'zlimmode','auto');
      set(handles{12}(3:6),'enable','off');
    else,
      set(handles{12}(2),'string','manual');
      set(h,'zlimmode','manual');
      zlim=get(h,'zlim');
      set(handles{12}(3:6),'enable','on');
      set(handles{12}(4),'string',gui_str(zlim(1)));
      set(handles{12}(6),'string',gui_str(zlim(2)));
    end;
  case 2,
    zlim=get(h,'zlim');
    zlimmin=eval(get(handles{12}(4),'string'),gui_str(zlim(1)));
    if (zlimmin>zlim(2)),
      zlim=[zlim(2) zlimmin];
    else,
      zlim=[zlimmin zlim(2)];
    end;
    if (zlim(1)==zlim(2)), zlim(1)=zlim(1)-1; end;
    set(h,'zlim',zlim);
    set(handles{12}(4),'string',gui_str(zlim(1)));
    set(handles{12}(6),'string',gui_str(zlim(2)));
  case 3,
    zlim=get(h,'zlim');
    zlimmax=eval(get(handles{12}(6),'string'),gui_str(zlim(2)));
    if (zlimmax<zlim(1)),
      zlim=[zlimmax zlim(1)];
    else,
      zlim=[zlim(1) zlimmax];
    end;
    if (zlim(1)==zlim(2)), zlim(2)=zlim(2)+1; end;
    set(h,'zlim',zlim);
    set(handles{12}(4),'string',gui_str(zlim(1)));
    set(handles{12}(6),'string',gui_str(zlim(2)));
  case 4,
    if strcmp(get(handles{12}(8),'string'),'manual'),
      set(handles{12}(8),'string','auto');
      set(handles{12}(12),'string','auto');
      set(h,'ztickmode','auto');
      set(h,'zticklabelmode','auto');
      set(handles{12}(9:12),'enable','off');
    else,
      set(handles{12}(8),'string','manual');
      set(h,'ztickmode','auto');
      set(handles{12}(9:12),'enable','on');
    end;
  case 5,
    vw=get(h,'view');
    if vw(2)==90 | vw(2)==-90,
      fprintf(1,'* Command incompatible with current view.\n');
    else,  
      set(fig,'visible','off');
      axes(h);
      ztick=get(h,'ztick');
      nticks=length(ztick);
      ztick=sort(ginput3d('z'));
      if length(ztick)~=nticks,
        if strcmp(get(h,'zticklabelmode'),'manual'),
          set(handles{12}(12),'string','auto');
          set(h,'zticklabelmode','auto');
        end;
      end;
      set(h,'ztick',ztick');
      set(fig,'visible','on');
    end;
  case 6,
    set(fig,'visible','off');
    ztick=transpose(get(h,'ztick'));
    if strcmp(get(h,'zticklabelmode'),'manual'),
      zticklabel=get(h,'zticklabel');
      [zticklabel,ztick]=md_edit(zticklabel,ztick,'multiple',{'ticklabel','tickvalue'},'dimfixed',[0 1]);
      set(h,'ztick',ztick,'zticklabel',zticklabel);
    else,
      ztick=sort(md_edit(ztick,'label',{'123',{'tick'}},'dimfixed',[0 1]));
      set(h,'ztick',ztick);
    end;
    set(fig,'visible','on');
  case 7,
    labelm=logicalswitch(strcmp(get(handles{12}(12),'string'),'manual'),'auto','manual');
    set(handles{12}(12),'string',labelm);
    set(h,'zticklabelmode',labelm);
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 12, % CAMERA ATTRIBUTES
  switch(cmd(2)),
  case 1, % camera up vector mode
    cuvmode=logicalswitch(strcmp(get(h,'cameraupvectormode'),'auto'),'manual','auto');
    set(h,'cameraupvectormode',cuvmode);
    set(handles{13}(2),'string',cuvmode);
    if strcmp(cuvmode,'auto'),
      set(handles{13}(3:8),'enable','off');
    else,
      set(handles{13}(3:8),'enable','on');
    end;
    cuv=get(h,'cameraupvector');
    set(handles{13}(4),'string',gui_str(cuv(1)));
    set(handles{13}(6),'string',gui_str(cuv(2)));
    set(handles{13}(8),'string',gui_str(cuv(3)));
  case 2, % camera up vector x value
    cuv=get(h,'cameraupvector');
    cuv(1)=eval(get(handles{13}(4),'string'),gui_str(cuv(1)));
    set(h,'cameraupvector',cuv);
    cuv=get(h,'cameraupvector');
    set(handles{13}(4),'string',gui_str(cuv(1)));
  case 3, % camera up vector y value
    cuv=get(h,'cameraupvector');
    cuv(2)=eval(get(handles{13}(6),'string'),gui_str(cuv(2)));
    set(h,'cameraupvector',cuv);
    cuv=get(h,'cameraupvector');
    set(handles{13}(6),'string',gui_str(cuv(2)));
  case 4, % camera up vector z value
    cuv=get(h,'cameraupvector');
    cuv(3)=eval(get(handles{13}(8),'string'),gui_str(cuv(3)));
    set(h,'cameraupvector',cuv);
    cuv=get(h,'cameraupvector');
    set(handles{13}(8),'string',gui_str(cuv(3)));
  case 5, % camera position mode
    cpmode=logicalswitch(strcmp(get(h,'camerapositionmode'),'auto'),'manual','auto');
    set(h,'camerapositionmode',cpmode);
    set(handles{13}(10),'string',cpmode);
    if strcmp(cpmode,'auto'),
      set(handles{13}(11:16),'enable','off');
    else,
      set(handles{13}(11:16),'enable','on');
    end;
    cp=get(h,'cameraposition');
    set(handles{13}(12),'string',gui_str(cp(1)));
    set(handles{13}(14),'string',gui_str(cp(2)));
    set(handles{13}(16),'string',gui_str(cp(3)));
  case 6, % camera position x value
    cp=get(h,'cameraposition');
    cp(1)=eval(get(handles{13}(12),'string'),gui_str(cp(1)));
    set(h,'cameraposition',cp);
    cp=get(h,'cameraposition');
    set(handles{13}(12),'string',gui_str(cp(1)));
  case 7, % camera position y value
    cp=get(h,'cameraposition');
    cp(2)=eval(get(handles{13}(14),'string'),gui_str(cp(2)));
    set(h,'cameraposition',cp);
    cp=get(h,'cameraposition');
    set(handles{13}(14),'string',gui_str(cp(2)));
  case 8, % camera position z value
    cp=get(h,'cameraposition');
    cp(3)=eval(get(handles{13}(16),'string'),gui_str(cp(3)));
    set(h,'cameraposition',cp);
    cp=get(h,'cameraposition');
    set(handles{13}(16),'string',gui_str(cp(3)));
  case 9, % camera target mode
    ctmode=logicalswitch(strcmp(get(h,'cameratargetmode'),'auto'),'manual','auto');
    set(h,'cameratargetmode',ctmode);
    set(handles{13}(18),'string',ctmode);
    if strcmp(ctmode,'auto'),
      set(handles{13}(19:24),'enable','off');
    else,
      set(handles{13}(19:24),'enable','on');
    end;
    ct=get(h,'cameratarget');
    set(handles{13}(20),'string',gui_str(ct(1)));
    set(handles{13}(22),'string',gui_str(ct(2)));
    set(handles{13}(24),'string',gui_str(ct(3)));
  case 10, % camera target x value
    ct=get(h,'cameratarget');
    ct(1)=eval(get(handles{13}(20),'string'),gui_str(ct(1)));
    set(h,'cameratarget',ct);
    ct=get(h,'cameratarget');
    set(handles{13}(20),'string',gui_str(ct(1)));
  case 11, % camera target y value
    ct=get(h,'cameratarget');
    ct(2)=eval(get(handles{13}(22),'string'),gui_str(ct(2)));
    set(h,'cameratarget',ct);
    ct=get(h,'cameratarget');
    set(handles{13}(22),'string',gui_str(ct(2)));
  case 12, % camera target z value
    ct=get(h,'cameratarget');
    ct(3)=eval(get(handles{13}(24),'string'),gui_str(ct(3)));
    set(h,'cameratarget',ct);
    ct=get(h,'cameratarget');
    set(handles{13}(24),'string',gui_str(ct(3)));
  case 13, % camera view angle mode
    cvamode=logicalswitch(strcmp(get(h,'cameraviewanglemode'),'auto'),'manual','auto');
    set(h,'cameraviewanglemode',cvamode);
    set(handles{13}(26),'string',cvamode);
    if strcmp(cvamode,'auto'),
      set(handles{13}(27:28),'enable','off');
    else,
      set(handles{13}(27:28),'enable','on');
    end;
    cva=get(h,'cameraviewangle');
    set(handles{13}(28),'string',gui_str(cva));
  case 14, % camera view angle
    cva=get(h,'cameraviewangle');
    cva=eval(get(handles{13}(28),'string'),gui_str(cva));
    set(h,'cameraviewangle',cva);
    cva=get(h,'cameraviewangle');
    set(handles{13}(28),'string',gui_str(cva));
  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 13, % CHILDREN
  switch(cmd(2)),
  case 1, % refresh list of children
    [chld,names]=childlist(h);
    set(handles{14}(2),'string',names,'userdata',chld,'value',1,'listboxtop',1);
    set(handles{14}(3),'enable',logicalswitch(isempty(chld),'off','on'));
    set(handles{14}(10),'enable',logicalswitch(isempty(chld),'off','on'));
    
  case 2, % open gui for selected child
    object=get(handles{14}(2),'value');
    handle=get(handles{14}(2),'userdata');
    handle=handle(object);
    if ishandle(handle),
      eval(['gui_',get(handle,'type'),'(handle)']);
    else, % refresh
      cmd_axes(fig,[13 1]);
    end;

  case 3, % create line
    newh=line('parent',h);
    gui_line(newh);
    cmd_axes(fig,[13 1]);

  case 4, % create text
    newh=text('parent',h);
    gui_text(newh);
    cmd_axes(fig,[13 1]);

  case 5, % create surface
    newh=surface('parent',h);
    gui_surface(newh);
    cmd_axes(fig,[13 1]);

  case 6, % create patch
    newh=patch('parent',h);
    gui_patch(newh);
    cmd_axes(fig,[13 1]);

  case 7, % create image
    newh=image('parent',h);
    gui_image(newh);
    cmd_axes(fig,[13 1]);

  case 8, % create light
    newh=light('parent',h);
    gui_light(newh);
    cmd_axes(fig,[13 1]);

  case 9, % put child on top
    object=get(handles{14}(2),'value');
    handle=get(handles{14}(2),'userdata');
    handle=handle(object);
    if ishandle(handle),
      handles=allchild(h);
      J=find(handles==handle);
      NotJ=find(handles~=handle);
      handles=[handles(J); handles(NotJ)];
      set(h,'child',handles);
      cmd_axes(fig,[13 1]);
    else, % refresh
      cmd_axes(fig,[13 1]);
    end;

  otherwise,
    fprintf(1,'* Unknown command.\n');
  end;

case 14, % OTHER ATTRIBUTES
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
    set(handles{15}(5),'string',selon);
  case 5, % selectionhighlight
    selon=logicalswitch(strcmp(get(h,'selectionhighlight'),'on'),'off','on');
    set(h,'selectionhighlight',selon);
    set(handles{15}(7),'string',selon);
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
    set(handles{15}(11),'string',busac);
  case 9, % toggle of clipping
    clipping=logicalswitch(strcmp(get(h,'clipping'),'on'),'off','on');
    set(h,'clipping',clipping);
    set(handles{15}(13),'string',clipping);
  case 10, % toggle of interruptible
    interrupt=logicalswitch(strcmp(get(h,'interruptible'),'on'),'off','on');
    set(h,'interruptible',interrupt);
    set(handles{15}(15),'string',interrupt);
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
