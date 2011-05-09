function [quad,varargout]=grid2quad(X,Y,Z),
% GRID2QUAD create quadrangle indices for a curvilinear grid
%       QUAD=GRID2QUAD(X,Y)
%       QUAD=GRID2QUAD(X,Y,Z)
%       where X and Y (and, optionally, Z) are matrices of the
%       same size, creates quadrangle indices for the grid cells
%       defined by the points X,Y of the curvilinear grid.
%       Quadrangles connected to points with undefined X/Y/Z
%       co-ordinates are removed from the full list.
%
%       [QUAD,J,XY]=GRID2QUAD(X,Y)
%       [QUAD,J,XYZ]=GRID2QUAD(X,Y,Z)
%       returns a matrix XY or XYZ containing the rearranged 
%       co-ordinates: [X(:) Y(:) Z(:)] and J is an index vector
%       for arrays that are one row and column smaller than X
%       and Y, such as arrays for flat shading.

error(nargchk(2,3,nargin))

szX=size(X);
I=reshape(1:prod(szX),szX);
I=I(1:end-1,1:end-1);
I=I(:);
szX1=size(X)-1;
J=reshape(1:prod(szX1),szX1);
J=J(:);

quad= [I I+1 I+szX(1)+1 I+szX(1)];

if nargin==2,
   k=any(isnan(X(quad)) | isnan(Y(quad)),2);
else
   k=any(isnan(X(quad)) | isnan(Y(quad)) | isnan(Z(quad)),2);
end
quad(k,:)=[];
J(k)=[];

varargout{1}=J;
if nargout>2
  if nargin==2
    varargout{2}=[X(:) Y(:)];
  else
    varargout{2}=[X(:) Y(:) Z(:)];
  end
end
