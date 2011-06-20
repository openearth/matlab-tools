function [tri,varargout]=grid2tri(X,Y,Z,option),
% GRID2TRI converts a curvilinear grid into a triangular grid
%       tri=grid2tri(X,Y);
%       [tri,XY]=grid2tri(X,Y);
%       tri=grid2tri(X,Y,Z);
%       [tri,XYZ]=grid2tri(X,Y,Z);
%       inserts always the same diagonal
%
%       ...=grid2tri(X,Y,Z,'highdiag')
%       inserts the diagonal with the highest average
%
%       ...=grid2tri(X,Y,Z,'lowdiag')
%       inserts the diagonal with the lowest average

error(nargchk(2,4,nargin))

szX=size(X);
[m,n]=ndgrid(1:szX(1),1:szX(2));
I=reshape(1:prod(szX),szX);
I=I(1:end-1,1:end-1);
I=I(:);

if (nargin==2) | (nargin==3),
   tri= [I I+1 I+szX(1)+1; I I+szX(1) I+szX(1)+1];
   mtri= [m(I);m(I)];
   ntri= [n(I);n(I)];
elseif (nargin==4),
  if strcmp(option,'highdiag'),
    HighDiag=(Z(I)+Z(I+szX(1)+1))<(Z(I+1)+Z(I+szX(1)));
    tri= [I I+1 I+szX(1)+1-HighDiag; I+HighDiag I+szX(1)+HighDiag I+szX(1)+1-HighDiag];
   mtri= [m(I);m(I)];
   ntri= [n(I);n(I)];
  elseif strcmp(option,'lowdiag'),
    LowDiag=(Z(I)+Z(I+szX(1)+1))>(Z(I+1)+Z(I+szX(1)));
    tri= [I I+1 I+szX(1)+1-LowDiag; I+LowDiag I+szX(1)+LowDiag I+szX(1)+1-LowDiag];
   mtri= [m(I);m(I)];
   ntri= [n(I);n(I)];
  else,
    error('Invalid option.');
  end;
end;

k=any(isnan(X(tri)) | isnan(Y(tri)),2);
tri(k,:)=[];

if nargout==2,
  if nargin==2,
    varargout{1}=[X(:) Y(:)];
  else,
    varargout{1}=[X(:) Y(:) Z(:)];
 end;
elseif nargout==3,
mtri(k)=[];
ntri(k)=[];
   varargout={mtri,ntri};
end;
