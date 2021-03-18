function [M ,V ,Tm ,cvar, tolm, tolv] = mdist2dstat(phat,condon,cvar,tol)
%MDIST2DSTAT  Mean and variance for the MDIST2D distribution.
%
%  CALL:  [M,V] = mdist2dstat(phat,condon,cvar, tol) 
%
%   M,V    = mean and variance of the mdist2d distribution
%   phat   = parameter structure array (see mdist2dfit)
%   condon = 0 returns the mean, covariance and modal value of x1 and x2 (default)
%            1 conditional mean, variance and modal value of x2 given x1 
%            2 conditional mean, variance and modal value of x1 given x2 
%  cvar    = conditional variable i.e., x1 or x2 depending on condon.
%   tol    = relative tolerance (default 1e-3)
%
% Example
%   x1=linspace(0,10)';
%   phat.x={1 2 10};
%   phat.dist={'rayl','rayl'};
%   [M,V]=mdist2dstat(phat,2,x1);
%   plot(x1,M,'r--',x1,sqrt(V),'k-')
%   title(' Conditional mean and standard deviation')
%   legend('E(x1|x2)','std(x1|x2)')
%   xlabel('x2')
% 
% See also  mdist2dpdf, mdist2dfit mdist2drnd

% references:
% Plackett, R. L. (1965) "A class of bivariate distributions."
%                                J. Am. Stat. Assoc. 60. 516-22
%      [1]  Michel K. Ochi,
%       OCEAN TECHNOLOGY series 6
%      "OCEAN WAVES, The stochastic approach", Cambridge
%      1998 p. 133-134.


%  tested on: matlab 5.2
% history
  
% revised pab jan2004
%  - added todo comment
% revised pab 8.11.1999
%  - updated header info
%  - changed phat from vector to structure
%  Per A. Brodtkorb 28.01.99

% TODO % modal value not implemented yet

if nargin < 1, 
  error('Requires 1 input argument.'); 
end

if (nargin < 2)|isempty(condon),   condon=0;end
if (nargin < 3)|isempty(cvar),     cvar=[]; end
if (nargin <4)|isempty(tol),  tol=1e-3;  end;
VDIST=lower(phat.dist{1});
HDIST=lower(phat.dist{2}); 

psi=phat.x{3};
PV=phat.x{1};
PH=phat.x{2};


[m1 v1]=dist1dstatfun(PV,VDIST);% marginal mean and covariance
[m2 v2]=dist1dstatfun(PH,HDIST);% marginal mean and covariance


% modal value not implemented yet
%
 if 0
   % This is a trick to get the html documentation correct.
   k = mdist2dpdf(1,1,2,3);
 end

switch condon
  case 0,    % mean and covariance
    covar=sqrt(v1*v2)*getrho(psi);
    
    M=[m1 m2];
    V=[v1 covar;covar' v2 ];
    %Tm=[tm1,tm2];
    Tm=[];
  case {1,2}, 
   
    if condon==1,%conditional mean and variance given V  
      txt='H';      vr=v2;      mn=m2; vc=v1;mc=m1;
      phat2=phat;
      phat2.x=phat.x([2 1 3]);
      phat2.dist=phat.dist([2 1]);
      
   else%conditional mean and variance given H  
     txt='V'; vr=v1;     mn=m1;  vc=v2;mc=m2;
     phat2=phat;
   end
     if isempty(cvar),cvar=linspace(0 ,mn+3*sqrt(vr),30)'; end
    if 1
       xinf=mn+mn./mc.*cvar   +15*sqrt(vr); % infinite value for V or H
      %tmp=input(['Enter an infinite value for ', txt, ':  (' , num2str(xinf), ')']);
      %if ~isempty(tmp), xinf=tmp;end
      %disp(['Infinite value for ' ,txt,' is set to ' num2str(xinf(:)')])
    end
   
    M=zeros(size(cvar));V=M;Tm=M;  tolm=M;tolv=V;
    %do the integration with a quadrature formulae
    %E(H|V) or E(V|H)
     [M   tolm]=gaussq('mdist2dpdf',0,xinf,tol,[],cvar,phat2,3);  
     %E(H^2|V) or E(V^2|H) 
     [V  tolv]=gaussq('mdist2dpdf',0,xinf,tol,[],cvar,phat2,4);
     V=V-M.^2;%var(H|V) or var(V|H)
     k=find(xinf<M+6*sqrt(V));
     if any(k),
       xinf(k)=M(k)+6*sqrt(V(k))+xinf(k); % update the infinite value                                           
       disp(['Changed Infinite value for ', txt]);%, ' to ',   num2str(xinf(k))])
     end
     
     if nargout>2
       Nint=length(cvar(:));
       mvrs=version;ix=find(mvrs=='.');
       if str2num(mvrs(1:ix(2)-1))>5.2,
	 
	 for ix=1:Nint,       
	   Tm(ix)=fminbnd('-mdist2dpdf(x,P1,P2,P3,P4)',...
		       max(0,M(ix)-sqrt(V(ix))),M(ix)+sqrt(V(ix)),[],...
		       cvar(ix),phat2,2 ); %modalvalue
	 end
       else
	
	 for ix=1:Nint,       
	   Tm(ix)=fmin('-mdist2dpdf(x,P1,P2,P3,P4)',...
		       max(0,M(ix)-sqrt(V(ix))),M(ix)+sqrt(V(ix)),[],...
		       cvar(ix),phat2,2 ); %modalvalue
	 end
       end
      
     end
      
 end
return 


function [me, va]=dist1dstatfun(Ah,dist2 )  
   switch dist2(1:2)
      case 'ra',  [me va] = wraylstat(Ah(1));
      case 'we' ,  [me va]=wweibstat(Ah(1),Ah(2));
      case 'gu' ,  [me va]=wgumbstat(Ah(1),Ah(2),0);
      case 'tg' ,  [me va]=wgumbstat(Ah(1),Ah(2),1);
      case 'ga' ,  [me va]=wgamstat(Ah(1),Ah(2));
      case 'lo' ,  [me va]=wlognstat(Ah(1),Ah(2));
      otherwise, error('unknown distribution')
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
