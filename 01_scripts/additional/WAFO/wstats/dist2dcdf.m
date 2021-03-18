function [y ,eps2] = dist2dcdf(V,H,phat,condon)
%DIST2DCDF Joint 2D CDF computed as int F(X1<v|X2=x2).*f(x2)dx2
%
% CALL:  [F tol] = dist2dcdf(x1,x2,phat,condon) 
%
%   F      = cdf evaluated at x1, x2
%   tol    = absolute tolerance of the calculated F's, i.e, abs(int-intold)
%   x1,x2  = evaluation points
%   phat   = structure array containing
%            x    = cellarray of distribution parameters
%            dist = cellarray of strings defining the distributions of 
%                  X2 and X1 given X2, respectively. Options are:
%                  'tgumbel', 'gumbel', 'lognormal','rayleigh','weibull',
%                   and 'gamma'.
%   condon = 0 regular cdf of X1 and X2, F(X1<v,X2<h), is returned (default)
%            1 cdf of X2 conditioned on X1, F(X2<h|X1=v), is returned
%            2 cdf of X1 conditioned on X2, F(X1<v|X2=h), is returned
%
% The size of F is the common size of X1 and X2.  
%
% Example: 2D Rayleigh, ie, f(x1|X2=x2)*f(x2)
%   x1=linspace(0,10)';
%   phat.x={[x1,exp(-0.1*x1)] 2 };
%   phat.dist={'rayl','rayl'};
%   dist2dcdf(2,1,phat)
%   f = dist2dpdf2(x1,x1,phat);
%   pdfplot(f)
%
% See also  dist2dfit, dist2drnd, dist2dpdf, dist2dprb

% tested on: matlab 5.2
% history:
%  Per A. Brodtkorb 28.10.98


if (nargin < 3), 
  error('Requires three input arguments.'); 
end

if (nargin <4)| isempty(condon), 
  condon=0;
end

CDIST=phat.dist{1}; %conditional distribution
UDIST=phat.dist{2}; %unconditional distribution
PH=phat.x{2};

[errorcode V H ] = comnsize(V,H);
if  errorcode > 0
  error('Requires non-scalar arguments to match in size.');
end

y = zeros(size(V));
eps2=y;

if strcmp('gu', lower(CDIST(1:2))),
  if strcmp('gu',lower(UDIST(1:2))),
    k=find(H>-inf);
  else
    k=find(H>=0);
  end
elseif strcmp('gu',lower(UDIST(1:2))),
  k = find(V >=0 );
else
  k = find(V >= 0 & H>=0);
end

% NB! weibpdf must be modified to correspond to
% pdf=x^(b-1)/a^b*exp(-(x/a)^b) 

if any(k), 
    global PHAT CONDON
    PHAT=phat;
    CONDON=condon;
    eps1=1e-6;%sqrt(eps); %accuracy of the estimates
   
    switch condon
      case { 0,1}, % 0:no conditional CDF  1: conditional CDF given V 
	%approximate # of divisions required for resolution
	%  H                       H
	% int  p(h)*P(V|h)dh or % int  p(h)*p(V|h)dh 
  	% 0                        0
	
	[y(k) eps2(k) ]=gaussq('dist2dfun', 0,H(k),eps1,[],V(k));
	if any(eps2>eps1),
	  disp(['The accuracy of the computed cdf is '  num2str(max(eps2))])
	end
	if condon==1,  %conditional CDF given V 
	  %must normalize y(k)
	  [M1, V1]=dist1dstat(PH,UDIST);
	  hmax=M1+10*sqrt(V1); %finding a value for inf
	 %  inf                                     
	% int  p(h)*p(V|h)dh  
  	% H           
	  [tmp eps3]=gaussq('dist2dfun', H(k),hmax+H(k),eps1,[],V(k))
	  if any(eps3>eps1),
	    disp(['The accuracy of the computed cdf is '  num2str(max(eps3))])
	  end
	  y(k)=y(k)./( y(k)+tmp);
	end
      case 2,% conditional CDF given H 
	y(k)=dist2dfun(H(k),V(k));	
    end
end

function cdf1=dist1dcdffun(H,Ah,dist2 )  
   switch dist2(1:2)
      case 'ra',  pdf1= wraylcdf(H,Ah);
      case 'we' ,  pdf1=wweibcdf(H,Ah(1),Ah(2));
      case 'gu' ,  pdf1=wgumbcdf(H,Ah(1),Ah(2),0);
      case 'tg' ,  pdf1=wgumbcdf(H,Ah(1),Ah(2),1);
      case 'ga' ,  pdf1=wgamcdf(H,Ah(1),Ah(2));
      case 'lo' ,  pdf1=wlogncdf(H,Ah(1),Ah(2));
      otherwise, error('unknown distribution')
    end 
return

function [m, v]=dist1dstat(Ah,dist2);
switch lower(dist2(1:2))
      case 'ra',  [m ,v]= wraylstat(Ah);
      case 'we' ,  [m ,v]=wweibstat(Ah(1),Ah(2));
      case 'gu' ,  [m ,v]=wgumbstat(Ah(1),Ah(2),0);
      case 'tg' ,  [m ,v]=wgumbstat(Ah(1),Ah(2),1);
      case 'ga' ,  [m ,v]=wgamstat(Ah(1),Ah(2));
      case 'lo' ,  [m ,v]=wlognstat(Ah(1),Ah(2));
      otherwise, error('unknown distribution')
    end 
return
 
