function It=di_trimfile(FileInfo,ax,itoptions)
% DI_TRIMFILE is an interface for a Delft3D-trim file
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

persistent DFld
if isempty(DFld),
  DFld=scan_dsl('trimfile.dsl');
end;

it=[];

if nargin==2, % Possibility 4: PossibleItems=DI_XXX(FileInfo,Axes)
  Option=4;

  It=[];

  axoptions=get(ax,'userdata');
  axtype=axoptions.Type;

  plottypes= ...
    {'hydrodynamic grid'                      {'undefined','2DH'}  ; ...
     'morphologic grid'                       {'undefined','2DH'}  ; ...
     'flow points'                            {'undefined','2DH'}  ; ...

     'waterlevel'                             {'undefined','2DH','3D'}  ; ...
     'bottom'                                 {'undefined','2DH','3D'}  ; ...
     'time var. bottom'                       {'undefined','2DH','3D'}  ; ...
     'flow field'                             {'undefined','2DH'}  ; ...
     'flow direction field'                   {'undefined','2DH'}  ; ...
     'streamlines'                            {'2DH'}  ; ...

     'waterlevel along a grid line'           {'undefined','2DV'}  ; ...
     'bottom along a grid line'               {'undefined','2DV'}  ; ...

     'waterlevel at a grid point'             {'undefined','ZT'} ; ...
     'bottom at a grid point'                 {'undefined','ZT'} ; ...

     'progress of hydrodynamic time'          {'undefined','TN'} };

  labels=str2mat(plottypes{:,1});
  for pt=size(plottypes,1):-1:1,
    enab(pt)=~isempty(strmatch(axtype,plottypes{pt,2},'exact'));
  end;
  Possible=find(enab);
  enab=enab(Possible);
  It=labels(Possible,:);
  return;
elseif isstruct(FileInfo), % Possibility 1: It=DI_TRIMFILE(FileInfo,Axes,ItemOptionsDefault)
  Option=1;

  it=[];

  axoptions=get(ax,'userdata');
  axtype=axoptions.Type;

  if strcmp(axtype,'OBJECT'),
    itoptions.ReproData.Type=axoptions.ObjectType;
  else,
    if ~isfield(itoptions,'ReproData') | ~isfield(itoptions.ReproData,'Type'),
      labels=di_trimfile(FileInfo,ax);
      itoptions.ReproData.Type=ui_select({1,'item'},labels);
      if itoptions.ReproData.Type>size(labels,1),
        It=[];
        return;
      end;
      itoptions.ReproData.Type=deblank(labels(itoptions.ReproData.Type,:));
    end;
  end;
elseif strcmp(get(FileInfo(1),'type'),'axes'),
  % Possibility 2: It=DI_TRIMFILE(Axes,ItemOptionsDefault,CommandStruct)
  % Start with opening the requested file
  Option=2;
  CommandStruct=itoptions;
  itoptions=ax;
  ax=FileInfo;

  it=[];

  FileInfo=ideas('opendata',CommandStruct.FileType,CommandStruct.FileName);
  itoptions.ReproData=CommandStruct;
else,
  % Possibility 3: DI_TRIMFILE(Item,AnimType,StepI)
  Option=3;
  AllItems=FileInfo;
  AnimType=ax;
  StepI=itoptions;

  NoOptItems=findobj(AllItems,'flat','userdata',[]);
  MainItem=setdiff(AllItems,NoOptItems);
  itoptions=get(MainItem,'userdata');
  FileInfo=ideas('opendata',itoptions.ReproData.FileType,itoptions.ReproData.FileName);
end;

FileData=FileInfo.Data;
Tag=di_tag;

