function [varargout]=ideas(cmd,varargin),
% ideas User interface for plotting and printing data

if nargout>0,
  varargout=cell(nargout);
end;

if nargin==0,
  cmd='initialize';
end;

if isempty(gcbf) | ~strcmp(get(gcbf,'tag'),'IDEAS - main'),
  mfig=findobj(allchild(0),'flat','tag','IDEAS - main');
else,
  mfig=gcbf;
end;

switch(cmd),
case 'initialize',

  ifig=[];
  mfig=findobj(allchild(0),'flat','tag','IDEAS - main');

  if length(mfig)>1,
    delete(mfig([2:length(mfig)]));
    mfig=mfig(1);
    return;
  elseif isempty(mfig),
    if isempty(gcbf), % display logo
      pos=get(0,'screensize');
      pos(1)=pos(3)/2-100;
      pos(2)=pos(4)/2-100;
      pos(3)=200;
      pos(4)=200;
      X=imread('ideas.bmp');
      ifig=figure('units','pixels','position',pos,'integerhandle','off','menubar','none','resize','off','numbertitle','off','closerequestfcn','');
      iax=axes('parent',ifig,'units','normalized','position',[0 0 1 1]);
      img=image(X);
      drawnow;
      StartLogo=now;
    end;

    ui_ideas;
    mfig=findobj(allchild(0),'flat','tag','IDEAS - main');

    currentdata=findobj(mfig,'tag','currentdata');
    closedata=findobj(mfig,'tag','closedata');
    md_filemem('addinterface',currentdata,closedata);
  else,
    figure(mfig);
    return;
  end;

  ideas('updatefigurelist');

  if isempty(gcbf), % remove logo
    while (now-StartLogo)<1/(24*60*60), % show logo for at least two seconds
    end;
    delete(ifig);
  end;

case 'newfigure',

  [fig,figoptions]=md_createfig;
  ideas('updatefigurelist');

case 'updatefigurelist',
  figlist=findobj(mfig,'tag','figlist');

  ffigs=findobj(allchild(0),'flat','tag','IDEAS - figure');

  figs=[];
  fignames='';

  for i=1:length(ffigs),
    if isempty(figs),
      figname=get(ffigs(i),'name');
      fignames=figname(8:end);
      figs=ffigs(i);
    else,
      figname=get(ffigs(i),'name');
      fignames=str2mat(figname(8:end),fignames);
      figs=[ffigs(i) figs];
    end;
  end;
  set(figlist,'userdata',figs,'string',fignames,'value',1);

  ideas('updateaxeslist');

  notempty=~isempty(figs);
  delfiglock=findobj(mfig,'tag','delfiglock');
  set(delfiglock,'backgroundcolor',logicalswitch(notempty,get(delfiglock,'userdata'),get(mfig,'color')));
  delfig=findobj(mfig,'tag','delfig');
  set(delfig,'enable',logicalswitch(isequal(get(delfiglock,'backgroundcolor'),[1 0 0]),'on','off'));
  printfig=findobj(mfig,'tag','printfig');
  set(printfig,'enable',logicalswitch(notempty,'on','off'));
  savefig=findobj(mfig,'tag','savefig');
  set(savefig,'enable',logicalswitch(notempty,'on','off'));

case 'figurelist',
  figlist=findobj(mfig,'tag','figlist');
  figs=get(figlist,'userdata');
  if ~isempty(figs),
    val=get(figlist,'value');
    if ~ishandle(figs(val)),
      ideas('updatefigurelist');
    else,
      figure(figs(val));
      figure(mfig);
      ideas('updateaxeslist');
    end;
  end;

case 'deletefigurelock',
  delfiglock=findobj(mfig,'tag','delfiglock');
  lock=get(delfiglock,'userdata');
  if isequal(get(delfiglock,'backgroundcolor'),lock),
    lock=[1 1 0]-lock;
    set(delfiglock,'userdata',lock);
    set(delfiglock,'backgroundcolor',lock);
    delfig=findobj(mfig,'tag','delfig');
    set(delfig,'enable',logicalswitch(isequal(lock,[1 0 0]),'on','off'));
  end;

