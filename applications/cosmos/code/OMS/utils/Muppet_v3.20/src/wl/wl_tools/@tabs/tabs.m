function Obj=tabs(fig,position),
% create tabs
% TabsObject=tabs(fig,position)
if nargin==0,
  error('No figure specified');
elseif nargin==1,
  fu=get(fig,'units');
  set(fig,'units','pixels');
  pos=get(fig,'position');
  position=[1 1 pos(3) pos(4)];
  set(fig,'units',fu);
end;

Obj.Main=axes('parent',fig, ...
           'units','pixels', ...
           'position',position-[0 0 0 20], ...
           'tag','tabs', ...
           'xlim',[0 position(3)], ...
           'ylim',[0 position(4)-20], ...
           'xtick',[], ...
           'ytick',[], ...
           'box','on', ...
           'color',[1 1 1], ...
           'visible','off');

border3d(Obj.Main,1,1,position(3)+1,position(4)-20+1);

position=[position(1) position(2)+position(4)-20 position(3) 20];

Pos=[position(1)+position(3)-1-position(4) position(2)+position(4)/4 1+position(4) position(4)/2];
Obj.Slider=uicontrol('parent',fig, ...
           'style','slider', ...
           'units','pixels', ...
           'position',Pos, ...
           'min', 0, ...
           'max', 1, ...
           'value', 1, ...
           'sliderstep', [0.1 1], ...
           'tag','tabs', ...
           'foregroundcolor',[0 0 0], ...
           'backgroundcolor',[1 1 1], ...
           'callback',sprintf('showtabs(get(hex2num(''%s''),''userdata''))',num2hex(Obj.Main)), ...
           'visible','off');
Obj.MostLeftTab=[];
Obj.Selected=[];
Obj.Units='pixels';
Obj.Position=position;
Obj.Tab=[];
Obj.TabWidth=[];
Obj.Handles={};

Obj=class(Obj,'tabs');
set(Obj.Main,'userdata',Obj);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% BORDER3D
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function l=border3d(ax,x,y,dx,dy,varargin),
HShift=-1;
VShift=-1;
DarkGray=[1 1 1]*128/255;
White=[1 1 1];
Black=[0 0 0];
LightGray=[1 1 1]*223/255;
MidGray=[1 1 1]*192/255;
l(5)=patch(HShift+[x+dx-1 x x x+dx-1],VShift+[y+dy-1 y+dy-1 y y],-[1 1 1 1],1,'parent',ax,'facecolor',MidGray,'edgecolor','none',varargin{:});
l(1)=line(HShift+[x+dx-1 x x],VShift+[y+dy-1 y+dy-1 y],-0.5*[1 1 1],'parent',ax,'color',White,varargin{:});
l(2)=line(HShift+[x+dx-2 x+1 x+1],VShift+[y+dy-2 y+dy-2 y+1],-0.5*[1 1 1],'parent',ax,'color',LightGray,varargin{:});
l(3)=line(HShift+[x+1 x+dx-2 x+dx-2],VShift+[y+1 y+1 y+dy-2],-0.5*[1 1 1],'parent',ax,'color',DarkGray,varargin{:});
l(4)=line(HShift+[x x+dx-1 x+dx-1],VShift+[y y y+dy-1],-0.5*[1 1 1],'parent',ax,'color',Black,varargin{:});

