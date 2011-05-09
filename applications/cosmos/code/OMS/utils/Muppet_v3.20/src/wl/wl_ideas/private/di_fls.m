function It=di_fls(FileInfo,ax,itoptions)
% DI_FLS is an interface for a fls files
%
%      Four different calls to this function can be expected:
% 
%      1. It=DI_XXX(FileInfo,Axes,ItemOptionsDefault)
%         To create the item interactively; when ItemOptionsDefault
%         has a ReproData.Type field the item type selection should
%         be skipped and the indicated string should be used as
%         item type.
%      2. It=DI_XXX(Axes,ItemOptionsDefault,CommandStruct)
%         To create the item from a scriptfile
%      3. DI_XXX(Item,AnimType,StepI)
%         To create StepI of an animation
%         StepI==-Inf is used to initialize the figure before an animation
%         StepI==Inf  is used to reset the figure after an animation
%      4. PossibleItems=DI_XXX(FileInfo,Axes)
%         To list all items that can be created based on the FileInfo in
%         the Axes (depends on Axes properties).
%
%      FileInfo is a structure containing some data of the active file
%      Axes is the handle of the axes object in which to plot the Item
%      ItemOptionsDefault is the default ItemOptions structure

%persistent DFld
%if isempty(DFld),
%  DFld=scan_dsl('fls.dsl');
%end;

it=[];

if nargin==2, % Possibility 4: PossibleItems=DI_XXX(FileInfo,Axes)
  Option=4;

  It=[];

  axoptions=get(ax,'userdata');
  axtype=axoptions.Type;
  plottypes= ...
    {'bottom'                                 {'undefined','2DH','3D'}; ...
     'waterlevel'                             {'undefined','2DH','3D'}; ...
     'velocity vectors'                       {'undefined','2DH','3D'}; ...

     'classified data'                        {'undefined','2DH','3D'}; ...

     'grid point'                             {'undefined','2DH','3D'}; ...

     'discharge through cross section'        {'undefined','ZT'}; ...

     'waterdepth [MAP] at a grid point'       {'undefined','ZT'}; ...
     'waterdepth [BIN] at a grid point'       {'undefined','ZT'}; ...
     'waterdepth [HIS] at a grid point'       {'undefined','ZT'}; ...

     'waterlevel [BIN] at a grid point'       {'undefined','ZT'}; ...
     'time line'                              {'ZT'}};

  labels=str2mat(plottypes{:,1});
  for pt=size(plottypes,1):-1:1,
    enab(pt)=~isempty(strmatch(axtype,plottypes{pt,2},'exact'));
  end;
  Possible=find(enab);
  enab=enab(Possible);
  It=labels(Possible,:);
  return;
elseif isstruct(FileInfo), % Possibility 1: It=DI_XXX(FileInfo,Axes,ItemOptionsDefault)
  Option=1;

  It=[];

  axoptions=get(ax,'userdata');
  axtype=axoptions.Type;
  if strcmp(axtype,'OBJECT'),
    itoptions.ReproData.Type=axoptions.ObjectType;
  else,
    if ~isfield(itoptions,'ReproData') | ~isfield(itoptions.ReproData,'Type'),
      labels=di_fls(FileInfo,ax);
      itoptions.ReproData.Type=ui_seltim(labels);
      if itoptions.ReproData.Type>size(labels,1),
        It=[];
        return;
      end;
      itoptions.ReproData.Type=deblank(labels(itoptions.ReproData.Type,:));
    end;
  end;
elseif strcmp(get(FileInfo(1),'type'),'axes'),
  % Possibility 2: It=DI_XXX(Axes,ItemOptionsDefault,CommandStruct)
  % Start with opening the requested file
  Option=2;

  CommandStruct=itoptions;
  itoptions=ax;
  ax=FileInfo;

  It=[];

  FileInfo.Data=ideas('opendata',CommandStruct.FileType,CommandStruct.FileName);
  itoptions.ReproData=CommandStruct;
else,
  % Possibility 3: DI_XXX(Item,AnimType,StepI)
  Option=3;
  AllItems=FileInfo;
  AnimType=ax;
  StepI=itoptions;

  NoOptItems=findobj(AllItems,'flat','userdata',[]);
  MainItem=setdiff(AllItems,NoOptItems);
  itoptions=get(MainItem,'userdata');
  FileInfo.Data=ideas('opendata',itoptions.ReproData.FileType,itoptions.ReproData.FileName);
end;

FileData=FileInfo.Data;
if Option<3,
  Tag=di_tag;
end;

