function [phat, var,pCI] = wexpfit(data,plotflag)
%WEXPFIT Parameter estimates for Exponential data.
%
% CALL: [bhat var] = wexpfit(data, plotflag)
%
%    mhat  = maximum likelihood estimate of the parameter of
%            the distribution (see wexppdf)
%    var   = estimated asymptotic variance of mhat
%    data  = data matrix
% plotflag = 0, do not plot
%          > 0, plot the empiricial distribution function and the
%               estimated cdf (see empdistr for options)(default)
%
% Example:
%   R=wexprnd(2,100,1);
%   [mhat var]=wexpfit(R,1)
%   R=wexprnd(2,100,3);
%   [mhat var]=wexpfit(R,3)
%
% See also  empdistr

% Reference: Johnson, Kotz and Balakrishnan (1994)
% "Continuous Univariate Distributions, vol. 1", p. 494 ff
% Wiley


%tested on: matlab 5.x
% History:
% revised pab 24.10.2000
% - added  nargchk + 95% CI for phat
% - fixed some bugs when data is a matrix 
% added ms 16.08.2000

error(nargchk(1,2,nargin))
if nargin<2|isempty(plotflag),  plotflag=1; end
sz = size(data);
Nsz=length(sz);
dim = min(find(sz~=1));  %1st non-singleton dimension
% make sure dim=1 is the first non-singleton dimension
if isempty(dim) | dim ~= 1, 
  order = [dim 1:dim-1 dim+1:Nsz];
  data  = permute(data,order);
  sz    = size(data);
end
m = prod(sz(2:end));
n =sz(1);

phat=mean(data);

var=phat.^2/n;
if nargout>2, % phat ~ gamma(n,phat/n)
  alpha2=0.05/2;
  pCI = [wgaminv(alpha2,n,phat/n);wgaminv(1 - alpha2,n,phat/n)];
end
if  plotflag
  sd=sort(data);
  empdistr(sd(:,1),[sd(:,1) wexpcdf(sd(:,1),phat(1))],plotflag), hold on
  for ix=2:m,empdistr(sd(:,ix),[sd(:,ix) wexpcdf(sd(:,ix),phat(ix))],plotflag),end
  hold off
  title([deblank(['Empirical and Exponential estimated cdf'])])
end






