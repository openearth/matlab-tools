function y=dist2dfun(H,V)
%DIST2DFUN is an internal function to dist2dcdf dist2dprb. 
%
%  CALL: y = dist2dfun(x2,x1)
%
% Dependending on condon it returns a product of conditional 
% pdf and cdf.
%   condon = 0  returns p(X1,X2)=p(X2)*P( X1|X2) 
%            1  returns p(X1)*p( X1|X2) 
%            2  returns P( X1|X2) 
%            3  returns p( X1|X2) 
%
%
%   X1 and X2 must have equal size.
%   The size of P is the common size of the arguments X1 and X2.
%   
% GLOBALS used PHAT  CONDON
%
% See also   dist2dcdf, dist2dprb

% tested on: matlab 5.2
% history:
% pab 09.11.99


global PHAT CONDON
UDIST=lower(PHAT.dist{2});
CDIST=lower(PHAT.dist{1});
PH=PHAT.x{2};


[Av , Bv,Cv]=dist2dsmfun(PHAT,H);
switch CONDON
  case {0,1} , % no conditional or conditional CDF given V
   switch UDIST(1:2)
    case 'ra',  pdf1= wraylpdf(H,PH);
    case 'we' ,  pdf1=wweibpdf(H,PH(1),PH(2));
    case 'gu' ,  pdf1=wgumbpdf(H,PH(1),PH(2),0);
    case 'tg' ,  pdf1=wgumbpdf(H,PH(1),PH(2),1);
    case 'ga' ,  pdf1=wgampdf(H,PH(1),PH(2));
    case 'gg',  pdf1=wggampdf(H,PH(1),PH(2),PH(3));
    case 'lo' ,  pdf1=wlognpdf(H,PH(1),PH(2));
    otherwise, error('unknown distribution')
   end 
  case {2,3}, pdf1=1;%conditional CDF given H
end

switch CONDON
  case {0,2}
    switch CDIST(1:2)
      case 'ra', y=pdf1.*wraylcdf(V-Cv,Av);
      case 'gu',y =  pdf1.*wgumbcdf(V-Cv,Av,Bv,0);
      case 'tg',  y =  pdf1.*wgumbcdf(V-Cv,Av,Bv,1);
      case 'lo', y =  pdf1.*wlogncdf(V-Cv,Av,Bv);
     case 'ga', y =  pdf1.*wgamcdf(V-Cv,Av,Bv);	
      case 'gg', y =  pdf1.*wggamcdf(V,Av,Bv,Cv);	
      case 'we', y =  pdf1.*wweibcdf(V-Cv,Av,Bv);
      otherwise, error('Unknown distribution')
    end
  case {1,3},
   switch CDIST(1:2)
    case 'ra', y=pdf1.*wraylpdf(V-Cv,Av);
    case 'gu',y =  pdf1.*wgumbpdf(V-Cv,Av,Bv,0);
    case 'tg',  y =  pdf1.*wgumbpdf(V-Cv,Av,Bv,1);
    case 'lo', y =  pdf1.*wlognpdf(V-Cv,Av,Bv);
    case 'ga', y =  pdf1.*wgampdf(V-Cv,Av,Bv);	
    case 'gg', y =  pdf1.*wggampdf(V,Av,Bv,Cv);
    case 'we', y =  pdf1.*wweibpdf(V-Cv,Av,Bv);
    otherwise, error('Unknown distribution')
   end
end

