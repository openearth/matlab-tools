function NormPos=getnormpos(fig),
% GETNORMPOS Select an area (using normalized units)
%
%       NormPos=GETNORMPOS(FigHandle)
%       if skipped FigHandle is replaced by GCF
 
  if nargin==0,
    fig=gcf;
  end;
  tmpax=axes('parent',fig,'visible','off','units','normalized','position',[0 0 1 1]);
  hvis=get(fig,'handlevisibility');
  set(fig,'handlevisibility','on');
  figure(fig);
  ginput(1);
  Point1 = get(tmpax,'currentpoint');
  Point1 = Point1(1,1:2);
  units = get(fig,'units'); set(fig,'units','pixels')
  rbbox([get(fig,'currentpoint') 0 0],get(fig,'currentpoint'));
  Point2 = get(tmpax,'currentpoint');
  Point2 = Point2(1,1:2);
  set(fig,'units',units);
  LowerLeft=min(Point1,Point2);
  UpperRight=max(Point1,Point2);
  NormPos=[LowerLeft UpperRight-LowerLeft];
  set(fig,'handlevisibility',hvis);
  delete(tmpax);
