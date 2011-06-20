function md_createaxes(fig,axoptions),

if isempty(gcbf) | ~strcmp(get(gcbf,'tag'),'IDEAS - main'),
  mfig=findobj(allchild(0),'flat','tag','IDEAS - main');
else,
  mfig=gcbf;
end;

anyfileopen=~isempty(md_filemem('listfiles'));
figoptions=get(fig,'userdata');
figadd = num2str(figoptions.Editable + 2*anyfileopen);
% which kind of axes should be created?
% 1 : figure editable, no file open
% 2 : figure not editable, a file open
% 3 : figure editable, a file open

labels={'one plot',                {'1','3'}; ...
        'user selected subplot',   {'1','3'}; ...
        'user positioned subplot', {'1','3'}; ...
        'legend area',             {'1','2','3'}; ...
        'NEW legend area',         {'1','2','3'}; ...
        'NEW counter',             {'1','2','3'}; ...
        'logo WL',                 {'1','2','3'}; ...
        'logo UT',                 {'1','2','3'}; ...
        'annotation layer',        {'1','2','3'}; ...
        'bitmap',                  {'1','2','3'}; ...
        'semitransparent bitmap',  {'1','2','3'}; ...
        'counter',                 {'2','3'}; ...
        'clock',                   {'2','3'}; ...
        'calendar',                {'2','3'}; ...
        'time bar',                {'2','3'}};

for pt=size(labels,1):-1:1,
  enab(pt)=~isempty(strmatch(figadd,labels{pt,2},'exact'));
end;
Possible=find(enab);
labels=labels(Possible,1);
[axtype,axname]=ui_typeandname(labels);

if isempty(axtype), % cancel pressed?
  return;
end;

switch(axtype),
case 'NEW counter',
  Cmd.Type='interactive create';
  Cmd.Name=axname;
  Cmd.Pos=getnormpos(fig);
  Cmd.Visible=1;
  ob_counter(fig,Cmd);

case 'one plot',
  ax=Local_subplot(fig,1,1,1);
  axoptions.Name=axname;
  set(ax,'tag',axoptions.Name,'userdata',axoptions);
case 'user selected subplot',
  labels={'number of plots per column','2'; ...
          'number of plots per row','2'; ...
          'plot number','1'};
  inp=inputdlg(labels(:,1),'Please specify',1,labels(:,2));

  NR=eval(inp{1},NaN);
  NC=eval(inp{2},NaN);
  NP=eval(inp{3},NaN);
  Correct = isnumeric(NR) & isequal(size(NR),[1 1]) & ~isnan(NR) & ~isinf(NR) & (NR>0) & (NR==round(NR));
  Correct = Correct & isnumeric(NC) & isequal(size(NC),[1 1]) & ~isnan(NC) & ~isinf(NC) & (NC>0) & (NC==round(NC));
  Correct = Correct & isnumeric(NP) & isequal(size(NP,1),1) & ~any(isnan(NP(:))) & ~any(isinf(NP(:))) & all(NP(:)>0) & all(NP(:)==round(NP(:)));
  if Correct,
    for i=1:length(NP(:));
      ax=Local_subplot(fig,NR,NC,NP(i));
      axoptions.Name=[axname ' (',num2str(NR),',',num2str(NC),',',num2str(NP(i)),')'];
      set(ax,'tag',axoptions.Name,'userdata',axoptions);
    end;
  else,
    uiwait(msgbox('Invalid numbers specified.'));
    return;
  end;
case 'user positioned subplot',
  Pos=getnormpos(fig);
  ax=axes('parent',fig,'units','normalized','position',Pos);

  axoptions.Name=axname;
  set(ax,'tag',axname,'userdata',axoptions);

case 'NEW legend area',
  Cmd.Name=axname;
  Cmd.Pos=getnormpos(fig);
  Cmd.Visible=1;
  ob_legend(fig,Cmd);

