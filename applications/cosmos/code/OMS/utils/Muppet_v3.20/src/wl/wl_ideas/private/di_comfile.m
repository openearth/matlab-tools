function It=di_comfile(FileInfo,ax,itoptions)
% DI_COMFILE is an interface for a Delft3D-trim file
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
  DFld=scan_dsl('comfile.dsl');
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
     'sediment transport'                     {'undefined','2DH','3D'}  ; ...
     'bottom'                                 {'undefined','2DH','3D'}  ; ...
     'bottom contours'                        {'undefined','2DH','3D'}  ; ...
     'flow field'                             {'undefined','2DH','3D'}  ; ...
     'flow direction field'                   {'undefined','2DH'}  ; ...
     'streamlines'                            {'2DH'}  ; ...

     'waterlevel along a grid line'           {'undefined','2DV'}  ; ...
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
elseif isstruct(FileInfo), % Possibility 1: It=DI_COMFILE(FileInfo,Axes,ItemOptionsDefault)
  Option=1;

  It=[];

  axoptions=get(ax,'userdata');
  axtype=axoptions.Type;
  if strcmp(axtype,'OBJECT'),
    itoptions.ReproData.Type=axoptions.ObjectType;
  else,
    if ~isfield(itoptions,'ReproData') | ~isfield(itoptions.ReproData,'Type'),
      labels=di_comfile(FileInfo,ax);
      itoptions.ReproData.Type=ui_select({1,'item'},labels);
      if itoptions.ReproData.Type>size(labels,1),
        It=[];
        return;
      end;
      itoptions.ReproData.Type=deblank(labels(itoptions.ReproData.Type,:));
    end;
  end;
elseif strcmp(get(FileInfo(1),'type'),'axes'),
  % Possibility 2: It=DI_COMFILE(Axes,ItemOptionsDefault,CommandStruct)
  % Start with opening the requested file
  Option=2;

  CommandStruct=itoptions;
  itoptions=ax;
  ax=FileInfo;

  It=[];

  FileInfo=ideas('opendata',CommandStruct.FileType,CommandStruct.FileName);
  itoptions.ReproData=CommandStruct;
else,
  % Possibility 3: DI_COMFILE(Item,AnimType,StepI)
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
case 'time line', % -------------------------------------------------------------------------

case 'hydrodynamic grid', % -----------------------------------------------------------------
  description.Type='grid';
  description.Name='hydrodynamic grid';
  description.X=DFld.Cmds{strmatch('hydrodynamic grid X',DFld.Label)};
  description.X{7}=FileInfo.FileName;
  description.Y=DFld.Cmds{strmatch('hydrodynamic grid Y',DFld.Label)};
  description.Y{7}=FileInfo.FileName;
  Info=vs_disp(FileData,'GRID','XWAT');
  description.Z=DFld.Cmds{strmatch('constant plane',DFld.Label)};
  description.Z{7}=gui_str(Info.SizeDim);
  description.Frame=1;
  ob_surface(ax,description);

case 'morphologic grid', % -------------------------------------------------------------------
  description.Type='grid';
  description.Name='morphologic grid';
  description.X=DFld.Cmds{strmatch('morphologic grid X',DFld.Label)};
  description.X{7}=FileInfo.FileName;
  description.Y=DFld.Cmds{strmatch('morphologic grid Y',DFld.Label)};
  description.Y{7}=FileInfo.FileName;
  Info=vs_disp(FileData,'GRID','XCOR');
  description.Z=DFld.Cmds{strmatch('constant plane',DFld.Label)};
  description.Z{7}=gui_str(Info.SizeDim);
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
  description.X=DFld.Cmds{strmatch('morphologic grid X',DFld.Label)};
  description.X{7}=FileInfo.FileName;
  description.Y=DFld.Cmds{strmatch('morphologic grid Y',DFld.Label)};
  description.Y{7}=FileInfo.FileName;
  Info=vs_disp(FileData,'BOTTIM',[]);
  description.Z=DFld.Cmds{strmatch('bottom Z',DFld.Label)};
  description.Z{7}=FileInfo.FileName;
  description.Z{9}=['AnimateFields = [' sprintf(' %i',1:Info.SizeDim) ']'];
  if strcmp(SurfCol,'erosion/sedimentation'),
    description.C=DFld.Cmds{strmatch('erosion/sedimentation',DFld.Label)};
    [description.C{[7 16]}]=deal(FileInfo.FileName);
    description.C{9}=['AnimateFields = [' sprintf(' %i',1:Info.SizeDim) ']'];
  end;
  description.T=DFld.Cmds{strmatch('bottom T',DFld.Label)};
  description.T{7}=FileInfo.FileName;
  description.T{9}=['AnimateFields = [' sprintf(' %i',1:Info.SizeDim) ']'];
  description.Frame=Info.SizeDim;
  ob_surface(ax,description);

