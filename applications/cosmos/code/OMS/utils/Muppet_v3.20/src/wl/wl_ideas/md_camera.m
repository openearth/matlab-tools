function Out=md_camera(cmd,AxesList),
% MD_CAMERA creates a menu
% MD_CAMERA('suspend',fig) suspends the usage of md_camera
%   for the specified figure

% (c) 1999, H.R.A. Jagers
%           University of Twente / WL | Delft Hydraulics, The Netherlands

% to be added: camera rotate
%
% also camera xrotate, ...? -> add check mark for target/camera manipulation
%                              reduces length of menu

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
  switch get(fig,'type'),
  case 'axes',
    if nargin<2,
      AxesList=fig;
    end;
    fig=get(fig,'parent');
  case 'figure',
    if nargin<2,
      AxesList=findobj(fig,'type','axes');
    end;
  end;
  UIM=findobj(fig,'tag','md_camera camera uimenu');
  if nargout>0, Out=UIM; end;
  if ~isempty(UIM),
    RotInfo=get(UIM,'userdata');
    AxesList=setdiff(AxesList,RotInfo.AxesList);
    if isempty(AxesList),
      return;
    end;
    AXL=findobj(UIM,'label','&select axes');
    names=listnames(AxesList);
    for i=1:length(AxesList),
      uimenu('parent',AXL,'label',names{i},'separator','off','callback','md_camera axesmenu','userdata',AxesList(i));
    end;
%    if isempty(RotInfo.AxesList) & ~isempty(AxesList),
%      set(allchild(UIM),'enable','on');
%    end;
%    set(allchild(AXL),'checked','off');
    set(findobj(AXL,'userdata',AxesList(1)),'checked','on');
    RotInfo.CurrentAxes = AxesList(1);
    RotInfo.AxesList=union(AxesList,RotInfo.AxesList);
    set(UIM,'userdata',RotInfo);
    set(AxesList, ...
            'CameraPositionMode','manual', ...
            'CameraTargetMode','manual', ...
            'CameraUpVectorMode','manual', ...
            'CameraViewAngleMode','manual', ...
            'XLimMode','manual', ...
            'YLimMode','manual', ...
            'ZLimMode','manual', ...
            'DataAspectRatioMode','manual');
    return;
  end;
  UIM=uimenu('parent',fig,'label','&Camera','tag','md_camera camera uimenu');
  if nargout>0, Out=UIM; end;
  uimenu('parent',UIM,'enable','on','label','s&uspend','checked','on','callback','md_camera suspend');
  AXL=uimenu('parent',UIM,'separator','on','enable','off','label','&select axes','checked','off','callback','md_camera menu');
  VPR=uimenu('parent',UIM,'enable','off','label','viewpoint re&corder','checked','off','callback','md_camera menu');
  uimenu('parent',UIM,'enable','off','label','camera &motion playback','separator','off','checked','off','callback','md_camera menu');
  uimenu('parent',VPR,'enable','on','label','&add','checked','off','callback','md_camera recmenu');
  uimenu('parent',VPR,'enable','on','label','&load','checked','off','callback','md_camera recmenu');
  uimenu('parent',VPR,'enable','on','label','&save','checked','off','callback','md_camera recmenu');
  uimenu('parent',UIM,'enable','off','label','&pan','separator','on','checked','off','callback','md_camera menu');
  uimenu('parent',UIM,'enable','off','label','&elevation','separator','off','checked','off','callback','md_camera menu');
  uimenu('parent',UIM,'enable','off','label','&zoom','checked','off','callback','md_camera menu');
%  uimenu('parent',UIM,'label','distance &target','checked','off','callback','md_camera menu');
  uimenu('parent',UIM,'enable','off','label','&x rotate','checked','off','callback','md_camera menu');
  uimenu('parent',UIM,'enable','off','label','&y rotate','checked','off','callback','md_camera menu');
  uimenu('parent',UIM,'enable','off','label','&z rotate','checked','off','callback','md_camera menu');
  uimenu('parent',UIM,'enable','off','label','&rotate','checked','on','callback','md_camera menu');
  uimenu('parent',UIM,'enable','off','label','&horizontal scale','separator','on','checked','off','callback','md_camera menu');
  uimenu('parent',UIM,'enable','off','label','&vertical scale','checked','off','callback','md_camera menu');
  uimenu('parent',UIM,'enable','off','label','pan &view','checked','off','callback','md_camera menu');
  uimenu('parent',UIM,'enable','off','label','camera e&levation','separator','on','checked','off','callback','md_camera menu');
  uimenu('parent',UIM,'enable','off','label','camera p&an','separator','off','checked','off','callback','md_camera menu');
  uimenu('parent',UIM,'enable','off','label','camera r&oll','checked','off','callback','md_camera menu');
%  uimenu('parent',UIM,'enable','off','label','camera r&otate','checked','off','callback','md_camera menu');
  uimenu('parent',UIM,'enable','off','label','camera vie&wangle','checked','off','callback','md_camera menu');
  uimenu('parent',UIM,'enable','off','label','perspective &distortion','checked','off','callback','md_camera menu');
  uimenu('parent',UIM,'enable','off','label','move as &box','checked','on','callback','md_camera menu');
  uimenu('parent',UIM,'enable','off','label','toggle &perspective','checked','off','callback','md_camera menu');
  uimenu('parent',UIM,'enable','off','label','opt&ions','separator','on','checked','off','callback','md_camera menu');
  uimenu('parent',UIM,'enable','off','label','&done','separator','on','callback','md_camera menu');
  if ~isstandalone
    pause(0); % fixes the problem with md_camera(gca) when no current axes exists
  end
  set(AxesList, ...
          'CameraPositionMode','manual', ...
          'CameraTargetMode','manual', ...
          'CameraUpVectorMode','manual', ...
          'CameraViewAngleMode','manual', ...
          'XLimMode','manual', ...
          'YLimMode','manual', ...
          'ZLimMode','manual', ...
          'DataAspectRatioMode','manual');

  if isempty(AxesList),
    RotInfo.CurrentAxes = [];
  else,
    RotInfo.CurrentAxes = AxesList(1);
    names=listnames(AxesList);
    for i=1:length(AxesList),
      uimenu('parent',AXL,'label',names{i},'separator','off','checked','off','callback','md_camera axesmenu','userdata',AxesList(i));
    end;
    set(findobj(AXL,'userdata',AxesList(1)),'checked','on');
  end;
  RotInfo.AxesList = AxesList;
  RotInfo.Sensitivity = 1;
  RotInfo.wbuf = '';
  RotInfo.wbdf = '';
  RotInfo.wbmf = '';
  RotInfo.bdf  = '';
  % Backup for UNDO LAST
  RotInfo.BackupAxes = [];
  RotInfo.BackupProps = {};
  set(UIM,'userdata',RotInfo);