switch(itoptions.ReproData.Type),
case 'counter', % ------------------------------------------------------------------------------
  if Option~=3,
    if Option==1,
      % <---------------- Time source
      Sources={'Map files: H maps';
               'Incremental files'};
      Source=ui_seltim(str2mat(Sources{:}));
      if Source>size(Sources,1),
        return;
      else,
        Source=Sources{Source};
      end;
      itoptions.ReproData.Source=Source;
      % <---------------- Time step
      switch Source,
      case 'Map files: H maps',
        tmstr=FileData.Map.HTimes;
      case 'Incremental files',
        tmstr=FileData.Begin:FileData.DisplayStep:FileData.End;
      end;
      tstep=ui_seltim(tmstr/24);
      itoptions.ReproData.Time=tstep;
    else, % Option==2
      % <---------------- Time source
      Source=itoptions.ReproData.Source;
      % <---------------- Time step
      tstep=itoptions.ReproData.Time;
    end;
    switch Source,
    case 'Map files: H maps',
      t=FileData.Map.HTimes(tstep); % in hours!
    case 'Incremental files',
      t=FileData.Begin+(tstep-1)*FileData.DisplayStep;
    end;

    it=line(0,0, ...
            'visible','off', ...
            'parent',ax); % dummy item
    set(it,'tag',num2hex(it));
    xx_counter(ax,t);
    % <---------------- Animation options
    switch Source,
    case 'Map files: H maps',
      itoptions.Animation(1).Type='Time evolution';
      itoptions.Animation(1).Nsteps=length(FileData.Map.HTimes);
    case 'Incremental files',
      itoptions.Animation(1).Type='Time evolution';
      itoptions.Animation(1).Nsteps=length(tmstr);
    end;
    % <---------------- Labels
    itoptions.Name=['counter - ',datestr(t,14)];
    itoptions.Type='dummy';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
  else,
    if StepI==-inf, return; end; % No initialization necessary
    if StepI==inf, % reset
      StepI=itoptions.ReproData.Time;
    end;

    Source=itoptions.ReproData.Source;
    switch AnimType,
    case 'Time evolution',
      it=AllItems(1); % one item part expected
      switch Source,
      case 'Map files: H maps',
        t=FileData.Map.HTimes(StepI); % in hours!
      case 'Incremental files',
        t=FileData.Begin+(StepI-1)*FileData.DisplayStep;
      end;
      xx_counter(get(MainItem,'parent'),t);
    end;
  end;
case 'clock', % -------------------------------------------------------------------------------
  if Option~=3,
    if Option==1,
      % <---------------- Time source
      Sources={'Map files: H maps';
               'Incremental files'};
      Source=ui_seltim(str2mat(Sources{:}));
      if Source>size(Sources,1),
        return;
      else,
        Source=Sources{Source};
      end;
      itoptions.ReproData.Source=Source;
      % <---------------- Time step
      switch Source,
      case 'Map files: H maps',
        tmstr=FileData.Map.HTimes;
      case 'Incremental files',
        tmstr=FileData.Begin:FileData.DisplayStep:FileData.End;
      end;
      tstep=ui_seltim(tmstr/24);
      itoptions.ReproData.Time=tstep;
    else, % Option==2
      % <---------------- Time source
      Source=itoptions.ReproData.Source;
      % <---------------- Time step
      tstep=itoptions.ReproData.Time;
    end;
    switch Source,
    case 'Map files: H maps',
      t=FileData.Map.HTimes(tstep); % in hours!
      t=1+t/24; % in days
    case 'Incremental files',
      t=FileData.Begin+(tstep-1)*FileData.DisplayStep;
      t=1+t/24; % in days
    end;

    dnum=datevec(t);
    it=line(0,0, ...
            'visible','off', ...
            'parent',ax); % dummy item
    set(it,'tag',num2hex(it));
    xx_clock(ax,dnum(4:6));
    % <---------------- Animation options
    switch Source,
    case 'Map files: H maps',
      itoptions.Animation(1).Type='Time evolution';
      itoptions.Animation(1).Nsteps=length(FileData.Map.HTimes);
    case 'Incremental files',
      itoptions.Animation(1).Type='Time evolution';
      itoptions.Animation(1).Nsteps=length(tmstr);
    end;
    % <---------------- Labels
    itoptions.Name=['clock - ',datestr(t,14)];
    itoptions.Type='dummy';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
  else,
    if StepI==-inf, return; end; % No initialization necessary
    if StepI==inf, % reset
      StepI=itoptions.ReproData.Time;
    end;

    Source=itoptions.ReproData.Source;
    switch AnimType,
    case 'Time evolution',
      it=AllItems(1); % one item part expected
      switch Source,
      case 'Map files: H maps',
        t=FileData.Map.HTimes(StepI); % in hours!
        t=1+t/24;
      case 'Incremental files',
        t=FileData.Begin+(StepI-1)*FileData.DisplayStep;
        t=1+t/24; % in days
      end;
      dnum=datevec(t);
      xx_clock(get(MainItem,'parent'),dnum(4:6));
    end;
  end;
case 'calendar', % -------------------------------------------------------------------------------
  if Option~=3,
    if Option==1,
      % <---------------- Time source
      Sources={'Map files: H maps';
               'Incremental files'};
      Source=ui_seltim(str2mat(Sources{:}));
      if Source>size(Sources,1),
        return;
      else,
        Source=Sources{Source};
      end;
      itoptions.ReproData.Source=Source;
      % <---------------- Time step
      switch Source,
      case 'Map files: H maps',
        tmstr=FileData.Map.HTimes;
      case 'Incremental files',
        tmstr=FileData.Begin:FileData.DisplayStep:FileData.End;
      end;
      tstep=ui_seltim(tmstr/24);
      itoptions.ReproData.Time=tstep;
    else, % Option==2
      % <---------------- Time source
      Source=itoptions.ReproData.Source;
      % <---------------- Time step
      tstep=itoptions.ReproData.Time;
    end;
    switch Source,
    case 'Map files: H maps',
      t=FileData.Map.HTimes(tstep); % in hours!
      t=1+t/24; % in days
    case 'Incremental files',
      t=FileData.Begin+(tstep-1)*FileData.DisplayStep;
      t=1+t/24; % in days
    end;

    it=line(0,0, ...
            'visible','off', ...
            'parent',ax); % dummy item
    set(it,'tag',num2hex(it));
    xx_date(ax,t);
    % <---------------- Animation options
    switch Source,
    case 'Map files: H maps',
      itoptions.Animation(1).Type='Time evolution';
      itoptions.Animation(1).Nsteps=length(FileData.Map.HTimes);
    case 'Incremental files',
      itoptions.Animation(1).Type='Time evolution';
      itoptions.Animation(1).Nsteps=length(tmstr);
    end;
    % <---------------- Labels
    itoptions.Name=['calendar - ',datestr(t,14)];
    itoptions.Type='dummy';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
  else,
    if StepI==-inf, return; end; % No initialization necessary
    if StepI==inf, % reset
      StepI=itoptions.ReproData.Time;
    end;

    Source=itoptions.ReproData.Source;
    switch AnimType,
    case 'Time evolution',
      it=AllItems(1); % one item part expected
      switch Source,
      case 'Map files: H maps',
        t=FileData.Map.HTimes(StepI); % in hours!
        t=1+t/24;
      case 'Incremental files',
        t=FileData.Begin+(StepI-1)*FileData.DisplayStep;
        t=1+t/24; % in days
      end;
      xx_date(get(MainItem,'parent'),t);
    end;
  end;