case 'sediment transport', % -------------------------------------------------------------------------------
  SurfCols={'average bedload transport xi-direction'; ...
     'average bedload transport eta-direction'; ...
     'average bedload transport'; ...
     'average suspended transport xi-direction'; ...
     'average suspended transport eta-direction'; ...
     'average suspended transport'; ...
     'average total sediment transport xi-direction'; ...
     'average total sediment transport eta-direction'; ...
     'average total sediment transport'};
  SurfCol=ui_type('colour',SurfCols);
  if isempty(SurfCol),
    return;
  end;
  description.Type='sediment transport';
  description.Name='sediment transport';
  description.X=DFld.Cmds{strmatch('hydrodynamic grid X',DFld.Label)};
  description.X{7}=FileInfo.FileName;
  description.Y=DFld.Cmds{strmatch('hydrodynamic grid Y',DFld.Label)};
  description.Y{7}=FileInfo.FileName;
  Info=vs_disp(FileData,'CURTIM',[]);
  AniStr=['AnimateFields = [' sprintf(' %i',1:Info.SizeDim) ']'];
  description.Z=GenLoad(DFld,'waterlevel',FileInfo.FileName,AniStr);
  Info=vs_disp(FileData.NefisStruct,'TRANSTIM',[]);
  AniStr=['AnimateFields = [' sprintf(' %i',1:Info.SizeDim) ']'];
  description.C=GenLoad(DFld,SurfCol,FileInfo.FileName,AniStr);
  description.T=GenLoad(DFld,'flow time',FileInfo.FileName,AniStr);
  AniStr=['AnimateFields = [' sprintf(' %i',1:Info.SizeDim) ']'];
  description.OpenU=GenLoad(DFld,'open U',FileInfo.FileName,AniStr);
  description.OpenV=GenLoad(DFld,'open V',FileInfo.FileName,AniStr);
  description.OpenV=GenLoad(DFld,SurfCol,FileInfo.FileName,'AnimateFields = [1]');
  description.Frame=1;
  ob_trisurface(ax,description);

case 'waterlevel', % -------------------------------------------------------------------------------
  SurfCols={'waterlevel'; ...
            'waterdepth'; ...
            'velocity U'; ...
            'velocity V'; ...
            'velocity magnitude'; ...
            'Froude number'; ...
            'energy height'; ...
            'spiral flow intensity'};
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
  Info=vs_disp(FileData,'KENMTIM',[]);
  AniStr=['AnimateFields = [' sprintf(' %i',1:Info.SizeDim) ']'];
  description.OpenU=GenLoad(DFld,'open U',FileInfo.FileName,AniStr);
  description.OpenV=GenLoad(DFld,'open V',FileInfo.FileName,AniStr);
  Info=vs_disp(FileData,'CURTIM',[]);
  AniStr=['AnimateFields = [' sprintf(' %i',1:Info.SizeDim) ']'];
  description.Z=GenLoad(DFld,'waterlevel',FileInfo.FileName,AniStr);
  description.T=GenLoad(DFld,'flow time',FileInfo.FileName,AniStr);
  switch SurfCol,
  case 'waterlevel',
  case 'waterdepth',
    description.C=DFld.Cmds{strmatch('waterdepth',DFld.Label)};
    [description.C{[7 16]}]=deal(FileInfo.FileName);
    description.C{9}=AniStr;
    InfoDP=vs_disp(FileData,'BOTTIM',[]);
    description.C{18}=sprintf('AnimateFields = [%i]',InfoDP.SizeDim); % only last bottom
  case 'energy height',
    description.C=DFld.Cmds{strmatch('energy height',DFld.Label)};
    [description.C{[7 36]}]=deal(FileInfo.FileName);
    [description.C{[9 38]}]=deal(AniStr);
  case 'Froude number',
    description.C=DFld.Cmds{strmatch('Froude number',DFld.Label)};
    [description.C{[7 16 51]}]=deal(FileInfo.FileName);
    [description.C{[9 53]}]=deal(AniStr);
    InfoDP=vs_disp(FileData,'BOTTIM',[]);
    description.C{18}=sprintf('AnimateFields = [%i]',InfoDP.SizeDim); % only last bottom
  case 'velocity U',
    description.C=GenLoad(DFld,'velocity U in waterlevel points',FileInfo.FileName,AniStr);
  case 'velocity V',
    description.C=GenLoad(DFld,'velocity V in waterlevel points',FileInfo.FileName,AniStr);
  case {'velocity magnitude','spiral flow intensity'},
    description.C=GenLoad(DFld,SurfCol,FileInfo.FileName,AniStr);
  end;
  description.Frame=Info.SizeDim;
  ob_trisurface(ax,description);