case 'axesmenu',
  Axes=get(gcbo,'userdata');
  if ishandle(Axes) & isequal(get(Axes,'parent'),gcbf),
    UIM=findobj(gcbf,'tag','md_camera camera uimenu');
    RotInfo=get(UIM,'userdata');
    set(allchild(get(gcbo,'parent')),'checked','off');
    set(gcbo,'checked','on');
    RotInfo.CurrentAxes=Axes;
    set(UIM,'userdata',RotInfo);
  else,
    if ~ishandle(Axes), % deleted
      uiwait(msgbox('The axes handle is not valid.','modal'));
    else, % moved
      uiwait(msgbox('No such axes in this figure.','modal'));
    end;
    UIM=findobj(gcbf,'tag','md_camera camera uimenu');
    RotInfo=get(UIM,'userdata');
    if RotInfo.CurrentAxes==Axes,
      RotInfo.CurrentAxes=[];
      RotInfo.AxesList=RotInfo.AxesList(RotInfo.AxesList~=Axes);
      set(UIM,'userdata',RotInfo);
      if isempty(RotInfo.AxesList),
        set(allchild(UIM),'enable','off');
        set(findobj(UIM,'label','&done'),'enable','on');
      end;
    end;
    delete(gcbo);
  end;

case 'recmenu',
  cmd=get(gcbo,'label');
  switch cmd,
  case '&apply',
    Setting=get(get(gcbo,'parent'),'userdata');
    props={'projection','dataaspectratio', ...
           'cameraposition','cameratarget','cameraviewangle','cameraupvector'};
    if ishandle(Setting.Axes),
      set(Setting.Axes,props,Setting.Props);
    end;
  case '&remove',
    SETTING=get(gcbo,'parent');
    delete(allchild(SETTING));

    if strcmp(get(SETTING,'separator'),'on'),
      VPRSET=get(SETTING,'parent');
      NSet=length(get(VPRSET,'children'));
      if NSet>4,
        NEWFIRST=findobj(get(VPRSET,'children'),'position',5);
        set(NEWFIRST,'separator','on');
      end;
    end;
    delete(SETTING);
  case '&add',
    UIM=findobj(gcbf,'tag','md_camera camera uimenu');
    RotInfo=get(UIM,'userdata');
    ax=RotInfo.CurrentAxes;
    if ~isempty(ax),
      %actual add
      VPRSET=findobj(gcbf,'label','viewpoint re&corder');
      props={'projection','dataaspectratio', ...
         'cameraposition','cameratarget','cameraviewangle','cameraupvector'};
      ViewPointName=inputdlg('Specify name of viewpoint:');
      if ~isempty(ViewPointName),
        ViewPointName=ViewPointName{1};
        Setting.Axes=ax;
        Setting.Name=ViewPointName;
        Setting.Props=get(ax,props);
        SETTING=uimenu('parent',VPRSET, ...
               'label',ViewPointName, ...
               'checked','off', ...
               'callback','', ...
               'userdata',Setting);
        NSet=length(get(VPRSET,'children'));
        if NSet==4,
          set(SETTING,'separator','on');
        end;
        uimenu('parent',SETTING, ...
               'label','&apply', ...
               'checked','off', ...
               'callback','md_camera recmenu');
        uimenu('parent',SETTING, ...
               'label','&remove', ...
               'checked','off', ...
               'callback','md_camera recmenu');
      end;
    end;
  case '&load',
    UIM=findobj(gcbf,'tag','md_camera camera uimenu');
    RotInfo=get(UIM,'userdata');
    ax=RotInfo.CurrentAxes;
    Setting.Axes=ax;
    if ~isempty(ax),
      %actual add
      VPRSET=findobj(gcbf,'label','viewpoint re&corder');
      props={'projection','dataaspectratio', ...
         'cameraposition','cameratarget','cameraviewangle','cameraupvector'};

      [fn,pn]=uigetfile('*.vp','Load viewpoints ...');
      if ~ischar(fn), % cancel
        return;
      end;
      fid=fopen([pn fn],'r');
      if fid<0, return; end;
      while ~feof(fid),
        Line=fgetl(fid);
        if length(Line)<5 | ~strcmp(lower(Line(1:5)),'name:'),
          fclose(fid);
          return;
        end;
        Setting.Name=deblank(Line(7:end)); % NAME:
        str=fscanf(fid,'%*5s %s',1); % PROJ:
        if ~isempty(findstr(lower(str),'orth')),
          Setting.Props{1}='orthographic';
        else,
          Setting.Props{1}='perspective';
        end;
        Setting.Props{2}=fscanf(fid,'%*5s %f %f %f',[1 3]); % ASPR:
        Setting.Props{3}=fscanf(fid,'%*5s %f %f %f',[1 3]); % POSI:
        Setting.Props{4}=fscanf(fid,'%*5s %f %f %f',[1 3]); % TRGT:
        Setting.Props{5}=fscanf(fid,'%*5s %f',1); % ANGL:
        Setting.Props{6}=fscanf(fid,'%*5s %f %f %f',[1 3]); % UPVC:
        Line=fgetl(fid); %read end-of-line
        SETTING=uimenu('parent',VPRSET, ...
               'label',Setting.Name, ...
               'checked','off', ...
               'callback','', ...
               'userdata',Setting);
        NSet=length(get(VPRSET,'children'));
        if NSet==4,
          set(SETTING,'separator','on');
        end;
        uimenu('parent',SETTING, ...
               'label','&apply', ...
               'checked','off', ...
               'callback','md_camera recmenu');
        uimenu('parent',SETTING, ...
               'label','&remove', ...
               'checked','off', ...
               'callback','md_camera recmenu');
      end;
      fclose(fid);
    end;
  case '&save',
    UIM=findobj(gcbf,'tag','md_camera camera uimenu');
    RotInfo=get(UIM,'userdata');
    ax=RotInfo.CurrentAxes;
    VPRSET=findobj(gcbf,'label','viewpoint re&corder');
    AllViewPoints=get(VPRSET,'children');
    Pos=get(AllViewPoints,'position');
    Pos=[Pos{:}];
    AllViewPoints(Pos<=3)=[];
    if isempty(AllViewPoints),
      uiwait(msgbox('No viewpoints defined.','modal'));
      return;
    end;
    ViewPointProps=get(AllViewPoints,'userdata');
    ViewPointOrder=get(AllViewPoints,'position');
    if iscell(ViewPointProps),
      ViewPointOrder=[ViewPointOrder{:}]-3;
      ViewPointProps=ViewPointProps(ViewPointOrder);
      ViewPointProps=[ViewPointProps{:}];
      VPax=[ViewPointProps(:).Axes];
    else,
      VPax=ViewPointProps(:).Axes;
    end;
    VPax=(VPax==ax);
    ViewPointProps=ViewPointProps(VPax);
    if isempty(ViewPointProps),
      uiwait(msgbox('No viewpoints defined.','modal'));
      return;
    end;

    [fn,pn]=uiputfile('*.vp','Save viewpoints as ...');
    if ~ischar(fn), % cancel
      return;
    end;
    fid=fopen([pn fn],'w');
    if fid<0, return; end;
    for i=1:length(ViewPointProps),
      fprintf(fid,'NAME: %s\n',ViewPointProps(i).Name);
      fprintf(fid,'PROJ: %s\n',ViewPointProps(i).Props{1});
      fprintf(fid,'ASPR: %f %f %f\n',ViewPointProps(i).Props{2});
      fprintf(fid,'POSI: %f %f %f\n',ViewPointProps(i).Props{3});
      fprintf(fid,'TRGT: %f %f %f\n',ViewPointProps(i).Props{4});
      fprintf(fid,'ANGL: %f\n',ViewPointProps(i).Props{5});
      fprintf(fid,'UPVC: %f %f %f\n',ViewPointProps(i).Props{6});
    end;
    fclose(fid);
  end;

