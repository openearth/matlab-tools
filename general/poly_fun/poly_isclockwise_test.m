function ok = poly_isclockwise_test(varargin)
%POLY_ISCLOCKWISE_TEST   tst for poly_isclockwise
%
%  ok = poly_isclockwise_test()
%
%See also: POLY_AREA

OPT.disp = 0;
ok       = 1;
OPT.area = 1;

%% custom polygon
if nargin==2
  p.x = varargin{1};r.x = flipdim(p.x,2);
  p.y = varargin{2};r.y = flipdim(p.y,2);
  OPT.area = varargin{3};

%% default polygon
else
  p(1).x = [0 2 2 0]-1;r(1).x = flipdim(p(1).x,2);
  p(1).y = [0 0 2 2]-1;r(1).y = flipdim(p(1).y,2);
  p(2).x = [1  0  0 -2  1];r(2).x = flipdim(p(2).x,2);
  p(2).y = [0  1 -2  0  0];r(2).y = flipdim(p(2).y,2);
  p(3).x = [2  0  0 -1  2];r(3).x = flipdim(p(3).x,2);
  p(3).y = [0  2 -1  0  0];r(3).y = flipdim(p(3).y,2);
end

if OPT.disp
FIG = figure('name','poly_area_test');
end

for i=1:length(p)

   p(i).iscw = poly_isclockwise(p(i).x,p(i).y);
   r(i).iscw = poly_isclockwise(r(i).x,r(i).y);
   
   if OPT.disp
   
      subplot(1,2,1)
      if p(i).iscw; c = 'r'; else c = 'b'; end
      H(1) = patch  (p(i).x   ,p(i).y   ,c);hold on
      T{1} = plot   (p(i).x   ,p(i).y   ,'-k','linewidth',2);
      T{2} = plot   (p(i).x(1),p(i).y(1),'ok','linewidth',2);
             u = p(i).x(end)-p(i).x(end-1);
             v = p(i).y(end)-p(i).y(end-1);
      T{3} = quiver2(p(i).x(end-1),p(i).y(end-1),u,v,.75,'k');
      axis equal
      grid on
      axis([-2 2 -2 2])
      title(['clockwise = ',num2str(p(i).iscw)])
   
      subplot(1,2,2)
      if r(i).iscw; c = 'r'; else c = 'b'; end
      H(2) = patch  (r(i).x   ,r(i).y   ,c);hold on
      T{4} = plot   (r(i).x   ,r(i).y   ,'-k','linewidth',2);
      T{5} = plot   (r(i).x(1),r(i).y(1),'ok','linewidth',2);
             u = r(i).x(end)-r(i).x(end-1);
             v = r(i).y(end)-r(i).y(end-1);
      T{6} = quiver2(r(i).x(end-1),r(i).y(end-1),u,v,.75,'k');
      axis equal	
      grid on
      axis([-2 2 -2 2])
      title(['clockwise = ',num2str(r(i).iscw)])
   
      pausedisp
      set(H,'FaceColor',[.5 .5 .5])
      delete(T{:})

   end % disp

end % i

try
   close(FIG)
end

if ~isequal([p.iscw],[0 1 0])
   ok = 0;
end


if ~isequal([r.iscw],[1 0 1])
   ok = 0;
end

%% EOF