case 'flow points', % -------------------------------------------------------------------------

case 'flow field', % -----------------------------------------------------------------------------
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
  Info=vs_disp(FileData,'CURTIM',[]);
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
    InfoDP=vs_disp(FileData,'BOTTIM',[]);
    description.C{18}=sprintf('AnimateFields = [%i]',InfoDP.SizeDim); % only last bottom
%  case 'velocity U',
%    description.C=GenLoad(DFld,'velocity U in waterlevel points',FileInfo.FileName,AniStr);
%  case 'velocity V',
%    description.C=GenLoad(DFld,'velocity V in waterlevel points',FileInfo.FileName,AniStr);
  case {'velocity magnitude','spiral flow intensity'},
    description.C=GenLoad(DFld,SurfCol,FileInfo.FileName,AniStr);
  end;
  description.Frame=Info.SizeDim;
  ob_quiver(ax,description);

case 'streamlines', % --------------------------------------------------------------------------
  if Option==1, % does not yet support Option 2
    [tstep,tmstr,FileData]=Local_seltim(FileData,'CURTIM');
    [x,y]=Local_SGrid(FileData,{0 0});
    u=vs_get(FileData,'CURTIM',{tstep},'U1',{0 0});
    v=vs_get(FileData,'CURTIM',{tstep},'V1',{0 0});
%    alfa=vs_get(FileData,'GRID',{1},'ALFAS',{0 0});
  %  uAct=u~=0;
  %  vAct=v~=0;
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
    set(it,'userdata',itoptions,'tag',Tag);
    itoptions.Name=['streamlines - ',tmstr];
    itoptions.Type='streamline';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
    if strcmp(axtype,'undefined'), xx_setax(ax,'2DH'); end;
  end;

case 'waterlevel along a grid line' % ---------------------------------------------------------
  if Option~=3,
    if Option==1,
      [tstep,tmstr,FileData]=Local_seltim(FileData,'CURTIM');
      itoptions.ReproData.Time=tstep;
      grid=vs_disp(FileData,'TEMPOUT','XWAT');
      MN=gui_selcross({1:grid.SizeDim(1),1:grid.SizeDim(2)},'OneAll',{1 1});
      M=MN{1}; if ischar(M), M=0; end;
      N=MN{2}; if ischar(N), N=0; end;
      itoptions.ReproData.M=M;
      itoptions.ReproData.N=N;
    else, % Option==2
      [tstep,tmstr,FileData]=Local_seltim(FileData,'CURTIM',itoptions.ReproData.Time);
      M=itoptions.ReproData.M;
      N=itoptions.ReproData.N;
    end;
    [x,y]=Local_SGrid(FileData,{M N});
    l=pathdistance(x,y);
    z=vs_get(FileData,'CURTIM',{tstep},'S1',{M N});
    it=line('xdata',l, ...
            'ydata',z, ...
            'marker','.', ...
            'tag',Tag, ...
            'parent',ax);
    if M==0,
      itoptions.Name=['waterlevel (N=',gui_str(N),') - ',tmstr];
    else,
      itoptions.Name=['waterlevel (M=',gui_str(M),') - ',tmstr];
    end;
    itoptions.Type='waterlevel gridline';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
    if strcmp(axtype,'undefined'), xx_setax(ax,'2DV'); end;
  end;