case 'is suspended',
  Out=1;
  if nargin==1,
    fig=gcbf;
  else,
    fig=AxesList;
  end;
  UIM=findobj(fig,'tag','md_camera camera uimenu');
  if isempty(UIM), return; end;
  SuspendMenu=findobj(UIM,'label','s&uspend');
  switch get(SuspendMenu,'checked'),
  case 'off',
    Out=0;
  case 'on',
    Out=1;
  end;

case 'suspend',
  if nargin==1,
    fig=gcbf;
  else,
    fig=AxesList;
  end;
  UIM=findobj(fig,'tag','md_camera camera uimenu');
  if isempty(UIM), return; end;
  RotInfo=get(UIM,'userdata');
  SuspendMenu=findobj(UIM,'label','s&uspend');
  switch get(SuspendMenu,'checked'),
  case 'off',
    set(fig,'WindowButtonUpFcn',    RotInfo.wbuf);
    set(fig,'WindowButtonDownFcn',  RotInfo.wbdf);
    set(fig,'WindowButtonMotionFcn',RotInfo.wbmf);
    set(fig,'ButtonDownFcn',        RotInfo.bdf);
    set(allchild(UIM),'enable','off');
    set(SuspendMenu,'checked','on','enable','on');
  case 'on',
    if ~md_figzoom('is suspended',fig),
      md_figzoom('suspend',fig);
    end;
    RotInfo.wbuf = get(fig,'WindowButtonUpFcn');
    RotInfo.wbdf = get(fig,'WindowButtonDownFcn');
    RotInfo.wbmf = get(fig,'WindowButtonMotionFcn');
    RotInfo.bdf  = get(fig,'ButtonDownFcn');
    set(UIM,'userdata',RotInfo);
  
    set(fig,'WindowButtonDownFcn','md_camera down');
    set(fig,'WindowButtonUpFcn'  ,'md_camera up');
    set(fig,'WindowButtonMotionFcn','');
    set(fig,'ButtonDownFcn','');
    set(SuspendMenu,'checked','off');
    set(allchild(UIM),'enable','on');
  end;

case 'menu',
  cmd=get(gcbo,'label');
  cmd(cmd=='&')=[];
  switch cmd,
  case 'select axes', % not used, always subset
  case 'options',
    UIM=findobj(gcbf,'tag','md_camera camera uimenu');
    RotInfo=get(UIM,'userdata');
    ParamStrings={'Sensitivity'};
    ParamDefault={num2str(RotInfo.Sensitivity)};
    answer=inputdlg(ParamStrings,'Camera options',[1],ParamDefault);
    if isempty(answer), % values unchanged
      return;
    end;
    answer{1}=str2num(answer{1});
    if isequal(size(answer{1}),[1 1]) & isnumeric(answer{1}) & isfinite(answer{1}) & answer{1}>0,
      RotInfo.Sensitivity=answer{1};
    end;
    set(UIM,'userdata',RotInfo);
  case 'suspend',
    UIM=get(gcbo,'parent');
    RotInfo=get(UIM,'userdata');
    switch get(gcbo,'checked'),
    case 'off',
      set(gcbf,'WindowButtonUpFcn',    RotInfo.wbuf);
      set(gcbf,'WindowButtonDownFcn',  RotInfo.wbdf);
      set(gcbf,'WindowButtonMotionFcn',RotInfo.wbmf);
      set(gcbf,'ButtonDownFcn',        RotInfo.bdf);
      set(allchild(UIM),'enable','off');
      set(gcbo,'checked','on','enable','on');
    case 'on',
      RotInfo.wbuf = get(gcbf,'WindowButtonUpFcn');
      RotInfo.wbdf = get(gcbf,'WindowButtonDownFcn');
      RotInfo.wbmf = get(gcbf,'WindowButtonMotionFcn');
      RotInfo.bdf  = get(gcbf,'ButtonDownFcn');
      set(UIM,'userdata',RotInfo);
    
      set(gcbf,'WindowButtonDownFcn','md_camera down');
      set(gcbf,'WindowButtonUpFcn'  ,'md_camera up');
      set(gcbf,'WindowButtonMotionFcn','');
      set(gcbf,'ButtonDownFcn','');
      set(gcbo,'checked','off');
      set(allchild(UIM),'enable','on');
    end;
  case 'toggle perspective',
    UIM=findobj(gcbf,'tag','md_camera camera uimenu');
    RotInfo=get(UIM,'userdata');
    ax=RotInfo.CurrentAxes;
    if ~isempty(ax),
      %actual toggle
      set(ax,'projection',logicalswitch(strcmp(get(ax,'projection'),'perspective'),'orthographic','perspective'));
    end;
  case 'camera motion playback',
    UIM=findobj(gcbf,'tag','md_camera camera uimenu');
    RotInfo=get(UIM,'userdata');
    ax=RotInfo.CurrentAxes;
    if ~isempty(ax),
      %check for camera positions
      VPRSET=findobj(gcbf,'label','viewpoint re&corder');
      AllViewPoints=get(VPRSET,'children');
      Pos=get(AllViewPoints,'position');
      Pos=[Pos{:}];
      AllViewPoints(Pos<=3)=[];
      if isempty(AllViewPoints),
        uiwait(msgbox('No viewpoints defined.','modal'));
        return;
      end;
      ViewPointProps=get(AllViewPoints,'userdata');
      ViewPointOrder=get(AllViewPoints,'position');
      if iscell(ViewPointProps),
        ViewPointOrder=[ViewPointOrder{:}]-3;
        ViewPointProps=ViewPointProps(ViewPointOrder);
        ViewPointProps=[ViewPointProps{:}];
        VPax=[ViewPointProps(:).Axes];
      else, % zero or one viewpoint defined for ax (since one for all axes)
        uiwait(msgbox('At least two viewpoints should be defined for the selected axes.','modal'));
        return;
      end;
      VPax=(VPax==ax);
      ViewPointProps=ViewPointProps(VPax);
      if length(ViewPointProps)<2,
        uiwait(msgbox('At least two viewpoints should be defined for the selected axes.','modal'));
        return;
      end;
      Props=reshape([ViewPointProps.Props],[6 length(ViewPointProps)]);
      if ~isequal(str2mat(Props{1,:}),ones(length(ViewPointProps),1)*Props{1,1}),
        uiwait(msgbox('Projection method should not vary.','modal'));
        return;
      end;
      %everything OK for cameramotion
      Animation=md_cameramotion(ViewPointProps);
      if ~isempty(Animation),
        % store camera motion
        axopt=get(ax,'userdata');
        if ~isfield(axopt,'Animation'),
          AnimI=1;
        else,
          AnimI=length(axopt.Animation)+1;
        end;
        axopt.Animation(AnimI).Type=sprintf('camera motion %i',AnimI);
        axopt.Animation(AnimI).Nsteps=size(Animation,2);
        axopt.Animation(AnimI).Data=Animation;
        set(ax,'userdata',axopt);
      end;
      return;
    end;
  case 'done',
    UIM=get(gcbo,'parent');
    RotInfo=get(UIM,'userdata');
    set(gcbf,'WindowButtonUpFcn',    RotInfo.wbuf);
    set(gcbf,'WindowButtonDownFcn',  RotInfo.wbdf);
    set(gcbf,'WindowButtonMotionFcn',RotInfo.wbmf);
    set(gcbf,'ButtonDownFcn',        RotInfo.bdf);
    delete(UIM);
  case 'perspective',

  case 'viewpoint recorder',

  case 'move as box',
    switch get(gcbo,'checked')
    case 'on'
      set(gcbo,'checked','off')
    case 'off',
      set(gcbo,'checked','on')
    end
    
  otherwise,
    mnu=allchild(get(gcbo,'parent'));
    mab=findobj(mnu,'flat','label','move as &box');
    mnu(mnu==mab)=[];
    set(mnu,'checked','off');
    set(gcbo,'checked','on');