case 'time line', % -------------------------------------------------------------------------------
  if Option~=3,
    if Option==1,
      % <---------------- Time source
      Sources={'Map files: H maps';
               'Incremental files'};
      Source=ui_seltim(str2mat(Sources{:}));
      if Source>size(Sources,1),
        return;
      else,
        Source=Sources{Source};
      end;
      itoptions.ReproData.Source=Source;
      % <---------------- Time step
      switch Source,
      case 'Map files: H maps',
        tmstr=FileData.Map.HTimes;
      case 'Incremental files',
        tmstr=FileData.Begin:FileData.DisplayStep:FileData.End;
      end;
      tstep=ui_seltim(tmstr/24);
      itoptions.ReproData.Time=tstep;
    else, % Option==2
      % <---------------- Time source
      Source=itoptions.ReproData.Source;
      % <---------------- Time step
      tstep=itoptions.ReproData.Time;
    end;
    switch Source,
    case 'Map files: H maps',
      t=FileData.Map.HTimes(tstep); % in hours!
      t=1+t/24; % in days
    case 'Incremental files',
      t=FileData.Begin+(tstep-1)*FileData.DisplayStep;
      t=1+t/24; % in days
    end;
    ylim=get(ax,'ylim');
    it=line(t*[1 1],ylim, ...
            'color','r', ...
            'tag',Tag, ...
            'parent',ax);
    set(it,'tag',num2hex(it));
    % <---------------- Animation options
    switch Source,
    case 'Map files: H maps',
      itoptions.Animation(1).Type='Time evolution';
      itoptions.Animation(1).Nsteps=length(FileData.Map.HTimes);
    case 'Incremental files',
      itoptions.Animation(1).Type='Time evolution';
      itoptions.Animation(1).Nsteps=length(tmstr);
    end;
    % <---------------- Labels
    itoptions.Name=['time line - ',datestr(t,6),' ',datestr(t,13)];
    itoptions.Type='time line';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
  else,
    if StepI==-inf, return; end; % No initialization necessary
    if StepI==inf, % reset
      StepI=itoptions.ReproData.Time;
    end;
    Source=itoptions.ReproData.Source;
    switch AnimType,
    case 'Time evolution',
      it=AllItems(1); % one item part expected
      switch Source,
      case 'Map files: H maps',
        t=FileData.Map.HTimes(StepI); % in hours!
        t=1+t/24;
      case 'Incremental files',
        t=FileData.Begin+(StepI-1)*FileData.DisplayStep;
        t=1+t/24; % in days
      end;
      ylim=get(get(it,'parent'),'ylim');
      set(it,'xdata',t*[1 1], ...
             'ydata',ylim);
    end;
  end;
case 'bottom', % ------------------------------------------------------------------------------
  if Option~=3,
    tmstr=FileData.Begin:FileData.DisplayStep:FileData.End;
    if Option==1,
      % <---------------- Surface colouring
      % <---------------- Time step
      tstep=ui_seltim(tmstr/24);
      tstep=tmstr(tstep);
      itoptions.ReproData.Time=tstep;
    else, % Option==2
      % <---------------- Surface colouring
      % <---------------- Time step
      tstep=itoptions.ReproData.Time;
    end;

