function hout=cones(varargin)
%CONES  Coloured 3D cone plot.
%   CONES(X,Y,Z,U,V,W) plots velocity vectors as cones at the 
%   points (X,Y,Z) with velocities defined by U,V,W. CONEPLOT
%   automatically scales the cones to fit. It is usually best
%   to set the DataAspectRatio before calling CONEPLOT.
%   
%   CONES(U,V,W) assumes [X Y Z] = meshgrid(1:N, 1:M, 1:P)
%   where [M,N,P]=SIZE(U). 
%
%   CONES(...,C) colors the cones based on the specified data.
%   The size of C should be equal to that of the other datasets.
%
%   CONES(...,S) automatically scales the cones to fit and then
%   stretches them by S.  Use S=0 to plot the cones without the automatic
%   scaling.
%   
%   CONES(...,'quiver') draws arrows instead of cones (see QUIVER3).
%
%   H = CONES(...) returns a PATCH handle.
%   
%   See also CONES.

%   Edited by H.R.A. Jagers, WL | Delft Hydraulics, 20/7/2000
%   Based on CONEPLOT
%            Copyright (c) 1984-98 by The MathWorks, Inc.
%            $Revision$  $Date$

[m,n,p]=size(varargin{1}); 

[cx cy cz ui vi wi col s quiv method] = parseargs(nargin,varargin);

if isempty(s)
  s = 1;
elseif length(s)>1,
  error('S must be a scalar.');
end

% Take this out when other data types are handled
ui = double(ui);
vi = double(vi);
wi = double(wi);


if quiv
  gcfNP = get(gcf, 'nextplot');
  gcaNP = get(gca, 'nextplot');
  set(gcf,'NextPlot','add');
  set(gca,'NextPlot', 'add');
  
  h=quiver3(cx,cy,cz,ui,vi,wi,s);
  if ~isempty(col),
    h=colquiver(h,col);
  end;
  
  set(gcf, 'nextplot', gcfNP);
  set(gca, 'nextplot', gcaNP);
else
  if s,  % based on code from quiver3.m
    % Base autoscale value on average spacing in the x and y and z
    % directions.
    
    if min(size(cx))==1,
      n=sqrt(prod(size(cx)));
      m=n;
    else
      [m,n]=size(cx);
    end
    dx = diff([min(cx(:)) max(cx(:))]); 
    dy = diff([min(cy(:)) max(cy(:))]);
    dz = diff([min(cz(:)) max(cy(:))]);
    del = sqrt((dx/n).^2 + (dy/m).^2 + (dz/max(m,n)).^2);
    len = sqrt((ui/del).^2 + (vi/del).^2 + (wi/del).^2);
    autoscale = s * 0.9 / max(len(:));
    ui = ui*autoscale; vi = vi*autoscale; wi = wi*autoscale;
  end
  
  conesegments = 14;
  conewidth = .333;
  
  h = [];
  [faces verts] = conegeom(conesegments);
  numcones = size(cx,1);
  flen = size(faces,1);
  vlen = size(verts,1);
  faces = repmat(faces, numcones,1);
  verts = repmat(verts, numcones,1);
  offset = floor([0:flen*numcones-1]/flen)';
  faces = faces+repmat(vlen*offset,1,3);
  
  dar = [];
  f = get(0, 'currentfigure');
  if ~isempty(f)
    ax = get(f, 'currentaxes');
    if ~isempty(ax) &  strcmp(get(ax, 'dataaspectratiomode'), 'manual')
      dar = get(ax, 'dataaspectratio');
    end
  end
  
  if isempty(dar)
    dar = [dx dy dz];
  end
  
  dar = dar/max(dar);
  
  for i = 1:size(cx,1)
    index = (i-1)*vlen+1:i*vlen;
    len = norm([ui(i),vi(i),wi(i)]);
    verts(index,3) = verts(index,3) * len;
    verts(index,1:2) = verts(index,1:2) * len*conewidth;
    
    verts(index,:) = coneorient(verts(index,:),  [ui(i),vi(i),wi(i)]);
    
    verts(index,1) = dar(1)*verts(index,1) + cx(i);
    verts(index,2) = dar(2)*verts(index,2) + cy(i);
    verts(index,3) = dar(3)*verts(index,3) + cz(i);
  end
  
  h = patch('faces', faces, 'vertices', verts);
  if ~isempty(col),
    col=repmat(transpose(col),42,1);
    set(h,'facevertexcdata',col(:),'facecolor','flat','edgecolor','none');
  end;