case 'deletefigure',
  figlist=findobj(mfig,'tag','figlist');
  axlist=findobj(mfig,'tag','axeslist');
  val=get(figlist,'value');
  figs=get(figlist,'userdata');
  if ~isempty(figs),
    delete(figs(val));
    notval=[1:(val-1) (val+1):length(figs)];
    set(figlist,'userdata',figs(notval));
    fignames=get(figlist,'string');
    if (val==length(figs)) & (val>1),
      val=val-1;
    end;
    set(figlist,'string',fignames(notval,:),'value',val);
    ideas('updateaxeslist');

    notempty=~isempty(figs(notval));
    delfiglock=findobj(mfig,'tag','delfiglock');
    set(delfiglock,'backgroundcolor',logicalswitch(notempty,get(delfiglock,'userdata'),get(mfig,'color')));
    if ~notempty, set(delfiglock,'userdata',[0 1 0]); end;
    delfig=findobj(mfig,'tag','delfig');
    set(delfig,'enable',logicalswitch(isequal(get(delfiglock,'backgroundcolor'),[1 0 0]),'on','off'));
    printfig=findobj(mfig,'tag','printfig');
    set(printfig,'enable',logicalswitch(notempty,'on','off'));
    savefig=findobj(mfig,'tag','savefig');
    set(savefig,'enable',logicalswitch(notempty,'on','off'));
  end;

case 'printfigure',
  figlist=findobj(mfig,'tag','figlist');
  axlist=findobj(mfig,'tag','axeslist');
  val=get(figlist,'value');
  figs=get(figlist,'userdata');
  if ~isempty(figs),
    md_print(figs(val));
  end;

case 'savefigure',
  figlist=findobj(mfig,'tag','figlist');
  axlist=findobj(mfig,'tag','axeslist');
  val=get(figlist,'value');
  figs=get(figlist,'userdata');
  if ~isempty(figs),
    md_save(figs(val));
  end;

case 'loadfigure',
  figlist=allchild(0);
  [mfile,mpath]=uigetfile('*.fig','Load from ...');
  if ischar(mfile),
    filename=[mpath mfile];
    hgload(filename);
    ideas('updatefigurelist');
  end;
  figlistnew=allchild(0);
  % get handle of new figure(s)
  fig=setdiff(figlistnew,figlist);
  % select only new ideas - figures
  fig=findobj(fig,'flat','tag','ideas - figure');
  % make sure that the userdata of the axes have a .Type record
  ax=findall(fig,'type','axes');
  for nr=1:length(ax);
    axud=get(ax(nr),'userdata');
    if ~isfield(axud,'Type'),
      axud.Type='undefined';
      axud.Editable=0;
    end;
    set(ax(nr),'userdata',axud);
  end;

case 'newaxes',
  figlist=findobj(mfig,'tag','figlist');
  val=get(figlist,'value');
  figs=get(figlist,'userdata');
  if ~isempty(figs),
    fig=figs(val);

    defaultaxoptions.Editable=1;
    defaultaxoptions.Type='undefined';
    defaultaxoptions.Name='[axes]';

    md_createaxes(fig,defaultaxoptions);

    ideas('updateaxeslist');
  end;

case 'updateaxeslist',
  figlist=findobj(mfig,'tag','figlist');
  axlist=findobj(mfig,'tag','axeslist');

  figs=get(figlist,'userdata');
  if ~isempty(figs),
    fig=figs(get(figlist,'value'));
    figoptions=get(fig,'userdata');
    axs=findobj(allchild(fig),'flat','type','axes');
    if isempty(axs),
      axnames='';
    else,
      axoptions=get(axs,'userdata');
      if ~iscell(axoptions),
        axoptions={axoptions};
      end;
      for i=length(axoptions):-1:1,
        if ~isfield(axoptions{i},'Name') | isfield(axoptions{i},'Type'),
          axnames{i}=get(axs(i),'tag');
        else,
          axnames{i}=axoptions{i}.Name;
        end;
      end;
      axnames=str2mat(axnames{:});
    end;
  else,
    axs=[];
    axnames='';
  end;
  set(axlist,'string',axnames,'userdata',axs,'value',1);
  ideas('updateitemlist');

  editable=0;
  if isempty(figs),
    notempty=0;
  else,
    notempty=~isempty(axs);
  end;

  delaxlock=findobj(mfig,'tag','delaxeslock');
  if notempty,
    set(delaxlock,'userdata',[0 1 0]);
  end;
  newax=findobj(mfig,'tag','newaxes');
  set(newax,'enable',logicalswitch(isempty(figs),'off','on'));
  ideas('axeslist');

