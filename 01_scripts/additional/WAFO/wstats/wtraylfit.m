function [phat,cov,pci] = wtraylfit(data,plotflag)
%WTRAYLFIT Parameter estimates for Truncated Rayleigh data.
%
% CALL:  [phat cov] = wtraylfit(data, plotflag)
%
%   phat  = maximum likelihood estimate of the parameter of
%           the distribution (see wtraylcdf)
%   cov   = estimated asymptotic covariance of phat
%   data  = data matrix
%plotflag = 0, do not plot
%         > 0, plot the empiricial distribution function and the
%              estimated cdf (see empdistr for options)(default)
%
% Example:
%   R=wraylrnd(2,200,1);
%   R=R(R>1)-1;   % Truncated Raylay with b=2, c=-1
%   [phat cov]=wtraylfit(R)
%
% See also  wtraylcdf, wraylfit

% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 181 ff, Marcel Dekker.

%tested on: matlab 5.x
% History:
%  by Per A. Brodtkorb 17.10.98
% revised ms 15.06.2000
% - updated header info
% - changed name to wraylfit (from raylfit)
% revised ms 11.08.2000
% - changed to standard *fit form
% -revised pab 24.10.2000
%  - replaced gamma with gammaln -> more robust
%  - added nargchk
% revised PJ 03-Apr-2001
%  - fmins changed name to fminsearch for version >= 5.3
% Revised pab Dec2003

error(nargchk(1,2,nargin))
if nargin<2|isempty(plotflag),  plotflag=1; end
data = data(:);
n = length(data);
phat = sqrt(sum(data.^2)/n/2); % Initial guess (MLE with c=0)

mvrs=version;ix=find(mvrs=='.');
if str2num(mvrs(1:ix(2)-1))>5.2,
  phat = fminsearch('loglike', [phat 0],optimset,data,'wtraylpdf');
else
  phat = fmins('loglike', [phat 0],[],[],data,'wtraylpdf');
end

if nargout > 1
   [L, cov] = loglike(phat,data,'wtraylpdf');
end


if nargout>2,
  var=diag(cov)';
  alpha2=ones(1,2)*0.05/2;
  pci = wnorminv([alpha2;1-alpha2],[phat;phat],[var;var]);
end

if plotflag 
  sd = sort(data);
  empdistr(sd,[sd,wtraylcdf(sd,phat(1),phat(2))],plotflag )
  title([deblank(['Empirical and truncated Rayleigh estimated cdf'])])
end



