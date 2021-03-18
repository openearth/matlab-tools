function [phat, var,pci] = wraylfit(data,plotflag)
%WRAYLFIT Parameter estimates for Rayleigh data.
%
% CALL:  [bhat var] = wraylfit(data, plotflag)
%
%   bhat  = maximum likelihood estimate of the parameter of
%           the distribution (see wraylcdf)
%   var   = estimated asymptotic variance of bhat
%   data  = data matrix
%plotflag = 0, do not plot
%         > 0, plot the empiricial distribution function and the
%              estimated cdf (see empdistr for options)(default)
%
% Example:
%   R=wraylrnd(2,100,2);
%   [bhat var]=wraylfit(R)
%
% See also  wraylcdf

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

phat=sqrt(sum(data.^2)/n/2); % MLE

if nargout > 1 
  if (n<200),
    var=phat.^2.*(n-(exp(gammaln(1/2+n)-gammaln(n))).^2)/n; 
  else    %n too large for evaluating gamma
    var=phat.^2.*0.25/n; 
  end
end


if nargout>2,
  alpha2=0.05/2;
  pci = [wnorminv(alpha2,phat,var);wnorminv(1-alpha2,phat,var)];
end

if plotflag 
  sd=sort(data);
  empdistr(sd(:,1),[sd(:,1),wraylcdf(sd(:,1),phat(1))],plotflag ), hold on
  for ix=2:m,empdistr(sd(:,ix),[sd(:,ix),wraylcdf(sd(:,ix),phat(ix))],plotflag),end
   hold off
  
  title([deblank(['Empirical and Rayleigh estimated cdf'])])
end



