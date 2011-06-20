function [out,out2]=selgrid(cmd,varargin)
%SELGRID Grid selection interface
%
%    F=SELGRID([],[])
%    initialise interface
%    F=SELGRID(X,Y)
%    initialise interface with grid
%    F=SELGRID(X,Y,range)
%    initialise interface with grid and range
%
%    SELGRID('setgrid',F,X,Y)
%    update grid used
%
%    SELGRID('setrange',F,range)
%    update range highlighted
%    rangestruct=SELGRID('getrange',F)
%    [rangetype,rangeindex]=SELGRID('getrange',F)
%    get highlighted range
%
%    SELGRID('callback',F,function,arg1,arg2,...)
%    set function to be called when selected range changes

% (c) Dec. 4, 2001, H.R.A. Jagers
%     WL | Delft Hydraulics, The Netherlands

if nargin==0
  cmd='initialize';
  UsrRange=[];
elseif nargin==1 & ischar(cmd)
elseif nargin==1
  error('Invalid input argument')
elseif ischar(cmd) & strcmp(lower(cmd),'getrange')
  F=varargin{1};
  SL=findobj(F,'tag','SELLINE');
  xx=get(SL,'userdata');
  if ~isfield(xx,'Type')
    xx.Type='none';
    xx.Range=[];
  end
  if nargout<=1
    out=xx;
  else
    out=xx.Type;
    out2=xx.Range;
  end
  return
elseif ischar(cmd)
else
  X=cmd;
  Y=varargin{1};
  cmd='initialize';
  UsrRange=[];
  if nargin>2
    UsrRange=varargin{2};
  end
end

switch cmd
case {'gridrangeup','gridrangemotion'}
  G=findobj(gcbf,'tag','GRID');
  SG=findobj(gcbf,'tag','SELGRID');
  SL=findobj(gcbf,'tag','SELLINE');
  ij0=get(SL,'userdata');
  UD=get(G,'userdata');
  pnt=get(get(G,'parent'),'currentpoint');
  pnt=pnt(1,1:2);
  dist=(pnt(1)-UD.X).^2+(pnt(2)-UD.Y).^2;
  mdist=min(dist(:));
  [i,j]=find(dist==mdist);
  i=i(1);
  j=j(1);
  %---trackcoord start
  XY=findobj(gcbf,'tag','XYcoord');
  if any(log10(abs(pnt))>3)
    set(XY,'string',sprintf('x,y: %8.0f,%8.0f',pnt))
  else
    set(XY,'string',sprintf('x,y: %8.3f,%8.3f',pnt))
  end
  MN=findobj(gcbf,'tag','MNcoord');
  set(MN,'string',sprintf('m,n: %i,%i',j,i))
  %---trackcoord stop
  i0=ij0(1);
  j0=ij0(2);
  i1=min(i0,i);
  i2=max(i0,i);
  j1=min(j0,j);
  j2=max(j0,j);
  if (i1~=i2) & (j1~=j2)
    set(SG,'xdata',UD.X(i1:i2,j1:j2),'ydata',UD.Y(i1:i2,j1:j2),'zdata',zeros(i2-i1+1,j2-j1+1))
    set(SL,'xdata',[],'ydata',[])
  elseif (i1==i2) & (j1==j2)
    set(SL,'xdata',UD.X(i0,j0),'ydata',UD.Y(i0,j0),'marker','.')
    set(SG,'xdata',[],'ydata',[],'zdata',[])
  elseif i1==i2
    set(SL,'xdata',UD.X(i0,j1:j2),'ydata',UD.Y(i0,j1:j2),'marker','none')
    set(SG,'xdata',[],'ydata',[],'zdata',[])
  else
    set(SL,'xdata',UD.X(i1:i2,j0),'ydata',UD.Y(i1:i2,j0),'marker','none')
    set(SG,'xdata',[],'ydata',[],'zdata',[])
  end
  switch cmd
  case {'gridrangeup'}
    set(gcbf,'WindowButtonDownFcn','')
    set(gcbf,'WindowButtonMotionFcn','')
    set(gcbf,'WindowButtonUpFcn','')
    set(findall(gcbf,'type','uimenu'),'enable','on')
    zoom(gcbf,'on');
    set(gcbf,'WindowButtonMotionFcn','selgrid trackcoord')
    X.Type='range';
    X.Range=[i1 i2 j1 j2];
    set(SL,'userdata',X)
    selgrid execcallback
  end