%    x=transpose(FileData.UpperLeft(1)+(1:FileData.Size(1))*FileData.GridSize)*ones(1,FileData.Size(2));
%    y=ones(FileData.Size(1),1)*(FileData.UpperLeft(2)+FileData.Size(2)*FileData.GridSize-(1:FileData.Size(2))*FileData.GridSize);
    x=transpose(FileData.UpperLeft(1)+((1:FileData.Size(1)+1)-1.5)*FileData.GridSize)*ones(1,FileData.Size(2)+1);
    y=ones(FileData.Size(1)+1,1)*(FileData.UpperLeft(2)+(FileData.Size(2)+.5)*FileData.GridSize-(1:FileData.Size(2)+1)*FileData.GridSize);
    %c=c;
    z=-fls('bottom',FileData,tstep);
    it=surface('xdata',x, ...
               'ydata',y, ...
               'zdata',zeros(size(x)), ...
               'cdata',z, ...
               'edgecolor','none', ...
               'facecolor','flat', ...
               'cdatamapping','direct', ...
               'linewidth',0.001, ...
               'tag',Tag, ...
               'parent',ax);
    % <---------------- Animation options
    itoptions.Animation(1).Type='Time evolution';
    itoptions.Animation(1).Nsteps=length(tmstr);
    % <---------------- Labels
    itoptions.Name='bottom';
    itoptions.Type='bottom';
    clim=[min(z(:)) max(z(:))]; if clim(2)==clim(1), clim(2)=clim(2)+1; end;
    itoptions.CLim=clim;
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
    CRange=md_clrmngr(Tag,xx_colormap('brownmap'));
    clr=CRange(1)+(CRange(2)-CRange(1))*max(0,min(1,(z-clim(1))/(clim(2)-clim(1))));
    clr(isnan(z))=NaN;
    set(it,'cdata',clr);
    if strcmp(axtype,'undefined'), Local_SetAx_2DH(ax); end;
  else,
    if StepI==-inf, return; end; % No initialization necessary
    if StepI==inf, % reset
      tstep=itoptions.ReproData.Time;
    else,
      tstep=FileData.Begin+(StepI-1)*FileData.DisplayStep;
    end;
    switch AnimType,
    case 'Time evolution',
      it=AllItems(1); % one item part expected
      z=-fls('bottom',FileData,tstep);
      CRange=md_clrmngr(get(it,'tag'));
      clim=itoptions.CLim;
      clr=CRange(1)+(CRange(2)-CRange(1))*max(0,min(1,(z-clim(1))/(clim(2)-clim(1))));
      clr(isnan(z))=NaN;
      set(it,'cdata',clr);
    end;
  end;
case 'waterlevel', % ------------------------------------------------------------------------------
  if isempty(FileData.Map.HTimes),
    uiwait(msgbox('No waterlevel maps available.','modal'));
    return;
  end;
  if Option~=3,
    if Option==1,
      % <---------------- Surface colouring
      SurfCols={'waterlevel'; ...
                'waterdepth'};
      SurfCol=ui_type('colour',SurfCols);
      if isempty(SurfCol),
        return;
      end;
      itoptions.ReproData.Colour=SurfCol;
      % <---------------- Time step
      tmstr=FileData.Map.HTimes;
      tstep=ui_seltim(tmstr/24);
      itoptions.ReproData.Time=tstep;
    else, % Option==2
      % <---------------- Surface colouring
      SurfCol=itoptions.ReproData.Colour;
      % <---------------- Time step
      tstep=itoptions.ReproData.Time;
    end;
    if FileData.MapWriteStep<1,
      FileNr=round((FileData.Map.HTimes(tstep)-FileData.FirstWrite)/FileData.MapWriteStep);
    else,
      FileNr=floor(FileData.Map.HTimes(tstep));
    end;
    FileName=[FileData.FileBase sprintf('%3.3i',FileNr) '.amh'];
    z=arcgrid('read',FileName); % read waterdepth
    x=transpose(FileData.UpperLeft(1)+(1:FileData.Size(1))*FileData.GridSize)*ones(1,FileData.Size(2));
    y=ones(FileData.Size(1),1)*(FileData.UpperLeft(2)+FileData.Size(2)*FileData.GridSize-(1:FileData.Size(2))*FileData.GridSize);
    z=z.Data;
    z=z+setnan(z==0);
    switch SurfCol,
    case 'waterlevel',
      z=z-FileData.Depth;
      c=z;
      cmap=xx_colormap('bluemap');
    case 'waterdepth',
      c=z;
      z=z-FileData.Depth;
      cmap=flipud(xx_colormap('bluemap'));
    end;
    it=surface('xdata',x, ...
               'ydata',y, ...
               'zdata',z, ...
               'cdata',c, ...
               'edgecolor','none', ...
               'facecolor','interp', ...
               'cdatamapping','direct', ...
               'linewidth',0.001, ...
               'tag',Tag, ...
               'parent',ax);
    % <---------------- Animation options
    itoptions.Animation(1).Type='Time evolution';
    itoptions.Animation(1).Nsteps=length(FileData.Map.HTimes);
    % <---------------- Labels
    Day=floor(FileData.Map.HTimes(tstep)/24);
    Time=FileData.Map.HTimes(tstep)/24-Day;
    itoptions.Name=[SurfCol ' [S1] - day ' num2str(Day+1) ' ' datestr(FileData.Map.HTimes(tstep),13)];
    itoptions.Type='waterlevel';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
    CRange=md_clrmngr(Tag,cmap);
    if isfield(itoptions,'CRange'),
      minc=itoptions.CRange(1);
      maxc=itoptions.CRange(2);
    else,
      minc=min(c(:));
      maxc=max(c(:));
    end;
    set(it,'cdata',CRange(1)+(CRange(2)-CRange(1))*min(1,max(0,(c-minc)/(maxc-minc))));
    if strcmp(axtype,'undefined'), Local_SetAx_2DH(ax); end;
  else,
    if StepI==-inf, return; end; % No initialization necessary
    if StepI==inf, % reset
      StepI=itoptions.ReproData.Time;
    end;
    switch AnimType,
    case 'Time evolution',
      it=AllItems(1); % one item part expected
      if FileData.MapWriteStep<1,
        FileNr=round((FileData.Map.HTimes(StepI)-FileData.FirstWrite)/FileData.MapWriteStep);
      else,
        FileNr=floor(FileData.Map.HTimes(StepI));
      end;
      FileName=[FileData.FileBase sprintf('%3.3i',FileNr) '.amh'];
      z=arcgrid('read',FileName); % read waterdepth
      x=transpose(FileData.UpperLeft(1)+(1:FileData.Size(1))*FileData.GridSize)*ones(1,FileData.Size(2));
      y=ones(FileData.Size(1),1)*(FileData.UpperLeft(2)+FileData.Size(2)*FileData.GridSize-(1:FileData.Size(2))*FileData.GridSize);
      z=z.Data;
      z=z+setnan(z==0);
      % <---------------- Surface colouring
      switch itoptions.ReproData.Colour,
      case 'waterlevel',
        z=z-FileData.Depth;
        c=z;
      case 'waterdepth',
        c=z;
        z=z-FileData.Depth;
      end;
      CRange=md_clrmngr(get(it,'tag'));
      if isfield(itoptions,'CRange'),
        minc=itoptions.CRange(1);
        maxc=itoptions.CRange(2);
      else,
        minc=min(c(:));
        maxc=max(c(:));
      end;
      set(it,'zdata',z,'cdata',CRange(1)+(CRange(2)-CRange(1))*min(1,max(0,(c-minc)/(maxc-minc))));
    end;
  end;
