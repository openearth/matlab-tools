function PutInCentre(f)

%Put box in centre (original version didnt work on my pc

set       (f,'Units','pixels');
PosOri=get(f,'Position');

ScreenSize=get(0,'ScreenSize');

Pos(1)=ScreenSize(3)/2-PosOri(3)/2;
Pos(2)=ScreenSize(4)/2-PosOri(4)/2;
Pos(3)=PosOri(3);
Pos(4)=PosOri(4);

set (f,'Position',Pos);
