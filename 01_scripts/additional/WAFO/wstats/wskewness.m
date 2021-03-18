function s = wskewness(X,dim)
%WSKEWNESS Computes sample skewness
%
% CALL:  k = wskewness(X,dim);
%
%        k = sample skewness (third central moment divided by second^(3/2))
%        X = data vector or matrix
%      dim = dimension to sum across. (default 1'st non-singleton 
%                                              dimension of X)
%
% Example:
%   R=wgumbrnd(2,2,[],100,2);
%   wskewness(R)
%
% See also  wkurtosis, mean, var

% Tested on: Matlab 5.3
% History:
% revised pab 24.10.2000
% - made it more general: accepts any size of X
% - added dim, nargchk
% added ms 16.06.2000

error(nargchk(1,2,nargin))
sz = size(X);
if nargin<2|isempty(dim),
  % Use 1'st non-singleton dimension or dimension 1
  dim = min(find(sz~=1)); 
  if isempty(dim), dim = 1; end
end

rsz = ones(size(sz)); rsz(dim)=sz(dim);
mu  = mean(X,dim);
mu  = repmat(mu,rsz); % reshape mu to the size of X
s   = mean((X-mu).^3,dim)./mean((X-mu).^2,dim).^(3/2);