case 'velocity vectors', % ------------------------------------------------------------------------------
  if isempty(FileData.Map.uTimes) |  isempty(FileData.Map.vTimes),
    uiwait(msgbox('No velocity maps available.','modal'));
    return;
  end;
  if Option~=3, % assumes uTimes are equal to vTimes
    if Option==1,
      % <---------------- Time step
      tmstr=FileData.Map.uTimes;
      tstep=ui_seltim(tmstr/24);
      itoptions.ReproData.Time=tstep;
    else, % Option==2
      % <---------------- Time step
      tstep=itoptions.ReproData.Time;
    end;
    if FileData.MapWriteStep<1,
      FileNr=round((FileData.Map.HTimes(tstep)-FileData.FirstWrite)/FileData.MapWriteStep);
    else,
      FileNr=floor(FileData.Map.HTimes(tstep));
    end;
    FileName=[FileData.FileBase sprintf('%3.3i',FileNr) '.amu'];
    u=arcgrid('read',FileName); % read U velocity
    FileName=[FileData.FileBase sprintf('%3.3i',FileNr) '.amv'];
    v=arcgrid('read',FileName); % read V velocity
    x=transpose(FileData.UpperLeft(1)+(1:FileData.Size(1))*FileData.GridSize)*ones(1,FileData.Size(2));
    y=ones(FileData.Size(1),1)*(FileData.UpperLeft(2)+FileData.Size(2)*FileData.GridSize-(1:FileData.Size(2))*FileData.GridSize);
    z=-FileData.Depth+10;
    tempfig=figure('integerhandle','off','visible','off');
    it=quiver3(x,y,z,u,v,zeros(size(u)),0.5);
%    it=quiver(x,y,z,u,v,zeros(size(u)),0.5,'x');
    set(it,'parent',ax,'tag',Tag);
    delete(tempfig); 

    % <---------------- Animation options
    itoptions.Animation(1).Type='Time evolution';
    itoptions.Animation(1).Nsteps=length(FileData.Map.uTimes);
    % <---------------- Labels
    Day=floor(FileData.Map.uTimes(tstep)/24);
    Time=FileData.Map.uTimes(tstep)/24-Day;
    itoptions.Name=['velocity vectors - day ' num2str(Day+1) ' ' datestr(FileData.Map.uTimes(tstep),13)];
    itoptions.Type='velocity vectors';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
    if strcmp(axtype,'undefined'), Local_SetAx_2DH(ax); end;
  else,
    if StepI==-inf, return; end; % No initialization necessary
    if StepI==inf, % reset
      StepI=itoptions.ReproData.Time;
    end;
    switch AnimType,
    case 'Time evolution',
      delete(AllItems);
      if FileData.MapWriteStep<1,
        FileNr=round((FileData.Map.uTimes(StepI)-FileData.FirstWrite)/FileData.MapWriteStep);
      else,
        FileNr=floor(FileData.Map.uTimes(StepI));
      end;
      FileName=[FileData.FileBase sprintf('%3.3i',FileNr) '.amu'];
      u=arcgrid('read',FileName); % read U velocity
      FileName=[FileData.FileBase sprintf('%3.3i',FileNr) '.amv'];
      v=arcgrid('read',FileName); % read V velocity
      x=transpose(FileData.UpperLeft(1)+(1:FileData.Size(1))*FileData.GridSize)*ones(1,FileData.Size(2));
      y=ones(FileData.Size(1),1)*(FileData.UpperLeft(2)+FileData.Size(2)*FileData.GridSize-(1:FileData.Size(2))*FileData.GridSize);
      z=-FileData.Depth+10;;

      tempfig=figure('integerhandle','off','visible','off');
      it=quiver3(x,y,z,u,v,zeros(size(u)),0.5);
%      it=quiver(x,y,z,u,v,zeros(size(u)),0.5,'x');
      set(it,'parent',ax);
      delete(tempfig); 
    end;
  end;
