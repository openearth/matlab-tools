function showtabs(Obj),
% process slider movement of tabs
if nargin~=1,
  error('Invalid number of arguments');
end;

MostLeft=get(Obj.Slider,'value');

N=length(Obj.Tab);
set(Obj.Tab(1:(MostLeft-1)),'visible','off');
posleft=get(Obj.Tab(MostLeft),'position');
leftshift=posleft(1)-Obj.Position(1);
CumPos=0;
i=MostLeft;
while (i<=N),
  if ((CumPos+Obj.TabWidth(i))<Obj.Position(3)-Obj.Position(4)-3),
    Pos=get(Obj.Tab(i),'position');
    Pos(1)=Obj.Position(1)+CumPos;
    CumPos=CumPos+Obj.TabWidth(i);
    set(Obj.Tab(i),'position',Pos,'visible','on');
    i=i+1;
  else,
    set(Obj.Tab(i:N),'visible','off');
    i=N+1;
  end;
end;
Obj.MostLeftTab=MostLeft;

% update tab information
set(Obj.Main,'userdata',Obj);
