function [phat, cov,pci]=wbetafit(data1, plotflag);
%WBETAFIT Parameter estimates for Beta data.
%
% CALL:  [phat, var] = wbetafit(data, plotflag)
%
%     phat = [a,b] = the maximum likelihood estimates of the  
%            parameters of the beta distribution
%            given the data.
%     cov  = asymptotic covariance matrix of estimates 
%     data = data vector
% plotflag = 0, do not plot
%          > 0, plot the empiricial distribution function and the
%               estimated cdf (see empdistr for options)(default)
%          
% Example:
%   R=wbetarnd(2,2,1,100);
%   phat = wbetafit(R,2) 
%
% See also  wbetacdf, empdistr

% No Reference
%  

% tested on: matlab 5.3
% History:
% By  pab 24.10.2000
% revised PJ 03-Apr-2001
%  - fmins changed name to fminsearch for version >= 5.3


error(nargchk(1,2,nargin))
if any(data1<=0)
  error('data must be strictly positive!')
end
if nargin<2|isempty(plotflag),plotflag=1;end

data=data1(:); % make sure it is a vector

mu = mean(data);
sa = std(data)^2;

% Supply a starting guess with method of moments:
a = (mu*(1-mu)/sa-1)*mu;
phat0 = [ a a*(1/mu-1)];

mvrs=version;ix=find(mvrs=='.');
if str2num(mvrs(1:ix(2)-1))>5.2,
  phat = fminsearch('loglike',phat0,optimset,data,'wbetapdf');
else
  phat = fmins('loglike',phat0,[],[],data,'wbetapdf');
end

if nargout>1,
  [LL, cov] = loglike(phat,data,'wbetapdf');
end
if nargout>2
  alpha2 = ones(1,2)*0.05/2;
  var = diag(cov).';
  pci = wnorminv([alpha2;1-alpha2], [phat;phat],[var;var]);
end

if plotflag 
  sd = sort(data); 
  empdistr(sd,[sd, wbetacdf(sd,phat(1),phat(2))],plotflag)
  title([deblank(['Empirical and Beta estimated cdf'])])
end
