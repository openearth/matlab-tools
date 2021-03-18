function [phat, cov, pci]=wtweibfit(data1, plotflag);
%WTWEIBFIT Parameter estimates for truncated Weibull data.
%
% CALL:  [phat, cov] = wtweibfit(data, plotflag)
%
%     phat = [a,b,c] = the Least Squares estimates of the  
%            parameters of the truncated  Weibull distribution
%            (see wtweibcdf) given the data.
%     cov  = asymptotic covariance matrix of estimates
%     data = data vector
% plotflag = 0, do not plot
%          > 0, plot the empiricial distribution function and the
%               estimated cdf (see empdistr for options)(default)
% 
% Example:
%   R=wweibrnd(2,2,1,200);
%   R=R(R>1)-1;  % Truncated weibul with a=2, b=2, c=1
%   [phat, cov] = wtweibfit(R)
%
% See also  wweibcdf

% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 25 ff, Marcel Dekker.

%Tested on: matlab  5.3
% History:
% revised pab July2004  
% revised pab Dec2003
% revised pab 03.11.2000
% - added
% revised pab 24.10.2000
%  - added nargchk + safer call to fzero
%  - made sure data is a vector 
% rewritten ms 20.06.2000

error(nargchk(1,2,nargin))
if nargin<2|isempty(plotflag),  plotflag=1; end

data  = data1(:);                            % make sure it is a vector
N     = length(data);

sd = sort(data);

F = [0.5./N:1./N:(N - 0.5)./N]';
if N>10000
  Fi = linspace(F(1),F(end-5),10000).';
  %Fi = fliplr(logspace(log10(F(end)),log10(F(1)),10000)).';
  sd =interp1(F,sd,Fi,'linear');
  F  = Fi;
end
phat0 = wweibfit(sd,0);


%g0=inline('mean((-log(1-F)+((data+abs(x(3)))./x(1)).^x(2)-abs(x(3)/x(1)).^x(2)).^2 )','x','data','F');


monitor = logical(0);

def=2; % PJ Added. What is def? See 'wtweibfun' 
mvrs=version;ix=find(mvrs=='.');
if str2num(mvrs(1:ix(2)-1))>5.2,
  phat = fminsearch('wtweibfun',[phat0,0],optimset,sd,F,def,monitor);
else
  phat =  fmins('wtweibfun',[phat0,0],[],[],sd,F,def,monitor);
end

%phat =  fminsearch('g0',[phat0,0],[],F,sd);
%phat  = fmins('loglike',[phat0,1],[],[],data,'wtweibpdf');

if nargout>1,
  [L,cov]= loglike(phat,data,'wtweibpdf');
end
if nargout>2,
  var=diag(cov)';
  alpha2=ones(1,3)*0.05/2;
  pci = wnorminv([alpha2;1-alpha2],[phat;phat],[var;var]);
end


if plotflag 
  empdistr(sd,[sd, wtweibcdf(sd,phat(1),phat(2),phat(3))],plotflag)
  title([deblank(['Empirical and truncated Weibull estimated cdf'])])
end



