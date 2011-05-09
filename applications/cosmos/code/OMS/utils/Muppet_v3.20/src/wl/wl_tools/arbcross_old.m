function [varargout]=arbcross(XG,YG,varargin)
%ARBCROSS Arbitrary cross-section through grid
%     [X,Y,V]=ARBCROSS(XGRID,YGRID,VGRID,XB,YB)
%     Creates appropriate coordinates X,Y based
%     on a grid XGRID,YGRID and base points for
%     a cross-section and interpolates the data
%     VGRID defined on the grid to these points
%     giving V.

if nargin<5
   error('Too few input arguments.');
elseif nargout+2~=nargin
   error('Number of input arguments does not match number of output arguments.');
end
varargout=cell(1,nargout);

tri=grid2tri(XG,YG);

X=varargin{end-1};
Y=varargin{end};
[x,y]=int_lngrd(X,Y,XG,YG);

varargout{1}=x;
varargout{2}=y;
[varargout{3:nargout}]=trivalue(tri,XG,YG,varargin{1:(nargout-2)},x,y);