case {'draglineup','draglinemotion','dragwholelineup','dragwholelinemotion'}
  G=findobj(gcbf,'tag','GRID');
  SL=findobj(gcbf,'tag','SELLINE');
  ij0=get(SL,'userdata');
  UD=get(G,'userdata');
  pnt=get(get(G,'parent'),'currentpoint');
  pnt=pnt(1,1:2);
  dist=(pnt(1)-UD.X).^2+(pnt(2)-UD.Y).^2;
  i0=ij0(1);
  j0=ij0(2);
  midist=min(dist(i0,:));
  mjdist=min(dist(:,j0));
  switch cmd,
  case {'draglineup','draglinemotion'}
    if midist<mjdist
      j1=find(dist(i0,:)==midist);
      j1=j1(1);
      i1=i0;
      if j1==j0
        set(SL,'xdata',UD.X(i0,j0),'ydata',UD.Y(i0,j0),'marker','.')
      elseif j1<j0
        set(SL,'xdata',UD.X(i0,j1:j0),'ydata',UD.Y(i0,j1:j0),'marker','none')
      else
        set(SL,'xdata',UD.X(i0,j0:j1),'ydata',UD.Y(i0,j0:j1),'marker','none')
      end
    else
      i1=find(dist(:,j0)==mjdist);
      i1=i1(1);
      j1=j0;
      if i1==i0
        set(SL,'xdata',UD.X(i0,j0),'ydata',UD.Y(i0,j0),'marker','.')
      elseif i1<i0
        set(SL,'xdata',UD.X(i1:i0,j0),'ydata',UD.Y(i1:i0,j0),'marker','none')
      else
        set(SL,'xdata',UD.X(i0:i1,j0),'ydata',UD.Y(i0:i1,j0),'marker','none')
      end
    end
    %---trackcoord start
    XY=findobj(gcbf,'tag','XYcoord');
    if any(log10(abs(pnt))>3)
      set(XY,'string',sprintf('x,y: %8.0f,%8.0f',pnt))
    else
      set(XY,'string',sprintf('x,y: %8.3f,%8.3f',pnt))
    end
    MN=findobj(gcbf,'tag','MNcoord');
    set(MN,'string',sprintf('m,n: %i,%i',j1,i1))
    %---trackcoord stop
  case {'dragwholelineup','dragwholelinemotion'}
    if midist<mjdist
      set(SL,'xdata',UD.X(i0,:),'ydata',UD.Y(i0,:),'marker','none')
    else
      set(SL,'xdata',UD.X(:,j0),'ydata',UD.Y(:,j0),'marker','none')
    end
    %---trackcoord start
    XY=findobj(gcbf,'tag','XYcoord');
    if any(log10(abs(pnt))>3)
      set(XY,'string',sprintf('x,y: %8.0f,%8.0f',pnt))
    else
      set(XY,'string',sprintf('x,y: %8.3f,%8.3f',pnt))
    end
    MN=findobj(gcbf,'tag','MNcoord');
    set(MN,'string','m,n:')
    %---trackcoord stop
  end
  switch cmd
  case 'draglineup'
    set(gcbf,'WindowButtonDownFcn','')
    set(gcbf,'WindowButtonMotionFcn','')
    set(gcbf,'WindowButtonUpFcn','')
    set(findall(gcbf,'type','uimenu'),'enable','on')
    zoom(gcbf,'on');
    set(gcbf,'WindowButtonMotionFcn','selgrid trackcoord')
    X.Type='lineseg';
    X.Range=[i0 i1 j0 j1];
    set(SL,'userdata',X)
    selgrid execcallback
  case 'dragwholelineup'
    set(gcbf,'WindowButtonDownFcn','')
    set(gcbf,'WindowButtonMotionFcn','')
    set(gcbf,'WindowButtonUpFcn','')
    set(findall(gcbf,'type','uimenu'),'enable','on')
    zoom(gcbf,'on');
    set(gcbf,'WindowButtonMotionFcn','selgrid trackcoord')
    X.Type='line';
    if midist<mjdist
      X.Range=[i0 inf];
    else
      X.Range=[inf j0];
    end
    set(SL,'userdata',X)
    selgrid execcallback
  end
