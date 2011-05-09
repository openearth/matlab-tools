function It=di_arcgrid(FileInfo,ax,itoptions)
% DI_ARCGRID is an interface for plotting items based on ARCGRID data
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
    {'grid'                             {'2DH','undefined'} };
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
case 'grid', % -------------------------------------------------------------------------------
  it=arcgrid('plot',FileData,ax);
  if ~isempty(it),
    set(it,'tag',Tag);
    range=md_clrmngr(Tag,xx_colormap('jet'));
    C=get(it,'cdata');
    C=range(1)+(range(2)-range(1))* ...
        min(max((C-min(C(:)))/(max(C(:))-min(C(:))),0),1);
    set(it,'cdata',C);
    itoptions.Name='arcgrid data';
    itoptions.Type='arcgrid data';
    set(it(1),'userdata',itoptions); % set option only to it(1) and keep the other ones empty
    
    if strcmp(axtype,'undefined'), xx_setax(ax,'2DH'); end;
  end;
otherwise, % ----------------------------------------------------------------------------------
  Str=sprintf('%s not yet implemented.',itoptions.ReproData.Type);
  uiwait(msgbox(Str,'modal'));
end;
if Option~=3,
  It=it;
end;
