function options = initoptions(speed,options)
%INITOPTIONS Initializes RIND options according to speed.
%                                   
% CALL options = initoptions(speed,options)    
%
%     speed = integer defining accuracy of calculations. 
%             Valid numbers:  1,2,...,10 
%            (1=slowest and most accurate,10=fastest, but less accuracy)
%   options = rind-options structure, see RINDOPTSET fort details.
%
% RIND OPTIONS parameters initialized according to speed:
% SPEED    = Integer defining accuracy of calculations. 
% ABSEPS   = Absolute error tolerance.
% RELEPS   = Relative error tolerance.
% COVEPS   = Error tolerance in Cholesky factorization.
% XCUTOFF  = Truncation limit of the normal CDF 
% MAXPTS   = Maximum number of function values allowed.
% QUADNO   = Quadrature formulae used in integration of Xd(i)
%            implicitly determining # nodes 
%
% Example:
%  opt = initoptions(3); 
%    
% See also  rindoptset, rind
  
  error(nargchk(1,2,nargin))
  if nargin<2|isempty(options)
    options = rindoptset;
  end
  options.speed =  min(max(speed,1),11);
  if isempty(speed)
    return
  end
 
  MAXPTS = 10000;
  options.quadno = (1:3)+ (10-min(options.speed,9)) + (options.speed==1);
  switch options.speed
   case 11,
    abseps = 1d-1;
   case (10)
    abseps = 1d-2;
   case {7,8,9} 
    abseps = 1d-2;
   case {4,5,6}
    MAXPTS = 20000;
    abseps = 1d-3;
   case {1,2,3}
    MAXPTS = 30000;
    abseps = 1d-4;
  end  
  TMP = max(11-abs(options.speed),1);
  TMP = mod(TMP+1,3)+1;
       
  options.releps = min(abseps ,1.d-2);
  options.coveps = abseps*((1.d-1)^TMP);
  options.maxpts = MAXPTS;    
  
  if (options.method==0) 
     % This gives approximately the same accuracy as when using 
     % RINDDND and RINDNIT    
     
     %    xCutOff= MIN(MAX(xCutOff+0.5d0,4.d0),5.d0)
     abseps = abseps*1.d-1;
  end
  options.abseps  = abseps;
  truncError      = 0.05 * max(0,options.abseps);
  options.xcutoff = max(min(abs(wnorminv(truncError)),7),1.2);
  options.abseps  = max(options.abseps - truncError,0);
  
 return 
 