case {'pwlinedown','pwlinemotion'}
  G=findobj(gcbf,'tag','GRID');
  SL=findobj(gcbf,'tag','SELLINE');
  Ln=get(SL,'userdata');
  UD=get(G,'userdata');
  pnt=get(get(G,'parent'),'currentpoint');
  pnt=pnt(1,1:2);
  dist=(pnt(1)-UD.X).^2+(pnt(2)-UD.Y).^2;
  if isempty(Ln)
    mdist=min(dist(:));
    [i,j]=find(dist==mdist);
    i=i(1);
    j=j(1);
    set(SL,'xdata',UD.X(i,j),'ydata',UD.Y(i,j),'marker','.')
    switch cmd
    case 'pwlinedown'
      Ln.ij0=[i j];
      Ln.RefPnt=Ln.ij0;
      Ln.XY=zeros(0,2);
      set(SL,'userdata',Ln)
    end
    %---trackcoord start
    XY=findobj(gcbf,'tag','XYcoord');
    if any(log10(abs(pnt))>3)
      set(XY,'string',sprintf('x,y: %8.0f,%8.0f',pnt))
    else
      set(XY,'string',sprintf('x,y: %8.3f,%8.3f',pnt))
    end
    MN=findobj(gcbf,'tag','MNcoord');
    set(MN,'string',sprintf('m,n: %i,%i',j,i))
    %---trackcoord stop
  else
    i0=Ln.ij0(1);
    j0=Ln.ij0(2);
    midist=min(dist(i0,:));
    mjdist=min(dist(:,j0));
    [mddist,indrng,i1,j1]=NearDiag(dist,i0,j0);
    if (mddist<midist) & (mddist<mjdist)
      XY=[UD.X(indrng)' UD.Y(indrng)'];
    elseif midist<mjdist
      i1=i0;
      j1=find(dist(i0,:)==midist);
      j1=j1(1);
      if j1==j0
        XY=zeros(0,2);
      elseif j1<j0
        XY=[UD.X(i0,j0:-1:j1)' UD.Y(i0,j0:-1:j1)'];
      else
        XY=[UD.X(i0,j0:j1)' UD.Y(i0,j0:j1)'];
      end
    else
      j1=j0;
      i1=find(dist(:,j0)==mjdist);
      i1=i1(1);
      if i1==i0
        XY=zeros(0,2);
      elseif i1<i0
        XY=[UD.X(i0:-1:i1,j0) UD.Y(i0:-1:i1,j0)];
      else
        XY=[UD.X(i0:i1,j0) UD.Y(i0:i1,j0)];
      end
    end
    set(SL,'xdata',[Ln.XY(:,1);XY(:,1)],'ydata',[Ln.XY(:,2);XY(:,2)],'marker','none')
    switch cmd
    case {'pwlinedown'}
      Ln.ij0=[i1 j1];
      Ln.RefPnt(end+1,:)=Ln.ij0;
      Ln.XY=[Ln.XY;XY];
      set(SL,'userdata',Ln);
      if ~strcmp(get(gcbf,'selectiontype'),'normal')
        set(gcbf,'WindowButtonDownFcn','')
        set(gcbf,'WindowButtonMotionFcn','')
        set(gcbf,'WindowButtonUpFcn','')
        set(findall(gcbf,'type','uimenu'),'enable','on')
        zoom(gcbf,'on');
        set(gcbf,'WindowButtonMotionFcn','selgrid trackcoord')
        X.Type='pwline';
        X.Range=Ln.RefPnt;
        set(SL,'userdata',X)
        selgrid execcallback
      end
    end
    %---trackcoord start
    XY=findobj(gcbf,'tag','XYcoord');
    if any(log10(abs(pnt))>3)
      set(XY,'string',sprintf('x,y: %8.0f,%8.0f',pnt))
    else
      set(XY,'string',sprintf('x,y: %8.3f,%8.3f',pnt))
    end
    MN=findobj(gcbf,'tag','MNcoord');
    set(MN,'string',sprintf('m,n: %i,%i',j1,i1))
    %---trackcoord stop
  end
  
