function [phat, cov,pci]=weib2dfit(data1,data2,method,given,gparam,alpha)
%WEIB2DFIT Parameter estimates for 2D Weibull data.
% 
% CALL:  [phat,cov,pci] = weib2dfit(data1,data2,method)
%
%   phat  = maximum likelihood estimates of the parameters of the distribution
%   cov   = estimated covariance of phat
%   pci   = 95% confidense intervals for phat
%   data  = vectors of data points
%  method = 'SMLE' : Simultanous Maximum Likelihood Estimate (Default)
%           'MMLE' : Marginal Maximum Likelihood Estimate    
% Example:
%   R = wweibrnd(1,2,10000,2);
%   phat = weib2dfit(R(:,1),R(:,2),'smle');
%
% See also  wweibfit, weib2dlike, wnorminv, hypgf, corrcoef

% tested on: matlab 5.2
%History:
% revised pab nov 2004
% fmins replaced with fminsearch  
% revised pab 02.11.2000
% by Per A. Brodtkorb 14.11.98

%   alpha = confidence level (default 0.05 corresponding to 95% CI)
%   g     = indices to fixed parameters not estimated     (Default [])
%   gphat = values for the fixed parameters not estimated (Default [])

% Example:
%  R = wweibrnd(1,2,10000,2);
%  phat0 = [2 2 0];  % set the B1 B2 and C12 respectively a priory
%  given = [2 4 5];  % = indices to the parameters phat0 set a priory
%  phat = weib2dfit(R(:,1),R(:,2),'smle',given,phat0); % estimate A1 and A2


error(nargchk(2,6,nargin))
if (nargin < 3 |isempty(method)), method = 'SMLE'; end
if (nargin < 5 |isempty(gparam)), gparam = []; end
if (nargin < 4 |isempty(given)),  given  = []; end
if (nargin < 6)|isempty(alpha),   alpha  = 0.05; end


data1 = data1(:);  data2 = data2(:);
n = length(data1); n2 = length(data2);
if n~=n2,  error('data1 and data2  must have equal size'),end

rho = corrcoef(data1,data2);
rho = rho(2,1);
pinit = [wweibfit(data1) wweibfit(data2) sqrt(abs(rho))*sign(rho) ];
%pinit(given) = gparam;
%pinit(5)=findk(rho,pinit);  

switch lower(method(1:4)),
  case 'smle', %simultanous MLE
    pinit(given)=[];
    mvrs=version;ix=find(mvrs=='.');
    if str2num(mvrs(1:ix(2)-1))>5.2,
      phat = fminsearch('weib2dlike',pinit,[],data1,data2,given,gparam);
    else
      phat = fmins('weib2dlike',pinit,[],[],data1,data2,given,gparam);
    end
    
  case 'mmle',% marginal MLE
    phat=pinit;
    phat(given)=gparam;
    phat(5)=findk(rho,phat);   
  otherwise
    phat = pinit;
end

if nargout > 1,
  p_int = [alpha/2; 1-alpha/2];
  [logL,cov] = weib2dlike(phat,data1,data2,given,gparam);
  sa  = diag(cov).';
  pci = wnorminv(repmat(p_int,1,5-length(given)),[phat; phat],[sa;sa]);
end
 
function k=findk(rho,sparam)
  % finds k by a simple iteration scheme 
  rtol=1e-6; %relativ tolerance
  kold=sqrt(abs(rho))*sign(rho);
  kold2=kold-0.001;
  rho2=getrho(kold2,sparam);
  for ix=1:500,
    rho1=getrho(kold,sparam);
    k=kold-(rho1-rho).*(kold-kold2)./( rho1-rho2);
    %    disp(['k=' num2str(k) ]), pause
    if abs(kold-k)<abs(rtol.*k),break
    elseif abs(k)>1, tmp=sqrt(abs(rho))*sign(rho):0.000001:kold;
      [tmp2 I]=min(abs(getrho(tmp,sparam)-rho)); %linear search
      k=tmp(I);
      break,
    end
    rho2=rho1;    kold2=kold;
    kold=k;
    if ix>=500, disp('could not find k'),end
  end
  return
  
function y=getrho(k,sparam)
  % returns the correlationcoefficient based on:
  a1=sparam(1);b1=sparam(2);a2=sparam(3);b2=sparam(4);
  % and k
  if 0, % calculating correlation correct if rayleigh
    [K,E] = ellipke(k.^2); %complete elliptic integral of first and
    %second kind
    y=  (E-.5*(1-k.^2).*K-pi/4)./(1-pi/4);	
  else % alternatively and possibly slower
    qx=1./b1;qy=1./b2;
    y=  (hypgf(-qx,-qy,1,k.^2)-1).* gamma(qx).*gamma(qy)  ./ ....
	( sqrt(2.*b1.*gamma(2.*qx) - gamma(qx).^2) .* ...
	sqrt(2.*b2.*gamma(2.*qy) - gamma(qy).^2) );
    
    
  end
  return