switch(itoptions.ReproData.Type),
case 'clock', % -------------------------------------------------------------------------------
  if Option~=3,
    if Option==1,
      % <---------------- Clock source
      Source='map-info-series'; % just one source
      itoptions.ReproData.Source=Source;
      % <---------------- Time step
      [tstep,tmstr,FileData]=Local_seltim(FileData);
      itoptions.ReproData.Time=tstep;
    else, % Option==2
      % <---------------- Clock source
      Source=itoptions.ReproData.Source;
      % <---------------- Time step
      [tstep,tmstr,FileData]=Local_seltim(FileData,itoptions.ReproData.Time);
    end;
    [dnum,FileData]=Local_readtim(FileData,tstep);
    dnum=datevec(dnum);
    it=line(0,0, ...
            'visible','off', ...
            'tag',Tag, ...
            'parent',ax); % dummy item
    di_clock(ax,dnum(4:6));
    % <---------------- Animation options
    itoptions.Animation(1).Type='Time evolution';
    timsource=vs_disp(FileData,Source,[]);
    itoptions.Animation(1).Nsteps=timsource.SizeDim;
    % <---------------- Labels
    itoptions.Name=['clock - ',tmstr];
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
      [dnum,FileData]=Local_readtim(FileData,StepI);
      dnum=datevec(dnum);
      di_clock(get(MainItem,'parent'),dnum(4:6));
    end;
  end;
case 'calendar', % -------------------------------------------------------------------------------
  if Option~=3,
    if Option==1,
      % <---------------- Calendar source
      Source='map-info-series'; % just one source
      itoptions.ReproData.Source=Source;
      % <---------------- Time step
      [tstep,tmstr,FileData]=Local_seltim(FileData);
      itoptions.ReproData.Time=tstep;
    else, % Option==2
      % <---------------- Calendar source
      Source=itoptions.ReproData.Source;
      % <---------------- Time step
      [tstep,tmstr,FileData]=Local_seltim(FileData,itoptions.ReproData.Time);
    end;
    [dnum,FileData]=Local_readtim(FileData,tstep);
    dnum=datevec(dnum);
    it=line(0,0, ...
            'visible','off', ...
            'tag',Tag, ...
            'parent',ax); % dummy item
    di_date(ax,dnum(1:3));
    % <---------------- Animation options
    itoptions.Animation(1).Type='Time evolution';
    timsource=vs_disp(FileData,Source,[]);
    itoptions.Animation(1).Nsteps=timsource.SizeDim;
    % <---------------- Labels
    itoptions.Name=['calendar - ',tmstr];
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
      [dnum,FileData]=Local_readtim(FileData,StepI);
      dnum=datevec(dnum);
      di_date(get(MainItem,'parent'),dnum(1:3));
    end;
  end;
case 'time bar', % -------------------------------------------------------------------------------
  if Option~=3,
    if Option==1,
      % <---------------- Time source
      Source='map-info-series'; % just one source
      itoptions.ReproData.Source=Source;
      % <---------------- Time step
      [tstep,tmstr,FileData]=Local_seltim(FileData);
      itoptions.ReproData.Time=tstep;
    else, % Option==2
      % <---------------- Clock source
      Source=itoptions.ReproData.Source;
      % <---------------- Time step
      [tstep,tmstr,FileData]=Local_seltim(FileData,itoptions.ReproData.Time);
    end;
    [dnum,FileData]=Local_readtim(FileData,tstep);
    it=line(0,0, ...
            'visible','off', ...
            'tag',Tag, ...
            'parent',ax); % dummy item
    [AllDNum,FileData]=Local_readtim(FileData);
    [dnumBegin,FileData]=Local_readtim(FileData,1);
    di_timbar(ax,'datediff',dnumBegin,dnum,max(AllDNum));
    % <---------------- Animation options
    itoptions.Animation(1).Type='Time evolution';
    timsource=vs_disp(FileData,Source,[]);
    itoptions.Animation(1).Nsteps=timsource.SizeDim;
    % <---------------- Labels
    itoptions.Name=['time bar - ',tmstr];
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
      [dnum,FileData]=Local_readtim(FileData,Source,StepI);
      di_timbar(get(MainItem,'parent'),dnum);
    end;
  end;
case 'morphologic grid', % -----------------------------------------------------------------
  description.Type='grid';
  description.Name='morphologic grid';
  description.X=DFld.Cmds{strmatch('morphologic grid X',DFld.Label)};
  description.X{7}=FileInfo.FileName;
  description.Y=DFld.Cmds{strmatch('morphologic grid Y',DFld.Label)};
  description.Y{7}=FileInfo.FileName;
  Info=vs_disp(FileData,'map-const','XCOR');
  description.Z=DFld.Cmds{strmatch('constant plane',DFld.Label)};
  description.Z{7}=gui_str(Info.SizeDim);
  description.Frame=1;
  ob_surface(ax,description);