%    uiwait(msgbox(['unknown menu: ' cmd],'modal'));
  end;

case 'down',
  fig = get(0,'PointerWindow');
  UIM=findobj(fig,'tag','md_camera camera uimenu');
  RotInfo=get(UIM,'userdata');

  if strcmp(get(fig,'selectiontype'),'alt'), % UNDO LAST
    props={'projection','dataaspectratio', ...
         'cameraposition','cameratarget','cameraviewangle','cameraupvector'};
    TProps=get(RotInfo.BackupAxes,props);
    set(RotInfo.BackupAxes,props,RotInfo.BackupProps);
    RotInfo.BackupProps=TProps;
    set(UIM,'userdata',RotInfo);
    return;
  end;

%  ax=Local_overaxes(RotInfo.AxesList);
  ax=RotInfo.CurrentAxes;
  if isempty(ax) | ~ishandle(ax),
    return;
  end;
  fig=get(ax,'parent');
% Check axes against stored AxesList
  UIM=findobj(fig,'tag','md_camera camera uimenu');
  RotInfo=get(UIM,'userdata');
  if ~ismember(ax,RotInfo.AxesList),
    return;
  end;
%
  set(ax,'camerapositionmode','manual', ...
         'cameratargetmode','manual', ...
         'cameraupvectormode','manual', ...
         'cameraviewanglemode','manual');
  Camera=findobj(fig,'tag','md_camera camera uimenu');
  Checked=findobj(allchild(Camera),'flat','checked','on');
  mab=findobj(Checked,'flat','label','move as &box');
  Checked(Checked==mab)=[];
  cmd=get(Checked,'label');
  set(fig,'windowbuttonmotionfcn','md_camera motion');
  set(fig,'windowbuttonupfcn','md_camera up');
  set(fig,'windowbuttondownfcn','');

%%%%%%%%%%%%%

  rotax=findobj(fig,'tag','md_camera rotax');
  if ~isempty(rotax),
    md_camera up;
    return;
  end;
  Point=get(fig,'currentpoint');
  Scale=get(fig,'position');
  RefFactor=Point/mean(Scale(3:4));

  ctar=get(ax,'cameratarget');
  cpos=get(ax,'cameraposition');
  cuv=get(ax,'cameraupvector');
  rotax=axes('parent',fig, ...
             'visible','off', ...
             'tag','md_camera rotax', ...
             'units',get(ax,'units'), ...
             'position',get(ax,'position'), ...
             'xlim',get(ax,'xlim'), ...
             'ylim',get(ax,'ylim'), ...
             'zlim',get(ax,'zlim'), ...
             'projection',get(ax,'projection'), ...
             'cameraposition',get(ax,'cameraposition'), ...
             'cameratarget',get(ax,'cameratarget'), ...
             'cameraviewangle',get(ax,'cameraviewangle'), ...
             'cameraupvector',get(ax,'cameraupvector'), ...
             'dataaspectratio',get(ax,'dataaspectratio'));
  set(rotax,'plotboxaspectratiomode','manual');
  set(ax,'xlimmode','manual','ylimmode','manual','zlimmode','manual');
  xlim=[get(ax,'xlim') NaN];                % get extreme values and NaN values for line separation
  ylim=[get(ax,'ylim') NaN];
  zlim=[get(ax,'zlim') NaN];
  dar=get(ax,'dataaspectratio');

  Pos(1,5)=0;                               % define bottom cross
  Pos(1,:)=xlim([1 2 3 1 2]);
  Pos(2,:)=ylim([1 2 3 2 1]);
  Pos(3,:)=zlim([1 1 3 1 1]);
  Box(1,35)=0;                               % define bounding box
  Box(1,:)=xlim([1 2 3 1 1 3 1 1 3 2 1 3 2 2 3 2 2 3 2 1 3 2 2 3 2 2 3 1 2 3 1 1 3 1 1]);
  Box(2,:)=ylim([1 1 3 1 2 3 1 1 3 2 2 3 2 1 3 2 2 3 1 1 3 1 2 3 1 1 3 2 2 3 2 1 3 2 2]);
  Box(3,:)=zlim([1 1 3 1 1 3 1 2 3 1 1 3 1 1 3 1 2 3 2 2 3 2 2 3 2 1 3 2 2 3 2 2 3 2 1]);

