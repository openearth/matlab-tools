function it=gen_surface(ax,x,y,z,c,xAct,yAct,option);
% GEN_SURFACE(AX,X,Y,Z,C)
% GEN_SURFACE(AX,X,Y,Z,C,xACT,yACT)
% GEN_SURFACE(AX,X,Y,Z,C,xACT,yACT,'fast')
% GEN_SURFACE(AX,X,Y,Z,C,xACT,yACT,'detailed')
% GEN_SURFACE(IT,Z,C)
% GEN_SURFACE(IT,Z,C,xACT,yACT)
% GEN_SURFACE(IT,Z,C,xACT,yACT,'fast')
% GEN_SURFACE(IT,Z,C,xACT,yACT,'detailed')


if nargin==0,
  return;
end;

if ~isnumeric(ax) | ~isequal(size(ax),[1 1]) | ~ishandle(ax),
  error('First argument should be a handle');

elseif strcmp(get(ax(1),'type'),'axes'), % create surface
% GEN_SURFACE(AX,X,Y,Z,C)
% GEN_SURFACE(AX,X,Y,Z,C,xACT,yACT)
% GEN_SURFACE(AX,X,Y,Z,C,xACT,yACT,'fast')
% GEN_SURFACE(AX,X,Y,Z,C,xACT,yACT,'detailed')

  if nargin==5,
    it=surface('xdata',x, ...
               'ydata',y, ...
               'zdata',z, ...
               'cdata',c, ...
               'edgecolor','none', ...
               'facecolor','interp', ...
               'linewidth',0.001, ...
               'parent',ax);
  else,
    if nargin==7,
      option='detailed'; % default detailed
    end;
    switch option,
    case 'fast',
      zAct=xAct|yAct|[zeros(1,size(xAct,2)); yAct(1:end-1,1:end)]|[zeros(size(yAct,1),1) xAct(1:end,1:end-1)];
      z=z+setnan(~zAct);
      c=c+setnan(~zAct);
      it=surface('xdata',x, ...
                 'ydata',y, ...
                 'zdata',z, ...
                 'cdata',c, ...
                 'edgecolor','none', ...
                 'facecolor','interp', ...
                 'linewidth',0.001, ...
                 'parent',ax);

    case 'detailed',
      xAct(:,end)=0;
      yAct(end,:)=0;
      xAct2=[xAct(2:end,1:end); zeros(1,size(xAct,2))];
      yAct2=[yAct(1:end,2:end), zeros(size(xAct,1),1)];
      vertices=[x(:),y(:),z(:)];
      N=size(x,1);
      faces=[];
      i=find(xAct & yAct);
      faces=[i i+1 i+N];
      i=find(xAct2 & yAct2);
      faces=[faces; i+1 i+N i+N+1];
      i=find(xAct2 & yAct & ~(xAct & yAct2));
      faces=[faces; i i+1 i+N+1];
      i=find(xAct & yAct2 & ~(xAct2 & yAct));
      faces=[faces; i i+N i+N+1];

      i=find(xAct & ~(yAct | yAct2 | [zeros(1,size(xAct,2)); yAct(1:end-1,1:end)] | [zeros(1,size(xAct,2)); yAct2(1:end-1,1:end)]));
      faces=[faces; i i i+N];
      i=find(yAct & ~(xAct | xAct2 | [zeros(size(yAct,1),1) xAct(1:end,1:end-1)] | [zeros(size(yAct,1),1) xAct2(1:end,1:end-1)]));
      faces=[faces; i i i+1];

      i=find(xAct|yAct|[zeros(1,size(xAct,2)); yAct(1:end-1,1:end)]|[zeros(size(yAct,1),1) xAct(1:end,1:end-1)]);
      fvc=NaN*zeros(size(z(:)));
      fvc(i)=c(i);
      it=patch('faces',faces, ...
               'vertices',vertices, ...
               'facevertexcdata',fvc, ...
               'edgecolor','interp', ...
               'facecolor','interp', ...
               'linewidth',1, ...
               'parent',ax);
    end;
  end;

else, % change surface
% GEN_SURFACE(IT,Z,C)
% GEN_SURFACE(IT,Z,C,xACT,yACT)
% GEN_SURFACE(IT,Z,C,xACT,yACT,'fast')
% GEN_SURFACE(IT,Z,C,xACT,yACT,'detailed')

  if nargin==3,
    it=ax;
    z=x;
    c=y;
    set(it,'zdata',z,'cdata',c);
  else,
    if nargin==5,
      option='detailed'; % default detailed
    else,
      optio=xAct;
    end;
    it=ax;
    xAct=z;
    yAct=c;
    z=x;
    c=y;

    switch option,
    case 'fast',
      zAct=xAct|yAct|[zeros(1,size(xAct,2)); xAct(1:end-1,1:end)]|[zeros(size(yAct,1),1) yAct(1:end,1:end-1)];
      z=z+setnan(~zAct);
      c=c+setnan(~zAct);
      set(it,'zdata',z,'cdata',c);

    case 'detailed',
      xAct(:,end)=0;
      yAct(end,:)=0;
      xAct2=[xAct(2:end,1:end); zeros(1,size(xAct,2))];
      yAct2=[yAct(1:end,2:end), zeros(size(xAct,1),1)];
      vertices=get(it,'vertices');
      vertices(:,3)=z(:);
      N=size(x,1);
      faces=[];
      i=find(xAct & yAct);
      faces=[i i+1 i+N];
      i=find(xAct2 & yAct2);
      faces=[faces; i+1 i+N i+N+1];
      i=find(xAct2 & yAct & ~(xAct & yAct2));
      faces=[faces; i i+1 i+N+1];
      i=find(xAct & yAct2 & ~(xAct2 & yAct));
      faces=[faces; i i+N i+N+1];

      i=find(xAct & ~(yAct | yAct2 | [zeros(1,size(xAct,2)); yAct(1:end-1,1:end)] | [zeros(1,size(xAct,2)); yAct2(1:end-1,1:end)]));
      faces=[faces; i i i+N];
      i=find(yAct & ~(xAct | xAct2 | [zeros(size(yAct,1),1) xAct(1:end,1:end-1)] | [zeros(size(yAct,1),1) xAct2(1:end,1:end-1)]));
      faces=[faces; i i i+1];

      i=find(xAct|yAct|[zeros(1,size(xAct,2)); yAct(1:end-1,1:end)]|[zeros(size(yAct,1),1) xAct(1:end,1:end-1)]);
      fvc=NaN*zeros(size(z(:)));
      fvc(i)=c(i);
      set(it,'faces',faces, ...
             'vertices',vertices, ...
             'facevertexcdata',fvc);
    end;
  end;

end;  