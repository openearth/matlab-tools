function [phat, cov,pci] = wgumbfit(data1, plotflag)
%WGUMBFIT Parameter estimates for Gumbel data.
%
% CALL: [phat, cov] = wgumbfit(data,plotflag) 
%
%     phat = the maximum likelihood estimates of the  
%            parameters of the Gumbel distribution given the data.
%     cov  = asymptotic covariance matrix of estimates
%     data = data vector
% plotflag = 0, do not plot
%          > 0, plot the empiricial distribution function and the
%               estimated cdf (see empdistr for options)(default)
%
% Example:
%   R = wgumbrnd(1,2,1,100,1);
%   [phat, cov] = wgumbfit(R)
%
% See also  wgumbplot, wgumbcdf, empdistr

% Reference: 
%  Johnson  N.L., Kotz S. and Balakrishnan, N. (1994)
%  Continuous Univariate Distributions, Volume 2. Wiley. 


% tested on: matlab 5.3
% rewritten ms 05.07.2000
% revised jr 01.09.2000
% - ahat and bhat were reversed in the covariance matrix.
% -revised pab added nargchk, pci + safer call to fzero  
% - made sure data is  vector
% revised PJ 02-Apr-2001
%   Fixed problem with no or empty plotflag

error(nargchk(1,2,nargin))
if (nargin<2)|isempty(plotflag), plotflag=1; end
data=data1(:); % make sure it is a vector

start=6^(1/2)/pi*std(data) % Moment estimate of scale parameter a
mvrs=version;
ix=find(mvrs=='.');
if str2num(mvrs(1:ix(2)-1))>5.2,
  ahat=fzero('wgumbafit',start,optimset,data);
else
  ahat=fzero('wgumbafit',start,sqrt(eps),[],data);  
end
bhat=-ahat*log(mean(exp(-data/ahat)));
phat=[ahat, bhat];

cov=[0.60793,0.25696;0.25696,1.10867]*ahat^2/length(data);
if nargout>2
  alpha2 = ones(1,2)*0.05/2;
  var = diag(cov).';
  pci = wnorminv([alpha2;1-alpha2], [phat;phat],[var;var]);
end


if plotflag
  sd=sort(data);
  empdistr(sd,[sd wgumbcdf(sd,ahat,bhat)],plotflag)
  title([deblank(['Empirical and Gumbel estimated cdf'])])
end


