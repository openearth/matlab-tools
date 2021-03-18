function [phat,cov,pci] = wgevfit(data,method,start,plotflag) 
%WGEVFIT Parameter estimates for GEV data
%
% CALL:  [phat,cov] = wgevfit(data,method,start,plotflag)
%
%        phat  = Estimated parameters
%                [k s m] = [shape scale location]   (see wgevcdf)
%        cov   = asymptotic covariance matrix of estimates
%        data  = an one-dimensional data set
%       method = a string, describing the method of estimation
%                'PWM' = Probability Weighted Moments (default)
%                'ML'  = Maximum Likelihood estimates
%        start = starting values for 'ML' method
%                (default 'PWM' estimate) 
%     plotflag = 0, do not plot
%              > 0, plot the empiricial distribution function and the
%                   estimated cdf (see empdistr for options)(default)
%                  
% The variances of the ML estimates are usually smaller than those of
% the PWM estimates. However, it is recommended to first use the PWM
% method since it works for a wider range of parameter values. 
% If method = 'ml' and  start  is missing, then  pwm  is used to 
% give the starting values  start.
%
% Example:  
%   R = wgevrnd(0.2,2,7.5,200,1);
%   [phat,cov] = wgevfit(R,'pwm',[],0)
%   [phat,cov] = wgevfit(R,'ml',[],0)
%
% See also  wgevcdf, empdistr, wgevlike

% References
%
%  Prescott, P. and Walden, A.T. (1980)
%  Maximum likelihood estimation of the parameters of the generalized
%  extreme-value distribution
%  Biometrika (67), pp. 723-724
%
%  Hosking, J.R.M, Wallis, J.R. and Wood E.F. (1985)
%  Estimation of the generalized extreme-value distribution by the
%  method of probability-weighted moments
%  Technometrics (27), pp. 251-261
%
%  Borg, S. (1992)
%  XS - a statistical program package in Splus for extreme-value
%  analysis. 
%  Dept. of Mathematical Statistics, Lund University, 1992:E2

% Tested on: Matlab 5.3
% History: 
% Revised by pab 13.06.2001
% - Replaced 
% [phat,dummy,Converged] = fminsearch('wgevlike',mlstart,....);
% with
%  [phat,dummy,Converged] = feval('fminsearch','wgevlike',mlstart,...);
% to avoid "Unknown function referenced: fminsearch" error on matlab 5.2
% and below. 
%
% Revised by PJ 02-Apr-2001
%   Method 'ml' now works with new format of fminsearch.
% Revised by jr 30.09.1999
% Modified by PJ 08-Mar-2000
%   Added 'hold off' in plotting.
%   Added routine 'gevll'. Now method 'ml' works.
% revised ms 14.06.2000
% - updated header info
% - changed name to wgevfit (from gevfit)
% - added w* to used WAFO-files
% - enabled consistent use of 3 and 4 arguments
% - enabled use of empty start in ML
% revised pab 29.10.2000
%  - added nargchk

error(nargchk(1,4,nargin))
if (nargin < 2)|isempty(method),     method = 'pwm'; end 
if (nargin < 4)|isempty(plotflag), plotflag = 1; end

