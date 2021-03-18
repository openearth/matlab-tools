function [M,V, eps2, a ,b] = dist2dstat(phat,condon,cvar,csm,lin)
% DIST2DSTAT  Mean and variance for the DIST2D distribution
%
%  CALL:  [M,V] = dist2dstat(phat,condon,cvar,csm,lin)
%    
%    M,V    = mean and variance, respectively
%    phat   = parameter structure array (see dist2dfit)
%    condon = 0 returns marginal mean and variance for X1, X2 (default)
%             1 returns conditional mean and variance of X2 given X1 
%             2 returns conditional mean and variance of X1 given X2
%     cvar  = conditional variable, i.e.,x1 or x2 depending on condon.
%     csm   = smoothing vector (see dist2dsmfun) (default [1 1 1])
%     lin   = extrapolation vector (default [1 1 1])
%
% Example:
%  x1=linspace(0,10)';
%  phat.x={[x1,exp(-0.1*x1)] 2 };
%  phat.dist={'rayl','rayl'};
%  [M,V]=dist2dstat(phat,2,x1);
%  plot(x1,M,'r--',x1,sqrt(V),'k-')
%  title(' Conditional mean and standard deviation')
%  legend('E(x1|x2)','std(x1|x2)')
%  xlabel('x2')
%
% See also  dist2dfit, dist2dsmfun

%tested on: matlab 5.2
% history:
%  by Per A. Brodtkorb 28.10.98

if (nargin< 4)|isempty(csm), 
  csm=[];
end
 
if (nargin< 5)|isempty(lin), 
  lin=[];
end
if nargin<3|isempty(cvar) ,
  cvar=[];
end
  
if (nargin <2) |  isempty(condon), 
 condon=0;
end
if (condon~=0 )&(nargin ==0), 
  error('Requires one input argument the levels to condition on.'); 
end

UDIST=lower(phat.dist{2});
CDIST=lower(phat.dist{1});
PH=phat.x{2};


switch UDIST(1:2)
  case 'ra',  [m2,v2]= wraylstat(PH(1));
  case 'we' ,  [m2,v2]=wweibstat(PH(1),PH(2));
  case 'gu' ,  [m2,v2]=wgumbstat(PH(1),PH(2),0);
  case 'tg' ,  [m2,v2]=wgumbstat(PH(1),PH(2),1);
  case 'ga' ,  [m2,v2]=wgamstat(PH(1),PH(2));
  case 'lo' ,  [m2,v2]=wlognstat(PH(1),PH(2));
  otherwise, error('unknown distribution')
end 

switch condon, %marginal stats
  case 0,
    M=zeros(1,2); %initialize mean
    V=M;%initialize variance
   M(2)=m2; V(2,2)=v2; 
   disp('Warning this option is not complete!')
   %    M(1)=m1; V(1,1)=v1; 
   % v(1,2)=covar; M2,1)=covar;
   
 case 1 , % conditional stats given V
      M=zeros(size(cvar)); %initialize mean
      V=M;%initialize variance
      error('not implemented yet!')
      switch UDIST(1:2) % this is not correct yet
	case 'ra',  pdf1= wraylstat(PH);
	case 'we' ,  pdf1=wweibstat(PH(1),PH(2));
	case 'gu' ,  pdf1=wgumbstat(PH(1),PH(2),0);
	case 'tg' ,  pdf1=wgumbstat(PH(1),PH(2),1);
	case 'ga' ,  pdf1=wgamstat(PH(1),PH(2));
	case 'lo' ,  pdf1=wlognstat(PH(1),PH(2));
	otherwise, error('unknown distribution')
      end 
    case 2, % conditional stats given H
  
      if isempty(cvar),cvar=linspace(0 ,m2+3*sqrt(v2),30)'; end
      M=zeros(size(cvar)); %initialize mean
      V=M;%initialize variance
      %size(cvar)
      [Av , Bv, Cv]=dist2dsmfun(phat,cvar,csm,lin);
      switch CDIST(1:2) 
	case 'ra', [M,V] =  wraylstat(Av);
	case 'gu', [M,V] =  wgumbstat(Av,Bv,0);
	case 'tg', [M,V] =  wgumbstat(Av,Bv,1);
	case 'lo', [M,V] =  wlognstat(Av,Bv);
	case 'ga', [M,V] =  wgamstat(Av,Bv);	
	case 'we', [M,V] =  wweibstat(Av,Bv);
	otherwise, error('Unknown distribution')
      end     
    
    otherwise error('Unkown value for condon')
  end
M=M+Cv;



