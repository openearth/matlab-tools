function y = dist2dpdf(v1,h1,phat)
%DIST2DPDF Joint 2D PDF computed as f(x1|X2=x2)*f(x2)
%
% CALL:  f = dist2dpdf(x1,x2,phat) 
%
%      f  = PDF evaluated at x1,x2
%  x1,x2  = evaluation points
%    phat = structure array containing
%           x    = cellarray of distribution parameters
%           dist = cellarray of strings defining the distributions of 
%                  X2 and X1 given X2, respectively. Options are:
%                  'tgumbel', 'gumbel', 'lognormal','rayleigh','weibull',
%                  and 'gamma'.
%
% DIST2DPDF evaluates f{x1|X2=x2}*f{x2}. 
%  The parameter(s) of the unconditional distribution of X2,
%  f{x2}, must be in in phat.x{2}. The parameters of the conditional
%  distribution of X1 given X2 must be in phat.x{1}. The first column
%  in phat.x{1} contains the X2 values the parameters in column 2 and 3 are
%  conditioned on.  
% 
% The size of f is the common size of X1 and X2.  
%
% Example: 2D Rayleigh, ie, f(x1)*f(x2)
%   x1=linspace(0,10)';
%   phat0.x={[x1,2*ones(size(x1))] 2 };
%   phat0.dist={'rayl','rayl'};
%   dist2dpdf(2,1,phat0)
%
% See also  dist2dfit dist2drnd dist2dpdf dist2dprb

%tested on: matlab 5.2
% history:
% revised pab 19.01.2001
% revised pab 03.12.2000
% added truncated weibull and truncated raleigh 
% revised pab 12.11.2000
%  - added ggampdf option
% revised pab 08.02.2000
%   fixed a bug CV -> Cv
%  Per A. Brodtkorb 28.10.98

error(nargchk(3,3,nargin))

dist=phat.dist;

V=v1; 
H=h1; 

y = zeros(max([size(V) ;size(H)]));

if strcmp('gu', lower(dist{1}(1:2))),
  if strcmp('gu', lower(dist{2}(1:2))),
    k=find(H>-inf);
  else
    k=find(H>0);
  end
elseif strcmp('gu', lower(dist{2}(1:2))),
  k = find(V > 0 );
else
  k = find(V > 0 & H>0);
end

PH=phat.x{2};


if any(k),     
    switch lower(dist{2}(1:2))
      case 'tr' ,  pdf1=wtraylpdf(H(k),PH(1),PH(2));
      case 'ra' ,  pdf1=wraylpdf(H(k),PH);
      case 'we' ,  pdf1=wweibpdf(H(k),PH(1),PH(2));
      case 'tw' ,  pdf1=wtweibpdf(H(k),PH(1),PH(2),PH(3));
      case 'gu' ,  pdf1=wgumbpdf(H(k),PH(1),PH(2),0);
      case 'tg' ,  pdf1=wgumbpdf(H(k),PH(1),PH(2),1);
      case 'ga' ,  pdf1=wgampdf(H(k),PH(1),PH(2));
      case 'gg' ,  pdf1=wggampdf(H(k),PH(1),PH(2),PH(3));
      case 'lo' ,  pdf1=wlognpdf(H(k),PH(1),PH(2));
      otherwise, error('unknown distribution')
    end 
    [Av , Bv, Cv]=dist2dsmfun(phat,H(k)); %parameters of V given H 
   switch lower(dist{1}(1:2))
     case 'tr', y(k) =  pdf1.*wtraylpdf(V(k),Av,Bv);
     case 'ra', y(k) =  pdf1.*wraylpdf(V(k)-Cv,Av);
     case 'gu', y(k) =  pdf1.*wgumbpdf(V(k)-Cv,Av,Bv,0);
     case 'tg', y(k) =  pdf1.*wgumbpdf(V(k)-Cv,Av,Bv,1);
     case 'lo', y(k) =  pdf1.*wlognpdf(V(k)-Cv,Av,Bv);
     case 'ga', y(k) =  pdf1.*wgampdf(V(k)-Cv,Av,Bv);	
     case 'gg', y(k) =  pdf1.*wggampdf(V(k),Av,Bv,Cv);	
     case 'we', y(k) =  pdf1.*wweibpdf(V(k)-Cv,Av,Bv);
     case 'tw', y(k) =  pdf1.*wtweibpdf(V(k),Av,Bv,Cv);
     otherwise, error('Unknown distribution')
   end
end

%y(find(isnan(y)|isinf(y)))=0;