case {'genlinedown','genlinemotion'}
  G=findobj(gcbf,'tag','GRID');
  SL=findobj(gcbf,'tag','SELLINE');
  Ln=get(SL,'userdata');
  UD=get(G,'userdata');
  pnt=get(get(G,'parent'),'currentpoint');
  pnt=pnt(1,1:2);
  %---trackcoord start
  XY=findobj(gcbf,'tag','XYcoord');
  if any(log10(abs(pnt))>3)
    set(XY,'string',sprintf('x,y: %8.0f,%8.0f',pnt))
  else
    set(XY,'string',sprintf('x,y: %8.3f,%8.3f',pnt))
  end
  MN=findobj(gcbf,'tag','MNcoord');
  set(MN,'string','m,n:')
  %---trackcoord stop
  if isempty(Ln)
    set(SL,'xdata',pnt(1),'ydata',pnt(2),'marker','.')
    switch cmd
    case 'genlinedown'
      Ln.XY=pnt;
      set(SL,'userdata',Ln)
    end
  else
    set(SL,'xdata',[Ln.XY(:,1);pnt(1)],'ydata',[Ln.XY(:,2);pnt(2)],'marker','none')
    switch cmd
    case {'genlinedown'}
      Ln.XY=[Ln.XY;pnt];
      set(SL,'userdata',Ln);
      if ~strcmp(get(gcbf,'selectiontype'),'normal')
        set(gcbf,'WindowButtonDownFcn','')
        set(gcbf,'WindowButtonMotionFcn','')
        set(gcbf,'WindowButtonUpFcn','')
        set(findall(gcbf,'type','uimenu'),'enable','on')
        zoom(gcbf,'on');
        set(gcbf,'WindowButtonMotionFcn','selgrid trackcoord')
        X.Type='genline';
        X.Range=Ln.XY;
        set(SL,'userdata',X)
        selgrid execcallback
      end
    end
  end
  
case 'trackcoord'
  G=findobj(gcbf,'tag','GRID');
  SL=findobj(gcbf,'tag','SELLINE');
  UD=get(G,'userdata');
  pnt=get(get(G,'parent'),'currentpoint');
  pnt=pnt(1,1:2);
  XY=findobj(gcbf,'tag','XYcoord');
  if any(log10(abs(pnt))>3)
    set(XY,'string',sprintf('x,y: %8.0f,%8.0f',pnt))
  else
    set(XY,'string',sprintf('x,y: %8.3f,%8.3f',pnt))
  end
  MN=findobj(gcbf,'tag','MNcoord');
  set(MN,'string','m,n:')

