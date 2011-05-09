function It=di_botmfile(FileInfo,ax,itoptions)
% DI_BOTMFILE is an interface for a Delft3D-botm file
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

it=[];

if nargin==2, % Possibility 4: PossibleItems=DI_XXX(FileInfo,Axes)
  Option=4;

  It=[];

  axoptions=get(ax,'userdata');
  axtype=axoptions.Type;

  plottypes= ...
    {'hydrodynamic grid'                      {'undefined','2DH'}  ; ...
     'morphologic grid'                       {'undefined','2DH'}  ; ...

     'bottom'                                 {'undefined','2DH','3D'}  ; ...
     'bottom contours'                        {'undefined','2DH','3D'}  ; ...

     'bottom along a grid line'               {'undefined','2DV'}  ; ...

     'bottom at a grid point'                 {'undefined','ZT'} ; ...
     'time line'                              {'ZT'} ; ...

     'progress of morphological time'         {'undefined','TN'} };
  labels=str2mat(plottypes{:,1});
  for pt=size(plottypes,1):-1:1,
    enab(pt)=~isempty(strmatch(axtype,plottypes{pt,2},'exact'));
  end;
  Possible=find(enab);
  enab=enab(Possible);
  It=labels(Possible,:);
  return;
elseif isstruct(FileInfo), % Possibility 1: It=DI_BOTMFILE(FileInfo,Axes,ItemOptionsDefault)
  Option=1;

  It=[];

  axoptions=get(ax,'userdata');
  axtype=axoptions.Type;
  if strcmp(axtype,'OBJECT'),
    itoptions.ReproData.Type=axoptions.ObjectType;
  else,
    if ~isfield(itoptions,'ReproData') | ~isfield(itoptions.ReproData,'Type'),
      labels=di_botmfile(FileInfo,ax);
      itoptions.ReproData.Type=ui_select({1,'item'},labels);
      if itoptions.ReproData.Type>size(labels,1),
        It=[];
        return;
      end;
      itoptions.ReproData.Type=deblank(labels(itoptions.ReproData.Type,:));
    end;
  end;
elseif strcmp(get(FileInfo(1),'type'),'axes'),
  % Possibility 2: It=DI_BOTMFILE(Axes,ItemOptionsDefault,CommandStruct)
  % Start with opening the requested file
  Option=2;

  CommandStruct=itoptions;
  itoptions=ax;
  ax=FileInfo;

  It=[];

  FileInfo=ideas('opendata',CommandStruct.FileType,CommandStruct.FileName);
  itoptions.ReproData=CommandStruct;
else,
  % Possibility 3: DI_BOTMFILE(Item,AnimType,StepI)
  Option=3;
  AllItems=FileInfo;
  AnimType=ax;
  StepI=itoptions;

  MainItem=AllItems(1);
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
      Source='MAPBOTTIM'; % just one source
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
            'parent',ax); % dummy item
    xx_clock(ax,dnum(4:6));
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
      xx_clock(get(MainItem,'parent'),dnum(4:6));
    end;
  end;
case 'calendar', % -------------------------------------------------------------------------------
  if Option~=3,
    if Option==1,
      % <---------------- Calendar source
      Source='MAPBOTTIM'; % just one source
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
            'parent',ax); % dummy item
    xx_date(ax,dnum(1:3));
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
      xx_date(get(MainItem,'parent'),dnum(1:3));
    end;
  end;
case 'time bar', % -------------------------------------------------------------------------------
  if Option~=3,
    if Option==1,
      % <---------------- Time source
      Source='MAPBOTTIM'; % just one source
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
            'parent',ax); % dummy item
    [AllDNum,FileData]=Local_readtim(FileData);
    [dnumBegin,FileData]=Local_readtim(FileData,1);
    xx_timbar(ax,'datediff',dnumBegin,dnum,max(AllDNum));
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
      xx_timbar(get(MainItem,'parent'),dnum);
    end;
  end;
