function guigr3(varargin),
% guigr3 User interface for graph editing
%
%       Usage: guigr3 to start a new graph
%              guigr3(NODES,EDGES) to continue editing a previous graph
%              [No input checking implemented!]
%
%       To export Nodes and Edges to the base workspace click once on the
%       "export data" menu or press Alt-X.

% Created by H.R.A. Jagers, University of Twente, WL | Delft Hydraulics, The Netherlands
%         on November 3rd, 1999

switch nargin,
case 4,
  sarrow(varargin{:})
case {0,2},
  [F,UD]=CreateUI;
  if nargin==2, % draw graph
    UD.Nodes=varargin{1};
    set(UD.NodeH,'xdata',UD.Nodes(:,1),'ydata',UD.Nodes(:,2));
    UD.Edges=varargin{2};
    I=transpose([ones(size(UD.Edges,1),1) UD.Edges]);
    I=UD.Nodes(I(:),:);
    I(1:3:end,:)=NaN;
%    set(UD.EdgeH,'xdata',I(:,1),'ydata',I(:,2));
    [X,Y]=plotarrow(UD.Nodes,UD.Edges,UD.Directional);
    set(UD.EdgeH,'xdata',X,'ydata',Y)
  end;
  set(F,'windowbuttondownfcn','guigr3 down','userdata',UD,'menubar','none','name','edit graph ...','numbertitle','off');
case 1,
  Pnt=get(getudf(gcbf,'Axes'),'currentpoint');
  Pnt=Pnt(1,1:2);
  UD=get(gcbf,'userdata');
  i=0;
  switch varargin{1},
  case 'down',
    switch get(gcbf,'selectiontype'),
    case 'normal',
      if isempty(UD.Nodes),
        minDistSq=100;
      else,
        DistSq=(UD.Nodes(:,1)-Pnt(1)).^2+(UD.Nodes(:,2)-Pnt(2)).^2;
        [minDistSq,i]=min(DistSq);
      end;
      if minDistSq<0.001,
        Pnt=UD.Nodes(i,:);
      else,
        if all(0<=Pnt) & all(Pnt<=1),
          i=size(UD.Nodes,1)+1;
          UD.Nodes(i,1:2)=Pnt;
          set(UD.NodeH,'xdata',UD.Nodes(:,1),'ydata',UD.Nodes(:,2));
        end;
      end;
      if (i>0),
        UD.StartCord=i;
        set(gcbf,'windowbuttonmotionfcn','guigr3 motion', ...
                 'windowbuttonupfcn','guigr3 up', ...
                 'windowbuttondownfcn','');
        set(UD.Cord,'xdata',[Pnt(1) Pnt(1)],'ydata',[Pnt(2) Pnt(2)],'visible','on');
      end;
    case 'alt',
    end;
  case 'motion',
    Pos=get(gcbf,'position');
    T=get(0,'pointerlocation');
    T=min(Pos(1:2)+Pos(3:4),max(Pos(1:2),T));
    set(0,'pointerlocation',T);
    Pnt=get(getudf(gcbf,'Axes'),'currentpoint');
    Pnt=Pnt(1,1:2);
    DistSq=(UD.Nodes(:,1)-Pnt(1)).^2+(UD.Nodes(:,2)-Pnt(2)).^2;
    [minDistSq,i]=min(DistSq);
    if minDistSq<0.001,
      Pnt=UD.Nodes(i,:);
    end;
    switch UD.Mode,
    case 'add',
      X=get(UD.Cord,'xdata');
      Y=get(UD.Cord,'ydata');
      if all(0<=Pnt) & all(Pnt<=1),
        X(2)=Pnt(1);
        Y(2)=Pnt(2);
      else,
        X(2)=X(1);
        Y(2)=Y(1);
      end;
      set(UD.Cord,'xdata',X,'ydata',Y);
    case 'change',
      X=get(UD.Cord,'xdata');
      Y=get(UD.Cord,'ydata');
      if all(0<=Pnt) & all(Pnt<=1),
        X(2:3:end)=Pnt(1);
        Y(2:3:end)=Pnt(2);
      else,
        X(2:3:end)=UD.Nodes(UD.Selected,1);
        Y(2:3:end)=UD.Nodes(UD.Selected,2);
      end;
      set(UD.Cord,'xdata',X,'ydata',Y);
    end;
  case 'move',
    UD.Mode='change';
    if isempty(UD.Nodes),
      minDistSq=100;
    else,
      DistSq=(UD.Nodes(:,1)-Pnt(1)).^2+(UD.Nodes(:,2)-Pnt(2)).^2;
      [minDistSq,i]=min(DistSq);
    end;
    if minDistSq<0.001,
      Pnt=UD.Nodes(i,:);
      UD.Selected=i;
    end;
    set(gcbf,'windowbuttonmotionfcn','', ...
             'windowbuttonupfcn','', ...
             'windowbuttondownfcn','guigr3 down');
    if isempty(UD.Edges),
      I=[];
    else,
      I=any(UD.Edges==UD.Selected,2);
    end;
    UD.StartCord=UD.Selected;
    if any(I),
      I=UD.Edges(I,:);
      I=unique(sort(I,2),'rows');
      I=I(I(:)~=UD.Selected);
      I=transpose([ones(size(I,1),2) I]);
      I(2,:)=UD.Selected;
      I=UD.Nodes(I(:),:);
      I(1:3:end,:)=NaN;
      set(UD.Cord,'xdata',I(:,1),'ydata',I(:,2),'visible','on');
    else,
      set(UD.Cord,'xdata',[],'ydata',[],'visible','off');
    end;
    set(gcbf,'windowbuttonmotionfcn','guigr3 motion', ...
             'windowbuttonupfcn','guigr3 up', ...
             'windowbuttondownfcn','');
  case 'delete',
    if isempty(UD.Nodes),
      minDistSq=100;
    else,
      DistSq=(UD.Nodes(:,1)-Pnt(1)).^2+(UD.Nodes(:,2)-Pnt(2)).^2;
      [minDistSq,i]=min(DistSq);
    end;
    if minDistSq<0.001,
      Pnt=UD.Nodes(i,:);
      UD.Selected=i;
    end;
    set(gcbf,'windowbuttonmotionfcn','', ...
             'windowbuttonupfcn','', ...
             'windowbuttondownfcn','guigr3 down');
    UD.Nodes(UD.Selected,:)=[];
    set(UD.NodeH,'xdata',UD.Nodes(:,1),'ydata',UD.Nodes(:,2));
    UD.Edges(any(UD.Edges==UD.Selected,2),:)=[];
    if isempty(UD.Edges),
