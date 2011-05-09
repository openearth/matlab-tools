function copy(h1)
% COPY Select an object and specify a target window / target axes for copying
if nargin<1,
  fprintf(1,'\nSelect an object.\n');
  waitforbuttonpress; h1=gco;
elseif size(h1)~=[1 1],
  fprintf(1,'\nScalar value expected as input argument.\n');
  return;
elseif ~ishandle(h1),
  fprintf(1,'\nInput argument should be a graphics object handle.\n');
  return;
end;
t1=get(h1,'type');
if strcmp(t1,'figure'),
  h2=copyprop(h1);
  s=' ';
  while ~any(s(1)=='YyNn'),
    s=input('Copy all children (Y/N) ? : ','s');
    if isempty(s), s=' '; end;
  end;
  if any(s(1)=='Yy'),
    a1=get(h1,'children');
    a2=copyprop(a1,h2);
    for i=1:length(a1), % axes or uicontrol objects
      c1=get(a1(i),'children');
      c2=copyprop(c1,a2(i));
    end;
  end;
elseif strcmp(t1,'axes'),
  fprintf(1,'Select a target figure.\n');
  waitforbuttonpress; h3=gco;
  if strcmp(get(h3,'type'),'axes'),
    s=' ';
    while ~any(s(1)=='YyNn'),
      s=input('Replace selected axes (Y/N) ? : ','s');
      if isempty(s), s=' '; end;
    end;
    h2=copyprop(h1,gcf);
    if any(s(1)=='Yy'),
      set(h3,'units',get(h2,'units'));
      set(h2,'position',get(h3,'position'));
      delete(h3);
    end;
  else,
    h2=copyprop(h1,gcf);
  end;
  t1=get(h1,'title');
  t2=get(h2,'title');
  copyprop(t1,t2);
  t1=get(h1,'xlabel');
  t2=get(h2,'xlabel');
  copyprop(t1,t2);
  t1=get(h1,'ylabel');
  t2=get(h2,'ylabel');
  copyprop(t1,t2);
  t1=get(h1,'zlabel');
  t2=get(h2,'zlabel');
  copyprop(t1,t2);
  s=' ';
  while ~any(s(1)=='YyNn'),
    s=input('Copy all children (Y/N) ? : ','s');
    if isempty(s), s=' '; end;
  end;
  if any(s(1)=='Yy'),
    c1=get(h1,'children');
    c2=copyprop(c1,h2);
  end;
else, % object in axes
  fprintf(1,'Select target axes.\n');
  axes(get(gco,'parent'));
  waitforbuttonpress; h2=gco;
  t2=get(h2,'type');
  if strcmp(t2,'figure'),
    axes;
  end;
  h2=copyprop(h1,gca);
end;