case 'hydrodynamic grid', % -----------------------------------------------------------------
  description.Type='grid';
  description.Name='hydrodynamic grid';
  description.X=DFld.Cmds{strmatch('hydrodynamic grid X',DFld.Label)};
  description.X{7}=FileInfo.FileName;
  description.Y=DFld.Cmds{strmatch('hydrodynamic grid Y',DFld.Label)};
  description.Y{7}=FileInfo.FileName;
  Info=vs_disp(FileData,'map-const','XZ');
  description.Z=DFld.Cmds{strmatch('constant plane',DFld.Label)};
  description.Z{7}=gui_str(Info.SizeDim);
  description.Frame=1;
  ob_surface(ax,description);

case 'bottom', % -----------------------------------------------------------------------------
  description.Type='bottom';
  description.Name='bottom';
  description.X=DFld.Cmds{strmatch('morphologic grid X',DFld.Label)};
  description.X{7}=FileInfo.FileName;
  description.Y=DFld.Cmds{strmatch('morphologic grid Y',DFld.Label)};
  description.Y{7}=FileInfo.FileName;
  description.Z=DFld.Cmds{strmatch('bottom Z',DFld.Label)};
  description.Z{7}=FileInfo.FileName;
  Info=vs_disp(FileData,'map-series',[]);
  AniStr=['AnimateFields = [' sprintf(' %i',1:Info.SizeDim) ']'];
  description.T=GenLoad(DFld,'flow time',FileInfo.FileName,AniStr);
  description.Frame=1;
  ob_surface(ax,description);

case 'time var. bottom', % -----------------------------------------------------------------------------
  description.Type='bottom';
  description.Name='time var. bottom';
  description.X=DFld.Cmds{strmatch('hydrodynamic grid X',DFld.Label)};
  description.X{7}=FileInfo.FileName;
  description.Y=DFld.Cmds{strmatch('hydrodynamic grid Y',DFld.Label)};
  description.Y{7}=FileInfo.FileName;
  description.Z=DFld.Cmds{strmatch('bottom SPoint Z',DFld.Label)};
  description.Z{7}=FileInfo.FileName;
  Info=vs_disp(FileData,'map-series',[]);
  AniStr=['AnimateFields = [' sprintf(' %i',1:Info.SizeDim) ']'];
  description.Z{9}=AniStr;
  description.T=GenLoad(DFld,'flow time',FileInfo.FileName,AniStr);
  description.Frame=Info.SizeDim;
  ob_surface(ax,description);

case 'waterlevel', % -----------------------------------------------------------------------------
  SurfCols={'waterlevel'; ...
            'waterdepth'; ...
            'velocity U'; ...
            'velocity V'; ...
            'concentration'; ...
            'velocity magnitude'; ...
            'vertical eddy viscosity'; ...
            'vertical eddy diffusivity'; ...
            'Froude number'};
%            'spiral flow intensity'
  SurfCol=ui_type('colour',SurfCols);
  if isempty(SurfCol),
    return;
  end;
  switch SurfCol,
  case {'waterlevel','waterdepth'},
    description.Type=SurfCol;
  otherwise,
    description.Type='intensity';
  end;
  description.Name='waterlevel';
  description.X=DFld.Cmds{strmatch('hydrodynamic grid X',DFld.Label)};
  description.X{7}=FileInfo.FileName;
  description.Y=DFld.Cmds{strmatch('hydrodynamic grid Y',DFld.Label)};
  description.Y{7}=FileInfo.FileName;
  Info=vs_disp(FileData,'map-series',[]);
  AniStr=['AnimateFields = [' sprintf(' %i',1:Info.SizeDim) ']'];
  description.Z=GenLoad(DFld,'waterlevel',FileInfo.FileName,AniStr);
  description.OpenU=GenLoad(DFld,'velocity U',FileInfo.FileName,AniStr);
  description.OpenV=GenLoad(DFld,'velocity V',FileInfo.FileName,AniStr);

  switch SurfCol,
  case 'waterlevel',
  case 'waterdepth',
    InfoDP=vs_disp(FileData,'map-const',[]);
    description.C=DFld.Cmds{strmatch('waterdepth',DFld.Label)};
    [description.C{[7 16]}]=deal(FileInfo.FileName);
    [description.C{[9 18]}]=deal(AniStr);
  case 'Froude number',
    InfoDP=vs_disp(FileData,'map-const',[]);
    description.C=DFld.Cmds{strmatch('Froude',DFld.Label)};
    [description.C{[7 16 51]}]=deal(FileInfo.FileName);
    [description.C{[9 18 53]}]=deal(AniStr);
  case {'velocity U','velocity V','velocity magnitude','spiral flow intensity','vertical eddy viscosity','vertical eddy diffusivity','concentration'},
    description.C=GenLoad(DFld,SurfCol,FileInfo.FileName,AniStr);
  end;
  description.T=GenLoad(DFld,'flow time',FileInfo.FileName,AniStr);
  description.Frame=Info.SizeDim;
  ob_trisurface(ax,description);

