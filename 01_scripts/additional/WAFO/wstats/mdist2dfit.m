function  phato=mdist2dfit(V,H,dist,alpha,method)
% MDIST2DFIT Parameter estimates for MDIST2D data.
%
%  CALL: Phat = mdist2dfit(x1,x2,dist,alpha,method)
%
%   phat = structure array containing
%          x      = cellarray of distribution parameters
%                   x{1} = Phat1 marginal parameters of x1
%                   x{2} = Phat2 marginal parameters of x2
%                   x{3} = Psi the interaction parameter between x1 and x2.
%          CI     = Confidence interval of distribution parameters
%          dist   = as explained below
%          alpha  = ------||----------
%          method = ------||----------
%          note   = Memorandum string
%          date   = date and time of creation 
%
% x1,x2  = input data
% dist   = list of distributions used in the fitting of X1 and X2, 
%          respectively. Options are 'tgumbel', 'gumbel', 
%          'lognormal','rayleigh','weibull','gamma'.
% alpha  = confidence level constant (If not given CI will not be computed)
% method = fitting method used 'SML' or 'MML' (Simultainous or Marginal 
%          Maximum Likelihood method) (default 'SML')
%
% Example:
%  phat.x={1 2  2 };
%  phat.dist={'rayl','rayl'};
%  [R1,R2] = mdist2drnd(1000,phat);
%  Phat2 = mdist2dfit(R1,R2,{'weibull','rayleigh'},.05,'SML')
% 
% See also  mdist2drnd,  mdist2dpdf, mdist2dcdf, mdist2dprb

% References:
% Plackett, R. L. (1965) "A class of bivariate distributions."
%                                J. Am. Stat. Assoc. 60. 516-22
%      [1]  Michel K. Ochi,
%       OCEAN TECHNOLOGY series 6
%      "OCEAN WAVES, The stochastic approach", Cambridge
%      1998 p. 133-134.


%  tested on: matlab 5.2
% history
% Revised pab nov2004
%  -replaced fmins with fminsearch  
% revised pab Dec2003
% revised pab 8.11.1999
%  - updated header info
%  - changed phat from vector to structure
% Per A. Brodtkorb 29.01.1999


if (nargin< 3)
  error('To few input arguments')
end
  CDIST=lower(dist{1});
  UDIST=lower(dist{2});

if (nargin<5)|isempty(method)
  method='SML'; % options MML, MOM or SML (simultaneous maximum likelihood)
 ;% marginal maximum likelihood 
end
if (nargin < 4)|isempty(alpha)
    alpha = [];
else
  p_int = [alpha/2; 1-alpha/2];
end
V = V(:);
H = H(:);
[n, m] = size(V);
[n2, m2] = size(H);
if n~=n2
  error('V and H  must have equal size')
end

[ ph, phci]=distfit(H,UDIST,method,alpha);
[ pv,  pvci]=distfit(V,CDIST,method,alpha);

rho= corrcoef(V,H);
rho=rho(2,1);
psi=findPsi(rho);  
phat=[pv ph psi ];
phatCI=[pvci phci];
switch lower(method(1:3)),
  case 'sml', %simultaneous MLE
   pinit=phat;
   mvrs=version;ix=find(mvrs=='.');
   if str2num(mvrs(1:ix(2)-1))>5.2,
     phat = fminsearch('mdist2dlike',pinit,[],V,H,dist);
   else
     phat = fmins('mdist2dlike',pinit,[],[],V,H,dist);
   end
  case 'mml',% marginal MLE is already found
     
end

if ~isempty(alpha) % 
   [logL,cov]=mdist2dlike(phat,V,H,dist);
   sa = diag(cov)';
   phatCI = wnorminv(repmat(p_int,1,length(phat)),[phat; phat],[sa;sa]);
 end
 phato.x=cell(2,1);
phato.CI=cell(1,1);
n1=length(pv);
[phato.x{1}]=phat(1:n1);
[phato.x{2}]=phat(n1+1:end-1);
[phato.x{3}]=phat(end);

[phato.CI{1}]=phatCI;
phato.dist=dist;
phato.alpha=alpha;
phato.method=method;
phato.note=[];
phato.date=datestr(now);

function k=findPsi(rho)
  % finds psi by a simple iteration scheme 
  rtol=1e-6; %relativ tolerance
  switch rho
  case 0,  k=1; return
  case 1, k=inf;return
  case -1, k=0; return
  otherwise, 
    if rho<0,
      kold=0.5;
    else
     kold=4;
    end
  end
  kold2=kold-0.001;
  rho2=getrho(kold2);
  for ix=1:500,
    rho1=getrho(kold);
    k=kold-(rho1-rho).*(kold-kold2)./( rho1-rho2);
   %    disp(['k=' num2str(k) ]), pause
    if abs(kold-k)<abs(rtol.*k),break
    elseif k<=0, k=linspace(0,20,1000);
      [tmp I]=min(abs(getrho(k)-rho)); %linear search
      k=k(I);
      break;
    end
    kold=k;
    if ix>=500, disp('could not find k'),end
  end
  return

function r=getrho(psi)
r=zeros(size(psi));
k1=find(psi==0);
if any(k1),
 r(k)=-1;
end
k3=find((psi<1.*psi>0)|psi>1);
if any(k3),
 r(k3)=(psi(k3).^2-1-2.*psi(k3).*log(psi(k3)))./((psi(k3)-1).^2) ;
end
return

function [pvhat,pvci]=distfit(tmp,dist,method,alpha)
  
  if strcmp(lower(method(2:3)),'ml'),
    switch lower(dist(1:2)),
      case 'ra', [pvhat tmp2] = wraylfit(tmp,0) ;
      case 'tg', [pvhat tmp2] = wgumbfit(tmp,0);
      case 'gu', [pvhat tmp2] = wgumbfit(tmp,0);
      case 'lo', [pvhat tmp2] = wnormfit(log(tmp),0);
      case 'ga', [pvhat tmp2] = wgamfit(tmp,0);
      case 'we', [pvhat tmp2] = wweibfit(tmp,0);
      otherwise, error('Unknown distribution')
    end
    if prod(size(tmp2))~=length(tmp2);
      sa=diag(tmp2)';
    else
      sa = tmp2(:)';
    end
    p_int=[alpha/2; 1-alpha/2];
    pvci = wnorminv(repmat(p_int,1,length(pvhat)),[pvhat; pvhat],[sa;sa]);
  else  % MOM fit
    pvci=NaN;
    error('MOM is not implemented for any distribution')	
    switch dist(1:2)
      case {'tg','gu'} ,  
      case 'we', 
      case 'lo', 
      case 'ga', error('MOM is not implemented for Gamma distribution')	 
      case 'ra', error('MOM is not implemented for Rayleigh distribution')	 
      otherwise , error('Unknown distribution')
    end
  end
  return