case 'editaxes',
  axlist=findobj(mfig,'tag','axeslist');
  val=get(axlist,'value');
  axs=get(axlist,'userdata');
  if ~isempty(axs),
    ax=axs(val);
    % are changes allowed?
    if strcmp(get(ax,'tag'),'border'),
      md_paper('edit',ax);
    else,
      md_axes(ax);
    end;
  end;

case 'axeslist',
  axlist=findobj(mfig,'tag','axeslist');
  editax=findobj(mfig,'tag','editaxes');
  delaxlock=findobj(mfig,'tag','delaxeslock');
  delax=findobj(mfig,'tag','delaxes');
  val=get(axlist,'value');
  axs=get(axlist,'userdata');
  editable=0;
  if ~isempty(axs),
    fig=get(axs(get(axlist,'value')),'parent');
    figoptions=get(fig,'userdata');
    axoptions=get(axs(get(axlist,'value')),'userdata');
    if ~isstruct(axoptions) | ~isfield(axoptions,'Name'), % border
      editable=figoptions.Editable;
      axname=get(axs(get(axlist,'value')),'tag');
    elseif ~isfield(axoptions,'Type'), % IDEAS OBJECT
      editable=1;
      axname=axoptions.Name;
    else,
      switch axoptions.Type,
      case 'OBJECT',
        editable=1;
        axname=get(axs(get(axlist,'value')),'tag');
      otherwise,
        editable=figoptions.Editable;
        axname='axes';
      end;
    end;
    set(delaxlock,'backgroundcolor',get(delaxlock,'userdata'));
    set(editax,'string',['edit ',axname],'enable','on'),
    set(delax,'string',['delete ',axname]);
    set(delax,'enable',logicalswitch(editable & isequal(get(delaxlock,'backgroundcolor'),[1 0 0]),'on','off'));
  else,
    axname='';
    set(editax,'string','edit','enable','off');
    set(delax,'string','delete');
    set(delaxlock,'backgroundcolor',get(mfig,'color'));
    set(delax,'enable','off');
  end;

  set(delax,'enable',logicalswitch(editable & isequal(get(delaxlock,'backgroundcolor'),[1 0 0]),'on','off'));
  ideas('updateitemlist');

case 'deleteaxeslock',
  delaxeslock=findobj(mfig,'tag','delaxeslock');
  lock=get(delaxeslock,'userdata');
  if isequal(get(delaxeslock,'backgroundcolor'),lock),
    lock=[1 1 0]-lock;
    set(delaxeslock,'userdata',lock);
    set(delaxeslock,'backgroundcolor',lock);
    delaxes=findobj(mfig,'tag','delaxes');
    ideas('axeslist');
  end;

case 'deleteaxes',
  axlist=findobj(mfig,'tag','axeslist');
  val=get(axlist,'value');
  axs=get(axlist,'userdata');
  if ~isempty(axs),
    ax=axs(val);
    fig=get(ax,'parent');
    delete(ax);
    notval=[1:(val-1) (val+1):length(axs)];
    set(axlist,'userdata',axs(notval));
    axnames=get(axlist,'string');
    if (val==length(axs)) & (val>1),
      val=val-1;
    end;
    set(axlist,'string',axnames(notval,:),'value',val);
    md_clrmngr(fig);

    ideas('updateaxeslist');
  end;