case 'flow field', % ------------------------------------------------------------------------------
  SurfCols={'velocity magnitude'; ...
            'Froude number'};
  SurfCol=ui_type('colour',SurfCols);
  if isempty(SurfCol),
    return;
  end;
%  switch SurfCol,
%  case {'waterlevel','waterdepth'},
%    description.Type=SurfCol;
%  otherwise,
    description.Type='flow field';
%  end;
  description.Name='flow field';
  description.X=DFld.Cmds{strmatch('hydrodynamic grid X',DFld.Label)};
  description.X{7}=FileInfo.FileName;
  description.Y=DFld.Cmds{strmatch('hydrodynamic grid Y',DFld.Label)};
  description.Y{7}=FileInfo.FileName;
  Info=vs_disp(FileData,'map-series',[]);
  AniStr=['AnimateFields = [' sprintf(' %i',1:Info.SizeDim) ']'];
  description.U=GenLoad(DFld,'vel. x-dir in waterlevel points',FileInfo.FileName,AniStr);
  description.V=GenLoad(DFld,'vel. y-dir in waterlevel points',FileInfo.FileName,AniStr);
  description.Z=GenLoad(DFld,'waterlevel',FileInfo.FileName,AniStr);
  description.T=GenLoad(DFld,'flow time',FileInfo.FileName,AniStr);
  switch SurfCol,
%  case 'waterlevel',
%  case 'waterdepth',
%    description.C=DFld.Cmds{strmatch('waterdepth',DFld.Label)};
%    [description.C{[7 16]}]=deal(FileInfo.FileName);
%    description.C{9}=AniStr;
%    InfoDP=vs_disp(FileData,'BOTTIM',[]);
%    description.C{18}=sprintf('AnimateFields = [%i]',InfoDP.SizeDim); % only last bottom
  case 'Froude number',
    description.C=DFld.Cmds{strmatch('Froude number',DFld.Label)};
    [description.C{[7 16 51]}]=deal(FileInfo.FileName);
    [description.C{[9 53]}]=deal(AniStr);
    description.C{18}='AnimateFields = [1]'; % only one bottom
%  case 'velocity U',
%    description.C=GenLoad(DFld,'velocity U in waterlevel points',FileInfo.FileName,AniStr);
%  case 'velocity V',
%    description.C=GenLoad(DFld,'velocity V in waterlevel points',FileInfo.FileName,AniStr);
  case {'velocity magnitude','spiral flow intensity'},
    description.C=GenLoad(DFld,SurfCol,FileInfo.FileName,AniStr);
  end;
  description.Frame=Info.SizeDim;
  ob_quiver(ax,description);