case 'bottom along a grid line' % -----------------------------------------------------------
  if Option~=3,
    if Option==1,
      % <---------------- Time step
      [tstep,tmstr,FileData]=Local_seltim(FileData,'BOTTIM');
      itoptions.ReproData.Time=tstep;
      % <---------------- Cross-section
      grid=vs_disp(FileData,'GRID','XCOR');
      MN=gui_selcross({1:grid.SizeDim(1),1:grid.SizeDim(2)},'OneAll',{1 1});
      % <---------------- Enclosure
      itoptions.ReproData.Enclosure=strcmp('Yes',questdlg('Restrict to enclosure?','Plot area bottom','Yes','No','No'));
      M=MN{1}; if ischar(M), M=0; end;
      N=MN{2}; if ischar(N), N=0; end;
      itoptions.ReproData.M=M;
      itoptions.ReproData.N=N;
    else, % Option==2
      [tstep,tmstr,FileData]=Local_seltim(FileData,'BOTTIM',itoptions.ReproData.Time);
      M=itoptions.ReproData.M;
      N=itoptions.ReproData.N;
    end;
    [x,y]=Local_DGrid(FileData,{M N});
    z=vs_get(FileData,'BOTTIM',{tstep},'DP',{M N});
    z=z+setnan(z==-999);

    if itoptions.ReproData.Enclosure, % apply grid enclosure
      zAct=vs_get(FileData,'KENMCNST',{1},'KCS',{M N});
      z(zAct==0)=NaN;
    end;
    l=pathdistance(x,y);
    it=line('xdata',l, ...
            'ydata',-z, ...
            'marker','.', ...
            'tag',Tag, ...
            'parent',ax);
    % <---------------- Animation options
    itoptions.Animation(1).Type='Time evolution';
    bottim=vs_disp(FileData,'BOTTIM',[]);
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
      z=vs_get(FileData,'BOTTIM',{StepI},'DP',{itoptions.ReproData.M itoptions.ReproData.N},'quiet');
      z=z+setnan(z==-999);
      if itoptions.ReproData.Enclosure, % apply grid enclosure
        zAct=vs_get(FileData,'KENMCNST',{1},'KCS',{itoptions.ReproData.M itoptions.ReproData.N},'quiet');
        z(zAct==0)=NaN;
      end;
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
      z=vs_get(FileData,'BOTTIM',{itoptions.ReproData.Time},'DP',{M N},'quiet');
      z=z+setnan(z==-999);
      if itoptions.ReproData.Enclosure, % apply grid enclosure
        zAct=vs_get(FileData,'KENMCNST',{1},'KCS',{M N},'quiet');
        z(zAct==0)=NaN;
      end;
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
    bottim=vs_disp(FileData,'BOTTIM',[]);
    z=vs_get(FileData,'BOTTIM',{1:bottim.SizeDim},'DP',{M N});
    if iscell(z),
      z=[z{:}];
    end;
    [t,FileData]=Local_readtim(FileData,'BOTTIM');
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
    bottim=vs_disp(FileData,'BOTTIM',[]);
    tstep=1:bottim.SizeDim;
    y0=vs_get(FileData,'PARAMS',{1},'IT01',{1});
    t0=vs_get(FileData,'PARAMS',{1},'IT02',{1});
    t=vs_get(FileData,'BOTTIM',{tstep},'TIMBOT',{1});
    t=Local_dt2datenum(y0,t0)+[t{:}]/(24*60);
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

function [x,y]=Local_SGrid(FileData,Selection); % determine locations of waterlevel points
  x=vs_get(FileData,'TEMPOUT',{1},'XWAT',Selection);
  y=vs_get(FileData,'TEMPOUT',{1},'YWAT',Selection);
  x((x==0) & (y==0))=NaN;
  y(isnan(x))=NaN;
%  x=x+setnan(x==0);
%  y=y+setnan(y==0);