case {'selpointup','selpointmotion','draglinedown','dragwholelinedown','gridrangedown'}
  G=findobj(gcbf,'tag','GRID');
  SL=findobj(gcbf,'tag','SELLINE');
  UD=get(G,'userdata');
  pnt=get(get(G,'parent'),'currentpoint');
  pnt=pnt(1,1:2);
  dist=(pnt(1)-UD.X).^2+(pnt(2)-UD.Y).^2;
  mdist=min(dist(:));
  [i,j]=find(dist==mdist);
  i=i(1);
  j=j(1);
  %---trackcoord start
  XY=findobj(gcbf,'tag','XYcoord');
  if any(log10(abs(pnt))>3)
    set(XY,'string',sprintf('x,y: %8.0f,%8.0f',pnt))
  else
    set(XY,'string',sprintf('x,y: %8.3f,%8.3f',pnt))
  end
  MN=findobj(gcbf,'tag','MNcoord');
  set(MN,'string',sprintf('m,n: %i,%i',j,i))
  %---trackcoord stop
  set(SL,'xdata',UD.X(i,j),'ydata',UD.Y(i,j),'marker','.')
  switch cmd
  case 'selpointup'
    set(gcbf,'WindowButtonDownFcn','')
    set(gcbf,'WindowButtonMotionFcn','')
    set(gcbf,'WindowButtonUpFcn','')
    set(findall(gcbf,'type','uimenu'),'enable','on')
    zoom(gcbf,'on');
    set(gcbf,'WindowButtonMotionFcn','selgrid trackcoord')
    X.Type='point';
    X.Range=[i j];
    set(SL,'userdata',X)
    selgrid execcallback
  case 'draglinedown'
    set(gcbf,'WindowButtonDownFcn','selgrid draglineup')
    set(gcbf,'WindowButtonMotionFcn','selgrid draglinemotion')
    set(gcbf,'WindowButtonUpFcn','')
    set(SL,'userdata',[i j])
  case 'dragwholelinedown'
    set(gcbf,'WindowButtonDownFcn','selgrid dragwholelineup')
    set(gcbf,'WindowButtonMotionFcn','selgrid dragwholelinemotion')
    set(gcbf,'WindowButtonupFcn','')
    set(SL,'userdata',[i j])
  case 'gridrangedown'
    set(gcbf,'WindowButtonDownFcn','selgrid gridrangeup')
    set(gcbf,'WindowButtonMotionFcn','selgrid gridrangemotion')
    set(gcbf,'WindowButtonupFcn','')
    set(SL,'userdata',[i j])
  end
  
case {'line','wholeline','gridrange'}
  set(findall(gcbf,'type','uimenu'),'enable','off')
  zoom(gcbf,'off');
  switch cmd
  case 'line'
    set(gcbf,'WindowButtonDownFcn','selgrid draglinedown')
  case 'wholeline'
    set(gcbf,'WindowButtonDownFcn','selgrid dragwholelinedown')
  case 'gridrange'
    set(gcbf,'WindowButtonDownFcn','selgrid gridrangedown')
    SL=findobj(gcbf,'tag','SELLINE');
    set(SL,'userdata',[])
  end
  set(gcbf,'WindowButtonMotionFcn','selgrid selpointmotion')
  set(gcbf,'WindowButtonUpFcn','')
  SG=findobj(gcbf,'tag','SELGRID');
  set(SG,'xdata',[],'ydata',[],'zdata',[],'userdat',[])
  SL=findobj(gcbf,'tag','SELLINE');
  set(SL,'userdata',[])
  selgrid selpointmotion
  
case 'pwline'
  set(findall(gcbf,'type','uimenu'),'enable','off')
  zoom(gcbf,'off');
  set(gcbf,'WindowButtonMotionFcn','selgrid pwlinemotion')
  set(gcbf,'WindowButtonDownFcn','selgrid pwlinedown')
  set(gcbf,'WindowButtonUpFcn','')
  SG=findobj(gcbf,'tag','SELGRID');
  set(SG,'xdata',[],'ydata',[],'zdata',[])
  SL=findobj(gcbf,'tag','SELLINE');
  set(SL,'userdata',[])
  selgrid pwlinemotion
  
case 'genline'
  set(findall(gcbf,'type','uimenu'),'enable','off')
  zoom(gcbf,'off');
  set(gcbf,'WindowButtonMotionFcn','selgrid genlinemotion')
  set(gcbf,'WindowButtonDownFcn','selgrid genlinedown')
  set(gcbf,'WindowButtonUpFcn','')
  SG=findobj(gcbf,'tag','SELGRID');
  set(SG,'xdata',[],'ydata',[],'zdata',[])
  SL=findobj(gcbf,'tag','SELLINE');
  set(SL,'userdata',[])
  selgrid genlinemotion
  
