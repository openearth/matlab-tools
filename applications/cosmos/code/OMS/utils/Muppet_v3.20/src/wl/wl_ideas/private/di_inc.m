function It=di_inc(FileInfo,ax,itoptions)
% DI_INC is an interface for a incremental files
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
%  DFld=scan_dsl('inc.dsl');
%end;

it=[];

if nargin==2, % Possibility 4: PossibleItems=DI_XXX(FileInfo,Axes)
  Option=4;

  It=[];

  axoptions=get(ax,'userdata');
  axtype=axoptions.Type;
  plottypes= ...
    {'waterdepth'                             {'undefined','2DH','3D'}
     'time line'                              {'undefined','ZT'}};

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
      % <---------------- Time step
      tmstr=FileData.Begin:FileData.DisplayStep:FileData.End;
      tstep=ui_seltim(tmstr/24);
      itoptions.ReproData.Time=tstep;
    else, % Option==2
      % <---------------- Time step
      tstep=itoptions.ReproData.Time;
    end;
    t=FileData.Begin+(tstep-1)*FileData.DisplayStep;
    
    it=line(0,0, ...
            'visible','off', ...
            'parent',ax); % dummy item
    set(it,'tag',num2hex(it));
    xx_counter(ax,t);
    % <---------------- Animation options
    itoptions.Animation(1).Type='Time evolution';
    itoptions.Animation(1).Nsteps=length(tmstr);
    % <---------------- Labels
    itoptions.Name=['counter - ',datestr(t,14)];
    itoptions.Type='dummy';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
  else,
    if StepI==-inf, return; end; % No initialization necessary
    if StepI==inf, % reset
      StepI=itoptions.ReproData.Time;
    end;

    switch AnimType,
    case 'Time evolution',
      it=AllItems(1); % one item part expected
      t=FileData.Begin+(StepI-1)*FileData.DisplayStep;
      xx_counter(get(MainItem,'parent'),t);
    end;
  end;
case 'clock', % -------------------------------------------------------------------------------
  if Option~=3,
    if Option==1,
      % <---------------- Time step
      tmstr=FileData.Begin:FileData.DisplayStep:FileData.End;
      tstep=ui_seltim(tmstr/24);
      itoptions.ReproData.Time=tstep;
    else, % Option==2
      % <---------------- Time step
      tstep=itoptions.ReproData.Time;
    end;
    t=FileData.Begin+(tstep-1)*FileData.DisplayStep;
    t=1+t/24; % in days

    dnum=datevec(t);
    it=line(0,0, ...
            'visible','off', ...
            'parent',ax); % dummy item
    set(it,'tag',num2hex(it));
    xx_clock(ax,dnum(4:6));
    % <---------------- Animation options
    itoptions.Animation(1).Type='Time evolution';
    itoptions.Animation(1).Nsteps=length(tmstr);
    % <---------------- Labels
    itoptions.Name=['clock - ',datestr(t,14)];
    itoptions.Type='dummy';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
  else,
    if StepI==-inf, return; end; % No initialization necessary
    if StepI==inf, % reset
      StepI=itoptions.ReproData.Time;
    end;

    switch AnimType,
    case 'Time evolution',
      it=AllItems(1); % one item part expected
      t=FileData.Begin+(StepI-1)*FileData.DisplayStep;
      t=1+t/24; % in days
      dnum=datevec(t);
      xx_clock(get(MainItem,'parent'),dnum(4:6));
    end;
  end;
case 'calendar', % -------------------------------------------------------------------------------
  if Option~=3,
    if Option==1,
      % <---------------- Time step
      tmstr=FileData.Begin:FileData.DisplayStep:FileData.End;
      tstep=ui_seltim(tmstr/24);
      itoptions.ReproData.Time=tstep;
    else, % Option==2
      % <---------------- Time step
      tstep=itoptions.ReproData.Time;
    end;
    t=FileData.Begin+(tstep-1)*FileData.DisplayStep;
    t=1+t/24; % in days

    it=line(0,0, ...
            'visible','off', ...
            'parent',ax); % dummy item
    set(it,'tag',num2hex(it));
    xx_date(ax,t);
    % <---------------- Animation options
    itoptions.Animation(1).Type='Time evolution';
    itoptions.Animation(1).Nsteps=length(tmstr);
    % <---------------- Labels
    itoptions.Name=['calendar - ',datestr(t,14)];
    itoptions.Type='dummy';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
  else,
    if StepI==-inf, return; end; % No initialization necessary
    if StepI==inf, % reset
      StepI=itoptions.ReproData.Time;
    end;

    switch AnimType,
    case 'Time evolution',
      it=AllItems(1); % one item part expected
      t=FileData.Begin+(StepI-1)*FileData.DisplayStep;
      t=1+t/24; % in days
      xx_date(get(MainItem,'parent'),t);
    end;
  end;
