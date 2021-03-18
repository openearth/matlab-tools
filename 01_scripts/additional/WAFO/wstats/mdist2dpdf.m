function y = mdist2dpdf(V,H,phat,condon)
%MDIST2DPDF Joint 2D PDF due to Plackett given as  f{x1}*f{x2}*G(x1,x2;Psi). 
%
%  CALL:  f = mdist2dpdf(x1,x2,phat,condon) 
%
%     f  = PDF evalutated at points (x1 , x2) 
%   phat = parameter structure containing
%          x{1} = Phat1 marginal parameters of X1
%          x{2} = Phat2 marginal parameters of X2
%          x{3} = Psi the interaction parameter between x1 and x2.
%          dist = list of marginal distributions of x1 and x2, respectively 
%                 Options are: 'tgumbel', 'gumbel', 
%                'lognormal','rayleigh','weibull','gamma'.
% condon = 0 regular pdf is returned (default)
%          1 conditional pdf of H given V is returned
%          2 conditional pdf of V given H is returned
%
% Example: 2D Weibull Rayleigh with parameters [2 3] and 3,
% respectively for the marginal distributions, and a interaction 
% parameter of 10:
%
%   phat.x={[2 3],3,10};
%   phat.dist={'weibull','rayleigh'};
%   f = mdist2dpdf(3,4,phat);
% 
% See also   mdist2dcdf, mdist2dfit, mdist2drnd


%   References:
%      Plackett, R. L. (1965) "A class of bivariate distributions."
%                                J. Am. Stat. Assoc. 60. 516-22
%      [1]  Michel K. Ochi,
%       OCEAN TECHNOLOGY series 6
%      "OCEAN WAVES, The stochastic approach", Cambridge
%      1998 pp. 133-134.


%  tested on: matlab 5.2
% history
% revised pab 20.10.2000
% - updated to new wstats toolbox
% revised pab 8.11.1999
%  - updated header info
%  - changed phat from vectro to structure
%  Per A. Brodtkorb 28.01.99


error(nargchk(3,4,nargin))
if nargin <4 |isempty(condon), condon =0;end
[errorcode V H ] = comnsize(V,H);
if  errorcode > 0
  error ('x1 and x2 must be of common size or scalar');
end

VDIST=lower(phat.dist{1});
HDIST=lower(phat.dist{2});


psi=phat.x{3}; % interaction parameter
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
 Fv=dist1dcdffun(V(k),PV, VDIST(1:2));
 fv=dist1dpdffun(V(k),PV, VDIST(1:2));
 Fh=dist1dcdffun(H(k),PH, HDIST(1:2));
 fh=dist1dpdffun(H(k),PH, HDIST(1:2));
 
  tmp=1+(Fv+Fh).*(psi-1);
  y(k)=psi.*((psi-1).*(Fv+Fh-2.*Fv.*Fh)+1)./(sqrt(tmp.^2-4.*psi.*(psi-1).*Fv.*Fh).^3);
   switch condon
   case 0, y(k)=y(k).*fv.*fh;
   case 1, y(k)=y(k).*fh;
   case 2, y(k)=y(k).*fv;
   case 3, % secret option  used by mdist2dstat: returns v*f(v|h) 
           y(k)=V(k).*y(k).*fv;  
   case 4, % secret option  used by weib2dstat: returns v^2*f(v|h) 
           y(k)=V(k).^2.*y(k).*fv; 
  end
%plot(V(k),y(k),'.') 
end

function cdf1=dist1dcdffun(H,Ah,dist2 )  
   switch dist2(1:2)
      case 'ra',   cdf1=wraylcdf(H,Ah);
      case 'we' ,  cdf1=wweibcdf(H,Ah(1),Ah(2));
      case 'gu' ,  cdf1=wgumbcdf(H,Ah(1),Ah(2),0);
      case 'tg' ,  cdf1=wgumbcdf(H,Ah(1),Ah(2),1);
      case 'ga' ,  cdf1=wgamcdf(H,Ah(1),Ah(2));
      case 'lo' ,  cdf1=wlogncdf(H,Ah(1),Ah(2));
      otherwise, error('unknown distribution')
    end 
return
function pdf1=dist1dpdffun(H,Ah,dist2 )  
   switch dist2(1:2)
      case 'ra',   pdf1=wraylpdf(H,Ah);
      case 'we' ,  pdf1=wweibpdf(H,Ah(1),Ah(2));
      case 'gu' ,  pdf1=wgumbpdf(H,Ah(1),Ah(2),0);
      case 'tg' ,  pdf1=wgumbpdf(H,Ah(1),Ah(2),1);
      case 'ga' ,  pdf1=wgampdf(H,Ah(1),Ah(2));
      case 'lo' ,  pdf1=wlognpdf(H,Ah(1),Ah(2));
      otherwise, error('unknown distribution')
    end 
return






