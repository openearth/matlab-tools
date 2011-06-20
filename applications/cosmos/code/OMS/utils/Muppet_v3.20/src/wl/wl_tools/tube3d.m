function [OUT1,OUT2,OUT3,OUT4]=tube3d(x,y,z,r,c,N);
% TUBE3D plots a tube in 3D space
%        TUBE3D(X,Y,Z)
%        plots a tube of radius one through the specified
%        points (X,Y,Z) where X, Y and Z are the coordinates
%        of the centerline of the tube. If X, Y and Z are
%        matrices. The columns form the centerlines of separate
%        tubes, but all data is stored in one surface object.
%        TUBE3D(X,Y,Z,R)
%        plots a tube of nonuniform radius R through the
%        specified points (X,Y,Z). The radius R should be either
%        a scalar or a matrix of equal size as X, Y and Z.
%        The default radius is 1.
%        TUBE3D(X,Y,Z,R,C)
%        plots a tube of varying radius R through the
%        specified points (X,Y,Z). The color C should be a scalar,
%        a matrix of equal size as X, Y and Z, or an RGB triplet.
%        Default coloring is based on Z value of the specified
%        centerline of the tubes.
%        TUBE3D(X,Y,Z,R,C,N)
%        The circular cross-section of the tube is approximated
%        using N points. By default TUBE3D uses 20 points.
%        H=TUBE3D(...)
%        returns the handle to the created surface object.
%        [X,Y,Z]=TUBE3D(...)
%        returns the surface coordinates. Does not plot the tube!
%        [X,Y,Z,C]=TUBE3D(...)
%        returns the surface coordinates and the color. Does not
%        plot the tube!
%
%        TUBE3D without any arguments gives two examples

% (c) copyright 1998-2000  H.R.A.Jagers
%                          WL | Delft Hydraulics / University of Twente,
%                          The Netherlands
%                          bert.jagers@wldelft.nl

if nargin==0, % two examples
  figure;
  subplot(1,2,1);
  t=0:.1:10;
  tube3d(t,sin(t),cos(t),t,t);
  shading interp
  lighting phong
  light
  axis off
  view([-53 28]);
  subplot(1,2,2);
  t=0:.1:9;
  tube3d(5*cos(t),t.*sin(t),3*sin(.25*t));
  view([170 80]);
  axis off
  rotate3d;
  return;
end;

if nargin<5,
  if nargin<3,
    error('At least three input arguments expected');
  elseif nargin==3,
    r=1;
  end;
  c=z;
end;

if size(x,1)==1, % row vector
  if ~isequal(size(x),size(y)) | ~isequal(size(x),size(z)) ...
    error('coordinate vectors of unequal length');
  end;
  if isequal(size(r),[1 1]), % scalar radius = uniform radius
    r=repmat(r,size(x));
  elseif ~isequal(size(x),size(r)) ...
    error('size of radius data does not match size of coordinate vectors');
  end;
  if ischar(c), % character color = uniform color
  elseif isequal(size(c),[1 1]), % scalar color = uniform color
    c=repmat(c,size(x));
  elseif isequal(size(c),[1 3]), % RGB triplet = uniform color
    if isequal(size(x),[1 3]),
      if all(c<=1) & all(c>=0),
        C=c;
        c='true color';
        warning('Color triplet interpreted as true color RGB specification.');
      else,
        % Non RGB triplet
      end;
    else,
      C=c;
      c='true color';
    end;
  elseif ~isequal(size(x),size(c)) ...
    error('size of color data size does not match size of coordinate vectors');
  end;
else,
  Multi=size(x,2)>1; % multiple columns -> combine to one row
  if ~isequal(size(x),size(y)) | ~isequal(size(x),size(z)) ...
    error('coordinate data of unequal size');
  end;
  if isequal(size(r),[1 1]), % scalar radius = uniform radius
    if Multi,
      r=repmat(r,1,prod(size(x)+[1 0])); % continue over NaN's
    else,
      r=repmat(r,1,size(x,1));
    end;
  elseif ~isequal(size(x),size(r)) ...
    error('size of radius data does not match size of coordinate data');
  else,
    % make row vector
    if Multi,
      r=[r; ones(1,size(r,2))];
      r=r(:)';
    else,
      r=r';
    end;
  end;
  if ischar(c), % character color = uniform color
    if ~isequal(size(c),[1 1]) | isempty(findstr('rgbmcywk',lower(c))),
      error('invalid color specification');
    else,
      RGB=[1 0 0; 0 1 0 ; 0 0 1; 1 0 1; 0 1 1; 1 1 0; 1 1 1; 0 0 0];
      C=RGB(findstr('rgbmcywk',lower(c)),:);
      c='true color';
    end;
  elseif isequal(size(c),[1 1]), % scalar color = uniform color
    % make row vectors
    if Multi,
      c=repmat(c,1,prod(size(x)+[1 0])); % continue over NaN's
    else,
      c=repmat(c,1,size(x,1));
    end;
  elseif isequal(size(c),[1 3]), % RGB triplet = uniform color
    C=c;
    c='true color';
  elseif ~isequal(size(x),size(c)) ...
    error('size of color data size does not match size of coordinate data');
  else,
    % make row vector
    if Multi,
      c=[c; ones(1,size(c,2))];
      c=c(:)';
    else,
      c=c';
    end;
  end;
  % make row vectors
  if Multi,
    x=[x; repmat(NaN,1,size(x,2))];
    x=x(:)';
    y=[y; repmat(NaN,1,size(y,2))];
    y=y(:)';
    z=[z; repmat(NaN,1,size(z,2))];
    z=z(:)';
  else,
    x=x';
    y=y';
    z=z';
  end;
