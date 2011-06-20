function box=bbox(Obj),
% minx, miny, maxx, maxy

H=handles(ob_ideas(Obj));
box=[NaN NaN NaN NaN];

for i=1:length(H),
  switch get(H(i),'type'),
  case 'text',
    P=get(H(i),'extent');
    box(1:2)=min(box(1:2),P(1:2));
    box(3:4)=max(box(3:4),P(1:2)+P(3:4));
  case {'line','patch','surface'},
    X=get(H(i),'xdata');
    Y=get(H(i),'ydata');
    if ~isempty(X),
      box(1)=min(box(1),min(X(:)));
      box(3)=max(box(3),max(X(:)));
    end;
    if ~isempty(Y),
      box(2)=min(box(2),min(Y(:)));
      box(4)=max(box(4),max(Y(:)));
    end;
  end;
end;