case 'time line', % -------------------------------------------------------------------------------
  if Option~=3,
    if Option==1,
      % <---------------- Time source
      Source='MAPBOTTIM'; % just one source
      itoptions.ReproData.Source=Source;
      % <---------------- Time step
      [tstep,tmstr,FileData]=Local_seltim(FileData);
      itoptions.ReproData.Time=tstep;
    else, % Option==2
      % <---------------- Time source
      Source=itoptions.ReproData.Source;
      % <---------------- Time step
      [tstep,tmstr,FileData]=Local_seltim(FileData,itoptions.ReproData.Time);
    end;
    [dnum,FileData]=Local_readtim(FileData,tstep);
    ylim=get(ax,'ylim');
    it=line(dnum*[1 1],ylim, ...
            'color','r', ...
            'parent',ax);
    % <---------------- Animation options
    itoptions.Animation(1).Type='Time evolution';
    timsource=vs_disp(FileData,Source,[]);
    itoptions.Animation(1).Nsteps=timsource.SizeDim;
    % <---------------- Labels
    itoptions.Name=['time line - ',tmstr];
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
      [dnum,FileData]=Local_readtim(FileData,StepI);
      ylim=get(get(it,'parent'),'ylim');
      set(it,'xdata',dnum*[1 1], ...
             'ydata',ylim);
    end;
  end;
case 'hydrodynamic grid', % -----------------------------------------------------------------
  description.Type='grid';
  description.Name='hydrodynamic grid';
  description.X={...
    'output = 1:1'
    '1:LoadField:load x-grid'
    'LowerLeft = 100 100'
    '0 inputs'
    '{'
    'Delft3D-botm'
    FileInfo.FileName
    'hydrodynamic grid X-coordinates'
    'AnimateFields = 1'
    '}'};
  description.Y={...
    'output = 1:1'
    '1:LoadField:load y-grid'
    'LowerLeft = 100 100'
    '0 inputs'
    '{'
    'Delft3D-botm'
    FileInfo.FileName
    'hydrodynamic grid Y-coordinates'
    'AnimateFields = 1'
    '}'};
  Info=vs_disp(FileData,'TEMPOUT','XWAT');
  description.Z={...
    'output = 1:1'
    '1:ConstantMatrix:elevation data'
    'LowerLeft = 100 100'
    '0 inputs'
    '{'
    '0'
    gui_str(Info.SizeDim)
    '}'};
  description.Frame=1;
  ob_surface(ax,description);

case 'morphologic grid', % -------------------------------------------------------------------
  description.Type='grid';
  description.Name='morphologic grid';
  description.X={...
    'output = 1:1'
    '1:LoadField:load x-grid'
    'LowerLeft = 100 100'
    '0 inputs'
    '{'
    'Delft3D-botm'
    FileInfo.FileName
    'morphologic grid X-coordinates'
    'AnimateFields = 1'
    '}'};
  description.Y={...
    'output = 1:1'
    '1:LoadField:load y-grid'
    'LowerLeft = 100 100'
    '0 inputs'
    '{'
    'Delft3D-botm'
    FileInfo.FileName
    'morphologic grid Y-coordinates'
    'AnimateFields = 1'
    '}'};
  Info=vs_disp(FileData,'GRID','XCOR');
  description.Z={...
    'output = 1:1'
    '1:ConstantMatrix:elevation data'
    'LowerLeft = 100 100'
    '0 inputs'
    '{'
    '0'
    gui_str(Info.SizeDim)
    '}'};
  description.Frame=1;
  ob_surface(ax,description);