case 'flow direction field', % -----------------------------------------------------------------
  if Option~=3,
    if Option==1,
      [tstep,tmstr,FileData]=Local_seltim(FileData);
      itoptions.ReproData.Time=tstep;
    else, % Option==2
      [tstep,tmstr,FileData]=Local_seltim(FileData,itoptions.ReproData.Time);
    end;
    [x,y]=Local_SGrid(FileData,{0 0});
    u=vs_get(FileData,'map-series',{tstep},'U1',{0 0 1});
    v=vs_get(FileData,'map-series',{tstep},'V1',{0 0 1});
    alfa=vs_get(FileData,'map-const',{1},'ALFAS',{0 0});
    uAct=vs_get(FileData,'map-series',{tstep},'KFU',{0 0});
    vAct=vs_get(FileData,'map-series',{tstep},'KFV',{0 0});
    utotal=sqrt(u.^2+v.^2);
    x=x+setnan(~uAct | ~vAct);
    utotal=utotal+setnan(utotal==0);
    u=u./utotal;
    v=v./utotal;
    tempfig=figure('integerhandle','off','visible','off');
    it=quiver(x,y,u.*cos(pi*alfa/180)+v.*sin(pi*alfa/180),u.*sin(pi*alfa/180)-v.*cos(pi*alfa/180),0.5,'x');
    it1=findobj(it,'flat','marker','x');
    set(it1,'marker','.','markersize',2);
    it2=findobj(it,'flat','marker','none');
    set(it2,'linewidth',0.1);
    set(it, ...
           'tag',Tag, ...
           'parent',ax);
    delete(tempfig); 
    itoptions.Name=['normalized flow field - ',tmstr];
    itoptions.Type='flow field';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
    if strcmp(axtype,'undefined'), xx_setax(ax,'2DH'); end;
  end;

case 'streamlines', % ---------------------------------------------------------------------------
  if Option==1, % Option==2 not yet supported
    [tstep,tmstr,FileData]=Local_seltim(FileData);
    itoptions.ReproData.Time=tstep;
    [x,y]=Local_SGrid(FileData,{0 0});
%    alfa=vs_get(FileData,'map-const',{1},'ALFAS',{0 0});
    u=vs_get(FileData,'map-series',{tstep},'U1',{0 0 1});
    v=vs_get(FileData,'map-series',{tstep},'V1',{0 0 1});
  %  uAct=vs_get(FileData,'map-series',{tstep},'KFU',{0 0});
  %  vAct=vs_get(vs,'map-series',{tstep},'KFV',{0 0});
    yesno='Yes';
    n=0;
    fig=get(ax,'parent');
    hvis=get(fig,'handlevisibility');
    set(fig,'handlevisibility','on');
    while strcmp(yesno,'Yes'),
      n=n+1;
      figure(fig);
      axes(ax);
      x0=fliplr(ginput(1));
      set(gcf,'pointer','watch');
      [xs,ys]=xx_streamline(x,y,u,v,x0);
%      [xs,ys]=xx_streamline(x,y,u.*cos(pi*alfa/180)+v.*sin(pi*alfa/180),u.*sin(pi*alfa/180)-v.*cos(pi*alfa/180),x0);
      set(gcf,'pointer','arrow');
      it(n)=line('xdata',xs, ...
              'ydata',ys, ...
              'linewidth',0.5, ...
              'parent',ax);
      yesno=questdlg('Draw another streamline?', ...
                     'Streamlines', ...
                     'Yes','No','Yes');
    end;
    set(fig,'handlevisibility',hvis);
    set(it, ...
           'tag',Tag, ...
           'userdata',itoptions);
    itoptions.Name=['streamlines - ',tmstr];
    itoptions.Type='streamline';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
    if strcmp(axtype,'undefined'), xx_setax(ax,'2DH'); end;
  end;

case 'flow points', % --------------------------------------------------------------------------
  if Option~=3,
    if Option==1,
      [tstep,tmstr,FileData]=Local_seltim(FileData);
      itoptions.ReproData.Time=tstep;
    else, % Option==2
      [tstep,tmstr,FileData]=Local_seltim(FileData,itoptions.ReproData.Time);
    end;
    [x,y]=Local_SGrid(FileData,{0 0});
    u=vs_get(FileData,'map-series',{tstep},'U1',{0 0 1});
    v=vs_get(FileData,'map-series',{tstep},'V1',{0 0 1});
    uAct=vs_get(FileData,'map-series',{tstep},'KFU',{0 0});
    vAct=vs_get(FileData,'map-series',{tstep},'KFV',{0 0});
    u=sign(u);
    v=sign(v);
    zero=zeros(size(u));
    xu=[(x(1:end,1:end-1)+x(1:end,2:end))/2 repmat(NaN,size(x,1),1)]+setnan(~uAct);
    yu=[(y(1:end,1:end-1)+y(1:end,2:end))/2 repmat(NaN,size(y,1),1)];
    tempfig=figure('integerhandle','off','visible','off');
    ittemp=cquiver(xu,yu,u,zero,0.5);
    set(ittemp, ...
               'tag',Tag, ...
               'parent',ax);
    it=ittemp;
    xu=[(x(1:end-1,1:end)+x(2:end,1:end))/2; repmat(NaN,1,size(x,1))]+setnan(~vAct);
    yu=[(y(1:end-1,1:end)+y(2:end,1:end))/2; repmat(NaN,1,size(y,1))];
    ittemp=cquiver(xu,yu,zero,v,0.5);
    set(ittemp, ...
               'tag',Tag, ...
               'parent',ax);
    it=[it; ittemp];
    delete(tempfig); 
    itoptions.Name=['flow points - ',tmstr];
    itoptions.Type='flow points';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
    if strcmp(axtype,'undefined'), xx_setax(ax,'2DH'); end;
  end;