%      set(UD.EdgeH,'xdata',[],'ydata',[]);
      [X,Y]=plotarrow(UD.Nodes,UD.Edges,UD.Directional);
      set(UD.EdgeH,'xdata',X,'ydata',Y)
    else,
      I=UD.Edges>UD.Selected;
      UD.Edges(I)=UD.Edges(I)-1;
      I=transpose([ones(size(UD.Edges,1),1) UD.Edges]);
      I=UD.Nodes(I(:),:);
      I(1:3:end,:)=NaN;
%      set(UD.EdgeH,'xdata',I(:,1),'ydata',I(:,2));
      [X,Y]=plotarrow(UD.Nodes,UD.Edges,UD.Directional);
      set(UD.EdgeH,'xdata',X,'ydata',Y)
    end;
    UD.Selected==0;
  case 'export',
    assignin('base','Nodes',UD.Nodes);
    if UD.Directional
      assignin('base','Edges',UD.Edges);
    else
      assignin('base','Edges',sort(UD.Edges,2));
    end
  case 'deledge',
    X=UD.Nodes(:,1)';
    Y=UD.Nodes(:,2)';
    XY=[X(UD.Edges) Y(UD.Edges)];
    N=ones(size(UD.Edges,1),1);
    X3=Pnt;
    EdgeVec=XY(:,[2 4])-XY(:,[1 3]);
    Dist=sqrt(sum((XY(:,[1 3])+((sum((N*X3-XY(:,[1 3])).*EdgeVec,2)./sum(EdgeVec.^2,2))*ones(1,2)).*EdgeVec-N*X3).^2,2));
    [minDist,edge]=min(Dist);
    UD.Edges(edge,:)=[];
    I=transpose([ones(size(UD.Edges,1),1) UD.Edges]);
    I=UD.Nodes(I(:),:);
    I(1:3:end,:)=NaN;
