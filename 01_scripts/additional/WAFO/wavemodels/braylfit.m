function [phat, cov,pci]=braylfit(data1,alpha)
%BRAYLFIT Parameter estimates for Beta-Rayleigh data.
%
% CALL: [phat,cov, pci] = braylfit(data,alpha);
%
%   phat  = [a, b, c] = maximum likelihood estimates of the
%           parameters of the Beta-Rayleigh distribution (see
%           braylpdf) given the data.
%   cov   = asymptotic covariance matrix of estimates
%   pci   = 100*(1-alpha) percent confidense intervals
%   data  = data matrix
%   alpha = confidence level (default 0.05 corresponding to 95% CI)
%
% Example:
%  a = .9; b = 105; sz = [100,1]
%  R = sort(wbetarnd(a,b,sz));
%  phat = braylfit(R)
%  empdistr(R,[R braylpdf(R,p(1),p(2),p(3))])
%
% See also  braylpdf, wbetafit

% tested on: matlab 5.2
%History:

% revised pabnov 2004
% -replaced fmins with fminsearch  
% by Per A. Brodtkorb 14.02.99
%   Reference:

error(nargchk(1,2,nargin))
if (nargin < 2)|isempty(alpha)
    alpha = 0.05;
end
p_int = [alpha/2; 1-alpha/2];

data1=data1(:)

c=sqrt(2)*max(data1);
pinit=[wbetafit((data1./c).^2) c]

%simultanous MLE
mvrs=version;ix=find(mvrs=='.');
if str2num(mvrs(1:ix(2)-1))>5.2,
  phat = fminsearch('loglike',pinit,[],data1,'braylpdf');
else
  phat = fmins('loglike',pinit,[],[],data1,'braylpdf');
end

% Old call
%phat = fmins('brayllike',pinit,[],[],data1);


if nargout >1 
   [L, cov] = loglike(phat,data1,'braylpdf')
   %[logL,cov]=brayllike(phat,data1); % old call
   sigma = diag(cov).';
   pci = wnorminv(repmat(p_int,1,2),[phat; phat],[sigma;sigma]);
 end
 