end

if nargout>0 
  hout = h;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, y, z, u, v, w, c, s, quiv, method] = parseargs(nin, vargin)

x = [];
y = [];
z = [];
u = [];
v = [];
w = [];
c = [];
s = [];
method = [];
quiv = 0;

for j=1:nin,
  if ischar(vargin{j}),
    str=lower(vargin{j});
    if ~isempty(strmatch(str,'quiver')),
      quiv = 1;
    else,
      method = str;
    end;
  else, % ~ischar
    if isempty(u),
      u = vargin{j};
    elseif isempty(v),
      v = vargin{j};
    elseif isempty(w),
      w = vargin{j};
    elseif isequal(size(vargin{j}),size(u)) & isempty(c),
      c = vargin{j};
    elseif isequal(size(vargin{j}),size(u)) & isempty(x),
      x = u; y = v; z = w; u = c; v = vargin{j}; w = []; c = [];
    elseif ~isequal(size(vargin{j}),[1 1]),
      warning(sprintf('Cannot interpret input argument %i',j));
      keyboard
    else,
      s = vargin{j};
    end;
  end;
end;  
for j=1:2
  if nin>0
    lastarg = vargin{nin};
    if isstr(lastarg) % coneplot(...,'method'),  coneplot(...,'quiver')
      if ~isempty(lastarg)
	lastarg = lower(lastarg);
	if lastarg(1)=='q'
	  quiv = 1;
	else
	  method = lastarg;
	end
      end
      nin = nin - 1;
    end
  end
end

if isempty(w),
  error('Wrong number of input arguments.'); 
end

if isempty(x),
  [M,N,P] = size(u);
  [x,y,z] = meshgrid(1:N, 1:M, 1:P);
end;

x = x(:); 
y = y(:); 
z = z(:); 
u = u(:); 
v = v(:); 
w = w(:); 
c = c(:);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [f, v] = conegeom(coneRes)

cr = coneRes;
[xx yy zz]=cylinder([.5 0], cr);
f = zeros(cr*2-2,3);
v = zeros(cr*3,3);
v(1     :cr  ,:) = [xx(2,1:end-1)' yy(2,1:end-1)' zz(2,1:end-1)'];
v(cr+1  :cr*2,:) = [xx(1,1:end-1)' yy(1,1:end-1)' zz(1,1:end-1)'];
v(cr*2+1:cr*3,:) = v(cr+1:cr*2,:);

f(1:cr,1) = [cr+2:2*cr+1]';
f(1:cr,2) = f(1:cr,1)-1;
f(1:cr,3) = [1:cr]';
f(cr,1) = cr+1;
f(cr+1:end,1) = 2*cr+1;
f(cr+1:end,2) = [2*cr+2:3*cr-1]';
f(cr+1:end,3) = f(cr+1:end,2)+1;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vout=coneorient(v, orientation)
cor = [-orientation(2) orientation(1) 0];
if sum(abs(cor(1:2)))==0
  if orientation(3)<0
    vout=rotategeom(v, [1 0 0], 180);
  else
    vout=v;
  end
else
  a = 180/pi*asin(orientation(3)/norm(orientation));
  vout=rotategeom(v, cor, 90-a);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vout=rotategeom(v,azel,alpha)
u = azel(:)/norm(azel);
alph = alpha*pi/180;
cosa = cos(alph);
sina = sin(alph);
vera = 1 - cosa;
x = u(1);
y = u(2);
z = u(3);
rot = [cosa+x^2*vera x*y*vera-z*sina x*z*vera+y*sina; ...
      x*y*vera+z*sina cosa+y^2*vera y*z*vera-x*sina; ...
      x*z*vera-y*sina y*z*vera+x*sina cosa+z^2*vera]';

x = v(:,1);
y = v(:,2);
z = v(:,3);

[m,n] = size(x);
newxyz = [x(:), y(:), z(:)];
newxyz = newxyz*rot;
newx = reshape(newxyz(:,1),m,n);
newy = reshape(newxyz(:,2),m,n);
newz = reshape(newxyz(:,3),m,n);

vout = [newx newy newz];