%    set(UD.EdgeH,'xdata',I(:,1),'ydata',I(:,2));
    [X,Y]=plotarrow(UD.Nodes,UD.Edges,UD.Directional);
    set(UD.EdgeH,'xdata',X,'ydata',Y)
  case 'up',
    Pos=get(gcbf,'position');
    T=get(0,'pointerlocation');
    T=min(Pos(1:2)+Pos(3:4),max(Pos(1:2),T));
    set(0,'pointerlocation',T);
    Pnt=get(getudf(gcbf,'Axes'),'currentpoint');
    Pnt=Pnt(1,1:2);
    set(gcbf,'windowbuttonmotionfcn','', ...
             'windowbuttonupfcn','', ...
             'windowbuttondownfcn','guigr3 down');
    switch UD.Mode,
    case 'add',
      set(UD.Cord,'visible','off');
      DistSq=(UD.Nodes(:,1)-Pnt(1)).^2+(UD.Nodes(:,2)-Pnt(2)).^2;
      [minDistSq,i]=min(DistSq);
      if minDistSq<0.001,
        Pnt=UD.Nodes(i,:);
      else,
        if all(0<=Pnt) & all(Pnt<=1),
          i=size(UD.Nodes,1)+1;
          UD.Nodes(i,1:2)=Pnt;
          set(UD.NodeH,'xdata',UD.Nodes(:,1),'ydata',UD.Nodes(:,2));
        else,
          i=UD.StartCord;
        end;
      end;
      if UD.StartCord~=i,
        if isempty(UD.Edges),
          Drawn=0;
        else,
          if UD.Directional
            Drawn=ismember([i UD.StartCord],UD.Edges,'rows');
          else
            Drawn=ismember([UD.StartCord i; i UD.StartCord],UD.Edges,'rows');
          end
        end;
        if ~any(Drawn),
          Ex=get(UD.EdgeH,'xdata'); Ex(size(Ex,2)+(1:3))=[NaN UD.Nodes(UD.StartCord,1) Pnt(1)];
          Ey=get(UD.EdgeH,'ydata'); Ey(size(Ey,2)+(1:3))=[NaN UD.Nodes(UD.StartCord,2) Pnt(2)];
          UD.Edges(size(UD.Edges,1)+1,1:2)=[i UD.StartCord];
          UD.StartCord=0;
%          set(UD.EdgeH,'xdata',Ex,'ydata',Ey);
          [X,Y]=plotarrow(UD.Nodes,UD.Edges,UD.Directional);
          set(UD.EdgeH,'xdata',X,'ydata',Y)
        end;
      end;
    case 'change',
      UD.Mode='add';
      set(UD.Cord,'visible','off');
      DistSq=(UD.Nodes(:,1)-Pnt(1)).^2+(UD.Nodes(:,2)-Pnt(2)).^2;
      [minDistSq,i]=min(DistSq);
      if minDistSq<0.001,
        UD.Nodes(UD.Selected,:)=[];
        set(UD.NodeH,'xdata',UD.Nodes(:,1),'ydata',UD.Nodes(:,2));
        UD.Edges(UD.Edges==UD.Selected)=i;
        UD.Edges(UD.Edges(:,1)==UD.Edges(:,2),:)=[];
        UD.Edges=unique(UD.Edges,'rows');
        if isempty(UD.Edges),
%          set(UD.EdgeH,'xdata',[],'ydata',[]);
          [X,Y]=plotarrow(UD.Nodes,UD.Edges,UD.Directional);
          set(UD.EdgeH,'xdata',X,'ydata',Y)
        else,
          I=UD.Edges>UD.Selected;
          UD.Edges(I)=UD.Edges(I)-1;
          I=transpose([ones(size(UD.Edges,1),1) UD.Edges]);
          I=UD.Nodes(I(:),:);
          I(1:3:end,:)=NaN;
%          set(UD.EdgeH,'xdata',I(:,1),'ydata',I(:,2));
          [X,Y]=plotarrow(UD.Nodes,UD.Edges,UD.Directional);
          set(UD.EdgeH,'xdata',X,'ydata',Y)
        end;
        if i>UD.Selected,
          UD.Selected=i-1;
        else,
          UD.Selected=i;
        end;
      else,
        i=UD.StartCord;
        if all(0<=Pnt) & all(Pnt<=1),
          UD.Nodes(i,:)=Pnt;
