function ok = poly_area_test(varargin)
%POLY_AREA_TEST   tst for poly_area
%
%  ok = poly_area_test()
%
% checks POLY_AREA for a single polygon 
% .. over a range of rotation angles
% .. and for change of sign when poly is reversed
%    (clockwise is positive)
%
%See also: POLY_AREA

OPT.disp = 0;
ok       = 1;
OPT.area = 1;

%% custom polygon
if nargin==2
  p0.x = varargin{1};r0.x = flipdim(p0.x,2);
  p0.y = varargin{2};r0.y = flipdim(p0.y,2);
  OPT.area = varargin{3};

%% default polygon
else
  p0.x = [0 1 0.5 1 0.5 0];r0.x = flipdim(p0.x,2);
  p0.y = [0 0 0.5 1 1.5 1];r0.y = flipdim(p0.y,2);
end

n   = 12; % number of angles probed
ang = linspace(0,360,n);

if OPT.disp
FIG = figure('name','poly_area_test');
end

for i=1:n

   p(i).x =  cosd(ang(i)).*p0.x + sind(ang(i)).*p0.y;
   p(i).y = -sind(ang(i)).*p0.x + cosd(ang(i)).*p0.y;

   r(i).x =  cosd(ang(i)).*r0.x + sind(ang(i)).*r0.y;
   r(i).y = -sind(ang(i)).*r0.x + cosd(ang(i)).*r0.y;

   p(i).area = poly_area(p(i).x,p(i).y);
   r(i).area = poly_area(r(i).x,r(i).y);

   % num2str(polyarea(p(i).x,p(i).y))
   % num2str(polyarea(r(i).x,r(i).y))
   
   if OPT.disp
      subplot(1,2,1)
      H(1) = patch(p(i).x,p(i).y,'r');
      axis equal
      grid on
      axis([-2 2 -2 2])
      title(['area = ',num2str(p(i).area)])

      subplot(1,2,2)
      H(2) = patch(r(i).x,r(i).y,'b');
      axis equal
      grid on
      axis([-2 2 -2 2])
      title(['area = ',num2str(r(i).area)])

      pausedisp
      set(H,'FaceColor',[.5 .5 .5])

   end % disp

end % i

try
   close(FIG)
end

if ~all(([p.area]-OPT.area)<10*eps)
   ok = 0;
end

if ~all(([r.area]+OPT.area)<10*eps)
   ok = 0;
end

%% EOF