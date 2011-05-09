function It=di_tramfile(FileInfo,ax,itoptions)
% DI_TRAMFILE is an interface for a Delft3D-tram file
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
     'morphologic grid'                       {'undefined','2DH'}  };
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
case 'hydrodynamic grid', % -----------------------------------------------------------------
  description.Type='grid';
  description.Name='hydrodynamic grid';
  description.X={...
    'output = 1:1'
    '1:LoadField:load x-grid'
    'LowerLeft = 100 100'
    '0 inputs'
    '{'
    'Delft3D-tram'
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
    'Delft3D-tram'
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
    'Delft3D-tram'
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
    'Delft3D-tram'
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

function [dnum,OutFileData]=Local_readtim(FileData,step),
%    Usage: [DNUM,OUTFILEDATA]=LOCAL_SELTIM(FILEDATA) returns all day numbers
%           [DNUM,OUTFILEDATA]=LOCAL_SELTIM(FILEDATA,STEP) returns requested day number
%           OUTFILEDATA equals FILEDATA with the addition of a DayNum field if
%           all day numbers are read from file.
%
  OutFileData=FileData;
  if nargin==2, % known step
    if isfield(FileData,'MapttranDayNum'),
      dnum=FileData.MapttranDayNum(step);
    else,
      tscale=vs_get(FileData,'MAPATRANNTR',{1},'TSCALE',{1},'quiet');
      t=vs_get(FileData,'MAPTTRAN',{1},'T-TRAN',{1},'quiet');
      dnum=Local_dt2datenum(0,0)+t*tscale/(24*60*60);
    end;
  else, % all steps
    if isfield(FileData,'MapttranDayNum'),
      dnum=FileData.MapttranDayNum;
    else,
      tscale=vs_get(FileData,'MAPATRANNTR',{1},'TSCALE',{1},'quiet');
      t=vs_get(FileData,'MAPTTRAN',{0},'T-TRAN',{1},'quiet');
      if iscell(t), 
        dnum=Local_dt2datenum(0,0)+[t{:}]*tscale/(24*60*60);
      else,
        dnum=Local_dt2datenum(0,0)+t*tscale/(24*60*60);
      end;
      OutFileData.MapttranDayNum=dnum; % save for next time
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