case 'legend area',

  answer=inputdlg({'Font size:','Legend text:'},'Legend parameters',1,{'6','Legend:'});
  if isempty(answer),
    return; % cancel pressed
  end;

  axoptions.Editable=1;
  axoptions.Type='LEGEND';
  Pos=getnormpos(fig);
  ax=axes('parent',fig,'units','normalized','position',Pos);
  set(ax,'userdata',axoptions, ...
         'visible','off', ...
         'dataaspectratio',[1 1 1], ...
         'units','pixels');
  P=get(ax,'position');
  LegHeight=P(4)/P(3);
  set(ax,'xlim',[0 1],'ylim',[0 LegHeight],'units','normalized');
  B=patch([0 0 1 1],[0 LegHeight LegHeight 0],1, ...
    'zdata',-ones(1,4), ...
    'facecolor','w', ...
    'parent',ax, ...
    'tag','BackgroundPlateLegend', ...
    'clipping','off');

  % Create 'Legend:' text
  itoptions.Name='.legend label';
  itoptions.Type='legend label';
  itoptions.Animation=[];

  temp=eval(answer{1},6);
  if ~isequal(size(temp),[1 1]) | temp<0,
    axoptions.Legend.FontSize=6;
  else,
    axoptions.Legend.FontSize=temp;
  end;

  LL=text(0.02,LegHeight-0.02,answer{2}, ...
    'parent',ax, ...
    'horizontalalignment','left', ...
    'verticalalignment','top', ...
    'fontunits','points', ...
    'fontsize',axoptions.Legend.FontSize, ...
    'userdata',itoptions, ...
    'tag','LegendText', ...
    'clipping','on');
  set(LL,'fontunits','normalized');
  axoptions.Legend.LineHeight=LegHeight*get(LL,'fontsize');
  set(LL,'fontunits','points');
  if isempty(answer{2}),
    set(LL,'visible','off', ...
           'position',get(LL,'position')+[0 1.5*axoptions.Legend.LineHeight 0]);
  end;

  axoptions.Name=axname;
  set(ax,'tag',axname,'userdata',axoptions);

case 'annotation layer',
  axoptions.Editable=1;
  axoptions.Type='annotation layer';
  axoptions.ObjectType='annotation layer';
  % check on occurence of an annotation layer
  ax=findobj(fig,'type','axes','tag','annotation layer');
  if isempty(ax), 
    ax=axes('parent',fig,'units','normalized','position',[0 0 1 1],'visible','off','xlim',[0 1],'ylim',[0 1]);
    axoptions.Name=axname;
    set(ax,'tag',axoptions.Name,'userdata',axoptions);
  else,
    axes(ax(1));
  end;
  md_annotation(ax(1));

case 'bitmap',
  axoptions.Editable=0;
  axoptions.Type='OBJECT';
  axoptions.ObjectType='bitmap';
  [filename,filedir]=uigetfile('*.*','Specify bitmap');
  if ~ischar(filename), % cancel pressed
    return;
  end;
  filename=[filedir filename];
  [X,map]=imread(filename);
  tmpunit=get(fig,'units');
  set(fig,'units','pixels');
  figsize=get(fig,'position');
  figsize=figsize(3:4);
  if (size(X,2)>figsize(1)) | (size(X,1)>figsize(2)), % if X is a true color image, size(X)=[. . 3]!
    ax=axes('userdata',axoptions, ...
         'visible','off', ...
         'dataaspectratio',[1 1 1], ...
         'units','normalized', ...
         'xlim',[0 size(X,2)], ...
         'ylim',[0 size(X,1)], ...
         'position',[0 0 1 1], ...
         'parent',fig);
  else,
    ax=axes('userdata',axoptions, ...
         'visible','off', ...
         'dataaspectratio',[1 1 1], ...
         'units','pixels', ...
         'xlim',[0 size(X,2)], ...
         'ylim',[0 size(X,1)], ...
         'position',[(figsize-[size(X,2) size(X,1)])/2 size(X,2) size(X,1)], ...
         'units','normalized', ...
         'parent',fig);
  end;
  set(fig,'units',tmpunit);
  Tag=di_tag;
  if ~isempty(map), % indexed color image
    if isa(X,'uint8'),
      X=double(X)+1;
    end;
    it=image(1,'parent',ax,'tag',Tag,'cdatamapping','direct');
    range=md_clrmngr(Tag,map);
    set(it,'cdata',X+range(1)-1);
  else, % true color image
    it=image(X,'parent',ax,'tag',axname);
    fprintf('Warning: true color image might give problem in animation creation process.\n');
  end;
  set(ax,'visible','off', ...
         'dataaspectratio',[1 1 1], ...
         'xlim',[0 size(X,2)], ...
         'ylim',[0 size(X,1)]);
  itoptions.Name='.dummy for image';
  itoptions.Type='DUMMY';
  set(it,'userdata',itoptions);

  axoptions.Name=axname;
  set(ax,'tag',axname,'userdata',axoptions);

