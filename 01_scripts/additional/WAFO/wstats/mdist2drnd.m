function [V,H,ind] = mdist2drnd(N,phat)
%MDIST2DRND  Random points from a bivariate MDIST2D distribution 
%
% CALL:  [R1,R2] = dist2drnd(N,phat);
% 
%     R1,R2   = N random points in R^2.
%     N       = number of points generated
%     phat    = parameter structure array (see mdist2dfit)
%
%Example: Random points from a 2D Rayleigh distribution
%    x1=linspace(0,10)';
%    phat.x={1 2  2 };
%    phat.dist={'rayl','rayl'};
%    [y1,y2] = mdist2drnd(1000,phat);
%    f = mdist2dpdf2(x1,x1,phat);
%    pdfplot(f), hold on
%    plot(y1,y2,'.'), hold off
% 
%  See also  mdist2dfit , mdist2dpdf, mdist2dcdf


%   References:
%      [1]  Michel K. Ochi,
%       OCEAN TECHNOLOGY series 6
%      "OCEAN WAVES, The stochastic approach", Cambridge
%      1998 p. 133-134.

%  tested on: matlab 5.2
% history
% revised pab 8.11.1999
%  - updated header info
%  - changed phat from vector to structure
%  Per A. Brodtkorb 28.01.99

if (nargin < 2), 
  error('Requires two input arguments.'); 
end

VDIST=lower(phat.dist{1});
HDIST=lower(phat.dist{2});

psi=phat.x{3};
switch VDIST(1:2),
  case 'ra', nv=1;
 otherwise, nv=2;
end
switch HDIST(1:2),
  case 'ra', nh=1;
 otherwise, nh=2;
end
PV=phat.x{1};
PH=phat.x{2};
if nv+nh~=length(PV)+length(PH)
 error('param is not the right size')
end

% V is distributed
switch VDIST(1:2),
  case 'ra', V=wraylrnd(PV(ones(N,1),:));
  case 'we', V=wweibrnd(PV(ones(N,1),1) , PV(ones(N,1),2));
  case 'tg', V=wgumbrnd(PV(ones(N,1),1) , PV(ones(N,1),2),[],[],1);
  case 'gu', V=wgumbrnd(PV(ones(N,1),1) , PV(ones(N,1),2),[],[],0);
  case 'lo', V=wlognrnd(PV(ones(N,1),1) , PV(ones(N,1),2));
  case 'ga', V=wgamrnd(PV(ones(N,1),1) , PV(ones(N,1),2));	
  otherwise , error('unknown distribution')
end


% perform a direct inversion by newton
P=rand(N,1);
[H ind]=mdist2dcinv(V ,P,phat); % Inverse of the 2D  cdf given V . slow