case 'bottom', % --------------------------------------------------------------------------------
  SurfCols={'bottom'; ...
            'erosion/sedimentation'};
  SurfCol=ui_type('colour',SurfCols);
  if isempty(SurfCol),
    return;
  end;
  description.Type='bottom';
  description.Name='bottom';
  description.X={...
    'output = 1:1'
    '1:LoadField:load x-grid'
    'LowerLeft = 100 100'
    '0 inputs'
    '{'
    'Delft3D-botm'
    FileInfo.FileName
    'morphologic grid X-coordinates'
    'AnimateFields = 1'
    '}'};
  description.Y={...
    'output = 1:1'
    '1:LoadField:load y-grid'
    'LowerLeft = 100 100'
    '0 inputs'
    '{'
    'Delft3D-botm'
    FileInfo.FileName
    'morphologic grid Y-coordinates'
    'AnimateFields = 1'
    '}'};
  Info=vs_disp('MAPBOTTIM',[]);
  description.Z={...
    'output = 2:1'
    '1:LoadField:load depth'
    'LowerLeft = 100 140'
    '0 inputs'
    '{'
    'Delft3D-botm'
    FileInfo.FileName
    'bottom'
    ['AnimateFields = [' sprintf(' %i',1:Info.SizeDim) ']']
    '}'
    '2:ScalarMultiply:times -1'
    'LowerLeft = 100 100'
    '1 inputs'
    '1:1'
    '{'
    '-1'
    '}'};
  if strcmp(SurfCol,'erosion/sedimentation'),
    description.C={...
      'output = 4:1'
      '1:LoadField:load depth'
      'LowerLeft = 100 180'
      '0 inputs'
      '{'
      'Delft3D-botm'
      FileInfo.FileName
      'bottom'
      ['AnimateFields = [' sprintf(' %i',1:Info.SizeDim) ']']
      '}'
      '2:LoadField:load reference depth'
      'LowerLeft = 200 180'
      '0 inputs'
      '{'
      'Delft3D-com'
      FileInfo.FileName
      'bottom'
      'AnimateFields = 1'
      '}'
      '3:ScalarMultiply:times -1'
      'LowerLeft = 100 140'
      '1 inputs'
      '1:1'
      '{'
      '-1'
      '}'
      '4:Sum:sum'
      'LowerLeft = 160 100'
      '2 inputs'
      '3:1'
      '2:1'
      '{'
      '}'};
  end;
  description.T={...
    'output = 1:1'
    '1:LoadField:load depth time'
    'LowerLeft = 100 140'
    '0 inputs'
    '{'
    'Delft3D-botm'
    FileInfo.FileName
    'bottom time'
    ['AnimateFields = [' sprintf(' %i',1:Info.SizeDim) ']']
    '}'};
  description.Frame=Info.SizeDim;
  ob_surface(ax,description);

case 'bottom contours', % -----------------------------------------------------------------
  if Option~=3,
    if Option==1,
      % <---------------- Time step
      [tstep,tmstr,FileData]=Local_seltim(FileData);
      itoptions.ReproData.Time=tstep;
      % <---------------- Enclosure
      itoptions.ReproData.Enclosure=strcmp('Yes',questdlg('Restrict to enclosure?','Plot area bottom','Yes','No','No'));
      % <---------------- Reference Time step
      if strcmp(itoptions.ReproData.Colour,'erosion/sedimentation'),
        [itoptions.ReproData.RefTime,DummyStr,FileData]=Local_seltim(FileData);
      end;
    else, % Option==2
      % <---------------- Time step
      [tstep,tmstr,FileData]=Local_seltim(FileData,itoptions.ReproData.Time);
    end;
    [x,y]=Local_DGrid(FileData,{0 0});
    z=vs_get(FileData,'MAPBOTTIM',{tstep},'DP',{0 0});
    if itoptions.ReproData.Enclosure, % apply grid enclosure
      zInAct=vs_get(FileData,'TEMPOUT',{1},'CODB',{0 0})<=0;
      x=x+setnan(zInAct);
      y=y+setnan(zInAct);
      z=z+setnan(zInAct);
    end;
    x=x+setnan(z==-999);
    y=y+setnan(z==-999);
    z=z+setnan(z==-999);
    % <---------------- Top extremes
    if any(abs(z(:))>100),
      warning('dataset contains extreme values: abs>100.');
      z=max(min(z,100),-100);
    end;
    tempfig=figure('integerhandle','off','visible','off');
    [cdata,it]=contour3(x,y,-z);
    set(it,'parent',ax,'userdata',[]);
    delete(tempfig); 
    % <---------------- Animation options