data = data(:)'; % make sure it is a vector
cov=[];
pci=[];
switch lower(method),
  case 'pwm',
    w=[ -0.4, 1.6637,  1.3355, 1.1405, 1.8461, 1.1628, 2.9092;
      -0.3, 1.4153,  0.8912, 0.5640, 1.2574, 0.4442, 1.4090;
      -0.2, 1.3322,  0.6727, 0.3926, 1.0013, 0.2697, 0.9139;
      -0.1, 1.2915,  0.5104, 0.3245, 0.8440, 0.2240, 0.6815;
      0.0, 1.2686,  0.3704, 0.2992, 0.7390, 0.2247, 0.5633;
      0.1, 1.2551,  0.2411, 0.2966, 0.6708, 0.2447, 0.5103;
      0.2, 1.2474,  0.1177, 0.3081, 0.6330, 0.2728, 0.5021;
      0.3, 1.2438, -0.0023, 0.3297, 0.6223, 0.3033, 0.5294;
      0.4, 1.2433, -0.1205, 0.3592, 0.6368, 0.3329, 0.5880];
   
    n = length(data);
    sortdata = sort(data);
    koeff1 = ((1:n)-1)/(n-1);
    koeff2 = koeff1.*((1:n)-2)/(n-2);
    b2 = (koeff2*sortdata')/n;
    b1 = (koeff1*sortdata')/n;
    b0 = mean(sortdata);
    z = (2*b1-b0)/(3*b2-b0)-log(2)/log(3); 
    shape = 7.8590*z+2.9554*z^2;
    scale = (2*b1-b0)*shape/(gamma(1+shape)*(1-2^(-shape)));
    location = b0+scale*(gamma(1+shape)-1)/shape;
    
    phat=[shape scale location];
    % if (abs(shape)>=0.5) changed by ms to deal with shapes in (.4,.5)
    if (abs(shape)>=0.4) 
      disp(' The estimate of shape is not within the range where ')
      disp(' the PWM estimator is valid.')
      % elseif (abs(shape)<=0.5) changed by ms to deal with shapes in (.4,.5)
    elseif (abs(shape)<=0.4) & nargout>1
      % calculate covariance matrix of estimates with 
      % linear interpolation between rows
      i1 = sum((w(:,1)<=shape));
      i2 = 10-sum((w(:,1)>=shape));
      w_s = w(i1,:)+(shape-w(i1,1))*(w(i2,:)-w(i1,:))/(w(i2,1)-w(i1,1));
      W=[w_s(7),w_s(6),w_s(4);w_s(6),w_s(5),w_s(3);w_s(4),w_s(3),w_s(2)];
      Cov=[1,scale,scale;scale,scale^2,scale^2;scale,scale^2,scale^2];
      cov=1/n*W.*Cov; 
   end
   
case 'ml',
  % ml.gev <- function(data, shape=NA, scale=NA, location=NA) {
  % J. Statist. Comput. Simul. 16, 241-250
  if (nargin<3)|isempty(start)   % compute starting values by  pwm
    mlstart=wgevfit(data,'pwm',[],0);% Added ms
  else,
    mlstart=start;
  end

  options(1) = 0;     % Display off
  options(2) = 1.e-5; % Termination tolerance on the function value  1.e-5]; 
  options(3) = 1.e-5; % Termination tolerance on X 
  options(14)= 500;   % Maximum number of iterations allowed 

  % Solve the ML-equation
  
  try 
  % For Matlab 5.3 and higher ???
    [options1] = optimset('disp','off','TolX',options(2),'TolFun',options(3),'MaxIter',options(14));
    [phat,dummy,Converged] = feval('fminsearch','wgevlike',mlstart,options1,data);
  
  catch
    % For Matlab 5.2 and lower ???
    [phat,option] = feval('fmins','wgevlike',mlstart,options,[],data);
    Converged = (option(14) <= options(14));
  end
  

  if ~Converged %(options(10)==500), 
     disp(' ML-routine did not converge in 500 steps.'); cov=[];
  elseif nargout>1 
    % Calculate the covariance matrix by inverting the observed information. 
    shape = phat(1);
    scale = phat(2);
    location = phat(3);
    y = -log(1-shape*(data-location)/scale)/shape;
    P = length(data)-sum(exp(-y));
    Q = sum(exp((shape-1)*y)+(shape-1)*exp(shape*y));
    R = length(data)-sum(y.*(1-exp(-y)));
    dLda = -(P+Q)/scale/shape;
    dLdb = -Q/scale;
    dLdk = -(R-(P+Q)/shape)/shape;
    dPdb = -sum(exp((shape-1)*y))/scale;
    dPda = sum(exp(-y))/scale/shape+dPdb/shape;
    dQdb = sum(exp((2*shape-1)*y));
    dQdb = (dQdb+shape*sum(exp(2*shape*y)))*(1-shape)/scale;
    dQda = sum(exp((shape-1)*y));
    dQda = -(dQda+shape*sum(shape*y))*(1-shape)/scale/shape + dQdb/shape;    
    dRda = length(data)-sum(exp(shape*y))+sum(y.*exp(-y))-sum(exp(-y));
    dRda = dRda+sum(exp((shape-1)*y))-sum(y.*exp((shape-1)*y));
    dRda = -dRda/scale/shape;
    dRdk = (sum(y)-sum(y.*exp(-y))+sum(y.*y.*exp(-y))-scale*dRda)/shape;
    dRdb = (sum(exp(shape*y).*(1-exp(-y)+y.*exp(-y))))/scale;
    d2Lda2 = -dLda/scale-(dPda+dQda)/scale/shape;
    d2Ldab = -(dPdb+dQdb)/scale/shape;
    d2Ldak = -(dRda+dLda+scale*d2Lda2)/shape;
    d2Ldb2 = -dQdb/scale;
    d2Ldbk = -(dRdb+scale*d2Ldab)/shape;
    d2Ldk2 = -(dRdk+dLdk+scale*d2Ldak)/shape;
    V = - [d2Ldk2, d2Ldak, d2Ldbk;
           d2Ldak, d2Lda2, d2Ldab;
           d2Ldbk, d2Ldab, d2Ldb2];
    cov = real(inv(V));
  end
end
 

if (nargout>2)&~isempty(cov)
  alpha2 = ones(1,3)*0.05/2;
  var = diag(cov).';
  pci = wnorminv([alpha2;1-alpha2], [phat;phat],[var;var]);
end

% Plotting,  JR 9909
if plotflag
  sd=sort(data);
  empdistr(sd(:),[sd(:), wgevcdf(sd(:),shape,scale,location)],plotflag)
  if strcmpi(method,'pwm'),
    str = 'PWM';
  else
    str = 'ML';
  end
  title([deblank(['Empirical and GEV estimated cdf (',str,' method)'])])
end




