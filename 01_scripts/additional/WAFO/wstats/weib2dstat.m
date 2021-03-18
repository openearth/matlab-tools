function [M ,V ,Tm ,cvar, tolm, tolv] = weib2dstat(a1,b1,a2,b2,c12,condon,cvar,tol)
% WEIB2DSTAT  Mean and variance for the 2D Weibull distribution 
%
%  CALL:  [M,V,Tm] = weib2dstat( a1,b1,a2,b2,c12,condon,cvar, tol ) 
%         [M,V,Tm] = weib2dstat([ a1,b1,a2,b2,c12],condon,cvar,tol ) 
%
%    M , V, Tm  = mean, variance and modal value, respectively
%   ai, bi, c12 = parameters of the distribution
%
%     condon    = 0 Return mean, covariance and modal value of X1 and X2 (default)
%                 1 Return the conditional values given X1 (cvar)
%                 2 Return the conditional values given X2 (cvar)
%
%          cvar = vector of conditional values 
%                 (default depending on marginal mean and variance)
%          tol  = relative tolerance used in the integration. (default 1e-3)
%
% The distribution is defined by its PDF:
%    f(X1,X2)=B1*B2*xn1^(B1-1)*xn2^(B2-1)/A1/B1/N*...
%             exp{-[xn1^B1 +xn2^B2 ]/N }*I0(2*C12*xn1^(B1/2)*xn2^(B2/2)/N) 
%  where 
%    N=1-C12^2, xn1=X1/A1,  xn2=X2/A2 and 
%    I0 is the modified bessel function of zeroth order.
%
% (The marginal distribution of X1 is weibull with parameters A1 and B1) 
% (The marginal distribution of X2 is weibull with parameters A2 and B2) 
%
% Examples:
%   [m v] = weib2dstat([2 2  3 2.5 .8]) %  mean and covariance
%   x = linspace(0,6)';
%   [m v] = weib2dstat([2 2  3 2.5 .8],2,x);
%   plot(x,m,'r--', x,sqrt(v),'g-') % conditional mean and standard deviation.
%
% See also  weib2dpdf, ellipke, hypgf, gamma, gaussq


%   References:
%     Dag Myrhaug & Håvard Rue
%  Journal of Ship Research, Vol 42, No3, Sept 1998, pp 199-205 

%tested on: matlab 5.1
% history:
%  by Per A. Brodtkorb 13.11.98



if nargin < 1, 
  error('Requires 1 input argument.'); 
elseif (nargin < 5) &prod(size((a1)))~=5|isempty(a1),
  error('Requires either 5 input arguments or that input argument 1 must have 5 entries .'); 
elseif (nargin < 5) &prod(size((a1)))==5,
  if (nargin<2)|isempty(b1), condon=0; else   condon=b1;  end
  if (nargin <3)|isempty(a2),  cvar=[]; else cvar=a2; end;
  if (nargin <4)|isempty(b2),  tol=1e-3; else tol=b2; end;
   b1=a1(2);
  a2=a1(3);  b2=a1(4);    c12=a1(5); a1=a1(1); 
else
  if (nargin < 6)|isempty(condon),   condon=0;end
  if (nargin < 7)|isempty(cvar),     cvar=[]; end
   if (nargin <8)|isempty(tol),  tol=1e-3;  end;
end

[errorcode  a1 b1 a2 b2 c12] = comnsize(a1,b1,a2,b2,c12);
if errorcode > 0
    error('Requires non-scalar arguments to match in size.');
end

[m1,v1]=wweibstat(a1,b1); % 
[m2,v2]=wweibstat(a2,b2);
tm1=zeros(size(a1));tm2=zeros(size(a2));


k=find(b1>1);
if any(k),
  tm1(k)=a1(k).*(1-1./b1(k)).^(1./b1(k));
end
k2=find(b2>1);
if any(k2),
  tm2(k2)=a2(k2).*(1-1./b2(k2)).^(1./b2(k2));
end
 