case 'point'
  set(findall(gcbf,'type','uimenu'),'enable','off')
  zoom(gcbf,'off');
  set(gcbf,'WindowButtonDownFcn','')
  set(gcbf,'WindowButtonMotionFcn','selgrid selpointmotion')
  set(gcbf,'WindowButtonUpFcn','selgrid selpointup')
  SG=findobj(gcbf,'tag','SELGRID');
  set(SG,'xdata',[],'ydata',[],'zdata',[])
  selgrid selpointmotion
  
case {'wholegrid'}
  G=findobj(gcbf,'tag','GRID');
  SL=findobj(gcbf,'tag','SELLINE');
  X.Type='wholegrid';
  X.Range=[];
  set(SL,'xdata',[],'ydata',[],'userdata',X)
  UD=get(G,'userdata');
  SG=findobj(gcbf,'tag','SELGRID');
  set(SG,'xdata',UD.X,'ydata',UD.Y,'zdata',zeros(size(UD.X)))
  selgrid execcallback
  
case 'setgrid'
  F=varargin{1};
  UD.X=varargin{2};
  UD.Y=varargin{3};
  zoom(F,'reset');
  zoom(F,'off');
  G=findobj(F,'tag','GRID');
  Go=findobj(F,'tag','GRIDother');
  SG=findobj(F,'tag','SELGRID');
  SL=findobj(F,'tag','SELLINE');
  A=get(G,'parent');
  delete(G)
  delete(Go)
  if ~isempty(UD.X)
    G=drawgrid(UD.X,UD.Y,'color',[0 .6 .6],'fontsize',8,'parent',A);
    off='on';
  else
    G=surface([],[],'parent',A);
    off='off';
  end
  set(G(1),'tag','GRID','userdata',UD)
  set(G(2:end),'tag','GRIDother')
  set(allchild(A),'clipping','off','hittest','off')
  xl=limits(A,'xlim'); xl=xl+[-1 1]*max(0.00001,abs(diff(xl)*0.01))/20;
  yl=limits(A,'ylim'); yl=yl+[-1 1]*max(0.00001,abs(diff(yl)*0.01))/20;
  if ~isfinite(xl), xl=[0 1]; yl=[0 1]; end
  set(A,'xlim',xl,'ylim',yl)
  delete(get(A,'zlabel')) % delete the old ZOOMAxesData applicationdata
  zoom(F,off);
  set(SL,'xdata',[],'ydata',[])
  set(SG,'xdata',[],'ydata',[],'zdata',[])
  xx.Type='none';
  xx.Range=[];
  set(SL,'userdata',xx)
  set(findall(F,'type','uimenu'),'enable',off)
  