case 'semitransparent bitmap',
  Tag=di_tag;
  axoptions.Editable=0;
  axoptions.Type='OBJECT';
  axoptions.ObjectType='bitmap';
  [filename,filedir]=uigetfile('*.*','Specify bitmap');
  if ~ischar(filename), % cancel pressed
    return;
  end;
  filename=[filedir filename];
  [X,map]=imread(filename);
  tmpunit=get(fig,'units');
  set(fig,'units','pixels');
  figsize=get(fig,'position');
  figsize=figsize(3:4);
  if (size(X,2)>figsize(1)) | (size(X,1)>figsize(2)), % if X is a true color image, size(X)=[. . 3]!
    ax=axes('userdata',axoptions, ...
         'visible','off', ...
         'dataaspectratio',[1 1 1], ...
         'units','normalized', ...
         'xlim',[0 size(X,2)], ...
         'ylim',[0 size(X,1)], ...
         'position',[0 0 1 1], ...
         'parent',fig);
  else,
    ax=axes('userdata',axoptions, ...
         'visible','off', ...
         'dataaspectratio',[1 1 1], ...
         'units','pixels', ...
         'xlim',[0 size(X,2)], ...
         'ylim',[0 size(X,1)], ...
         'position',[(figsize-[size(X,2) size(X,1)])/2 size(X,2) size(X,1)], ...
         'units','normalized', ...
         'parent',fig);
  end;
  set(fig,'units',tmpunit);
  if ~isempty(map), % indexed color image
    it=surface(0:size(X,2),size(X,1):-1:0,zeros(size(X,1)+1,size(X,2)+1), ...
      'facecolor','flat', ...
      'edgecolor','none', ...
      'cdatamapping','direct', ...
      'parent',ax, ...
      'tag',Tag);
    Black=(map(:,1)==0) & (map(:,2)==0) & (map(:,3)==0);
    Renum=zeros(size(map,1),1);
    Renum(Black)=NaN;
    Renum(~Black)=1:sum(~Black);
    
    map=map(~Black,:);
    range=md_clrmngr(Tag,map);
    if isa(X,'uint8'),
      X=double(X)+1;
    end;

    Black=find(Black);
    X=Renum(X);
    %if ~isempty(Black),
    %  X(ismember(X,Black))=NaN;
    %end;
    set(it,'cdata',X+range(1)-1);

  else, % true color image
    if isa(X,'uint8'),
      X=double(X);
      X=X/255;
    end;

    x=(X(:,:,1)==0) & (X(:,:,2)==0) & (X(:,:,3)==0);
    x(:,:,2)=x(:,:,1);
    x(:,:,3)=x(:,:,1);
    X(x)=NaN;
    it=surface(0:size(X,2),size(X,1):-1:0,zeros(size(X,1)+1,size(X,2)+1), ...
      'cdata',X, ...
      'facecolor','flat', ...
      'edgecolor','none', ...
      'parent',ax, ...
      'tag',axname);

    fprintf('Warning: true color image might give problem in animation creation process.\n');
  end;
  set(ax,'visible','off', ...
         'dataaspectratio',[1 1 1], ...
         'xlim',[0 size(X,2)], ...
         'ylim',[0 size(X,1)]);
  itoptions.Name='.dummy for image';
  itoptions.Type='DUMMY';
  set(it,'userdata',itoptions);

  axoptions.Name=axname;
  set(ax,'tag',axname,'userdata',axoptions);

case 'counter',
  axoptions.Editable=0;
  axoptions.Type='OBJECT';
  axoptions.ObjectType=axtype;
  Pos=getnormpos(fig);
  ax=axes('parent',fig,'units','normalized','position',Pos);
  xx_counter(ax);
  set(ax,'userdata',axoptions);

  it=md_createitem(ax);

  if isempty(it),
    delete(ax);
    return;
  end;

  axoptions.Name=axname;
  set(ax,'tag',axname,'userdata',axoptions);

case 'clock',
  axoptions.Editable=0;
  axoptions.Type='OBJECT';
  axoptions.ObjectType=axtype;
  Pos=getnormpos(fig);
  ax=axes('parent',fig,'units','normalized','position',Pos);
  xx_clock(ax);
  set(ax,'userdata',axoptions);

  it=md_createitem(ax);

  if isempty(it),
    delete(ax);
    return;
  end;

  axoptions.Name=axname;
  set(ax,'tag',axname,'userdata',axoptions);

case 'calendar',
  axoptions.Editable=0;
  axoptions.Type='OBJECT';
  axoptions.ObjectType=axtype;
  Pos=getnormpos(fig);
  ax=axes('parent',fig,'units','normalized','position',Pos);
  xx_date(ax);
  set(ax,'userdata',axoptions);

  it=md_createitem(ax);

  if isempty(it),
    delete(ax);
    return;
  end;

  axoptions.Name=axname;
  set(ax,'tag',axname,'userdata',axoptions);

