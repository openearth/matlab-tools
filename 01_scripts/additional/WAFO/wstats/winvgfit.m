function [phat, var,ciL,ciU] = winvgfit(data,plotflag)
%WINVGFIT Parameter estimates for Inverse Gaussian data.
%
% CALL:  [phat var] = winvgfit(data, plotflag)
%
%   phat  = [m, l] = maximum likelihood estimate of the parameters of
%           the distribution (see winvgpdf)
%   var   = estimated asymptotic variance of phat (cov(m,l)=0)
%   data  = data matrix
% plotflag = 0, do not plot
%          > 0, plot the empiricial distribution function and the
%               estimated cdf (see empdistr for options)(default)
%
% Example:
%   R=winvgrnd(2,2,100,2);
%   [phat, var]=winvgfit(R)
%
% See also  winvgcdf, empdistr

% Reference: Chhikara & Folks, "The Inverse Gaussian Distribution", p. 53


%tested on: matlab 5.x
% History:
% revised pab 24.10.2000
% - added  nargchk
% - fixed some bugs when data is a matrix 
% - cov changed to var = variance since cov(m,l)=0
% added ciU, and ciL which is the 95% confidence interval  upper & lower
%     limits, respectively, for phat.
% added ms 14.08.2000

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
n0 =sz(1);

mhat=mean(data);
lhat=1./(mean(data(:,:).^(-1)-mhat(ones(n0,1),:).^(-1)));
phat=[mhat(:),lhat(:)];


if nargout>1
  %nl/lhat is chi2(n-1)
  n=max(6,n0);
  var=[mhat(:).^3./lhat(:), lhat(:).^2*(n^3/(n-3)/(n-5)-n^3/(n-3)^2)]/n; 
end

if nargout>2, % nl/lhat ~ chi2(n-1)
  alpha2=ones(1,2)*0.05/2;
  ciL = wnorminv(alpha2(ones(m,1),:),phat,var);
  ciU = wnorminv(1-alpha2(ones(m,1),:),phat,var);
end

if plotflag 
  sd=sort(data);
  empdistr(sd(:,1),[sd(:,1) winvgcdf(sd(:,1),mhat(1),lhat(1))],plotflag), hold on
  for ix=2:m, empdistr(sd(:,ix),[sd(:,ix) winvgcdf(sd(:,ix),mhat(ix),lhat(ix))],plotflag),end 
  hold off
  title([deblank(['Empirical and Inverse Gaussian estimated cdf'])])
end







