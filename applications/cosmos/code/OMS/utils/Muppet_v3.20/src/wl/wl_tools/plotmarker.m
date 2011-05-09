function [out1,out2]=plotmarker(xm,ym,x,y,varargin),
%PLOTMARKER Plot curstom marker at various locations.
%     PLOTMARKER(xMarker,yMarker,xLoc,yLoc,S)
%     plots at every position specified by (xLoc,yLoc)
%     the marker of the shape (xMarker,yMarker) scaled by
%     by a factor S. S must be either a scalar or a matrix
%     of the same size as xLoc and yLoc (default 1). The
%     marker shape can be either a simple polygon or
%     multiple polygons compatible with:
%       PATCH(xMarker,yMarker,1)
%
%     PLOTMARKER(...,'Propname',PropValue)
%     passes properties to the patch object.
%
%     H=PLOTMARKER(...)
%     returns a handle to the created patch object.
%
%     [X,Y]=PLOTMARKER(...)
%     does not plot, but returns the X and Y coordinates
%     needed for plotting (optional properties are ignored).

% (c) Copyright, 16-5-2000 H.R.A. Jagers
%                WL | Delft Hydraulics, The Netherlands
%                bert.jagers@wldelft.nl


if ~isequal(size(xm),size(ym)),
  error('X and Y shapes of markers are of different size');
end;

if (nargin>4),
  if ~ischar(varargin{1}),
    scale=varargin{1};
    options=varargin(2:end);
  else,
    scale=1;
    options=varargin;
  end;
else,
  scale=1;
  options={};
end;

% xm and ym should not be row vectors
if size(xm,1)==1,
  xm=xm(:);
  ym=ym(:);
end;

% apply scale if scalar
if isequal(size(scale),[1 1]),
  xm=xm*scale;
  ym=ym*scale;
  scale=[];
end;

if ~isequal(size(x),size(y)) | ~( isequal(size(x),size(scale)) | isempty(scale) ),
  error('X and Y marker locations are of different size');
end;

% x, y and scale should be row vectors
x=x(:)';
y=y(:)';
scale=scale(:)';

if isempty(scale),
  xm=repmat(xm,1,length(x))+reparray(x,size(xm),[1 1]);
  ym=repmat(ym,1,length(x))+reparray(y,size(ym),[1 1]);
else,
  scale=reparray(scale,size(xm),[1 1]);
  xm=repmat(xm,1,length(x)).*scale+reparray(x,size(xm),[1 1]);
  ym=repmat(ym,1,length(x)).*scale+reparray(y,size(ym),[1 1]);
end;

switch nargout,
case 0,
  patch(xm,ym,1,options{:});
case 1,
  out1=patch(xm,ym,1,options{:});
case 2,
  out1=xm;
  out2=ym;
end;

