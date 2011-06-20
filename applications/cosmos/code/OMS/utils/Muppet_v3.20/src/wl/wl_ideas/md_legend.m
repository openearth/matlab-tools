function LegendItemId=md_legend(LegendHandle,Cmd,varargin);
% plots a legend in the IDEAS functionality
%
%         LegendItemId=md_legend(LegendHandle,'add',   ItemOptions,Struct)
%         LegendItemId=md_legend(LegendHandle,'add',   ItemOptions)
%                      md_legend(LegendHandle,'update',Struct)
%                      md_legend(LegendHandle,'update')
%                      md_legend(LegendHandle,'delete',Struct)

% Struct.Type={'line','surface','vectors','object'}
% Struct.LineType
% Struct.CLim
% Struct.LegendTag
% Struct.ItemTag
% Struct.LegendString

if nargin<3,
  if nargin<2,
    warning('Not enough input arguments.');
    if nargout==1,
      LegendItemId=-1;
    end;
    return;
  elseif ~strcmp(Cmd,'update'),
    warning('Expected ''update'' as second argument.');
    if nargout==1,
      LegendItemId=-1;
    end;
    return;
  end;
end;

OK=1;

if isempty(LegendHandle),
  OK=0;
else,
  LegendHandle=LegendHandle(1);
  if ~ishandle(LegendHandle),
    OK=0;
  elseif ~strcmp(get(LegendHandle,'type'),'axes'),
    OK=0;
  else,
    axoptions=get(LegendHandle,'userdata');
    if ~isstruct(axoptions),
      OK=0;
    elseif ~strcmp(axoptions.Type,'LEGEND'),
      OK=0;
    end;
  end;
end;

if ~OK,
  warning('Legend handle expected as first input argument.');
  if nargout==1,
    LegendItemId=-1;
  end;
  return;
end;

if ~strmatch(Cmd,{'add','update','delete'},'exact'),
  warning('Second argument should be ''add'', ''update'', or ''delete''.');
  if nargout==1,
    LegendItemId=-1;
  end;
  return;
end;

switch Cmd,
case 'add',
  LegendItemId=Local_AddLegendItem(LegendHandle,varargin{:});
case 'update',
  if nargin<3,
    Local_UpdateLegend(LegendHandle);
  else,
    Local_UpdateLegendItem(LegendHandle,varargin{1});
  end;
case 'delete',
  Local_DeleteLegendItem(LegendHandle,varargin{1});
end;

function LegendItemId=Local_AddLegendItem(LegendHandle,itoptions,Struct),
%         LegendItemId=md_legend(LegendHandle,'add',   ItemOptions,Struct)
%         LegendItemId=md_legend(LegendHandle,'add',   ItemOptions)
%
% Struct.Type={'line','surface','vectors'}
% Struct.LineType
% Struct.CLim
% Struct.LegendTag
% Struct.ItemHandle
% Struct.LegendString