case 'time bar',
  axoptions.Editable=0;
  axoptions.Type='OBJECT';
  axoptions.ObjectType=axtype;
  Pos=getnormpos(fig);
  ax=axes('parent',fig,'units','normalized','position',Pos);
  xx_timbar(ax,'values',0,0,1);
  set(ax,'userdata',axoptions);
  it=md_createitem(ax);
  if isempty(it),
    delete(ax);
    return;
  end;

  axoptions.Name=axname;
  set(ax,'tag',axname,'userdata',axoptions);

case 'logo WL',
  axoptions.Editable=0;
  axoptions.Type='OBJECT';
  axoptions.ObjectType='logo WL';
  Pos=getnormpos(fig);
  ax=axes('parent',fig,'units','normalized','position',Pos);
  xx_logo('DH',ax,2,'k');
  set(ax,'userdata',axoptions);

  axoptions.Name=axname;
  set(ax,'tag',axname,'userdata',axoptions);

case 'logo UT',
  axoptions.Editable=0;
  axoptions.Type='OBJECT';
  axoptions.ObjectType='logo UT';
  Pos=getnormpos(fig);
  ax=axes('parent',fig,'units','normalized','position',Pos);
  xx_logo('UT',ax,'k');
  set(ax,'userdata',axoptions);

  axoptions.Name=axname;
  set(ax,'tag',axname,'userdata',axoptions);

otherwise,
  Str=sprintf('Requested axes type not yet implemented.');
  uiwait(msgbox(Str,'modal'));
  return;
end;


function ax = Local_subplot(fig,nrows, ncols, thisPlot)
%LOCAL_SUBPLOT Create axes in tiled positions.
%   LOCAL_SUBPLOT(fig,m,n,p), breaks the Figure <fig> window into
%   an m-by-n matrix of small axes, selects the p-th axes for 
%   for the current plot, and returns the axis handle.  The axes 
%   are counted along the top row of the Figure window, then the
%   second row, etc. If overlapping axes objects are encountered
%   the user will be ask whether they should be deleted.

% This is the percent offset from the subplot grid of the plotbox.
PERC_OFFSET_L = 2*0.09;
PERC_OFFSET_R = 2*0.045;
PERC_OFFSET_B = PERC_OFFSET_L;
PERC_OFFSET_T = PERC_OFFSET_R;
if nrows > 2
  PERC_OFFSET_T = 0.9*PERC_OFFSET_T;
  PERC_OFFSET_B = 0.9*PERC_OFFSET_B;
end
if ncols > 2
  PERC_OFFSET_L = 0.9*PERC_OFFSET_L;
  PERC_OFFSET_R = 0.9*PERC_OFFSET_R;
end

row = (nrows-1) -fix((thisPlot-1)/ncols);
col = rem (thisPlot-1, ncols);

% For this to work the default axes position must be in normalized coordinates
def_pos = [.13 .11 .775 .815];

col_offset = def_pos(3)*(PERC_OFFSET_L+PERC_OFFSET_R)/ ...
                        (ncols-PERC_OFFSET_L-PERC_OFFSET_R);
row_offset = def_pos(4)*(PERC_OFFSET_B+PERC_OFFSET_T)/ ...
                        (nrows-PERC_OFFSET_B-PERC_OFFSET_T);
totalwidth = def_pos(3) + col_offset;
totalheight = def_pos(4) + row_offset;
width = totalwidth/ncols*(max(col)-min(col)+1)-col_offset;
height = totalheight/nrows*(max(row)-min(row)+1)-row_offset;
position = [def_pos(1)+min(col)*totalwidth/ncols ...
            def_pos(2)+min(row)*totalheight/nrows ...
            width height];
if width <= 0.5*totalwidth/ncols
  position(1) = def_pos(1)+min(col)*(def_pos(3)/ncols);
  position(3) = 0.7*(def_pos(3)/ncols)*(max(col)-min(col)+1);
end
if height <= 0.5*totalheight/nrows
  position(2) = def_pos(2)+min(row)*(def_pos(4)/nrows);
  position(4) = 0.7*(def_pos(4)/nrows)*(max(row)-min(row)+1);
end

% create the axis:
ax = axes('parent',fig,'units','normal','Position', position);
set(ax,'units',get(fig,'defaultaxesunits'))
