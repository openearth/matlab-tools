function [phat, cov,pci]=wgamfit(data1, plotflag);
%WGAMFIT Parameter estimates for Gamma data.
%
% CALL: [phat, cov] = wgamfit(data, plotflag)
%
%     phat = [a,b] = the maximum likelihood estimates of the  
%            parameters of the Gamma distribution
%            (see wgamcdf) given the data.
%     cov  = asymptotic covariance matrix of estimates 
%     data = data vector
% plotflag = 0, do not plot
%          > 0, plot the empiricial distribution function and the
%               estimated cdf (see empdistr for options)(default)
%          
% Example:
%   R = wgamrnd(5,1,1,100);
%   phat = wgamfit(R,2) 
%
% See also  wgamcdf, empdistr

% Reference:
% Bowman & Shenton, "Properties of estimators for the Gamma distribution"
% Marcel Dekker

% tested on: matlab 5.3
% History:
% revised pab 21.01.2004
% revised pab 24.10.2000
% - added check on fzero in order to run on matlab 5.2
% - added pci
% added ms 23.08.2000


error(nargchk(1,2,nargin))
if any(data1<=0)
  error('data must be strictly positive!')
end
if nargin<2|isempty(plotflag),plotflag=1;end

data=data1(:); % make sure it is a vector

meanData    = mean(data);
logData     = log(data);
meanLogData = mean(logData);
ahat0 = -(meanLogData-mean(data.*logData)/meanData)^(-1);
if 1,
  G     = exp(meanLogData);
  start = 1./(2*log(meanData/G));
  %start = ahat0
  mvrs=version;
  ix=find(mvrs=='.');
  if str2num(mvrs(1:ix(2)-1))>5.2,
    ahat = fzero('wgamafit',start,optimset,meanData,G);
  else
    ahat = fzero('wgamafit',start,sqrt(eps),[],meanData,G); 
  end	
else
  ahat = ahat0;  
end
bhat = meanData/ahat;

phat=[ahat, bhat];

if nargout>1,
  [LL, cov] = loglike(phat,data,'wgampdf');
end
if nargout>2
  alpha2 = ones(1,2)*0.05/2;
  var = diag(cov).';
  pci = wnorminv([alpha2;1-alpha2], [phat;phat],[var;var]);
end

if plotflag 
  sd = sort(data); 
  empdistr(sd,[sd, wgamcdf(sd,ahat,bhat)],plotflag)
  title([deblank(['Empirical and Gamma estimated cdf'])])
end
