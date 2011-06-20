function [Cx,Cy]=geomcorr(varargin),
% GEOMCORR Function to assist geometric correction of data
%          [Cx,Cy] = geomcorr(Wx,Wy,p1Wx,p1Wy,p1Cx,p1Cy,p2Wx,p2Wy,p2Cx,p2Cy)
%          corrects the wrong points (Wx,Wy) based on two reference
%          displacements: (p1Wx,p1Wy) -> (p1Cx,p1Cy),
%                         (p2Wx,p2Wy) -> (p2Cx,p2Cy).
%          This correction uses translation, isotropic scaling, and rotation.
%
%          [Cx,Cy] = geomcorr(Wx,Wy,p1Wx,p1Wy,p1Cx,p1Cy)
%          corrects the wrong points (Wx,Wy) based on one reference
%          displacement: (p1Wx,p1Wy) -> (p1Cx,p1Cy),
%          This correction performs a translation only.
%
%          Pnts = geomcorr(axesHandle)
%          Interactively determine the p1Wx,p1Wy,p1Cx,p1Cy,p2Wx,p2Wy,p2Cx,p2Cy
%          coordinates. To be used in combination, like
%             Pnts = geomcorr(axesHandle);
%             [Cx,Cy] = geomcorr(Wx,Wy,Pnts{:})
%
%          Pnts = geomcorr(axesHandle,lineHandles)
%          Interactively determine the p1Wx,p1Wy,p1Cx,p1Cy,p2Wx,p2Wy,p2Cx,p2Cy
%          coordinates and applies the transformation to the specified line
%          objects.

% (c) July 12th, 1999, H.R.A. Jagers, wl | delft hydraulics, The Netherlands
% 15/3/2001: changed order of wrong/correct points from W1,W2,C1,C2 to W1,C1,W2,C2
%            added option for translation only.

switch nargin
case {1,2} % Pnts = geomcorr(axesHandle)
           % Pnts = geomcorr(axesHandle,lineHandles)
  axesHandle=varargin{1};
  fprintf('Select first wrong point   :  ');
  waitforbuttonpress;
  p1W=get(axesHandle,'currentpoint');
  p1W=p1W(1,1:2);
  fprintf('%20.8f %20.8f\n',p1W);
  fprintf('Select first correct point :  ');
  waitforbuttonpress;
  p1C=get(axesHandle,'currentpoint');
  p1C=p1C(1,1:2);
  fprintf('%20.8f %20.8f\n',p1C);
  fprintf('Select second wrong point  :  ');
  waitforbuttonpress;
  if strcmp(get(get(axesHandle,'parent'),'SelectionType'),'alt') % no second point
    fprintf('<none>\n');
    Cx={p1W(1) p1W(2) p1C(1) p1C(2)};
  else
    p2W=get(axesHandle,'currentpoint');
    p2W=p2W(1,1:2);
    fprintf('%20.8f %20.8f\n',p2W);
    fprintf('Select second correct point: ');
    waitforbuttonpress;
    p2C=get(axesHandle,'currentpoint');
    p2C=p2C(1,1:2);
    fprintf('%20.8f %20.8f\n',p2C);
    Cx={p1W(1) p1W(2) p1C(1) p1C(2) p2W(1) p2W(2) p2C(1) p2C(2)};
  end;
  if nargin==2
    lh=varargin{2};
    for i=1:length(lh)
      x=get(lh(i),'xdata');
      y=get(lh(i),'ydata');
      [xn,yn]=geomcorr(x,y,Cx{:});
      set(lh(i),'xdata',xn,'ydata',yn);
    end
  end
case {5,9},
  % geomcorr(lh,p1Wx,p1Wy,p1Cx,p1Cy)
  % geomcorr(lh,p1Wx,p1Wy,p1Cx,p1Cy,p2Wx,p2Wy,p2Cx,p2Cy)
  lh=varargin{1};
  for i=1:length(lh)
    x=get(lh(i),'xdata');
    y=get(lh(i),'ydata');
    [xn,yn]=geomcorr(x,y,varargin{2:end});
    set(lh(i),'xdata',xn,'ydata',yn);
  end
case 6, % [Cx,Cy] = geomcorr(Wx,Wy,p1Wx,p1Wy,p1Cx,p1Cy)
   % translation
  [Wx,Wy,p1Wx,p1Wy,p1Cx,p1Cy]=deal(varargin{:});
  Cx=p1Cx+Wx-p1Wx;
  Cy=p1Cy+Wy-p1Wy;
case 10, % [Cx,Cy] = geomcorr(Wx,Wy,p1Wx,p1Wy,p1Cx,p1Cy,p2Wx,p2Wy,p2Cx,p2Cy)
  % translation, rotation and scaling
  [Wx,Wy,p1Wx,p1Wy,p1Cx,p1Cy,p2Wx,p2Wy,p2Cx,p2Cy]=deal(varargin{:});
  Wdx=p2Wx-p1Wx;
  Wdy=p2Wy-p1Wy;
  Wangle=atan2(Wdy,Wdx);
  Wdist=sqrt(Wdy^2+Wdx^2);
  
  Cdx=p2Cx-p1Cx;
  Cdy=p2Cy-p1Cy;
  Cangle=atan2(Cdy,Cdx);
  Cdist=sqrt(Cdy^2+Cdx^2);
  
  Dangle=Cangle-Wangle;
  if Dangle>pi,
    Dangle=Dangle-pi;
  elseif Dangle<-pi,
    Dangle=Dangle+pi;
  end;
  Ddist=Cdist/Wdist;
  
  Cx=p1Cx+(cos(Dangle)*(Wx-p1Wx)-sin(Dangle)*(Wy-p1Wy))*Ddist;
  Cy=p1Cy+(cos(Dangle)*(Wy-p1Wy)+sin(Dangle)*(Wx-p1Wx))*Ddist;
otherwise
  error('Invalid number of input arguments.');
end;

if 0,
% based on three points
%
%  p1W=[p1Wx p2Wy]; etc
%  W = Nx2 wrong points matrix
  I=ones(size(W,1),1);
  v1W=p2W-p1W; v1W=transpose(v1W/norm(v1W));
  v2W=p3W-p1W; v2W=v2W-v2W*v1W; v2W=transpose(v2W/norm(v2W));
  lambda1=(W-I*p1W)*v1W;
  lambda2=(W-I*p1W)*v2W;

  v1C=p2C-p1C; v1C=v1C/norm(v1C);
  v2C=p3C-p1C; v2C=v2C-v2C*transpose(v1C); v2C=v2C/norm(v2C);
  C=I*p1C+lambda1*v1C+lambda2*v2C;

% general way given N reference points:
% 1) get a delaunay triangulation of those points
% 2) for all wrong points:
%      tsearch triangles in which they are contained, and
% 3) for points within the triangulated area (tri found):
%      correct position based on corrected positions of corner points
%        of those triangles as above
% 4) for points outside the triangulated area (tri is NaN):
%      find nearest point i on convex hull using dsearch and
%      find second nearest point j (either i-1 or i+1)
%      find triangle with both i and j as node
%      correct position based on corrected positions of corner points
%        of those triangles as above
% 5) all points done, return data
end;