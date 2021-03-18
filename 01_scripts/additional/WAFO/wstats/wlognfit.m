function [phat, var,ciL,ciU] = wlognfit(data,plotflag)
%WLOGNFIT Parameter estimates for Lognormal data.
%
% CALL:  [phat var] = wlognfit(data, plotflag)
%
%   phat  = [m, v] = maximum likelihood estimate of the parameters of
%           the distribution (see wlognpdf)
%   var   = estimated asymptotic variance of phat (cov(m,v)=0)
%   data  = data matrix
%plotflag = 0, do not plot
%         > 0, plot the empiricial distribution function and the
%              estimated cdf (see empdistr for options)(default)
%
% Example:
%   R=wlognrnd(5,2,100,3);
%   [phat var]=wlognfit(R)

% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 59 ff, Marcel Dekker.



%tested on: matlab 5.x
% History:
% revised pab 24.10.2000
% - added  nargchk
% - cov changed to var = variance since cov(m,v)=0
% - fixed some bugs when data is a matrix 
% added ms 15.08.2000


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
mhat=mean(log(data));
vhat=mean(log(data).^2)-mhat.^2;
phat=[mhat(:),vhat(:)];

var=[vhat(:), 2*vhat(:).^2]/n;

if nargout>2, 
  alpha2=ones(1,2)*0.05/2;
  tcrit = wtinv([alpha2 1-alpha2],n-1);
  chi2crit = wchi2inv([alpha2 1-alpha2],n-1);
  ciL = [(mhat + tcrit(1)*sqrt(vhat/n)), sqrt(vhat*(n-1)./chi2crit(2))];
  ciU = [(mhat + tcrit(2)*sqrt(vhat/n)), sqrt(vhat*(n-1)./chi2crit(1))];
  %  ciL = wnorminv(alpha2(ones(m,1),:),phat,var);
  %  ciU = wnorminv(1-alpha2(ones(m,1),:),phat,var);
end

if nargin < 2 | plotflag 
  sd=sort(data);
  empdistr(sd(:,1),[sd(:,1),wlogncdf(sd(:,1),mhat(1),vhat(1))],plotflag ), hold on
  for ix=2:m,empdistr(sd(:,ix),[sd(:,ix),wlogncdf(sd(:,ix),mhat(ix),vhat(ix))],plotflag),end
   hold off
  title([deblank(['Empirical and Lognormal estimated cdf'])])
end
