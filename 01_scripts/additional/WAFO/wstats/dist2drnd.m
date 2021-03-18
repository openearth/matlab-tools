function [V,H] = dist2drnd(N,phat,csm,lin)
%DIST2DRND  Random points from a bivariate DIST2D distribution 
%  
%  CALL:  [x1,x2] = dist2drnd(N,phat,[csma,csmb,csmc],[lina,linb,linc]);
%
%    X1,X2   = N random points in R^2.
%    N       = number of points generated
%    phat    = parameter structure array (see dist2dfit)
%    csma..c =  vector of internal smoothing parameters (default [1 1 1])
%               0 -> LS-straight line
%               1 -> cubic spline interpolant
%   lina..c  = vector defining the extrapolation of parameter A,B and C, respectively 
%              0 No linear extrapolation outside the range of data
%              1 Linear extrapolation outside the range of data (default)
%
% Example: Random points from a 2D Rayleigh distribution
%   x1=linspace(0,10)';
%   phat.x={[x1,exp(-0.1*x1)] 2 };
%   phat.dist={'rayl','rayl'};
%   [y1,y2] = dist2drnd(1000,phat);
%   f = dist2dpdf2(x1,x1,phat);
%   pdfplot(f), hold on
%   plot(y1,y2,'.'), hold off
%   
%
% See also  dist2dfit , dist2dpdf

% tested on: matlab 5.2
% history:
% by Per A. Brodtkorb 28.10.98

error(nargchk(2,4,nargin))

if (nargin< 3)|isempty(csm), 
  csm=[];
end
if (nargin< 4)|isempty(lin), 
  lin=[];
end
UDIST=phat.dist{2};
CDIST=phat.dist{1};

PH=phat.x{2};

  
% H is distributed
switch UDIST(1:2),
  case 'ra', H=wraylrnd(PH(ones(N,1),:));
  case 'we', H=wweibrnd(PH(ones(N,1),1) , PH(ones(N,1),2));
  case 'tg', H=wgumbrnd(PH(ones(N,1),1) , PH(ones(N,1),2),1);
  case 'gu', H=wgumbrnd(PH(ones(N,1),1) , PH(ones(N,1),2),0);
  case 'lo', H=wlognrnd(PH(ones(N,1),1) , PH(ones(N,1),2));
  case 'ga', H=wgamrnd(PH(ones(N,1),1) , PH(ones(N,1),2));	
end
 

[Av , Bv, Cv]=dist2dsmfun(phat,H,csm,lin); %parameters of V given H 

% V conditioned on H  is distributed 
switch CDIST(1:2)
  case 'ra', V = wraylrnd(Av)+Cv;
  case 'gu', V = wgumbrnd(Av,Bv,0)+Cv;% tGumbel
  case 'tg', V = wgumbrnd(Av,Bv,1)+Cv;% truncated  Gumbel
  case 'lo', V = wlognrnd(Av,Bv)+Cv;
  case 'ga', V = wgamrnd(Av,Bv)+Cv;	
  case 'we', V = wweibrnd(Av,Bv)+Cv;
  otherwise, error('Unknown distribution') 
end