case 'time line', % -------------------------------------------------------------------------------
  if Option~=3,
    if Option==1,
      % <---------------- Time step
      tmstr=FileData.Begin:FileData.DisplayStep:FileData.End;
      tstep=ui_seltim(tmstr/24);
      itoptions.ReproData.Time=tstep;
    else, % Option==2
      % <---------------- Time step
      tstep=itoptions.ReproData.Time;
    end;
    t=FileData.Begin+(tstep-1)*FileData.DisplayStep;
    t=1+t/24; % in days
    ylim=get(ax,'ylim');
    it=line(t*[1 1],ylim, ...
            'color','r', ...
            'tag',Tag, ...
            'parent',ax);
    set(it,'tag',num2hex(it));
    % <---------------- Animation options
    itoptions.Animation(1).Type='Time evolution';
    itoptions.Animation(1).Nsteps=length(tmstr);
    % <---------------- Labels
    itoptions.Name=['time line - ',datestr(t,6),' ',datestr(t,13)];
    itoptions.Type='time line';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
  else,
    if StepI==-inf, return; end; % No initialization necessary
    if StepI==inf, % reset
      StepI=itoptions.ReproData.Time;
    end;
    switch AnimType,
    case 'Time evolution',
      it=AllItems(1); % one item part expected
      t=FileData.Begin+(StepI-1)*FileData.DisplayStep;
      t=1+t/24; % in days
      ylim=get(get(it,'parent'),'ylim');
      set(it,'xdata',t*[1 1], ...
             'ydata',ylim);
    end;
  end;
case 'waterdepth', % ------------------------------------------------------------------------------
  if Option~=3,
    tmstr=FileData.Begin:FileData.DisplayStep:FileData.End;
    if Option==1,
      % <---------------- Time step
      tstep=ui_seltim(tmstr/24);
      tstep=tmstr(tstep);
      itoptions.ReproData.Time=tstep;
    else, % Option==2
      % <---------------- Time step
      tstep=itoptions.ReproData.Time;
    end;
    [C,FileData]=fls('inc',FileData,1,tstep);
    try,
      FI2.FileName=FileData.FileName;
      FI2.FileType='incremental file';
      FI2.Data=FileData;
      md_filemem('newfileinfo',FI2);
    catch,end;
    if ~iscell(C), C={C}; end
    xv=zeros(0,3);
    fv=zeros(0,4); foffset=0;
    cv=zeros(0,1);
    ZeroClasses=logical([1 [FileData.Quant(1).Class]<=0]);
    for i=1:length(C)
      c=C{i};
      x=transpose(FileData.Domain(i).XCorner+((1:FileData.Domain(i).NRows-1)-0.5)*FileData.Domain(i).XCellSize)*ones(1,FileData.Domain(i).NCols-1);
      y=ones(FileData.Domain(i).NRows-1,1)*(FileData.Domain(i).YCorner+(0.5:(FileData.Domain(i).NCols-1.5))*FileData.Domain(i).YCellSize);
      c=c(2:end-1,2:end-1);
%      x=transpose(FileData.Domain(i).XCorner+((1:FileData.Domain(i).NRows+1)-1.5)*FileData.Domain(i).XCellSize)*ones(1,FileData.Domain(i).NCols+1);
%      y=ones(FileData.Domain(i).NRows+1,1)*(FileData.Domain(i).YCorner+(FileData.Domain(i).NCols+.5)*FileData.Domain(i).YCellSize-(1:FileData.Domain(i).NCols+1)*FileData.Domain(i).YCellSize);
%      %c=c;
      c(isnan(c))=0;
      c(ZeroClasses(c+1))=NaN;
      z=zeros(size(x));
      faces=reshape(1:prod(size(x)),size(x));
      faces=faces(1:end-1,1:end-1);
      xv=[xv;x(:) y(:) z(:)];
      fv=[fv;foffset+[faces(:) faces(:)+1 faces(:)+size(x,1)+1 faces(:)+size(x,1)]];
      foffset=size(xv,1);
      cv=[cv;c(:)];
    end;
    cmap=flipud(xx_colormap('bluemap',length(FileData.Quant(1).Class)-sum(ZeroClasses)+1));
    clim=[sum(ZeroClasses) length(FileData.Quant(1).Class)];
    it=patch('vertices',xv, ...
               'faces',fv, ...
               'facevertexcdata',cv, ...
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
    itoptions.Name=['waterdepth [CLASS] - day ' num2str(Day+1) ' ' datestr(Time,13)];
    itoptions.Type='classified data';
    itoptions.CLim=clim;
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
    CRange=md_clrmngr(Tag,cmap);
    cv=CRange(1)+cv-clim(1);
    set(it,'facevertexcdata',cv);
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
      [C,FileData]=fls('inc',FileData,1,StepI);
      if ~iscell(C), C={C}; end
      try,
        FI2.FileName=FileData.FileName;
        FI2.FileType='incremental file';
        FI2.Data=FileData;
        md_filemem('newfileinfo',FI2);
      catch, end;
      cv=zeros(0,1);
      ZeroClasses=logical([1 [FileData.Quant(1).Class]<=0]);
      for i=1:length(C)
        c=C{i};
%        c=c(1:end-1,1:end-1);
        c=c(2:end-1,2:end-1);
        c(isnan(c))=0;
        c(ZeroClasses(c+1))=NaN;
        cv=[cv;c(:)];
      end;
      CRange=md_clrmngr(get(it,'tag'));
      cv=CRange(1)+cv-itoptions.CLim(1);
      set(it,'facevertexcdata',cv);
    end;
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