%  ref=(Box(:,1)+Box(:,17))/2;

%  yvis=((ctar-cpos)./dar)/norm(ctar-cpos);   % y in view direction (positive facing away)
%  zvis=get(ax,'cameraupvector');
%  zvis=zvis-(zvis*transpose(yvis))*yvis;     % z in cameraupdirection, orthogonal to y
%  zvis=zvis/norm(zvis);

%  plot2vis=index(get(ax,'xform'),1:3,1:3);  % 

%  plot2vis(:,1)=plot2vis(:,1)/dar(1);
%  plot2vis(:,2)=plot2vis(:,2)/dar(2);
%  plot2vis(:,3)=plot2vis(:,3)/dar(3);

%  vis2plot=inv(plot2vis);                    % backward transformation

  userdat.ax=ax;
  userdat.cpos=transpose(cpos);
  userdat.ctar=transpose(ctar);
  userdat.cuv=transpose(cuv);
  userdat.Box=Box;
  userdat.RefFactor=RefFactor;
%  userdat.ref=ref;
  userdat.vw1=getview(ax,1);
  userdat.vw2=getview(ax,2);
  userdat.vw=getview(ax);
  setview(rotax,userdat.vw);
  userdat.figname=get(fig,'name');
  userdat.dar=dar;
  mab=findobj(UIM,'label','move as &box');
  userdat.Vis=get(mab,'checked');

  Back=line('parent',rotax, ...
            'visible','off', ...
            'xdata',userdat.Box(1,:), ...
            'ydata',userdat.Box(2,:), ...
            'zdata',userdat.Box(3,:), ...
            'tag','md_camera back', ...
            'color',[0 0 0], ...
            'linestyle',':', ...
            'erasemode','xor', ...
            'clipping','off', ...
            'userdata',userdat);
  Cross=line('parent',rotax, ...
            'visible','off', ...
            'xdata',Pos(1,:), ...
            'ydata',Pos(2,:), ...
            'zdata',Pos(3,:), ...
            'tag','md_camera cross', ...
            'color',[0 0 0], ...
            'linestyle',':', ...
            'erasemode','xor', ...
            'clipping','off');
  XLim=get(rotax,'xlim');
  DX=(XLim(2)-XLim(1))*100000;
  YLim=get(rotax,'ylim');
  DY=(YLim(2)-YLim(1))*100000;
%  XHelp=[XLim(1)*ones(1,2*L+1) NaN XLim(2)*ones(1,2*L+1) NaN DX*((-L):(L+1))       NaN DX*((-L):(L+1))      ];
%  YHelp=[DY*((-L):(L+1))       NaN DY*((-L):(L+1))       NaN YLim(1)*ones(1,2*L+1) NaN YLim(2)*ones(1,2*L+1)];
  XHelp=[XLim(1)*ones(1,3) NaN XLim(2)*ones(1,3) NaN DX*[-1 0 1]       NaN DX*[-1 0 1]      ];
  YHelp=[DY*[-1 0 1]       NaN DY*[-1 0 1]       NaN YLim(1)*ones(1,3) NaN YLim(2)*ones(1,3)];
  Front=line('parent',rotax, ...
            'visible','off', ...
            'xdata',userdat.Box(1,:), ...
            'ydata',userdat.Box(2,:), ...
            'zdata',userdat.Box(3,:), ...
            'tag','md_camera front', ...
            'color',[0 0 0], ...
            'linewidth',1, ...
            'linestyle','-', ...
            'erasemode','xor', ...
            'clipping','off');
  [Min,Closest]=min(sum((userdat.Box-userdat.cpos*ones(1,35)).^2));
  HelpLine=line('parent',rotax, ...
            'visible','off', ...
            'xdata',XHelp, ...
            'ydata',YHelp, ...
            'tag','md_camera helpline', ...
            'color',[0 0 0], ...
            'linewidth',1, ...
            'linestyle',':', ...
            'erasemode','xor', ...
            'clipping','off');
  TargetCross=line('parent',rotax, ...
           'xdata',userdat.ctar(1), ...
           'ydata',userdat.ctar(2), ...
           'zdata',userdat.ctar(3), ...
           'tag','md_camera target', ...
           'color',[0 0 0], ...
           'markersize',25, ...
           'marker','x', ...
           'erasemode','xor', ...
           'visible',userdat.Vis, ...
           'clipping','off');
  Dot=line('parent',rotax, ...
           'xdata',userdat.Box(1,Closest), ...
           'ydata',userdat.Box(2,Closest), ...
           'zdata',userdat.Box(3,Closest), ...
           'tag','md_camera dot', ...
           'color',[0 0 0], ...
           'markersize',25, ...
           'marker','.', ...
           'erasemode','xor', ...
           'visible',userdat.Vis, ...
           'clipping','off');
  switch cmd,
  case 'pan',
%    str=strrep(strrep(sprintf('[ %.4G %.4G %.4G]',cpos-ctar),'E+','E'),'E0','E');
%    set(fig,'name',str);
  case 'elevation',