case 'waterlevel along a grid line' % ----------------------------------------------------------
  if Option~=3,
    if Option==1,
      [tstep,tmstr,FileData]=Local_seltim(FileData);
      itoptions.ReproData.Time=tstep;
      grid=vs_disp(FileData,'map-const','XZ');
      MN=gui_selcross({1:grid.SizeDim(1),1:grid.SizeDim(2)},'OneAll',{1 1});
      M=MN{1}; if ischar(M), M=0; end;
      N=MN{2}; if ischar(N), N=0; end;
      itoptions.ReproData.Time=tstep;
      itoptions.ReproData.M=M;
      itoptions.ReproData.N=N;
    else, % Option==2
      [tstep,tmstr,FileData]=Local_seltim(FileData,itoptions.ReproData.Time);
      M=itoptions.ReproData.M;
      N=itoptions.ReproData.N;
    end;
    x=vs_get(FileData,'map-const',{1},'XZ',{M N});
    x=x(2:end-1);
    x=x+setnan(x==0);
    y=vs_get(FileData,'map-const',{1},'YZ',{M N});
    y=y(2:end-1);
    y=y+setnan(y==0);
    l=pathdistance(x,y);
    z=vs_get(FileData,'map-series',{tstep},'S1',{M N});
    z=z(2:end-1);
    it=line('xdata',l, ...
            'ydata',z, ...
            'marker','.', ...
            'tag',Tag, ...
            'parent',ax);
    % <---------------- Animation options
    itoptions.Animation(1).Type='Time evolution';
    curtim=vs_disp(FileData,'map-series',[]);
    itoptions.Animation(1).Nsteps=curtim.SizeDim;
    % <---------------- Labels
    if M==0,
      itoptions.Name=['waterlevel (N=',gui_str(N),') - ',tmstr];
    else,
      itoptions.Name=['waterlevel (M=',gui_str(M),') - ',tmstr];
    end;
    itoptions.Type='waterlevel gridline';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
    if strcmp(axtype,'undefined'), xx_setax(ax,'2DV'); end;
  else,
    switch AnimType,
    case 'Time evolution',
      if StepI==-inf, return; end; % No initialization necessary
      if StepI==inf, % reset
        StepI=itoptions.ReproData.Time;
      end;
      it=AllItems(1); % one item part expected
      z=vs_get(FileData,'map-series',{StepI},'S1',{itoptions.ReproData.M itoptions.ReproData.N},'quiet');
      z=z(2:end-1)
      set(it,'ydata',z);
    end;
  end;

case 'bottom along a grid line' % ------------------------------------------------------------
  if Option~=3,
    if Option==1,
      grid=vs_disp(FileData,'map-const','XCOR');
      MN=gui_selcross({1:grid.SizeDim(1),1:grid.SizeDim(2)},'OneAll',{1 1});
      M=MN{1}; if ischar(M), M=0; end;
      N=MN{2}; if ischar(N), N=0; end;
      itoptions.ReproData.M=M;
      itoptions.ReproData.N=N;
    else, % Option==2
      M=itoptions.ReproData.M;
      N=itoptions.ReproData.N;
    end;
    x=vs_get(FileData,'map-const',{1},'XCOR',{M N});
    x=x(2:end-1);
    x=x+setnan(x==0);
    y=vs_get(FileData,'map-const',{1},'YCOR',{M N});
    y=y(2:end-1);
    y=y+setnan(y==0);
    l=pathdistance(x,y);
    z=vs_get(FileData,'map-const',{1},'DP0',{M N});
    z=z(2:end-1);
    z=z+setnan(z==-999);
    it=line('xdata',l, ...
            'ydata',-z, ...
            'marker','.', ...
            'tag',Tag, ...
            'parent',ax);
    if M==0,
      itoptions.Name=['bottom (N=',gui_str(N),')'];
    else,
      itoptions.Name=['bottom (M=',gui_str(M),')'];
    end;
    itoptions.Type='bottom gridline';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
    if strcmp(axtype,'undefined'), xx_setax(ax,'2DV'); end;
  end;