case 'opendata',
  if nargin>1, % ideas('opendata','filetype','filename') called
    filetype=varargin{1};
    filename=varargin{2};
    [Succes,FileInfo]=md_filemem('openfile',filetype,filename);
  else,
    [Succes,FileInfo]=md_filemem('openfile');
  end;
  if nargout==1, % <-- Output of a call to [filedata]=ideas('opendata','filetype','filename');
    varargout{1}=FileInfo.Data;
  elseif nargout==3, % <-- Output of a call to [filedata,filetype,filename]=ideas('opendata','filetype','filename');
    varargout{1}=FileInfo.Data;
    varargout{2}=FileInfo.FileType;
    varargout{3}=FileInfo.FileName;
  end;

case 'currentdata',
  currentdata=findobj(mfig,'tag','currentdata');
  md_filemem('selectfile',currentdata);

case 'closedata',
  md_filemem('closefile');

case 'newitem',
  figlist=findobj(mfig,'tag','figlist');
  val=get(figlist,'value');
  figs=get(figlist,'userdata');
  if ~isempty(figs),
    fig=figs(val);
    axlist=findobj(mfig,'tag','axeslist');
    val=get(axlist,'value');
    axs=get(axlist,'userdata');
    if ~isempty(axs),
      ax=axs(val);

      it=md_createitem(ax);

      ideas('updateitemlist');
    end;
  end;

case 'edititem',
  itlist=findobj(mfig,'tag','itemlist');
  val=get(itlist,'value');
  UD=get(itlist,'userdata');
  its=UD{1};
  if ~isempty(its),
    itAllObj=xx_tag2handles(UD{2}{val});
%    itAllObj=xx_allitems(itAllObj(1));
    it=itAllObj(1);
%    it=its(val);
%    it=xx_allitems(it); % get all parts of the item
    itoptions=get(it(1),'userdata'); % get data stored in main part
    % default call [ItemParts,itoptions.UserData]=COMMAND(ItemParts,itoptions.UserData);
    % where itoptions=get(it,'userdata');
    %       ItemParts=findobj(allchild(get(it,'parent')),'flat','tag',get(it,'tag'));
    if isfield(itoptions,'Object'),
      edit(itoptions.Object);
    else,
      switch itoptions.Type,
%      case {'waterlevel','waterdepth','bottom','grid','velocity magnitude','bottom contours','arcgrid data','free format surface','classified data'},
%        ideas_item2dh(it);
%      case {'ideas_line','waterlevel gridline','bottom gridline','waterlevel point','waterdepth point','bottom point','time progress'}
%        ideas_item1dh(it);
      case {'path','line','text'}
        gc(it);
      otherwise,
        Str={'No editing options available for:',[itoptions.Type,': ',get(it(1),'tag')]};
        uiwait(msgbox(Str,'modal'));
      end;
    end;
  end;