%          text(Pnt(1)-0.02,Pnt(2)+0.02,num2str(i))
          set(UD.NodeH,'xdata',UD.Nodes(:,1),'ydata',UD.Nodes(:,2));
          I=transpose([ones(size(UD.Edges,1),1) UD.Edges]);
          I=UD.Nodes(I(:),:);
          I(1:3:end,:)=NaN;
%          set(UD.EdgeH,'xdata',I(:,1),'ydata',I(:,2));
          [X,Y]=plotarrow(UD.Nodes,UD.Edges,UD.Directional);
          set(UD.EdgeH,'xdata',X,'ydata',Y)
        end;
      end;
    end;
  end;
  set(gcbf,'userdata',UD);
end;

function [F,UD]=CreateUI,
TmpU=get(0,'units');
set(0,'units','centimeter');
Pos=get(0,'screensize');
set(0,'units',TmpU);
F=figure('doublebuffer','on', 'units','centimeter', ...
         'position',[Pos(3)/2-5 Pos(4)/2-5 10 10], ...
         'units','pixels');
DGray=[.5 .5 .5];
LGray=[.9 .9 .9];
A=axes('parent',F, ...
       'units','normalized', 'position',[0 0 1 1], ...
       'xlim',[0 1], 'ylim',[0 1], 'dataaspectratio',[1 1 1], ...
       'box','on', 'xtick',[], 'ytick',[], ...
       'color',LGray, 'xcolor',DGray, 'ycolor',DGray); 
UD.Axes=A;

UD.EditMenu=uicontextmenu;
uimenu(UD.EditMenu,'label','&move','callback','guigr3 move');
uimenu(UD.EditMenu,'separator','on','label','&delete','callback','guigr3 delete');

UD.EditEdgeMenu=uicontextmenu;
uimenu(UD.EditEdgeMenu,'label','&delete','callback','guigr3 deledge');

UD.EdgeH=line('xdata',[],'ydata',[], ...
              'linestyle','-', ...
              'parent',A,'clipping','off', ...
              'uicontextmenu',UD.EditEdgeMenu);
UD.NodeH=line('xdata',[],'ydata',[], ...
              'linestyle','none','marker','.', ...
              'parent',A,'clipping','off', ...
              'uicontextmenu',UD.EditMenu);
UD.Cord=line('xdata',[],'ydata',[], ...
             'linestyle','-', ...
             'parent',A, ...
             'erasemode','xor','color',[.5 .5 .5],'clipping','off');
UD.Selected=0;
UD.StartCord=0;
UD.Nodes=[];
UD.Edges=[];
UD.Mode='add';
UD.Directional=1;
uimenu('parent',F,'label','e&xport data','callback','guigr3 export');


function [XCoords,YCoords]=plotarrow(Nodes,Edges,directional)
XCoords=[];
YCoords=[];
if isempty(Edges), return; end;
X=Nodes(:,1)';
Y=Nodes(:,2)';
XY=[X(Edges) Y(Edges)];
if directional,
  HeadAngle = pi*(15/180);
  HeadLength = 0.02;

  pVec=XY(:,[2 4])-XY(:,[1 3]);
  pVec=pVec./(sqrt(sum(pVec.^2,2))*ones(1,2));

  Angle=atan2(pVec(:,2),pVec(:,1));
  Angle1=Angle - HeadAngle;
  Angle2=Angle + HeadAngle;

  XCoords=[repmat(NaN,size(XY,1),1) XY(:,2) XY(:,1) XY(:,1)+HeadLength*cos(Angle1) XY(:,1)+HeadLength*cos(Angle2) XY(:,1)]';
  YCoords=[repmat(NaN,size(XY,1),1) XY(:,4) XY(:,3) XY(:,3)+HeadLength*sin(Angle1) XY(:,3)+HeadLength*sin(Angle2) XY(:,3)]';
else,
  XCoords=[repmat(NaN,size(XY,1),1) XY(:,2) XY(:,1)]';
  YCoords=[repmat(NaN,size(XY,1),1) XY(:,4) XY(:,3)]';
end;
XCoords=XCoords(:);
YCoords=YCoords(:);