case 'waterlevel at a grid point', % ----------------------------------------------------------
  if Option~=3,
    [t,FileData]=Local_readtim(FileData);
    if Option==1,
      grid=vs_disp(FileData,'map-const','XZ');
      MN=gui_selcross({1:grid.SizeDim(1),1:grid.SizeDim(2)},'NoAll',{1 1});
      itoptions.ReproData.M=MN{1};
      itoptions.ReproData.N=MN{2};
    else, % Option==2
      M=itoptions.ReproData.M;
      N=itoptions.ReproData.N;
    end;
    z=vs_get(FileData,'map-series',{tstep},'S1',{M N});
    z=[z{:}];
    it=line('xdata',t, ...
            'ydata',z, ...
            'marker','.', ...
            'tag',Tag, ...
            'parent',ax);
    itoptions.Name=['waterlevel at point (',gui_str(M),',',gui_str(N),')'];
    itoptions.Type='waterlevel point';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
    if strcmp(axtype,'undefined'), xx_setax(ax,'ZT'); end;
  end;

case 'bottom at a grid point', % ---------------------------------------------------------------
  if Option~=3,
    [t,FileData]=Local_readtim(FileData);
    if Option==1,
      grid=vs_disp(FileData,'map-const','XCOR');
      MN=gui_selcross({1:grid.SizeDim(1),1:grid.SizeDim(2)},'NoAll',{1 1});
      itoptions.ReproData.M=MN{1};
      itoptions.ReproData.N=MN{2};
    else, % Option==2
      M=itoptions.ReproData.M;
      N=itoptions.ReproData.N;
    end;
    z=vs_get(FileData,'map-const',{1},'DP0',{M N});
    if z==-999,
      uiwait(msgbox('no bottom defined for the indicated point','modal'));
      return;
    end;
    z=repmat(z,size(tstep));
    it=line('xdata',t, ...
            'ydata',-z, ...
            'marker','.', ...
            'tag',Tag, ...
            'parent',ax);
    itoptions.Name=['bottom at point (',gui_str(M),',',gui_str(N),')'];
    itoptions.Type='bottom point';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
    if strcmp(axtype,'undefined'), xx_setax(ax,'ZT'); end;
  end;

case 'progress of hydrodynamic time', % -------------------------------------------------------
  if Option~=3,
    [t,FileData]=Local_readtim(FileData);
    it=line('xdata',tstep, ...
            'ydata',t, ...
            'marker','.', ...
            'tag',Tag, ...
            'parent',ax);
    itoptions.Name=['time progress'];
    itoptions.Type='time progress';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
    if strcmp(axtype,'undefined'), xx_setax(ax,'TN'); end;
  end;

otherwise, % -----------------------------------------------------------------------------------
  Str=sprintf('%s not yet implemented.',itoptions.ReproData.Type);
  uiwait(msgbox(Str,'modal'));
end;
if Option~=3,
  It=it;
end;
FileInfo.Data=FileData;
md_filemem('newfileinfo',FileInfo);

% ----------------------------------------------------------------------------------------

function [x,y]=Local_UGrid(FileData,Selection); % determine locations of U points

function [x,y]=Local_VGrid(FileData,Selection); % determine locations of U points

function [x,y]=Local_DGrid(FileData,Selection); % determine locations of bottom points
  x=vs_get(FileData,'map-const',{1},'XCOR',Selection);
  y=vs_get(FileData,'map-const',{1},'YCOR',Selection);
  x((x==0) & (y==0))=NaN;
  y(isnan(x))=NaN;
%  x=x+setnan(x==0);
%  y=y+setnan(y==0);