end;
  
if nargin<6,
  N=20;
else,
  if ~isnumeric(N) | ~isequal(size(N),[1 1]) ...
     | round(N(1))~=N(1) | N(1)<=0,
    error('input arguments six should be a positive integer');
  end;
end;

P=[x;y;z];

s=[[0;0;0] P(:,2:end)-P(:,1:(end-1))];
s(:,1)=s(:,2);
norm_s=sqrt(sum(s.^2,1));
norm_s(logical(norm_s==0))=1;
s=s./(ones(3,1)*norm_s);

n1=zeros(size(s));
n2=zeros(size(s));

% n1 and n3 normal directions
% n1 'x' direction
% n2 'y' direction

NEW_segment=1;
i=1;
while i<=size(s,2),
  if NEW_segment==1,
    if isnan(s(:,i)) & (i<size(s,2))
      s(:,i)=s(:,i+1);
    end;
    if ~isnan(s(:,i)),
      if (s(1,i)==0) & (s(2,i)==0),
        if (s(3,i)==0),
          n1(:,i)=[0;0;0];
          n2(:,i)=[0;0;0];
        else,
          n1(:,i)=[1;0;0];
          n2(:,i)=cross(n1(:,i),s(:,i));
          n2(:,i)=n2(:,i)/norm(n2(:,i));
          NEW_segment=0;
        end;
      else,
        n1(:,i)=[-s(2,i);s(1,i);0];
        n1(:,i)=n1(:,i)/norm(n1(:,i));
        n2(:,i)=cross(n1(:,i),s(:,i));
        n2(:,i)=n2(:,i)/norm(n2(:,i));
        NEW_segment=0;
      end;
    else,
    end;
  else,
    if i<size(s,2),
      S=(s(:,i)+s(:,i+1))/2;
      if isnan(norm(S)),
        if isnan(norm(s(:,i+1))),
          NEW_segment=1;
          S=s(:,i);
        else,
          S=s(:,i+1);
        end;
      end;
    else,
      S=s(:,i);
    end;
    if norm(S)~=0,
      alpha=-dot(n1(:,i-1),S)/norm(S)^2;
      n1(:,i)=n1(:,i-1)+alpha*S;
      n1(:,i)=n1(:,i)/norm(n1(:,i));
  
      alpha=-dot(n2(:,i-1),S)/norm(S)^2;
      n2(:,i)=n2(:,i-1)+alpha*S;
      n2(:,i)=n2(:,i)/norm(n2(:,i));
    else,
      i=i-1;
      NEW_segment=1;
    end;
  end;
  i=i+1;
end;

theta=(0:1/N:1)*2*pi;
circlex=transpose(cos(theta));
circley=transpose(sin(theta));
pos_ones=ones(size(circlex));

X=circlex*(r.*n1(1,:))+circley*(r.*n2(1,:))+pos_ones*P(1,:);
Y=circlex*(r.*n1(2,:))+circley*(r.*n2(2,:))+pos_ones*P(2,:);
Z=circlex*(r.*n1(3,:))+circley*(r.*n2(3,:))+pos_ones*P(3,:);

if ischar(c),
  if strcmp(c,'true color'),
    C=repmat(reshape(C,[1 1 3]),size(X));
  end;
else,
  C=pos_ones*c;
end;

switch nargout,
case 0,
  TempH=surf(X,Y,Z,C);
  set(get(TempH,'parent'),'dataaspectratio',[1 1 1]);
case 1,
  TempH=surf(X,Y,Z,C);
  set(get(TempH,'parent'),'dataaspectratio',[1 1 1]);
  OUT1=TempH;
case 3,
  OUT1=X;
  OUT2=Y;
  OUT3=Z;
case 4,
  OUT1=X;
  OUT2=Y;
  OUT3=Z;
  OUT4=C;
end;