case 'classified data', % ------------------------------------------------------------------------------
%  if isempty(FileData.Map.HTimes),
%    uiwait(msgbox('No waterlevel maps available.','modal'));
%    return;
%  end;
  VertShift=50;
  if Option~=3,
    tmstr=FileData.Begin:FileData.DisplayStep:FileData.End;
    if Option==1,
      % <---------------- Surface colouring
      SurfCols={'waterdepth';'waterlevel'};
      SurfCol=ui_type('colour',SurfCols);
      if isempty(SurfCol),
        return;
      end;
      itoptions.ReproData.Colour=SurfCol;
      % <---------------- Time step
      tstep=ui_seltim(tmstr/24);
      tstep=tmstr(tstep);
      itoptions.ReproData.Time=tstep;
    else, % Option==2
      % <---------------- Surface colouring
      SurfCol=itoptions.ReproData.Colour;
      % <---------------- Time step
      tstep=itoptions.ReproData.Time;
    end;
    x=transpose(FileData.UpperLeft(1)+(1:FileData.Size(1))*FileData.GridSize)*ones(1,FileData.Size(2));
    y=ones(FileData.Size(1),1)*(FileData.UpperLeft(2)+(0:(FileData.Size(2)-1))*FileData.GridSize);
    switch SurfCol,
    case 'waterdepth',
      z=-FileData.Depth+VertShift;
      faces=reshape(1:prod(size(x)),size(x));
      faces=faces(1:end-1,1:end-1);
      [c,FileData]=fls('inc',FileData,1,tstep);
      try,
        FI2.FileName=FileData.FileName;
        FI2.FileType='FLS mdf file';
        FI2.Data=FileData;
        md_filemem('newfileinfo',FI2);
      catch,end;
      c=c(1:end-1,1:end-1);
      c(isnan(c))=0;
      ZeroClasses=[1 [FileData.Class.FileInfo.Quant(1).Class]<=0];
      c=c+setnan(ZeroClasses(c+1));
      cmap=flipud(xx_colormap('bluemap',length(FileData.Class.H)-sum(ZeroClasses)+1));
      clim=[sum(ZeroClasses) length(FileData.Class.H)];
    case 'waterlevel',
      [h,FileData]=fls('inc',FileData,1,tstep);
      h(isnan(h))=0;
      ZeroClasses=[1 [FileData.Class.FileInfo.Quant(1).Class]<=0];

      [c,FileData]=fls('inc',FileData,3,tstep);
      try,
        FI2.FileName=FileData.FileName;
        FI2.FileType='FLS mdf file';
        FI2.Data=FileData;
        md_filemem('newfileinfo',FI2);
      catch,end;
      c(isnan(c))=0;
      Map=[NaN FileData.Class.FileInfo.Quant(3).Class];
      z=Map(c+1);
      z=z+setnan(ZeroClasses(h+1));
      faces=reshape(1:prod(size(x)),size(x));
      faces=faces(1:end-1,1:end-1);
      c=c(1:end-1,1:end-1);
      % c(isnan(c))=0;
      cmap=flipud(xx_colormap('bluemap',length(FileData.Class.H)-sum(ZeroClasses)+1));
      clim=[0 length(FileData.Class.Z)];
    otherwise,
      c=[];
      cmap=[1 1 1];
      clim=[1 2];
    end;
%    it=trisurface(ax,x,y,z,c,ones(size(x)),ones(size(x)));
%    it=surface('xdata',x,'ydata',y,'zdata',z, ...
%               'cdata',c, ...
%               'edgecolor','none', ...
%               'facecolor','flat', ...
%               'linewidth',0.001, ...
%               'parent',ax);
    it=patch('vertices',[x(:) y(:) z(:)], ...
               'faces',[faces(:) faces(:)+1 faces(:)+size(x,1)+1 faces(:)+size(x,1)], ...
               'facevertexcdata',c(:), ...
               'cdatamapping','direct', ...
               'edgecolor','none', ...
               'facecolor','flat', ...
               'linewidth',0.001, ...
               'tag',Tag, ...
               'parent',ax);
    % <---------------- Animation options
    itoptions.Animation(1).Type='Time evolution';
    itoptions.Animation(1).Nsteps=length(tmstr);
    % <---------------- Labels
    Day=floor(tstep/24);
    Time=tstep/24-Day;
    itoptions.Name=[SurfCol ' [CLASS] - day ' num2str(Day+1) ' ' datestr(Time,13)];
    itoptions.Type='classified data';
    itoptions.CLim=clim;
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
    CRange=md_clrmngr(Tag,cmap);
    c=CRange(1)+c-clim(1);
    set(it,'facevertexcdata',c(:));
    if strcmp(axtype,'undefined'), Local_SetAx_2DH(ax); end;
  else,
    if StepI==-inf, return; end; % No initialization necessary
    if StepI==inf, % reset
      StepI=itoptions.ReproData.Time;
    else,
      StepI=FileData.Begin+(StepI-1)*FileData.DisplayStep;
    end;
    switch AnimType,
    case 'Time evolution',
      it=AllItems(1); % one item part expected
      % <---------------- Surface colouring
      switch itoptions.ReproData.Colour,
      case 'waterdepth',
        [c,FileData]=fls('inc',FileData,1,StepI);
        try,
          FI2.FileName=FileData.FileName;
          FI2.FileType='FLS mdf file';
          FI2.Data=FileData;
          md_filemem('newfileinfo',FI2);
        catch,end;
        c=c(1:end-1,1:end-1);
        c(isnan(c))=0;
        ZeroClasses=[1 [FileData.Class.FileInfo.Quant(1).Class]<=0];
        c=c+setnan(ZeroClasses(c+1));
        CRange=md_clrmngr(get(it,'tag'));
        c=CRange(1)+c-itoptions.CLim(1);
        set(it,'facevertexcdata',c(:));
      case 'waterlevel',
        [h,FileData]=fls('inc',FileData,1,StepI);
        h(isnan(h))=0;
        ZeroClasses=[1 [FileData.Class.FileInfo.Quant(1).Class]<=0];
  
        [c,FileData]=fls('inc',FileData,3,StepI);
        try,
          FI2.FileName=FileData.FileName;
          FI2.FileType='FLS mdf file';
          FI2.Data=FileData;
          md_filemem('newfileinfo',FI2);
        catch,end;
        c(isnan(c))=0;
        Map=[NaN FileData.Class.FileInfo.Quant(3).Class];
        z=Map(c+1);
        z=z+setnan(ZeroClasses(h+1));
        c=c(1:end-1,1:end-1);
        % c(isnan(c))=0;

        CRange=md_clrmngr(get(it,'tag'));
        c=CRange(1)+c-itoptions.CLim(1);
        set(it,'vertices',vert,'facevertexcdata',c(:));
      end;
