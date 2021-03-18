function [phat, cov, pci]=wweibfit(data1, plotflag);
%WWEIBFIT Parameter estimates for Weibull data.
%
% CALL:  [phat, cov] = wweibfit(data, plotflag)
%
%     phat = [a,c] = the maximum likelihood estimates of the  
%            parameters of the Weibull distribution
%            (see wweibcdf) given the data.
%     cov  = asymptotic covariance matrix of estimates
%     data = data vector
% plotflag = 0, do not plot
%          > 0, plot the empiricial distribution function and the
%               estimated cdf (see empdistr for options)(default)
% 
% Example:
%   R=wweibrnd(10,2,1,100);
%   [phat, cov] = wweibfit(R)
%
% See also  wweibcdf

% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 25 ff, Marcel Dekker.

%Tested on: matlab  5.3
% History:
% revised pab 03.11.2000
% - added
% revised pab 24.10.2000
%  - added nargchk + safer call to fzero
%  - made sure data is a vector 
% rewritten ms 20.06.2000

error(nargchk(1,2,nargin))
if nargin<2|isempty(plotflag),  plotflag=1; end

data  = data1(:);                            % make sure it is a vector
start = 1./(6^(1/2)/pi*std(log(data)));

mvrs=version;ix=find(mvrs=='.');
if str2num(mvrs(1:ix(2)-1))>5.2,
  chat = fzero('wweibcfit',start,optimset,data); 
else
  chat = fzero('wweibcfit',start,sqrt(eps),[],data);
end
ahat = mean(data.^chat).^(1./chat);
phat = [ahat(:), chat(:)];

cov=[1.109*ahat^2/chat^2,0.257*ahat;0.257*ahat,0.608*chat^2]/length(data);

if nargout>2,
  var=diag(cov)';
  alpha2=ones(1,2)*0.05/2;
  pci = wnorminv([alpha2;1-alpha2],[phat;phat],[var;var]);
end


if plotflag 
  sd=sort(data);
  empdistr(sd,[sd, wweibcdf(sd,ahat,chat)],plotflag)
  title([deblank(['Empirical and Weibull estimated cdf'])])
end