function [x,y]=Local_SGrid(FileData,Selection); % determine locations of waterlevel points
  x=vs_get(FileData,'map-const',{1},'XZ',Selection);
  y=vs_get(FileData,'map-const',{1},'YZ',Selection);
  x((x==0) & (y==0))=NaN;
  y(isnan(x))=NaN;
%  x=x+setnan(x==0);
%  y=y+setnan(y==0);


function [tstep,tmstr,OutFileData]=Local_seltim(FileData,step),
%    Usage: [TSTEP,TMSTR,OutFileData]=LOCAL_SELTIM(FileData)
%           lets the user specify a time
%           [TSTEP,TMSTR,OutFileData]=LOCAL_SELTIM(FileData,TSTEP)
%           selects TSTEP, input and output TSTEP are the same in this case.
%           OutFileData equals FileData with the addition of a DayNum field if
%           all day numbers are read from file.
%
  if nargin==2, % known step
    tstep=step;
    [dnum,OutFileData]=Local_readtim(FileData,step);
    tmstr=datestr(dnum,0);
  else, % user select time step
    [dnum,OutFileData]=Local_readtim(FileData);
    if length(dnum)>1,
      tmstr={};
      for i=length(dnum):-1:1,
        tmstr{i}=datestr(dnum(i),0);
      end;
      tstep=gui_seltim(tmstr);
      tmstr=tmstr{tstep};
    else,
      tstep=1;
      tmstr=datestr(dnum,0);
    end;
  end;

function [dnum,OutFileData]=Local_readtim(FileData,step),
%    Usage: [DNUM,OUTFILEDATA]=LOCAL_SELTIM(FILEDATA) returns all day numbers
%           [DNUM,OUTFILEDATA]=LOCAL_SELTIM(FILEDATA,STEP) returns requested day number
%           OUTFILEDATA equals FILEDATA with the addition of a DayNum field if
%           all day numbers are read from file.
%
  OutFileData=FileData;
  if nargin==2, % one step
    if isfield(FileData,'MapInfoSeriesDayNum'),
      dnum=FileData.MapInfoSeriesDayNum(step);
    else,
      id=vs_get(FileData,'map-const',{1},'ITDATE',{1:2},'quiet');
      tunit=vs_get(FileData,'map-const',{1},'TUNIT',{1},'quiet');
      dt=vs_get(FileData,'map-const',{1},'DT',{1},'quiet');
      t=vs_get(FileData,'map-info-series',{step},'ITMAPC',{1},'quiet');
      dnum=Local_dt2datenum(id(1),id(2))+t*dt*tunit/(24*60*60);
    end;
  else, % all steps
    if isfield(FileData,'MapInfoSeriesDayNum'),
      dnum=FileData.MapInfoSeriesDayNum;
    else,
      id=vs_get(FileData,'map-const',{1},'ITDATE',{1:2},'quiet');
      tunit=vs_get(FileData,'map-const',{1},'TUNIT',{1},'quiet');
      dt=vs_get(FileData,'map-const',{1},'DT',{1},'quiet');
      t=vs_get(FileData,'map-info-series',{0},'ITMAPC',{1},'quiet');
      if iscell(t), 
        dnum=Local_dt2datenum(id(1),id(2))+[t{:}]*dt*tunit/(24*60*60);
      else,
        dnum=Local_dt2datenum(id(1),id(2))+t*dt*tunit/(24*60*60);
      end;
      OutFileData.MapInfoSeriesDayNum=dnum; % save for next time
    end;
  end;

function DateNum=Local_dt2datenum(Day,Time),

ref_year=floor(Day/10000);
ref_month=floor(Day/100-ref_year*100);
ref_day=Day-10000*ref_year-100*ref_month;

ref_hour=floor(Time/10000);
ref_minute=floor(Time/100-ref_hour*100);
ref_second=Time-10000*ref_hour-100*ref_minute;

DateNum=datenum(ref_year,ref_month,ref_day,ref_hour,ref_minute,ref_second);

function Fld=GenLoad(DFld,Str,FileName,AniStr);
Fld=DFld.Cmds{strmatch('general load',DFld.Label)};
Fld{2}=['1:LoadField:load ',Str];
Fld{7}=FileName;
Fld{8}=Str;
Fld{9}=AniStr;