%      trisurface(it,z,c,ones(size(z)),ones(size(z)));
%      set(it,'cdata',c(:));

    end;
  end;
case 'grid point', % ------------------------------------------------------------------------------
  if Option~=3,
    if Option==1,
      MN=gui_selcross({1:FileData.Size(1),1:FileData.Size(2)},'NoAll',{1 1});
      itoptions.ReproData.M=MN{1};
      itoptions.ReproData.N=MN{2};
    end;
    M=itoptions.ReproData.M;
    N=FileData.Size(2)-itoptions.ReproData.N+1;
    x=transpose(FileData.UpperLeft(1)+(1:FileData.Size(1))*FileData.GridSize)*ones(1,FileData.Size(2));
    y=ones(FileData.Size(1),1)*(FileData.UpperLeft(2)+FileData.Size(2)*FileData.GridSize-(1:FileData.Size(2))*FileData.GridSize);
    zLim=get(ax,'zlim');
    PointStr=['(',num2str(itoptions.ReproData.M),',',num2str(itoptions.ReproData.N),')'];
    it(3)=text(x(M,N),y(M,N),zLim(2),['  ' PointStr], ...
            'fontunits','points', ...
            'fontsize',6, ...
            'color','k', ...
            'clipping','off', ...
            'tag',Tag, ...
            'parent',ax);
    it(2)=line([x(M,N) x(M,N)],[y(M,N) y(M,N)],zLim, ...
            'color','b', ...
            'linestyle','-', ...
            'linewidth',1, ...
            'marker','none', ...
            'clipping','off', ...
            'tag',Tag, ...
            'parent',ax);
    it(1)=line(x(M,N),y(M,N),zLim(2), ...
            'color','r', ...
            'marker','.', ...
            'markersize',12, ...
            'clipping','off', ...
            'tag',Tag, ...
            'parent',ax);
    itoptions.Name=['grid point ',PointStr];
    itoptions.Type='grid point';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
    if strcmp(axtype,'undefined'), Local_SetAx_2DH(ax); end;
  end;
case 'waterdepth [MAP] at a grid point', % ------------------------------------------------------------------------------
  if Option~=3,
    if Option==1,
      MN=gui_selcross({1:FileData.Size(1),1:FileData.Size(2)},'NoAll',{1 1});
      itoptions.ReproData.M=MN{1};
      itoptions.ReproData.N=MN{2};
    end;
    M=itoptions.ReproData.M;
    N=itoptions.ReproData.N;
    if FileData.MapWriteStep<1,
      FileNrs=round((FileData.Map.HTimes-FileData.FirstWrite)/FileData.MapWriteStep);
    else,
      FileNrs=floor(FileData.Map.HTimes);
    end;
    t=FileData.Map.HTimes; % in hours!
    t=1+t/24; % in days
    S=zeros(size(t));
    for i=1:length(t),
      FileName=[FileData.FileBase sprintf('%3.3i',FileNrs(i)) '.amh'];
      z=arcgrid('read',FileName); % read waterdepth
      S(i)=z.Data(M,N);
    end;
    it=line('xdata',t, ...
            'ydata',S, ...
            'marker','.', ...
            'tag',Tag, ...
            'parent',ax);
    itoptions.Name=['waterdepth at point (',num2str(M),',',num2str(N),')'];
    itoptions.Type='fls line';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
    if strcmp(axtype,'undefined'), Local_SetAx_ZT(ax); end;
  end;
case 'discharge through cross section'
  if Option~=3,
    CrossSecs=[ones(FileData.Cross.FileInfo.NumCross,1)*'(', ...
      num2str(FileData.Cross.FileInfo.M(:,1)), ...
      ones(FileData.Cross.FileInfo.NumCross,1)*',', ...
      num2str(FileData.Cross.FileInfo.N(:,1)), ...
      ones(FileData.Cross.FileInfo.NumCross,1)*')-(', ...
      num2str(FileData.Cross.FileInfo.M(:,2)), ...
      ones(FileData.Cross.FileInfo.NumCross,1)*',', ...
      num2str(FileData.Cross.FileInfo.N(:,2)), ...
      ones(FileData.Cross.FileInfo.NumCross,1)*')'];
    if Option==1,
      CrossSec=ui_seltim(CrossSecs);
      if CrossSec>FileData.Cross.FileInfo.NumCross,
        return;
      end;
      itoptions.ReproData.CrossSec=CrossSec;
    else, % Option==2
      CrossSec=itoptions.ReproData.CrossSec;
    end;
    t=1+fls('cross',FileData,'T')/24;
    Q=fls('cross',FileData,CrossSec);
    it=line('xdata',t, ...
            'ydata',Q, ...
            'marker','.', ...
            'tag',Tag, ...
            'parent',ax);
    itoptions.Name=['discharge [CRS] at ',CrossSecs(CrossSec,:),'.'];
    itoptions.Type='fls line';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
    if strcmp(axtype,'undefined'), Local_SetAx_ZT(ax); end;
  end;