%    itoptions.Animation(1).Type='Time evolution';
%    bottim=vs_disp(FileData,'BOTTIM',[]);
%    itoptions.Animation(1).Nsteps=bottim.SizeDim;
    % <---------------- Labels
    itoptions.Name=[SurfCol,' [DP Contours] - ',tmstr];
    itoptions.Type='bottom contours';
    zz.Name=[SurfCol,' [DP Contours] - ',tmstr];
    set(it, ...
           'tag',Tag, ...
           'userdata',zz);
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
    if strcmp(axtype,'undefined'), xx_setax(ax,'2DH'); end;
  else,
    if StepI==-inf, return; end; % No initialization necessary
    if StepI==inf, % reset
      StepI=itoptions.ReproData.Time;
    end;
    switch AnimType,
    case 'Time evolution',
      delete(it);
      z=vs_get(FileData,'MAPBOTTIM',{StepI},'DP',{0 0},'quiet');
      z=z+setnan(z==-999);
      % <---------------- Top extremes
      if any(abs(z(:))>100),
        warning('dataset contains extreme values: abs>100.');
        z=max(min(z,100),-100);
      end;
      tempfig=figure('integerhandle','off','visible','off');
      [cdata,it]=contour3(x,y,-z);
      set(it,'parent',ax,'userdata',[]);
      delete(tempfig); 
      zz.Name=[SurfCol,' [DP Contours] - ',tmstr];
      set(it, ...
             'tag',Tag, ...
             'userdata',zz);
      set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
      if strcmp(axtype,'undefined'), xx_setax(ax,'2DH'); end;
    end;
  end;

case 'bottom along a grid line' % -----------------------------------------------------------
  if Option~=3,
    if Option==1,
      [tstep,tmstr,FileData]=Local_seltim(FileData);
      itoptions.ReproData.Time=tstep;
      grid=vs_disp(FileData,'GRID','XCOR');
      MN=gui_selcross({1:grid.SizeDim(1),1:grid.SizeDim(2)},'OneAll',{1 1});
      M=MN{1}; if ischar(M), M=0; end;
      N=MN{2}; if ischar(N), N=0; end;
      itoptions.ReproData.M=M;
      itoptions.ReproData.N=N;
    else, % Option==2
      [tstep,tmstr,FileData]=Local_seltim(FileData,itoptions.ReproData.Time);
      M=itoptions.ReproData.M;
      N=itoptions.ReproData.N;
    end;
    [x,y]=Local_DGrid(FileData,{M N});
    l=pathdistance(x,y);
    z=vs_get(FileData,'MAPBOTTIM',{tstep},'DP',{M N});
    z=z+setnan(z==-999);
    it=line('xdata',l, ...
            'ydata',-z, ...
            'marker','.', ...
            'tag',Tag, ...
            'parent',ax);
    % <---------------- Animation options
    itoptions.Animation(1).Type='Time evolution';
    bottim=vs_disp(FileData,'MAPBOTTIM',[]);
    itoptions.Animation(1).Nsteps=bottim.SizeDim;
    itoptions.Animation(2).Type='Spatial shift';
    Grid=vs_disp(FileData,'GRID','XCOR');
    if itoptions.ReproData.M==0,
      itoptions.Animation(2).Nsteps=Grid.SizeDim(2);
    else, % itoptions.ReproData.N=0;
      itoptions.Animation(2).Nsteps=Grid.SizeDim(1);
    end;
    % <---------------- Labels
    if M==0,
      itoptions.Name=['bottom (N=',gui_str(N),') - ',tmstr];
    else,
      itoptions.Name=['bottom (M=',gui_str(M),') - ',tmstr];
    end;
    itoptions.Type='bottom gridline';
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
      z=vs_get(FileData,'MAPBOTTIM',{StepI},'DP',{itoptions.ReproData.M itoptions.ReproData.N},'quiet');
      z=z+setnan(z==-999);
      set(it,'ydata',-z);
    case 'Spatial shift',
      if StepI==-inf, return; end; % No initialization necessary
      if itoptions.ReproData.M==0,
        M=0;
        if StepI==inf, % reset
          N=itoptions.ReproData.N;
        else,
          N=StepI;
        end;
      else, % itoptions.ReproData.N=0;
        if StepI==inf, % reset
          M=itoptions.ReproData.M;
        else,
          M=StepI;
        end;
        N=0;
      end;
      it=AllItems(1); % one item part expected
      z=vs_get(FileData,'MAPBOTTIM',{itoptions.ReproData.Time},'DP',{M N},'quiet');
      z=z+setnan(z==-999);
      set(it,'ydata',-z);
    end;
  end;

