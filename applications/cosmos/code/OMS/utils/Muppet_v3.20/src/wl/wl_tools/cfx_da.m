function varargout=cfx_da(DMP,varargin),
% CFX_DA Obtain depth-averaged data from CFX dump file.
%
%     [V1,V2,...]=cfx_da(DMP,'V-NAME1','V-NAME2',...)
%     [X,Y,V1,V2,...]=cfx_da(DMP,'V-NAME1','V-NAME2',...)


if nargin<2,
  error('not enough input arguments');
end;

XYcoord=0;
if nargout==nargin+1, % X,Y, V1,V2,V3, ...
  XYcoord=1;
elseif nargout==nargin-1,
else,
  error('Number of output arguments does not match number of input arguments.');
end;

X=cfx('read',DMP,'X COORDINATES');
Y=cfx('read',DMP,'Y COORDINATES');
Z=cfx('read',DMP,'Z COORDINATES');

up=zeros(size(X));

for i=1:length(X),
  C=ones(2,2,2)/4;
  if (X{i}(1)==X{i}(end,1,1)) & (Y{i}(1)==Y{i}(end,1,1)),
    up(i)=1;
    C(2,:,:)=-1/4;
    X{i}=squeeze(X{i}(1,:,:));
    Y{i}=squeeze(Y{i}(1,:,:));
  elseif (X{i}(1)==X{i}(1,end,1)) & (Y{i}(1)==Y{i}(1,end,1)),
    up(i)=2;
    C(:,2,:)=-1/4;
    X{i}=squeeze(X{i}(:,1,:));
    Y{i}=squeeze(Y{i}(:,1,:));
  elseif (X{i}(1)==X{i}(1,1,end)) & (Y{i}(1)==Y{i}(1,1,end)),
    up(i)=3;
    C(:,:,2)=-1/4;
    X{i}=X{i}(:,:,1);
    Y{i}=Y{i}(:,:,1);
  else,
    error(sprintf('Block %i has no exactly vertical direction',i));
  end;
  Z{i}=convn(Z{i},C,'valid'); % compute average cell heights
end;


vu=0;
varargout=cell(1,nargout);
if XYcoord,
  varargout{1}=X;
  varargout{2}=Y;
  vu=2;
end;
for vi=1:length(varargin),
  vu=vu+1;
  V=cfx('read',DMP,varargin{vi});
  for i=1:length(V),
    V{i}=squeeze(sum(Z{i}.*V{i},up(i)));
  end;
  varargout{vu}=V;
end;