case 'updateitemlist',
  figlist=findobj(mfig,'tag','figlist');
  axlist=findobj(mfig,'tag','axeslist');
  itlist=findobj(mfig,'tag','itemlist');

  figs=get(figlist,'userdata');
  if ~isempty(figs),
    fig=figs(get(figlist,'value'));
    axs=get(axlist,'userdata');
    if ~isempty(axs),
      ax=axs(get(axlist,'value'));
      if ~strcmp(get(ax,'tag'),'border'),
        its=allchild(ax);
        labels=[get(ax,'xlabel');get(ax,'ylabel');get(ax,'zlabel');get(ax,'title')];
        its=setdiff(its,labels); % don't include labels
        if ~isempty(its),
          itnoud=get(its,'userdata'); % get userdata
          if iscell(itnoud),
            itnoud=cellfun('isempty',itnoud);
          else,
            itnoud=isempty(itnoud);
          end;
          its=its(~itnoud); % keep those items with userdata
        end;
        itids=get(its,'tag');
        if iscell(itids),
          itids=str2mat(itids{:});
        end;
        [itids,i,j]=unique(itids,'rows');
        its=its(i);
        itnames={};
        for i=length(its):-1:1,
          itoptions=get(its(i),'userdata');
          if isfield(itoptions,'Name'),
            itnames{i}=itoptions.Name;
          else,
            itnames{i}='.';
          end;
        end;
        itnames=str2mat(itnames{:});

        % Item names starting with . are hidden
        DotStart=strmatch('.',itnames);
        NotDotStart=setdiff(1:length(its),DotStart);
        its=its(NotDotStart);
        itnames=itnames(NotDotStart,:);

        % 
        axoptions=get(ax,'userdata');
      else,
        its=[];
        itnames='';
      end;
    else,
      its=[];
      itnames='';
    end;
  else,
    its=[];
    itnames='';
  end;
  if isempty(its),
    tags={};
  else,
    tags=get(its,'tag');
    if ~iscell(tags),
      tags={tags};
    end;
  end;
  set(itlist,'string',itnames,'userdata',{its tags},'value',1);

  if isempty(figs) | isempty(axs) | strcmp(get(ax,'tag'),'border'),
    editable=0;
    notempty=1;
  elseif isfield(axoptions,'Object'),
    if isfield(axoptions,'Type'),
      editable=0;
      notempty=1;
    else,
      editable=1;
      notempty=~isempty(its);
    end;
  else,
    if isfield(axoptions,'Editable'),
      editable=axoptions.Editable;
    else,
      editable=1;
    end;
    notempty=~isempty(its);
  end;

  newit=findobj(mfig,'tag','newitem');
  set(newit,'enable',logicalswitch(editable,'on','off'));

  delitlock=findobj(mfig,'tag','delitemlock');
  set(delitlock,'backgroundcolor',logicalswitch(editable & notempty,get(delitlock,'userdata'),get(mfig,'color')));
  if ~notempty, set(delitlock,'userdata',[0 1 0]); end;
  delit=findobj(mfig,'tag','delitem');
  set(delit,'enable',logicalswitch(isequal(get(delitlock,'backgroundcolor'),[1 0 0]),'on','off'));
  editem=findobj(mfig,'tag','editem');
  set(editem,'enable',logicalswitch(editable & notempty,'on','off'));

case 'itemlist',

case 'deleteitemlock',
  delitemlock=findobj(mfig,'tag','delitemlock');
  lock=get(delitemlock,'userdata');
  if isequal(get(delitemlock,'backgroundcolor'),lock),
    lock=[1 1 0]-lock;
    set(delitemlock,'userdata',lock);
    set(delitemlock,'backgroundcolor',lock);
    delitem=findobj(mfig,'tag','delitem');
    set(delitem,'enable',logicalswitch(isequal(lock,[1 0 0]),'on','off'));
  end;

case 'deleteitem',
  itlist=findobj(mfig,'tag','itemlist');
  val=get(itlist,'value');
  UD=get(itlist,'userdata');
  its=UD{1};
  if ~isempty(its),
    itAllObj=xx_tag2handles(UD{2}{val});
%    itAllObj=xx_allitems(itAllObj(1));
    it=itAllObj(1);
    %it=its(val);
    ax=get(it,'parent');
    itoptions=get(it,'userdata'); % get data stored in main part
%    itAllObj=findobj(allchild(get(it,'parent')),'flat','tag',get(it,'tag'));
    if isfield(itoptions,'Object'),
      delete(itoptions.Object);
    else,
      delete(itAllObj);
    end;
    md_clrmngr(get(ax,'parent'));
    notval=[1:(val-1) (val+1):length(its)];
    set(itlist,'userdata',{its(notval) UD{2}(notval)});
    itnames=get(itlist,'string');
    if (val==length(its)) & (val>1),
      val=val-1;
    end;
    itnames=itnames(notval,:);
    set(itlist,'string',itnames,'value',val);
    axoptions=get(ax,'userdata');
    if isempty(itnames),
      if ~isfield(axoptions,'Type') | ~isempty(strmatch(axoptions.Type,{'annotation layer','LEGEND','undefined'},'exact')),
      elseif strcmp(questdlg('Reset axes?','Please specify ...','Yes','No','Yes'),'Yes'),
        xx_setax(ax,'undefined');
      end;
    end;
    ideas('updateitemlist');
  end;

case 'close',
%  figlist=findobj(mfig,'tag','figlist');
%  delete(get(figlist,'userdata'));
  delete(mfig);

otherwise,
  Str=['Unknown command: ',cmd];
  uiwait(msgbox(Str,'modal'));
end;