case 'bottom at a grid point', % ------------------------------------------------------------
  if Option~=3,
    if Option==1,
      grid=vs_disp(FileData,'GRID','XCOR');
      MN=gui_selcross({1:grid.SizeDim(1),1:grid.SizeDim(2)},'NoAll',{1 1});
      itoptions.ReproData.M=MN{1};
      itoptions.ReproData.N=MN{2};
    else, % Option==2
      M=itoptions.ReproData.M;
      N=itoptions.ReproData.N;
    end;
    bottim=vs_disp(FileData,'MAPBOTTIM',[]);
    z=vs_get(FileData,'MAPBOTTIM',{1:bottim.SizeDim},'DP',{M N});
    [t,FileData]=Local_readtim(FileData);
    z=[z{:}];
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

case 'progress of morphological time', % ------------------------------------------------------
  if Option~=3,
    bottim=vs_disp(FileData,'MAPBOTTIM',[]);
    tstep=1:bottim.SizeDim;
    % ----------------> reference date ?
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

otherwise, % ----------------------------------------------------------------------------------
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
  x=vs_get(FileData,'GRID',{1},'XCOR',Selection);
  y=vs_get(FileData,'GRID',{1},'YCOR',Selection);
  x((x==0) & (y==0))=NaN;
  y(isnan(x))=NaN;
%  x=x+setnan(x==0);
%  y=y+setnan(y==0);

function [x,y]=Local_SGrid(vs,Selection); % determine locations of waterlevel points
  x=vs_get(FileData,'TEMPOUT',{1},'XWAT',Selection);
  y=vs_get(FileData,'TEMPOUT',{1},'YWAT',Selection);
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
      tstep=ui_seltim(tmstr);
      tmstr=tmstr{tstep};
    else,
      tstep=1;
      tmstr=datestr(dnum,0);
    end;
  end;

function [dnum,OutFileData]=Local_readtim(FileData,step), % ----------------> reference date ?
%    Usage: [DNUM,OUTFILEDATA]=LOCAL_SELTIM(FILEDATA) returns all day numbers
%           [DNUM,OUTFILEDATA]=LOCAL_SELTIM(FILEDATA,STEP) returns requested day number
%           OUTFILEDATA equals FILEDATA with the addition of a DayNum field if
%           all day numbers are read from file.
%
  OutFileData=FileData;
  if nargin==2, % one step
    if isfield(FileData,'MapbottimDayNum'),
      dnum=FileData.MapbottimDayNum(step);
    else,
      tscale=vs_get(FileData,'MAPBOT',{1},'TSCALE',{1},'quiet');
      t=vs_get(FileData,'MAPBOTTIM',{step},'ITBODE',{1},'quiet');
      dnum=Local_dt2datenum(00101,0)+t*tscale/(24*60*60);
    end;
  else, % all steps
    if isfield(FileData,'MapbottimDayNum'),
      dnum=FileData.MapbottimDayNum;
    else,
      tscale=vs_get(FileData,'MAPBOT',{1},'TSCALE',{1},'quiet');
      t=vs_get(FileData,'MAPBOTTIM',{0},'ITBODE',{1},'quiet');
      if iscell(t), 
        dnum=Local_dt2datenum(00101,0)+[t{:}]*tscale/(24*60*60);
      else,
        dnum=Local_dt2datenum(00101,0)+t*tscale/(24*60*60);
      end;
      OutFileData.MapbottimDayNum=dnum; % save for next time
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