function [tstep,tmstr,OutFileData]=Local_seltim(FileData,option,step),
%    Usage: [TSTEP,TMSTR,OutFileData]=LOCAL_SELTIM(FileData,'TIMELIST')
%           lets the user specify a time from the specified 'TIMELIST'
%           [TSTEP,TMSTR,OutFileData]=LOCAL_SELTIM(FileData,'TIMELIST',TSTEP)
%           selects TSTEP from the specified 'TIMELIST', input and output TSTEP
%           are the same in this case.
%           OutFileData equals FileData with the addition of a DayNum field if
%           all day numbers are read from file.
%
  if nargin==3, % known step
    tstep=step;
    [dnum,OutFileData]=Local_readtim(FileData,option,step);
    tmstr=datestr(dnum,0);
  else, % user select time step
    [dnum,OutFileData]=Local_readtim(FileData,option);
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

function [dnum,OutFileData]=Local_readtim(FileData,option,step),
%    Usage: [DNUM,OUTFILEDATA]=LOCAL_SELTIM(FILEDATA,'TIMELIST') returns all day numbers
%           [DNUM,OUTFILEDATA]=LOCAL_SELTIM(FILEDATA,'TIMELIST',STEP) returns requested day number
%           OUTFILEDATA equals FILEDATA with the addition of a DayNum field if
%           all day numbers are read from file.
%
  OutFileData=FileData;
  switch option,
  case 'CURTIM',
    if nargin==3, % known step
      if isfield(FileData,'CurtimDayNum'),
        dnum=FileData.CurtimDayNum(step);
      else,
        tscale=vs_get(FileData,'PARAMS',{1},'TSCALE',{1},'quiet');
        y0=vs_get(FileData,'PARAMS',{1},'IT01',{1},'quiet');
        t0=vs_get(FileData,'PARAMS',{1},'IT02',{1},'quiet');
        t=vs_get(FileData,'CURTIM',{step},'TIMCUR',{1},'quiet');
        dnum=Local_dt2datenum(y0,t0)+t*tscale/(24*60*60);
      end;
    else, % all steps
      if isfield(FileData,'CurtimDayNum'),
        dnum=FileData.CurtimDayNum;
      else,
        tscale=vs_get(FileData,'PARAMS',{1},'TSCALE',{1},'quiet');
        y0=vs_get(FileData,'PARAMS',{1},'IT01',{1},'quiet');
        t0=vs_get(FileData,'PARAMS',{1},'IT02',{1},'quiet');
        t=vs_get(FileData,'CURTIM',{0},'TIMCUR',{1},'quiet');
        if iscell(t), 
          dnum=Local_dt2datenum(y0,t0)+[t{:}]*tscale/(24*60*60);
        else,
          dnum=Local_dt2datenum(y0,t0)+t*tscale/(24*60*60);
        end;
        OutFileData.CurtimDayNum=dnum; % save for next time
      end;
    end;
  case 'BOTTIM',
    if nargin==3, % known step
      if isfield(FileData,'BottimDayNum'),
        dnum=FileData.BottimDayNum(step);
      else,
        tscale=vs_get(FileData,'PARAMS',{1},'TSCALE',{1},'quiet');
        y0=vs_get(FileData,'PARAMS',{1},'IT01',{1},'quiet');
        t0=vs_get(FileData,'PARAMS',{1},'IT02',{1},'quiet');
        t=vs_get(FileData,'BOTTIM',{step},'TIMBOT',{1},'quiet');
        dnum=Local_dt2datenum(y0,t0)+t*tscale/(24*60*60);
      end;
    else, % all steps
      if isfield(FileData,'BottimDayNum'),
        dnum=FileData.BottimDayNum;
      else,
        tscale=vs_get(FileData,'PARAMS',{1},'TSCALE',{1},'quiet');
        y0=vs_get(FileData,'PARAMS',{1},'IT01',{1},'quiet');
        t0=vs_get(FileData,'PARAMS',{1},'IT02',{1},'quiet');
        t=vs_get(FileData,'BOTTIM',{0},'TIMBOT',{1},'quiet');
        if iscell(t), 
          dnum=Local_dt2datenum(y0,t0)+[t{:}]*tscale/(24*60*60);
        else,
          dnum=Local_dt2datenum(y0,t0)+t*tscale/(24*60*60);
        end;
        OutFileData.BottimDayNum=dnum; % save for next time
      end;
    end;
  otherwise,
    uiwait(msgbox(['Unknown timing: ',option],'modal'));
    dnum=[];
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