case 'initialize'
  F=figure('integerhandle','off','color','w','renderer','painters','doublebuffer','on','name','Grid selection','numbertitle','off','handlevisibility','callback','visible','off');
  set(F,'menubar','none')
  mlbversion=sscanf(version,'%f',1);
  if mlbversion > 5.2
    set(F,'ToolBar','none');
  end
  A=axes('parent',F,'unit','normalized','position',[0 0 1 1]);
  XY=uicontrol('parent',F,'style','text','hittest','off','units','pixels','backgroundcolor','w','string','x,y:','horizontalalignment','left','position',[0 0 150 20],'tag','XYcoord');
  MN=uicontrol('parent',F,'style','text','hittest','off','units','pixels','backgroundcolor','w','string','m,n:','horizontalalignment','left','position',[150 0 70 20],'tag','MNcoord');
  if nargin<2
    [UD.X,UD.Y]=drawgrid;
  else
    UD.X=X;
    UD.Y=Y;
  end
  if ~isempty(UD.X)
    G=drawgrid(UD.X,UD.Y,'color',[0 .6 .6],'fontsize',8,'parent',A);
    off='on';
  else
    G=surface([],[],'parent',A);
    off='off';
  end
  set(G(1),'tag','GRID','userdata',UD)
  set(G(2:end),'tag','GRIDother')
  SG=surface([],[],[],'parent',A,'facecolor','r','edgecolor','none','tag','SELGRID','erasemode','xor');
  SL=line('xdata',[],'ydata',[],'parent',A,'color','r','tag','SELLINE','markersize',18,'linewidth',4,'erasemode','xor');
  set(A,'vis','off','da',[1 1 1],'view',[0 90])
  xl=limits(A,'xlim'); xl=xl+[-1 1]*diff(xl)/20; 
  yl=limits(A,'ylim'); yl=yl+[-1 1]*diff(yl)/20;
  if ~isfinite(xl), xl=[0 1]; yl=[0 1]; end
  set(A,'xlim',xl,'ylim',yl)
  set(allchild(A),'clipping','off','hittest','off')
  zoom(F,off);
  uim=uimenu('label','&Select','parent',F);
  uimenu('tag','point','label','Grid &point','parent',uim,'callback','selgrid point');
  uimenu('tag','line','label','Grid &line','parent',uim,'callback','selgrid wholeline','separator','on');
  uimenu('tag','lineseg','label','Grid line &segment','parent',uim,'callback','selgrid line');
  uimenu('tag','pwline','label','Piecewise grid &line','parent',uim,'callback','selgrid pwline');
  uimenu('tag','range','label','Grid &range','parent',uim,'callback','selgrid gridrange','separator','on');
  uimenu('tag','wholegrid','label','Whole &grid','parent',uim,'callback','selgrid wholegrid');
  uimenu('tag','genline','label','Gene&ral line','parent',uim,'callback','selgrid genline','separator','on');
  set(findall(F,'type','uimenu'),'enable',off)
  xx.Type='none';
  xx.Range=[];
  set(SL,'userdata',xx)
  if ~isempty(UsrRange)
    if isstruct(UsrRange)
      xx=UsrRange;
    else
      xx.Type='range';
      xx.Range=UsrRange;
    end
    selgrid('setrange',F,xx)
  end
  if nargout>0
    out=F;
  end
  set(F,'visible','on')
  set(F,'windowbuttonmotionfcn','selgrid trackcoord')
  
case 'execcallback'
  F=gcbf;
  G=findobj(F,'tag','GRID');
  A=get(G,'parent');
  UD=get(A,'userdata');
  if ~isempty(UD)
%    d3d_qp gridviewupdate
    feval(UD{1},UD{2:end})
  end
  
case 'callback'
  F=varargin{1};
  G=findobj(F,'tag','GRID');
  A=get(G,'parent');
  set(A,'userdata',varargin(2:end))
  