%    str=strrep(strrep(sprintf('[ %.4G %.4G %.4G]',cpos-ctar),'E+','E'),'E0','E');
%    set(fig,'name',str);
  case 'zoom',
    set(fig,'name','1');
  case 'distance target',
    set(fig,'name','1');
  case 'x rotate',
    Angle=userdat.vw1(1:2);
    Angle(2)=min(max(Angle(2),-90),90);
    setview(rotax,[Angle userdat.vw1(3:4)],'eldir',1);
    str=sprintf('[ %.2f %.2f]',Angle);
    set(fig,'name',str);
  case 'y rotate',
    Angle=userdat.vw2(1:2);
    Angle(2)=min(max(Angle(2),-90),90);
    setview(rotax,[Angle userdat.vw2(3:4)],'eldir',2);
    str=sprintf('[ %.2f %.2f]',Angle);
    set(fig,'name',str);
  case 'z rotate',
    Angle=userdat.vw(1:2);
    Angle(2)=min(max(Angle(2),-90),90);
    setview(rotax,Angle);
    str=sprintf('[ %.2f %.2f]',Angle);
    set(fig,'name',str);
  case 'rotate',
    Angle=userdat.vw(1:2);
    Angle(2)=min(max(Angle(2),-90),90);
    setview(rotax,Angle);
    str=sprintf('[ %.2f %.2f]',Angle);
    set(fig,'name',str);
  case 'horizontal scale',
    set(fig,'name',num2str(dar(2)/dar(1)));
  case 'vertical scale',
    set(fig,'name',num2str(dar(3)/dar(1)));
  case 'pan view',
    set(fig,'name','[0,0,0]');
  case 'camera elevation',
    str=strrep(strrep(sprintf('[ %.4G %.4G %.4G]',cpos-ctar),'E+','E'),'E0','E');
    set(fig,'name',str);
  case 'camera pan',
    str=strrep(strrep(sprintf('[ %.4G %.4G %.4G]',cpos-ctar),'E+','E'),'E0','E');
    set(fig,'name',str);
  case 'camera roll',
    set(gcbf,'name',num2str(userdat.vw(4)));
  case 'camera rotate',
    Angle=userdat.vw(1:2);
    Angle(2)=min(max(Angle(2),-90),90);
    setview(rotax,Angle);
    str=sprintf('[ %.2f %.2f]',Angle);
    set(fig,'name',str);
  case 'camera viewangle',
    viewangle=get(rotax,'cameraviewangle');
    set(gcbf,'name',num2str(viewangle));
  case 'perspective distortion',
    if strcmp(get(rotax,'projection'),'perspective'),
      viewangle=get(rotax,'cameraviewangle');
      set(gcbf,'name',num2str(viewangle));
    else,
      md_camera up;
      uiwait(msgbox('Perspective distortion not valid for orthographic axes.','modal'));
    end;
  end;

case 'motion',
  Camera=findobj(gcbf,'tag','md_camera camera uimenu');
  Checked=findobj(allchild(Camera),'flat','checked','on');
  mab=findobj(Checked,'flat','label','move as &box');
  Checked(Checked==mab)=[];
  cmd=get(Checked,'label');
  cmd(cmd=='&')=[];

  Point=get(gcbf,'currentpoint');
  RotAx=findobj(gcbf,'tag','md_camera rotax');
  if isempty(RotAx),
    return;
  end;

  Back=findobj(RotAx,'tag','md_camera back');
  Dot=findobj(RotAx,'tag','md_camera dot');
  Front=findobj(RotAx,'tag','md_camera front');
  Cross=findobj(RotAx,'tag','md_camera cross');
  HelpLine=findobj(RotAx,'tag','md_camera helpline');
  TargetCross=findobj(RotAx,'tag','md_camera target');
  userdat=get(Back,'userdata');

  set([Dot,Back,Front,Cross,HelpLine,TargetCross],'visible','off');

  UIM=findobj(gcbf,'tag','md_camera camera uimenu');
  RotInfo=get(UIM,'userdata');

  if strcmp(userdat.Vis,'off')
    RefAx=RotAx;
    RotAx=userdat.ax;
  else
    RefAx=userdat.ax;
  end
  
  switch cmd,
  case 'pan',
    Scale=get(gcbf,'position');
    Factor=Point(1:2)/mean(Scale(3:4));
    Factor=Factor-userdat.RefFactor;
    Factor=RotInfo.Sensitivity*Factor; % max(min(Factor,1),-1);

    cpos=transpose(userdat.cpos);
    ctar=transpose(userdat.ctar);
    dar=userdat.dar;
    cuv=userdat.cuv;

    viewVec=(ctar-cpos)./dar;
    viewVec=viewVec/norm(viewVec);
    UpVec=transpose(cuv)-(viewVec*cuv)*viewVec;
    UpVec=UpVec/norm(UpVec);
    HorVec=cross(UpVec,viewVec);
    HorVec=HorVec/norm(HorVec);
    UpVec=UpVec.*dar;
    HorVec=HorVec.*dar;

    Shift=-UpVec*Factor(2)+HorVec*Factor(1);
    Shift=Shift*norm((ctar-cpos)./dar);
    ctar=ctar+Shift;
    cpos=cpos+Shift;

    set(RotAx,'cameraposition',cpos);
    set(RotAx,'cameratarget',ctar);

    str=strrep(strrep(sprintf('[ %.4G %.4G %.4G]',Shift),'E+','E'),'E0','E');
    set(gcbf,'name',str);

  case 'elevation',
    Scale=get(gcbf,'position');
    Factor=Point(2)/mean(Scale(3:4));
    Factor=Factor-userdat.RefFactor(2);
    Factor=-RotInfo.Sensitivity*Factor; % max(min(Factor,1),-1);

    cpos=userdat.cpos;
    ctar=userdat.ctar;
    dar=userdat.dar;
    viewVec=transpose(cpos-ctar)./dar;

    Delta=viewVec(3)*Factor;

    cpos(3)=cpos(3)+Delta;
    set(RotAx,'cameraposition',cpos);

    ctar(3)=ctar(3)+Delta;
    set(RotAx,'cameratarget',ctar);