case 'waterdepth [BIN] at a grid point', % ------------------------------------------------------------------------------
  if Option~=3,
    Stations=[ones(FileData.Bin.FileInfo.NumSta,1)*'[', ...
      num2str(transpose(FileData.Bin.FileInfo.M)), ...
      ones(FileData.Bin.FileInfo.NumSta,1)*',', ...
      num2str(transpose(FileData.Bin.FileInfo.N)), ...
      ones(FileData.Bin.FileInfo.NumSta,1)*']'];
    if Option==1,
      Station=ui_seltim(Stations);
      if Station>FileData.Bin.FileInfo.NumSta,
        return;
      end;
      itoptions.ReproData.Station=Station;
    else, % Option==2
      Station=itoptions.ReproData.Station;
    end;
    t=1+fls('bin',FileData,'T')/24;
    H=fls('bin',FileData,'H',Station);
    it=line('xdata',t, ...
            'ydata',H, ...
            'marker','.', ...
            'tag',Tag, ...
            'parent',ax);
    itoptions.Name=['waterdepth [BIN] at ',Stations(Station,:),'.'];
    itoptions.Type='fls line';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
    if strcmp(axtype,'undefined'), Local_SetAx_ZT(ax); end;
  end;

case 'waterlevel [BIN] at a grid point', % ------------------------------------------------------------------------------
  if Option~=3,
    Stations=[ones(FileData.Bin.FileInfo.NumSta,1)*'[', ...
      num2str(transpose(FileData.Bin.FileInfo.M)), ...
      ones(FileData.Bin.FileInfo.NumSta,1)*',', ...
      num2str(transpose(FileData.Bin.FileInfo.N)), ...
      ones(FileData.Bin.FileInfo.NumSta,1)*']'];
    if Option==1,
      Station=ui_seltim(Stations);
      if Station>FileData.Bin.FileInfo.NumSta,
        return;
      end;
      itoptions.ReproData.Station=Station;
    else, % Option==2
      Station=itoptions.ReproData.Station;
    end;
    t=1+fls('bin',FileData,'T')/24;
    S=fls('bin',FileData,'S',Station);
    it=line('xdata',t, ...
            'ydata',S, ...
            'marker','.', ...
            'tag',Tag, ...
            'parent',ax);
    itoptions.Name=['waterdepth [BIN] at ',Stations(Station,:),'.'];
    itoptions.Type='fls line';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
    if strcmp(axtype,'undefined'), Local_SetAx_ZT(ax); end;
  end;

case 'waterdepth [HIS] at a grid point', % ------------------------------------------------------------------------------
  if Option~=3,
    Stations=[ones(FileData.His.FileInfo.NumSta,1)*'[', ...
      num2str(transpose(FileData.His.FileInfo.M)), ...
      ones(FileData.His.FileInfo.NumSta,1)*',', ...
      num2str(transpose(FileData.His.FileInfo.N)), ...
      ones(FileData.His.FileInfo.NumSta,1)*']'];
    if Option==1,
      Station=ui_seltim(Stations);
      if Station>FileData.His.FileInfo.NumSta,
        return;
      end;
      itoptions.ReproData.Station=Station;
    else, % Option==2
      Station=itoptions.ReproData.Station;
    end;
    t=1+fls('his',FileData,'T')/24;
    H=fls('his',FileData,'H',Station);
    it=line('xdata',t, ...
            'ydata',H, ...
            'marker','.', ...
            'tag',Tag, ...
            'parent',ax);
    itoptions.Name=['waterdepth [HIS] at ',Stations(Station,:),'.'];
    itoptions.Type='fls line';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
    if strcmp(axtype,'undefined'), Local_SetAx_ZT(ax); end;
  end;
otherwise, % ----------------------------------------------------------------------------------
  Str=sprintf('%s not yet implemented.',itoptions.ReproData.Type);
  uiwait(msgbox(Str,'modal'));
end;
if Option~=3,
  It=it;
end;

% ----------------------------------------------------------------------------------------

function Local_SetAx_XXX(ax),
  axoptions=get(ax,'userdata');
  axoptions.Type='XXX';
  set(ax,'userdata',axoptions);

function Local_SetAx_2DH(ax),
  axoptions=get(ax,'userdata');
  axoptions.Type='2DH';
  set(ax,'userdata',axoptions);
  set(ax,'dataaspectratio',[1 1 1]);
  set(get(ax,'xlabel'),'string','m');
  set(get(ax,'ylabel'),'string','m');
  set(ax,'xlimmode','auto','xtickmode','auto','xticklabelmode','auto');
  set(ax,'ylimmode','auto','ytickmode','auto','yticklabelmode','auto');

function Local_SetAx_ZT(ax),
  axoptions=get(ax,'userdata');
  axoptions.Type='ZT';
  set(ax,'userdata',axoptions);
  get(ax,'xlim')
  set(ax,'dataaspectratiomode','auto','xlimmode','manual');
  set(get(ax,'xlabel'),'string','time');
  set(get(ax,'ylabel'),'string','m');
  tick(ax,'x','date');
  set(ax,'ylimmode','auto','ytickmode','auto','yticklabelmode','auto');
