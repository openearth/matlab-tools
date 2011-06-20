function [varargout]=trivalue(TRI,X,Y,varargin);
%TRIVALUE interpolates data given a triangulation
%    ZI = TRIVALUE(TRI,X,Y,Z,XI,YI)
%    If the size of Z equals the size of X, TRIVALUE interpolates this
%    surface at the points specified by (XI,YI) to produce ZI.  The
%    surface always goes through the data points. "interpolated shading"
%
%    If Z is a vector of the length of size(TRI,1), TRIVALUE determines
%    the triangles in which the points (XI,YI) lie and assigns the
%    corresponding values to ZI. "flat shading"
%    Note: points on the boundary of two triangles get assigned the
%    value of one of the triangles.
%
%    [ZI1,ZI2,...] = TRIVALUE(TRI,X,Y,Z1,Z2,...,XI,YI)
%    Support for multiple datasets.
%
%    Contrary to GRIDDATA this function does not compute a
%    Delaunay triangulation of the grid, but it uses the triangulation
%    specified by TRI.
%
%    See also: GRIDDATA, DELAUNAY, TRIMESH, GRID2TRI

% (c) Copyright 1997-2000, H.R.A.Jagers, Delft Hydraulics, The Netherlands

if (nargin~=nargout+5) & (nargin~=3 | nargout~=0)
   error('Number of input arguments does not match number of output arguments.')
elseif nargout==0 & nargin==3
   N=1;
else
   N=nargout;
end
X=X(:);
Y=Y(:);
Xi=varargin{N+1}; 
Yi=varargin{N+2};
szXi=size(Xi);
Xi=Xi(:);
Yi=Yi(:);
T = tsearchsafe(X,Y,TRI,Xi,Yi);
I=~(isnan(T(:)) | T(:)==0);
varargout=cell(1,nargout);
TRITI=TRI(T(I),:);
dX21=X(TRITI(:,2))-X(TRITI(:,1));
dY21=Y(TRITI(:,2))-Y(TRITI(:,1));
dX31=X(TRITI(:,3))-X(TRITI(:,1));
dY31=Y(TRITI(:,3))-Y(TRITI(:,1));
Det=dX21.*dY31-dY21.*dX31;
if any(I),
   for i=1:nargout
      Z=varargin{i}; Z=Z(:);
      Zi=repmat(NaN,szXi);
      if isequal(size(Z),size(X))
         dZ21=Z(TRITI(:,2))-Z(TRITI(:,1));
         dZ31=Z(TRITI(:,3))-Z(TRITI(:,1));
         Alpha=(dZ21.*dY31-dZ31.*dY21)./Det;
         Beta=(-dZ21.*dX31+dZ31.*dX21)./Det;
         Zi(I)=Z(TRITI(:,1)) ...
            + Alpha.*(Xi(I)-X(TRITI(:,1))) ...
            + Beta.*(Yi(I)-Y(TRITI(:,1)));
      elseif isequal(size(Z),[size(TRI,1) 1]) | isequal(size(Z),[1 size(TRI,1)])
         Zi(I)=Z(T(I));
      else
         error('Invalid size of Z')
      end
      varargout{i}=Zi;
   end
end;
I=(T(:)==0);
if any(I),
   warning('Some points on boundary: no data assigned!');
end;