LegendItemId=[];
LegendOptions=get(LegendHandle,'userdata');
fig=get(LegendHandle,'parent');
if nargin<3,
  % determine Struct interactively

  % find all items without legend
  
  % take all axes
  Axes=findobj(fig,'type','axes');

  % don't include legends which contain legend items!
  NotPlotAxes=findobj(Axes,'flat','userdata',[]);
  Axes=setdiff(Axes,NotPlotAxes);
  axoptions=get(Axes,'userdata');
  AxesTypes={};
  for i=1:length(Axes),
    if isfield(axoptions{i},'Type'),
      AxesTypes{i}=axoptions{i}.Type;
    else,
      AxesTypes{i}=axoptions{i}.Name;
    end;
  end;
  Legends=strmatch('LEGEND',AxesTypes);
  NotLegends=setdiff(1:length(Axes),Legends);
  Axes=Axes(NotLegends);

  % find all items
  AllHandles=findobj(Axes);
  NotItems=findobj(Axes,'userdata',[]);
  Items=setdiff(AllHandles,[NotItems; Axes(:)]);
  NumItems=length(Items);
  ItemOptions=get(Items,'userdata');
  if ~iscell(ItemOptions),
    ItemOptions={ItemOptions};
  end;
  ItNames=cell(NumItems,1);
  Include=ones(NumItems,1);
  for i=1:NumItems,
    if isfield(ItemOptions{i},'Name'),
      ItNames{i}=ItemOptions{i}.Name;
      if isfield(ItemOptions{i},'LegendTag'),
        if ~isempty(ItemOptions{i}.LegendTag), % don't include items that already have a legend
          if isempty(findobj(fig,'tag',ItemOptions{i}.LegendTag)), % if legend doesn't exist remove link
            ItemOptions{i}.LegendTag=[];
            set(Items(i),'userdata',ItemOptions{i});
          else,
            Include(i)=0;
          end;
        end;
      end;
    else,
      Include(i)=0;
    end;
  end;
  Include=find(Include);
  ItNames=ItNames(Include);
  ItemOptions=ItemOptions(Include);
  Items=Items(Include);
  NumItems=length(Items);

  % select one item
  [itemname,legendname,Item]=ui_typeandname(ItNames);
  if isempty(Item), % cancel pressed?
    return;
  end;
  itoptions.Name=legendname;

  ItemOptions=ItemOptions{Item};
  Item=Items(Item);
  Tag=get(Item,'tag');
  if isfield(ItemOptions,'Object'),
    itoptions.Type='object';
  else,
    switch ItemOptions.Type,
    case {'bottom','waterlevel'}
      itoptions.Type='surface legend';
    case {'classified data'}
      itoptions.Type='class legend vertical';
    case {'grid'}
      itoptions.Type='grid legend';
    otherwise,
      uiwait(msgbox(['Don''t know how to create a legend for an object of type ''',ItemOptions.Type,'''']));
      return;
    end;
  end;
else,
  % Struct specified
end;

% determine top line of lowest legend line
LegendItems=allchild(LegendHandle);
LegendItems(cellfun('isempty',get(LegendItems,'userdata')))=[]; % non-empty userdata
LegendTexts=findobj(LegendItems,'flat','type','text');
ymin=inf;
for i=1:length(LegendTexts),
  ymin=min(ymin,index(get(LegendTexts(i),'position'),2));
end;
ymin=ymin-0.5*LegendOptions.Legend.LineHeight;

if ymin<LegendOptions.Legend.LineHeight,
  uiwait(msgbox('Not enough space in this legend'));
  return;
end;

BackgroundPlateLegend=findobj(LegendHandle,'tag','BackgroundPlateLegend');

% create legend for item
switch itoptions.Type,
case 'surface legend',
  LegendPart(1)=text(0.02,ymin-LegendOptions.Legend.LineHeight,itoptions.Name, ...
    'parent',LegendHandle, ...
    'horizontalalignment','left', ...
    'verticalalignment','top', ...
    'fontunits','points', ...
    'fontsize',LegendOptions.Legend.FontSize, ...
    'clipping','off');
  crange=md_clrmngr(Tag);
  Cmin=crange(1); % find min and max of color range
  Cmax=crange(2);
  x=0.02+0.96*[0:(Cmax-Cmin+1)]/(Cmax-Cmin+1); x=[x;x];
  y=[2.2;2.8]*ones(1,(Cmax-Cmin+1)+1);
  LegendPart(2)=surface(x, ...
    ymin-y*LegendOptions.Legend.LineHeight, ...
    ones(size(y)), ...
    Cmin:Cmax, ...
    'facecolor','flat', ...
    'edgecolor','none', ...
    'cdatamapping','direct', ...
    'parent',LegendHandle, ...
    'clipping','off');
  LegendPart(3)=text(0.02,ymin-3*LegendOptions.Legend.LineHeight, ...
    num2str(ItemOptions.CLim(1)), ...
    'parent',LegendHandle, ...
    'horizontalalignment','left', ...
    'verticalalignment','top', ...
    'fontunits','points', ...
    'fontsize',LegendOptions.Legend.FontSize, ...
    'clipping','off');
  LegendPart(4)=text(0.98,ymin-3*LegendOptions.Legend.LineHeight, ...
    num2str(ItemOptions.CLim(2)), ...
    'parent',LegendHandle, ...
    'horizontalalignment','right', ...
    'verticalalignment','top', ...
    'fontunits','points', ...
    'fontsize',LegendOptions.Legend.FontSize, ...
    'clipping','off');
  LegendPart(5)=patch([0.02 0.02 0.98 0.98], ...
    ymin-[2.2 2.8 2.8 2.2]*LegendOptions.Legend.LineHeight, ...
    2*ones(1,4), ...
    NaN, ...
    'facecolor','flat', ...
    'cdatamapping','direct', ...
    'parent',LegendHandle, ...
    'clipping','off');
  BPLy=get(BackgroundPlateLegend,'ydata');
  BPLy([1 4])=ymin-4.5*LegendOptions.Legend.LineHeight;
  set(BackgroundPlateLegend,'ydata',BPLy);
case 'class legend',
  LegendPart(1)=text(0.02,ymin-LegendOptions.Legend.LineHeight,itoptions.Name, ...
    'parent',LegendHandle, ...
    'horizontalalignment','left', ...
    'verticalalignment','top', ...
    'fontunits','points', ...
    'fontsize',LegendOptions.Legend.FontSize, ...
    'clipping','off');
  crange=md_clrmngr(Tag);
  Cmin=crange(1); % find min and max of color range
  Cmax=crange(2);
  x=0.02+0.96*[0:(Cmax-Cmin+1)]/(Cmax-Cmin+1); x=[x;x];
  y=[2.2;2.8]*ones(1,(Cmax-Cmin+1)+1);
  LegendPart(2)=surface(x, ...
    ymin-y*LegendOptions.Legend.LineHeight, ...
    ones(size(y)), ...
    Cmin:Cmax, ...
    'facecolor','flat', ...
    'cdatamapping','direct', ...
    'parent',LegendHandle, ...
    'clipping','off');
  LegendPart(3)=text(0.02,ymin-3*LegendOptions.Legend.LineHeight, ...
    num2str(ItemOptions.CLim(1)), ...
    'parent',LegendHandle, ...
    'horizontalalignment','left', ...
    'verticalalignment','top', ...
    'fontunits','points', ...
    'fontsize',LegendOptions.Legend.FontSize, ...
    'clipping','off');
  LegendPart(4)=text(0.98,ymin-3*LegendOptions.Legend.LineHeight, ...
    num2str(ItemOptions.CLim(2)), ...
    'parent',LegendHandle, ...
    'horizontalalignment','right', ...
    'verticalalignment','top', ...
    'fontunits','points', ...
    'fontsize',LegendOptions.Legend.FontSize, ...
    'clipping','off');
  BPLy=get(BackgroundPlateLegend,'ydata');
  BPLy([1 4])=ymin-4.5*LegendOptions.Legend.LineHeight;
  set(BackgroundPlateLegend,'ydata',BPLy);
case 'class legend vertical',
  LegendPart(1)=text(0.02,ymin-LegendOptions.Legend.LineHeight,itoptions.Name, ...
    'parent',LegendHandle, ...
    'horizontalalignment','left', ...
    'verticalalignment','top', ...
    'fontunits','points', ...
    'fontsize',LegendOptions.Legend.FontSize, ...
    'clipping','off');
  crange=md_clrmngr(Tag);
  Cmin=crange(1); % find min and max of color range
  Cmax=crange(2);
  x=0.02+[0 0.08]; x=[x;x];
  y=[1.2 1.2;1.8 1.8];
  N=crange(2)-crange(1)+1;
  Inp=cell(1,N);
  for i=1:N,
    Inp{i}=sprintf('class %i',i);
  end;
  Inp=ui_labels(Inp);
  twocolumn=N>10;
  if twocolumn,
    twocolumnstart=ceil(N/2);
  else,
    twocolumnstart=N+1;
  end;
  for i=1:N,
    if i>twocolumnstart,
      twocolumnx=0.5;
      twocolumny=twocolumnstart;
    else,
      twocolumnx=0.0;
      twocolumny=0;
    end;
    LegendPart(1+i)=surface(x+twocolumnx, ...
      ymin-(y+i-twocolumny)*LegendOptions.Legend.LineHeight, ...
      ones(size(y)), ...
      crange(1)-1+i, ...
      'facecolor','flat', ...
      'cdatamapping','direct', ...
      'parent',LegendHandle, ...
      'clipping','off');
    LegendPart(1+N+i)=text(0.16+twocolumnx,ymin-(1+i-twocolumny)*LegendOptions.Legend.LineHeight, ...
      Inp{i}, ...
      'parent',LegendHandle, ...
      'horizontalalignment','left', ...
      'verticalalignment','top', ...
      'fontunits','points', ...
      'fontsize',LegendOptions.Legend.FontSize, ...
      'clipping','off');
  end;
  BPLy=get(BackgroundPlateLegend,'ydata');
  if twocolumn,
    BPLy([1 4])=ymin-(twocolumnstart+2.5)*LegendOptions.Legend.LineHeight;
  else,
    BPLy([1 4])=ymin-(N+2.5)*LegendOptions.Legend.LineHeight;
  end;
  set(BackgroundPlateLegend,'ydata',BPLy);
case 'grid legend',
  LegendPart(1)=text(0.02,ymin-LegendOptions.Legend.LineHeight,itoptions.Name, ...
    'parent',LegendHandle, ...
    'horizontalalignment','left', ...
    'verticalalignment','top', ...
    'fontunits','points', ...
    'fontsize',LegendOptions.Legend.FontSize, ...
    'clipping','off');
  XData=0.02:(0.6*LegendOptions.Legend.LineHeight):0.98;
  LegendPart(2)=surface([XData;XData],ymin-[2.2*ones(size(XData)); 2.8*ones(size(XData))]*LegendOptions.Legend.LineHeight, ...
    [ones(size(XData));ones(size(XData))], ...
    'facecolor',get(Item,'facecolor'), ...
    'edgecolor',get(Item,'edgecolor'), ...
    'linewidth',get(Item,'linewidth'), ...
    'linestyle',get(Item,'linestyle'), ...
    'parent',LegendHandle, ...
    'clipping','off');
  BPLy=get(BackgroundPlateLegend,'ydata');
  BPLy([1 4])=ymin-3.5*LegendOptions.Legend.LineHeight;
  set(BackgroundPlateLegend,'ydata',BPLy);
case 'object',
  LegendPart(1)=text(0.02,ymin-LegendOptions.Legend.LineHeight,itoptions.Name, ...
    'parent',LegendHandle, ...
    'horizontalalignment','left', ...
    'verticalalignment','top', ...
    'fontunits','points', ...
    'fontsize',LegendOptions.Legend.FontSize, ...
    'clipping','off');
  BPLy=get(BackgroundPlateLegend,'ydata');
  BPLy([1 4])=ymin-2.5*LegendOptions.Legend.LineHeight;
  set(BackgroundPlateLegend,'ydata',BPLy);
end;
itoptions.ItemTag=get(Item,'tag');
LegendTag=num2hex(LegendPart(1));
set(LegendPart,'tag',LegendTag,'userdata',itoptions);

% add reference to this legend to item
ItemOptions.LegendTag=LegendTag;
set(Item,'userdata',ItemOptions);


function Local_UpdateLegendItem(LegendHandle,Struct),
%                      md_legend(LegendHandle,'update',Struct)

function Local_DeleteLegendItem(LegendHandle,Struct),
%                      md_legend(LegendHandle,'delete',Struct)

function Local_UpdateLegend(LegendHandle),
%                      md_legend(LegendHandle,'update')
