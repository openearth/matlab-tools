function y = mdist2dcdf(V,H,phat,condon)
%MDIST2DCDF Joint 2D CDF due to Plackett 
%
% CALL F = mdist2dcdf(x1,x2,phat,condon) 
%
%     F  = the cdf evalutated at points (x1 , x2) 
%          with the parameters Phat1, Phat2 and Psi.
%   phat = parameter structure containing
%          x{1} = Phat1 marginal parameters of x1
%          x{2} = Phat2 marginal parameters of x2
%          x{3} = Psi the interaction parameter between x1 and x2.
%          dist = list of marginal distributions of x1 and x2, respectively 
%                 Options are: 'tgumbel', 'gumbel', 
%                'lognormal','rayleigh','weibull','gamma'.
% condon = 0 regular cdf is returned (default)
%          1 conditional cdf of H given V is returned
%          2 conditional cdf of V given H is returned
%
% Example: 2D Weibull Rayleigh with marginal parameters [2 3] and 3,
%   % respectively and interaction parameter of 10 : 
%   phat.x={[2 3],3,10};
%   phat.dist={'weibull','rayleigh'};
%   F = mdist2dcdf(3,4,phat);
% 
% See also   mdist2dpdf, mdist2dfit, mdist2drnd

% references:
% Plackett, R. L. (1965) "A class of bivariate distributions."
%                                J. Am. Stat. Assoc. 60. 516-22
%      [1]  Michel K. Ochi,
%       OCEAN TECHNOLOGY series 6
%      "OCEAN WAVES, The stochastic approach", Cambridge
%      1998 p. 133-134.

%  tested on: matlab 5.2
% history
% revised pab 8.11.1999
%  - updated header info
%  - changed phat from vectro to structure
%  Per A. Brodtkorb 28.01.99

error(nargchk(3,4,nargin))
if nargin <4 |isempty(condon), condon =0;end

[errorcode V H ] = comnsize(V,H);
if  errorcode > 0
  error('x1 and x2 must be of common size or scalar.');
end

VDIST=lower(phat.dist{1});
HDIST=lower(phat.dist{2});

psi=phat.x{3};
PV=phat.x{1};
PH=phat.x{2};
 


y = zeros(size(V));


if strcmp('gu', VDIST(1:2)),
  if strcmp('gu',HDIST(1:2)),
    k=find(H>-inf&V>-inf);
  else
   k=find(H>0&V>-inf);
  end
elseif strcmp('gu',HDIST(1:2)),
  k = find(H>-inf & V > 0 );
else
  k = find( H>0 &V > 0);
end

if any(k),  
  Fh=dist1dcdffun(H(k),PH,HDIST(1:2) ); 
  Fv=dist1dcdffun(V(k),PV,VDIST(1:2) ); 
  tmp=1+(Fv+Fh).*(psi-1);
  y(k)=(tmp-sqrt(tmp.^2-4.*psi.*(psi-1).*Fv.*Fh))./(2.*(psi-1));
  switch condon
    case 0, 
    case 1, y(k)=0.5-0.5.*(tmp-2.*psi.*Fh)./sqrt(tmp.^2-4.*psi.*(psi-1).*Fv.*Fh);
    case 2, y(k)=0.5-0.5.*(tmp-2.*psi.*Fv)./sqrt(tmp.^2-4.*psi.*(psi-1).*Fv.*Fh);
  end
end

return

function cdf1=dist1dcdffun(H,Ah,dist2 )  
   switch dist2(1:2)
      case 'ra',  cdf1=wraylcdf(H,Ah);
      case 'we' ,  cdf1=wweibcdf(H,Ah(1),Ah(2));
      case 'gu' ,  cdf1=wgumbcdf(H,Ah(1),Ah(2),0);
      case 'tg' ,  cdf1=wgumbcdf(H,Ah(1),Ah(2),1);
      case 'ga' ,  cdf1=wgamcdf(H,Ah(1),Ah(2));
      case 'lo' ,  cdf1=wlogncdf(H,Ah(1),Ah(2));
      otherwise, error('unknown distribution')
    end 
return


