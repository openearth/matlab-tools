function [Obj,N]=add(ObjIn,Label,Handles),
% add a tab
% [TabsObject,TabNr]=add(TabsObject,TabLabel)
if nargin~=3,
  error('Invalid number of arguments');
elseif ~ischar(Label),
  error('Tab label must be character');
end;

Obj=ObjIn;
N=length(Obj.Tab)+1;
LabelWidth=ceil(7*length(Label))+20;
Left=sum(Obj.TabWidth);
Obj.TabWidth(N)=LabelWidth;
if (Left+LabelWidth)<=Obj.Position(3), % they all fit together
  Pos=[Obj.Position(1)+Left Obj.Position(2) LabelWidth Obj.Position(4)];
  Obj.MostLeftTab=1;
else,  % Too many tabs; they don't fit in the available space!
  if N==1, % one label and too wide, just make it fit
    Pos=[Obj.Position(1) Obj.Position(2) Obj.Position(3) Obj.Position(4)];
    Obj.MostLeftTab=1;
  else, % show arrow buttons
    CumWidth=fliplr(cumsum(fliplr(Obj.TabWidth)));
    MostLeft=min([N,find(diff(CumWidth<(Obj.Position(3)-Obj.Position(4)-5)))+1]);
    set(Obj.Tab(1:(MostLeft-1)),'visible','off');
    posleft=get(Obj.Tab(MostLeft),'position');
    leftshift=posleft(1)-Obj.Position(1);
    for i=MostLeft:(N-1),
      Pos=get(Obj.Tab(i),'position');
      Pos(1)=Pos(1)-leftshift;
      set(Obj.Tab(i),'position',Pos);
    end;
    Pos=[Obj.Position(1)+sum(Obj.TabWidth(MostLeft:(N-1))) Obj.Position(2) min(LabelWidth,Obj.Position(3)-Obj.Position(4)-5) Obj.Position(4)];
    Obj.MostLeftTab=MostLeft;
    set(Obj.Slider,'visible','on', ...
        'min',1, ...
        'max',N, ...
        'value', MostLeft, ...
        'sliderstep', [1/(N-1) min(1,10/(N-1))]);
  end;
end;
if N==1,
  Obj.Selected=1;
  enable='off';
else,
  enable='on';
end;
Obj.Tab(N)=uicontrol('parent',get(Obj.Main,'parent'), ...
             'units','pixels', ...
             'position',Pos, ...
             'string',Label, ...
             'enable',enable, ...
             'style','togglebutton', ...
             'callback',sprintf('tabselect(get(hex2num(''%s''),''userdata''),%i)',num2hex(Obj.Main),N), ...
             'value',N~=Obj.Selected);
Obj.Handles{N}=Handles;
if N~=Obj.Selected,
  set(Handles,'visible','off');
else,
  set(Handles,'visible','on');
end;

% update tab information
set(Obj.Main,'userdata',Obj);