case 'setrange'
  F=varargin{1};
  UsrRange=varargin{2};
  SL=findobj(F,'tag','SELLINE');
  set(F,'WindowButtonDownFcn','')
  set(F,'WindowButtonMotionFcn','selgrid trackcoord')
  set(F,'WindowButtonUpFcn','')
  SG=findobj(F,'tag','SELGRID');
  SL=findobj(F,'tag','SELLINE');
  G=findobj(F,'tag','GRID');
  UD=get(G,'userdata');
  zoom(F,'on');
  xx.Type='none';
  xx.Range=[];
  if ~isempty(UsrRange)
    if isstruct(UsrRange)
      xx=UsrRange;
    else
      xx.Type='range';
      xx.Range=UsrRange;
    end
  end
  switch xx.Type,
  case 'none'
    set(SL,'xdata',[],'ydata',[])
    set(SG,'xdata',[],'ydata',[],'zdata',[])
  case 'point'
    set(SL,'xdata',UD.X(xx.Range(1),xx.Range(2)),'ydata',UD.Y(xx.Range(1),xx.Range(2)),'marker','.')
    set(SG,'xdata',[],'ydata',[],'zdata',[])
  case 'range'
    i1=min(xx.Range([1 2]));
    i2=max(xx.Range([1 2]));
    j1=min(xx.Range([3 4]));
    j2=max(xx.Range([3 4]));
    if (i1==i2) | (j1==j2)
      mrkr='none';
      if (i1==i2) & (j1==j2), mrkr='.'; end
      set(SL,'xdata',UD.X(i1:i2,j1:j2),'ydata',UD.Y(i1:i2,j1:j2),'marker',mrkr)
      set(SG,'xdata',[],'ydata',[],'zdata',[])
    else
      set(SL,'xdata',[],'ydata',[])
      set(SG,'xdata',UD.X(i1:i2,j1:j2),'ydata',UD.Y(i1:i2,j1:j2),'zdata',zeros(i2-i1+1,j2-j1+1))
    end
  case 'wholegrid'
    set(SL,'xdata',[],'ydata',[])
    set(SG,'xdata',UD.X,'ydata',UD.Y,'zdata',zeros(size(UD.X)))
  case 'genline'
    set(SL,'xdata',xx.Range(:,1),'ydata',xx.Range(:,2),'marker','none')
    set(SG,'xdata',[],'ydata',[],'zdata',[])
  case 'line'
    if isfinite(X.Range(1))
      set(SL,'xdata',UD.X(X.Range(1),:),'ydata',UD.Y(X.Range(1),:),'marker','none')
    else
      set(SL,'xdata',UD.X(:,X.Range(2)),'ydata',UD.Y(:,X.Range(2)),'marker','none')
    end
    set(SG,'xdata',[],'ydata',[],'zdata',[])
  case 'lineseg'
    i1=min(xx.Range([1 2]));
    i2=max(xx.Range([1 2]));
    j1=min(xx.Range([3 4]));
    j2=max(xx.Range([3 4]));
    mrkr='none';
    if (i1==i2) & (j1==j2), mrkr='.'; end
    set(SL,'xdata',UD.X(i1:i2,:),'ydata',UD.Y(j1:j2,:),'marker',mrkr)
    set(SG,'xdata',[],'ydata',[],'zdata',[])
  case 'pwline'
    i0=xx.Range(1,1);
    j0=xx.Range(1,2);
    sd=diff(xx.Range);
    for i=1:size(sd,1)
      di=max(abs(sd(i,:)));
      if di~=0
        i0=[i0 i0(end)+(1:di)*sign(sd(i,1))];
        j0=[j0 j0(end)+(1:di)*sign(sd(i,2))];
      end
    end
    ind=sub2ind(size(UD.X),i0,j0);
    mrkr='none';
    if length(ind)==1, mrkr='.'; end
    set(SL,'xdata',UD.X(ind),'ydata',UD.Y(ind),'marker',mrkr)
    set(SG,'xdata',[],'ydata',[],'zdata',[])
  end
  set(SL,'userdata',xx)
  return
  
otherwise
  fprintf('Unkwown command: %s\n',cmd)
end


function [mdist,indrng,i1,j1]=NearDiag(dist,i0,j0);
sz=size(dist);
szi=sz(1);
szj=sz(2);
ind0=sub2ind(sz,i0,j0);

di=min(i0,j0)-1;
ir=i0-di;
jr=j0-di;
di=min(szi-ir,szj-jr);
ir=ir+(0:di);
jr=jr+(0:di);

ind=sub2ind(sz,ir,jr);
[m1dist,ind1]=min(dist(ind));
ir1=ir(ind1);
jr1=jr(ind1);
ind1=ind(ind1);
if ind1<ind0
  indrng1=ind0:-(szi+1):ind1;
else
  indrng1=ind0:(szi+1):ind1;
end

di=min(i0,szj-j0+1)-1;
ir=i0-di;
jr=j0+di;
di=min(szi-ir,jr-1);
ir=ir+(0:di);
jr=jr-(0:di);

ind=sub2ind(sz,ir,jr);
[m2dist,ind2]=min(dist(ind));
ir2=ir(ind2);
jr2=jr(ind2);
ind2=ind(ind2);
if ind2<ind0
  indrng2=ind0:-(szi-1):ind2;
else
  indrng2=ind0:(szi-1):ind2;
end

if m1dist<m2dist
  indrng=indrng1;
  mdist=m1dist;
  i1=ir1;
  j1=jr1;
else
  indrng=indrng2;
  mdist=m2dist;
  i1=ir2;
  j1=jr2;
end