%    str=strrep(strrep(sprintf('[ %.4G %.4G %.4G]',cpos-ctar),'E+','E'),'E0','E');
%    set(gcbf,'name',str);

  case 'zoom',
    Scale=get(gcbf,'position');
    Factor=Point(2)/mean(Scale(3:4));
    Factor=Factor-userdat.RefFactor(2);
    Factor=2^(RotInfo.Sensitivity*Factor); % 2^(max(min(Factor,1),-1));

    cpos=userdat.cpos;
    ctar=userdat.ctar;
    cpos(1)=ctar(1)+Factor*(cpos(1)-ctar(1));
    cpos(2)=ctar(2)+Factor*(cpos(2)-ctar(2));
    cpos(3)=ctar(3)+Factor*(cpos(3)-ctar(3));
    set(RotAx,'cameraposition',cpos);
    set(gcbf,'name',num2str(Factor));

  case 'distance target',
    Scale=get(gcbf,'position');
    Factor=Point(2)/mean(Scale(3:4));
    Factor=Factor-userdat.RefFactor(2);
    Factor=2^(RotInfo.Sensitivity*Factor); % 2^(max(min(Factor,1),-1));

    cpos=userdat.cpos;
    ctar=userdat.ctar;
    ctar(1)=cpos(1)+Factor*(ctar(1)-cpos(1));
    ctar(2)=cpos(2)+Factor*(ctar(2)-cpos(2));
    ctar(3)=cpos(3)+Factor*(ctar(3)-cpos(3));
    set(RotAx,'cameratarget',ctar);
    set(gcbf,'name',num2str(Factor));

  case 'x rotate',
    Scale=get(gcbf,'position');
    Angle=Point/mean(Scale(3:4));
    Angle=userdat.vw1(1:2)-RotInfo.Sensitivity*360*(Angle-userdat.RefFactor);
    Angle(2)=userdat.vw1(2);

    setview(RotAx,[Angle userdat.vw1(3:4)],'eldir',1);

    Local_updbox(userdat,RotAx,Back,Front,Dot);

    str=sprintf('[ %.2f %.2f]',Angle);
    set(gcbf,'name',str);

  case 'y rotate',
    Scale=get(gcbf,'position');
    Angle=Point/mean(Scale(3:4));
    Angle=userdat.vw2(1:2)-RotInfo.Sensitivity*360*(Angle-userdat.RefFactor);
    Angle(2)=userdat.vw2(2);

    setview(RotAx,[Angle userdat.vw2(3:4)],'eldir',2);

    Local_updbox(userdat,RotAx,Back,Front,Dot);

    str=sprintf('[ %.2f %.2f]',Angle);
    set(gcbf,'name',str);

  case 'z rotate',
    Scale=get(gcbf,'position');
    Angle=Point/mean(Scale(3:4));
    Angle=userdat.vw(1:2)-RotInfo.Sensitivity*360*(Angle-userdat.RefFactor);
    Angle(2)=userdat.vw(2);

    setview(RotAx,Angle);

    Local_updbox(userdat,RotAx,Back,Front,Dot);

    str=sprintf('[ %.2f %.2f]',Angle);
    set(gcbf,'name',str);

  case 'rotate',
    Scale=get(gcbf,'position');
    Angle=Point/mean(Scale(3:4));
    Angle=userdat.vw(1:2)-RotInfo.Sensitivity*360*(Angle-userdat.RefFactor);
    Angle(2)=min(max(Angle(2),-90),90);
    Vw=getview(RefAx);
    Vw(1:2)=Angle;
    setview(RotAx,Vw);

    Local_updbox(userdat,RotAx,Back,Front,Dot);

    str=sprintf('[ %.2f %.2f]',Angle);
    set(gcbf,'name',str);

  case 'horizontal scale',
    Scale=get(gcbf,'position');
    Factor=Point(2)/mean(Scale(3:4));
    Factor=Factor-userdat.RefFactor(2);
    Factor=2^(-RotInfo.Sensitivity*Factor); % 2^(-max(min(Factor,1),-1));

    dar=userdat.dar;
    dar(1)=dar(1)/Factor;
    dar(2)=dar(2)*Factor;
    set(RotAx,'dataaspectratio',dar);
    setview(RotAx,userdat.vw);
    set(gcbf,'name',num2str(dar(2)/dar(1)));

  case 'vertical scale',
    Scale=get(gcbf,'position');
    Factor=Point(2)/mean(Scale(3:4));
    Factor=Factor-userdat.RefFactor(2);
    Factor=4^(-RotInfo.Sensitivity*Factor); % 4^(-max(min(Factor,1),-1));

    dar=userdat.dar;
    dar(3)=dar(3)*Factor;
    set(RotAx,'dataaspectratio',dar);
    setview(RotAx,userdat.vw);
    set(gcbf,'name',num2str(dar(3)/dar(1)));

  case 'pan view',
    Scale=get(gcbf,'position');
    Factor=Point(1:2)/mean(Scale(3:4));
    Factor=Factor-userdat.RefFactor(1:2);
    Factor=25*RotInfo.Sensitivity*Factor;

    cpos=transpose(userdat.cpos);
    ctar=transpose(userdat.ctar);
    dar=userdat.dar;
    cuv=userdat.cuv;

    viewVec=(ctar-cpos)./dar;
    viewVec=viewVec/norm(viewVec);
    UpVec=transpose(cuv)-(viewVec*cuv)*viewVec;
    UpVec=UpVec/norm(UpVec);
    HorVec=cross(UpVec,viewVec);
    HorVec=HorVec/norm(HorVec);
    UpVec=UpVec.*dar;
    HorVec=HorVec.*dar;

    Shift=-UpVec*Factor(2)+HorVec*Factor(1);
    ctar=ctar+Shift;
    cpos=cpos+Shift;
    set(RotAx,'cameraposition',cpos,'cameratarget',ctar);

    str=strrep(strrep(sprintf('[ %.4G %.4G %.4G]',Shift),'E+','E'),'E0','E');
    set(gcbf,'name',str);

  case 'camera elevation',
    Scale=get(gcbf,'position');
    Factor=Point(2)/mean(Scale(3:4));
    Factor=Factor-userdat.RefFactor(2);
    Factor=2^(RotInfo.Sensitivity*Factor); % 2^(max(min(Factor,1),-1));

    cpos=userdat.cpos;
    ctar=userdat.ctar;
    dar=userdat.dar;
    cpos(3)=ctar(3)+(cpos(3)-ctar(3))*Factor;
    viewVec=transpose(cpos-ctar)./dar;
    set(RotAx,'cameraposition',cpos);
    setview(RotAx,getview(RotAx));
    set(gcbf,'name',num2str(cpos(3)));

  case 'camera pan',
    Scale=get(gcbf,'position');
    Factor=Point(1:2)/mean(Scale(3:4));
    Factor=Factor-userdat.RefFactor(1:2);
    Factor=(RotInfo.Sensitivity*Factor)/2; % (max(min(Factor,1),-1))/2;

    cpos=userdat.cpos;
    ctar=userdat.ctar;
    dar=userdat.dar;
    viewVec=transpose(cpos-ctar)./dar;
    cpos(1)=cpos(1)-viewVec(2)*Factor(1)-viewVec(1)*Factor(2);
    cpos(2)=cpos(2)+viewVec(1)*Factor(1)-viewVec(2)*Factor(2);
    set(RotAx,'cameraposition',cpos);
    vw=getview(RotAx);
    vw(4)=userdat.vw(4);
    setview(RotAx,vw);
    str=strrep(strrep(sprintf('[ %.4G %.4G %.4G]',cpos-ctar),'E+','E'),'E0','E');
    set(gcbf,'name',str);

  case 'camera roll',
    Scale=get(gcbf,'position');
    Angle=Point/mean(Scale(3:4));
    Angle=userdat.vw(4)+180*RotInfo.Sensitivity*(Angle-userdat.RefFactor);

    vw=userdat.vw;
    vw(4)=Angle(1);
    setview(RotAx,vw);
    set(gcbf,'name',num2str(vw(4)));

  case 'camera viewangle',
    Scale=get(gcbf,'position');
    Factor=Point(2)/mean(Scale(3:4));
    Factor=Factor-userdat.RefFactor(2);
    Factor=2^(max(min(Factor,1),-1));
    viewangle=get(RefAx,'cameraviewangle');
    viewangle=min(viewangle*Factor*RotInfo.Sensitivity,180);

    set(RotAx,'cameraviewangle',viewangle);
    set(gcbf,'name',num2str(viewangle));

  case 'perspective distortion',
    Scale=get(gcbf,'position');
    Factor=Point(2)/mean(Scale(3:4));
    Factor=Factor-userdat.RefFactor(2);
    Factor=2^(RotInfo.Sensitivity*Factor); % 2^(max(min(Factor,1),-1));

    viewangle=get(RefAx,'cameraviewangle');
    viewangle=viewangle*Factor;
    set(RotAx,'cameraviewangle',viewangle);

    cpos=get(RefAx,'cameraposition');
    ctar=get(RefAx,'cameratarget');
    cpos(1)=ctar(1)+Factor^(-1)*(cpos(1)-ctar(1));
    cpos(2)=ctar(2)+Factor^(-1)*(cpos(2)-ctar(2));
    cpos(3)=ctar(3)+Factor^(-1)*(cpos(3)-ctar(3));
    set(RotAx,'cameraposition',cpos);
    set(gcbf,'name',num2str(viewangle));

  end;

  ctar=get(RotAx,'cameratarget');
  set(TargetCross,'xdata',ctar(1),'ydata',ctar(2),'zdata',ctar(3));
  set([Dot Back Front Cross TargetCross],'visible',userdat.Vis);
  if strcmp(get(RotAx,'projection'),'perspective'),
    set(HelpLine,'visible',userdat.Vis);
  end;
  
