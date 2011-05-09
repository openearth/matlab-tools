function varargout=surfintp(varargin),
% SURFINTP Linear interpolates a quadrangles based surface.
%
%     [An,Bn,Cn,...]=SURFINTP(Ao,Bo,Co,...,N) adds (N-1) rows
%          between every two rows, and adds (N-1) columns between
%          every two columns of the matrices Ao,Bo,Co, ...
%          The new values are obtained by linearly interpolating
%          the old values.
%
%     [An,Bn,Cn,...]=SURFINTP(Ao,Bo,Co,...,N,M) adds (N-1) rows
%          between every two rows, and adds (M-1) columns between
%          every two columns. The new values are obtained by
%          linearly interpolating the old values.

% (c) copyright 2000: H.R.A. Jagers
%                     WL | Delft Hydraulics, The Netherlands
%                     bert.jagers@wldelft.nl

NMat=nargin;
K=nargin-max(1,nargout);
if nargin<2,
  error('Not enough input arguments.');
elseif K<=0,
  error('Too many output arguments.');
elseif K>2,
  error('Not enough output arguments.');
elseif K==1,
  n=varargin{end};
  m=n;
  NMat=NMat-1;
else, % K==2
  n=varargin{end-1};
  m=varargin{end};
  NMat=NMat-2;
end;

varargout=cell(NMat,1);
for i=1:NMat,
  varargout{i}=LocalInterp(varargin{i},n,m);
end;



function Xn=LocalInterp(X,n,m);
% interpolation core routine

% uses Xn=Xo+N*diff(X) for increasing X with n interpolated rows/columns

% interpolate in column direction
if (size(X,1)>1) & (n>0),

  % compute interpolation factors N
  N=(0:n-1)/n;

  % select offsets Xo
  Xo=X(1:end-1,:);
  
  % preallocate Xn and copy last row
  Xn=ones(size(Xo).*[n 1]+[1 0]);
  Xn(end,:)=X(end,:);
  
  % prepare "Tony's trick" for offsets
  ind=1:size(Xo,1);
  ind=ind(ones(n,1),:);
  
  % compute interpolation using matrix indexing (ind is matrix)
  % for offsets and kronecker product for interpolation
  Xn(1:end-1,:)=Xo(ind,:)+kron(diff(X),N');
  
  % copy original values (to solve border problems when dealing
  % with NaNs)
  Xn(1:n:end,:)=X;
  X=Xn;

end;

% interpolate in row direction
if (size(X,2)>1) & (m>0),

  % compute interpolation factors M
  M=(0:m-1)/m;

  % select offsets Xo
  Xo=X(:,1:end-1);
  
  % preallocate Xn and copy last column
  Xn=ones(size(Xo).*[1 m]+[0 1]);
  Xn(:,end)=X(:,end);
  
  % prepare "Tony's trick" for offsets
  ind=1:size(Xo,2);
  ind=ind(ones(m,1),:);
  
  % compute interpolation using matrix indexing (ind is matrix)
  % for offsets and kronecker product for interpolation
  Xn(:,1:end-1)=Xo(:,ind)+kron(diff(X,1,2),M);

  % copy original values (to solve border problems when dealing
  % with NaNs)
  Xn(:,1:m:end)=X;

else,
  Xn=X;
end;