function k = wkurtosis(X,dim)
%WKURTOSIS Computes sample kurtosis
%
% CALL:  k = wkurtosis(X,dim);
%
%        k = sample kurtosis (fourth central moment divided by squared second)
%        X = data vector or matrix
%      dim = dimension to sum across. (default 1'st non-singleton 
%                                              dimension of X)
%
% Example:  
%   R=wgumbrnd(2,2,100,2);
%   wkurtosis(R)
%
% See also  wskewness, mean, var

% Tested on: Matlab 5.3
% History:
% revised pab 24.10.2000
% - made it more general: accepts any size of X
% - added dim, nargchk
% added ms 16.06.2000

error(nargchk(1,2,nargin))
sz = size(X);
if nargin<2|isempty(dim)
  % Use 1'st non-singleton dimension or dimension 1
  dim = min(find(sz~=1)); 
  if isempty(dim), dim = 1; end
end
rsz = ones(size(sz)); rsz(dim)=sz(dim);
mu  = mean(X);
mu  = repmat(mu,rsz);
k   = mean((X-mu).^4,dim)./mean((X-mu).^2,dim).^2;