case 'up',
  Camera=findobj(gcbf,'tag','md_camera camera uimenu');
  Checked=findobj(allchild(Camera),'flat','checked','on');
  cmd=get(Checked,'label');
  set(gcbf,'windowbuttondownfcn','md_camera down');
  set(gcbf,'windowbuttonmotionfcn','');
  set(gcbf,'windowbuttonupfcn','');
  Point=get(gcbf,'currentpoint');
  RotAx=findobj(gcbf,'tag','md_camera rotax');
  if isempty(RotAx),
    return;
  end;
  Back=findobj(RotAx,'tag','md_camera back');
  userdat=get(Back,'userdata');
  set(gcbf,'name',userdat.figname);
  props={'projection','dataaspectratio', ...
         'cameraposition','cameratarget','cameraviewangle','cameraupvector'};
  if strcmp(userdat.Vis,'off')
    OldProps=get(RotAx,props);
    NewProps=get(userdat.ax,props);
  else
    NewProps=get(RotAx,props);
    OldProps=get(userdat.ax,props);
  end
  if ~isequal(NewProps,OldProps),
    % Backup old status for UNDO LAST
    UIM=findobj(gcbf,'tag','md_camera camera uimenu');
    RotInfo=get(UIM,'userdata');
    RotInfo.BackupAxes=userdat.ax;
    RotInfo.BackupProps=OldProps;
    set(UIM,'userdata',RotInfo);
  end;

  set(userdat.ax,props,NewProps);
  delete(RotAx);

otherwise,
  uiwait(msgbox(['unknown command: ' cmd],'modal'));

end;

function h = Local_overaxes(AxesList)
%Local_overaxes Get handle of axes the pointer is over.
%   Adopted from L. Ljung 9-27-94 (MathWorks), Adopted from Joe, AFP 1-30-95

fig = get(0,'PointerWindow'); 
% Look for quick exit
if (fig==0) | isempty(AxesList),
   h = [];
   return
end

% Assume root and figure units are pixels
p = get(0,'PointerLocation');
% Get figure position in pixels
figUnit = get(fig,'Units');
set(fig,'Units','pixels');
figPos = get(fig,'Position');
set(fig,'Units',figUnit)

x = (p(1)-figPos(1))/figPos(3);
y = (p(2)-figPos(2))/figPos(4);
if nargin<1,
  AxesList = findobj(get(fig,'Children'),'flat','Type','axes'); % might be invisible, handlevisibility must be on
end;
if size(AxesList,1)>1, AxesList=transpose(AxesList); end;
for h = AxesList,
   hUnit = get(h,'Units');
   set(h,'Units','norm')
   r = get(h,'Position');
   set(h,'Units',hUnit)
   if ( (x>r(1)) & (x<r(1)+r(3)) & (y>r(2)) & (y<r(2)+r(4)) )
      return
   end
end
h = [];


function Local_updbox(userdat,RotAx,Back,Front,Dot)
    [Min,Closest]=min(sum((userdat.Box-transpose(get(RotAx,'cameraposition'))*ones(1,35)).^2));
    set(Dot,'xdata',userdat.Box(1,Closest),'ydata',userdat.Box(2,Closest),'zdata',userdat.Box(3,Closest));
    Box=userdat.Box;
    Box(:,find(sum((Box-Box(:,Closest)*ones(1,35)).^2)==0))=NaN;
    set(Back,'xdata',Box(1,:),'ydata',Box(2,:),'zdata',Box(3,:));

    [Max,Furthest]=max(sum((userdat.Box-transpose(get(RotAx,'cameraposition'))*ones(1,35)).^2));
    Box=userdat.Box;
    Box(:,find(sum((Box-Box(:,Furthest)*ones(1,35)).^2)==0))=NaN;
    set(Front,'xdata',Box(1,:),'ydata',Box(2,:),'zdata',Box(3,:));

    
function ax=Local_getaxes(fig)
% LOCAL_GETAXES waits for a click in the specified figure

    ax=[];
    % get all children
    SHH=get(0,'ShowHiddenHandles');
    set(0,'ShowHiddenHandles','on');
    Objects=findobj(fig);

    % remove all buttondown functions from all children
    WinButton={'WindowButtonUpFcn','WindowButtonDownFcn','WindowButtonMotionFcn'};
    WinButtonFcn = get(fig,WinButton);
    set(fig,WinButton,{'' '' ''});
    ButtonDownFcns=get(Objects,'buttondownfcn');
    set(Objects,'buttondownfcn','');

    UIM=findobj(fig,'tag','md_camera camera uimenu');
    RotInfo=get(UIM,'userdata');
    figure(fig);

    CorrectFig=0;
    while ~CorrectFig,
      waitforbuttonpress;
      CorrectFig=(get(0,'PointerWindow')==fig);
    end;
    ax=Local_overaxes(RotInfo.AxesList);

    set(0,'ShowHiddenHandles',SHH);

    % reset all buttondown functions of all children
    for i=1:length(Objects),
      set(Objects(i),'buttondownfcn',ButtonDownFcns{i});
    end;
    set(fig,WinButton,WinButtonFcn);
