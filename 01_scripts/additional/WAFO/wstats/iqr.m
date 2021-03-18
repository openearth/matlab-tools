function r = iqr(X,dim)
%IQR Computes the Inter Quartile Range
%
% CALL:  r = iqr(X,dim);
%
%        r = abs(diff(wquantile(X,[0.25 .75]))),
%        X = data vector or matrix
%      dim = dimension to sum across. (default 1'st non-singleton 
%                                              dimension of X)
% IQR is a robust measure of spread.
% The use of interquartile range guards against outliers if 
% the distribution have heavy tails.
%
% Example:
%   R=wgumbrnd(2,2,[],100,2);
%   iqr(R)
%
% See also  std

% Tested on: Matlab 5.3
% History:
% revised pab 24.10.2000

error(nargchk(1,2,nargin))
sz = size(X);
if nargin<2|isempty(dim),
  % Use 1'st non-singleton dimension or dimension 1
  dim = min(find(sz~=1)); 
  if isempty(dim), dim = 1; end
end

if dim~=1, 
  iorder=1:length(sz);
  tmp=iorder(dim);
  iorder(dim)=iorder(1);
  iorder(1)=tmp;
  X = permute(X,iorder);
end
r = abs(diff(wquantile(X,[0.25 0.75])));

if dim~=1, 
  iorder=1:length(sz);
  tmp=iorder(dim);
  iorder(dim)=iorder(1);
  iorder(1)=tmp;
  r=ipermute(r,iorder);
end


%sz(dim)=sz(dim);