switch condon
  case 0,    % mean and covariance
    covar=zeros(size(a2));
    ok = a1 > 0 & b1 > 0 &a2 > 0 & b2 > 0 | abs(c12)<1;
    k = find(~ok);
    if any(k)
      tmp   = NaN;
      covar(k) = tmp(ones(size(k))); 
    end
    k = find(ok);
    if any(k),
      if 0, % calculating covar correct for Rayleigh
	[K,E] = ellipke(c12(k).^2); %complete elliptic integral of first and
	%second kind
	covar(k) =  sqrt(v1(k).*v2(k)).*(E-.5*(1-c12(k).^2).*K-pi/4)./(1-pi/4);	
      else % calculating covar correct for Weibull
	qx=1./b1(k);qy=1./b2(k);
	covar(k)=   sqrt(v1(k).*v2(k)).*(hypgf(-qx,-qy,1,c12(k).^2)-1).* gamma(qx).*gamma(qy)./ ....
              ( sqrt(2.*b1(k).*gamma(2*qx) - gamma(qx).^2) .* ...
                sqrt(2.*b2(k).*gamma(2*qy) - gamma(qy).^2) );	
      end
    end
    M=[m1 m2];
    V=[v1 covar;covar' v2 ];
    Tm=[tm1,tm2];
  case {1,2}, 
    sparam={a1 b1 a2 b2 c12};
   
    if condon==1,%conditional mean and variance given x1  
      txt='x2';      vr=v2;      mn=m2; vc=v1;mc=m1;
      porder=[3:4 1:2 5];
   else%conditional mean and variance given x2  
     txt='x1'; vr=v1;     mn=m1;  vc=v2;mc=m2;
     porder=1:5;
   end
     if isempty(cvar),cvar=linspace(0 ,mn+3*sqrt(vr),30)'; end
    if 1
      
       xinf=mn+mn./mc.*cvar   +15*sqrt(vr); % infinite value for x1 or x2
      %tmp=input(['Enter an infinite value for ', txt, ':  (' , num2str(xinf), ')']);
      %if ~isempty(tmp), xinf=tmp;end
      %disp(['Infinite value for ' ,txt,' is set to ' num2str(xinf(:)')])
    end
    
    M=zeros(size(cvar));V=M;Tm=M;  tolm=M;tolv=V;
    %do the integration with a quadrature formulae
     [M   tolm]=gaussq('weib2dpdf',0,xinf,tol,[],cvar,sparam{porder},3);  %E(x2|x1) or E(x1|x2)
     [V  tolv]=gaussq('weib2dpdf',0,xinf,tol,[],cvar,sparam{porder},4);%E(x2^2|x1) or E(x1^2|x2) 
     V=V-M.^2;%var(x2|x1) or var(x1|x2)
     k=find(xinf<M+6*sqrt(V));
     if any(k),
       xinf(k)=M(k)+6*sqrt(V(k))+xinf(k); % update the infinite value                                           
       disp(['Changed Infinite value for ', txt]);%, ' to ',   num2str(xinf(k))])
     end
     
     if sparam{porder(2)}>1 & nargout>2
       %modalvalue
       Nint=length(cvar(:));
       mvrs = ver; ix = find(mvrs=='.');
       if str2num(mvrs(1:ix(2)-1))>5.2,
	 
	 for ix=1:Nint,       
	   Tm(ix)=fminbnd('-weib2dpdf(x,P1,P2,P3)',max(0,M(ix)-sqrt(V(ix))),...
			  M(ix)+sqrt(V(ix)),[],cvar(ix),sparam{porder},2 ); 
	 end
       else
	 
	 for ix=1:Nint,       
	   Tm(ix)=fmin('-weib2dpdf(x,P1,P2,P3)',max(0,M(ix)-sqrt(V(ix))),...
		       M(ix)+sqrt(V(ix)),[],cvar(ix),sparam{porder},2 ); 
	 end
       end
     end     
 end
 
 
 % [M(ix)   tolm(ix)]=quadg('weib2dpdf',0,xinf(ix),tol,[],cvar(ix),sparam(porder),3);  %E(x2|x1) or E(x1|x2)
 % [V(ix)  tolv(ix)]=quadg('weib2dpdf',0,xinf(ix),tol,[],cvar(ix),sparam(porder),4);%E(x2^2|x1) or E(x1^2|x2) 
 %V(ix)=V(ix)-M(ix)^2; %var(x2|x1) or var(x1|x2)
 %if Nint>ix & xinf(ix)<M(ix)+6*sqrt(V(ix)),
 %  xinf(ix+1)=xinf(ix+1)+M(ix)+10*sqrt(V(ix))-xinf(ix); % update the infinite value                                           
 %  disp(['Changed Infinite value for ', txt, ' to ',   num2str(xinf(ix))])
 %end