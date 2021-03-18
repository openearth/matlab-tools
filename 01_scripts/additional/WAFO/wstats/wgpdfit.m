function [parms,cov] = wgpdfit(data,method,plotflag) 
%WGPDFIT Parameter estimates for Generalized Pareto data
%
% CALL:  [phat,cov] = wgpdfit(data,method,plotflag)
%
%         phat = Estimated parameters (see wgpdcdf)
%                [k s] = [shape scale]  
%        cov   = covariance matrix of estimates
%        data  = an one-dimensional data set
%       method = a string, describing the method of estimation
%                'pkd' = Pickands' estimator (default)
%                'pwm' = Probability Weighted Moments 
%                'mom' = Moment method
%                'ml'  = Maximum Likelihood method
%     
%     plotflag = 1, plot the empiricial distribution
%                   function and the estimated cdf (default)
%              = 0, do not plot
%                  
% Estimates parameters in  the Generalized Pareto Distribution (GPD).
% The default method is PKD since it works for all values of the shape 
% parameter. The ML is valid when shape<=1, the PWM when shape>-0.5, 
% the MOM when shape>-0.25. The variances of the ML estimates are usually 
% smaller than those of the other estimators. However, for small sample 
% sizes it is recommended to use the PWM or MOM, if they are valid.
%
% Example:  
%   sample = wgpdrnd(0.3,1,0,200,1);
%   [phat,cov] = wgpdfit(sample,'pkd')
%   [phat,cov] = wgpdfit(sample,'ml')
%
% See also wgpdcdf, wgevfit, empdistr

% References
%
%  Borg, S. (1992)
%  XS - a statistical program package in Splus for extreme-value
%  analysis. 
%  Dept. of Mathematical Statistics, Lund University, 1992:E2
%
%  Davidson & Smith (1990)
%  Models for Exceedances over high Threholds.
%  Journal of the Royal Statistical Society B,52, pp. 393-442.
%
%  Grimshaw, S. D. (1993)
%  Computing the Maximum Likelihood Estimates for the Generalized Pareto Distribution.
%  Technometrics, 35, pp. 185-191.

% Tested on; Matlab 5.3
% History: 
% Revised by jr 22.12.1999
% Modified by PJ 08-Mar-2000
%   Changed 'pgpd' to 'gpdcdf' for method 'pkd'.
%   Hjälptext
%   Added 'hold off' in plotting.
%   Added line: 'data = data(:)';'
% revised ms 14.06.2000
% - updated header info
% - changed name to wgpdfit (from gpdfit)
% - added w* to used WAFO-files
% Updated by PJ 22-Jun-2000
%   Added new method 'ml', maximum likelihood estimation of 
%   parameters in GPD.
% Correction by PJ 19-Jul-2000
%   Found error in the covariance matrix for method 'ml'. Now correct!
%   Some other small changes in method 'ml'
% Correction by PJ 30-Nov-2000
%   Updated method 'ml'. New method for finding start values for numerical solving.
%   Updated help text, and some other small changes.
% Correction by PJ 11-Dec-2000
%   Now method 'ml' works with Matlab <5.3. ('fzero' changed format)

% Check input
ni = nargin;
no = nargout;
error(nargchk(1,3,ni));

if ni < 2, method = []; end
if ni < 3, plotflag = []; end

% Default values
if isempty(method), method = 'pkd'; end
if isempty(plotflag), plotflag = 1; end

data = data(:)';  % Make sure data is a row vector, PJ 08-Mar-2000
n = length(data);
method = lower(method);

if strcmp(method,'pkd'),
  
  epsilon=1.e-4;
  xi = -sort(-data);  %  data in descending order
  x = sort(data);
  y = ((1:n)-0.5)/n;
  
  EDF=[x' y'];  
  
  % Find the M that minimizes diff. between EDF and G, the estimated cdf.
  n4=floor(n/4);
  d = 2*ones(1,n4);;
  
  for M=1:n4,
    shape = - log((xi(M)-xi(2*M))/(xi(2*M)-xi(4*M)))/log(2);
    scale = (xi(2*M)-xi(4*M));
    
    if (abs(shape) < epsilon), 
      scale = scale/log(2); 
    else 
      scale = scale*shape/(1-0.5^shape);
    end
    
    d(M) = max(abs(wgpdcdf(EDF(:,1), shape, scale)-EDF(:,2)));
    
  end    % end M-loop
  
  least = find(d(:)==min(d));
  M = least(1); % possibly more than one M; in that case use the smallest.
  
  shape = - log((xi(M)-xi(2*M))/(xi(2*M)-xi(4*M)))/log(2);
  scale = (xi(2*M)-xi(4*M));
  
  if (abs(shape) < epsilon), 
    scale = 1000*scale/log(2);
  else
    scale = scale*shape/(1-1/(2^shape));
  end
  
  cov=[];
  
elseif strcmp(method,'mom'),
  
  m=mean(data); s=std(data);
  shape = ((m/s)^2 - 1)/2;
  scale = m*((m/s)^2+1)/2;
  if (shape<=-0.25),
    cov=ones(2)*NaN;
    warning([' The estimate of shape (' num2str(shape) ') is not within the range where the Moment estimator is valid (shape>-0.25).'])
  else
    Vshape = (1+2*shape)^2*(1+shape+6*shape^2);
    Covari = scale*(1+2*shape)*(1+4*shape+12*shape^2);
    Vscale = 2*scale^2*(1+6*shape+12*shape^2);
    cov_f = (1+shape)^2/(1+2*shape)/(1+3*shape)/(1+4*shape)/n;
    cov=cov_f*[Vshape Covari; Covari, Vscale];
  end

elseif strcmp(method,'pwm'),  
  
  a0 = mean(data);
  xio = sort(data);
  p = n+0.35-(1:n);
  a1 = sum(p.*xio)/n/n;
  shape = a0/(a0-2*a1)-2;
  scale = 2*a0*a1/(a0-2*a1);
  if (shape <= -0.5),
    cov=ones(2)*NaN;
    warning([' The estimate of shape (' num2str(shape) ') is not within the range where the PWM estimator is valid (shape>-0.5).'])
  else 
    f = 1/(1+2*shape)/(3+2*shape);
    Vscale = scale^2*(7+18*shape+11*shape^2+2*shape^3);
    Covari = scale*(2+shape)*(2+6*shape+7*shape^2+2*shape^3);
    Vshape = (1+shape)*(2+shape)^2*(1+shape+2*shape^2);
    cov = f/n*[Vshape Covari; Covari, Vscale];
  end

elseif strcmp(method,'ml'),  % Maximum Likelihood
  % See Davidson & Smith (1990) and Grimshaw (1993)
  
  max_data = max(data);
  
  % Calculate start values
  % The start value can not be less than  1/max_data ,
  %   since if it happens then the upper limit of the GPD is 
  %   lower than the highest data value
  
  % Change variables, in order to avoid boundary problems in numerical solution 
  %   Transformation: x = log(1/max_data - t),   -Inf < t < 1/max_data
  %   Inverse Trans.: t = 1/max(data) - exp(x),  -Inf < x < Inf
  
  old_ver = 0;
  if old_ver  
    % Old version
    % Find a start value for the zero-search.

    if (nargin<4)   % Start values
      t_start = [];
    else  % start values from input
      if start<1/max_data
        t_start=start;
      else
        t_start = [];
      end
    end
    
    if isempty(t_start)   % compute starting values by  pwm or mom
      parms0 = wgpdfit(data,'pwm',0);
      t_start= parms0(1)/parms0(2);
    end
    if t_start>=1/max_data
      parms0 = wgpdfit(data,'mom',0);
      t_start= parms0(1)/parms0(2);
    end
    
    if t_start<1/max_data
      x_start = log(1/max_data - t_start);
    else
      x_start = 0;
    end
    
  else
    % New version
    % Find an interval where the function changes sign.
    % Gives interval for start value for the zero-search.
    % Upper and lower limits are given in Grimshaw (1993)
    
    X1=min(data); Xn=max(data); Xmean = mean(data);
    Eps = 1e-6/Xmean;
    t_L = 2*(X1-Xmean)/X1^2;     % Lower limit
    t_U = 1/Xn-Eps;              % Upper limit
    x_L = log(1/max_data - t_L); % Lower limit
    x_U = log(1/max_data - t_U); % Upper limit
    
    x=linspace(x_L,x_U,10);
    for i=1:length(x)
      f(i)=wgpdfit_ml(x(i),data);
    end
    
    I = find(f(1:end-1).*f(2:end) < 0); 
    if isempty(I)
      x_start = [];
    else
      i = I(1);
      x_start = [x(i) x(i+1)];
    end
  end
  
  if isempty(x_start)
    shape=NaN; scale=NaN; cov=ones(2)*NaN;
    warning([' Can not find an estimate. Probably the ML-estimator does not exist for this data. Try other methods.'])
  else
    % Solve the ML-equation
    if exist('optimset') >= 2 % Function 'optimset' exists ?
      % For Matlab 5.3 and higher ???
      xx = fzero('wgpdfit_ml',x_start,optimset('disp','off'),data);
      %xx = fzero('wgpdfit_ml',x_start,optimset('disp','iter'),data);
    else 
      % For Matlab 5.2 and lower ???
      xx = fzero('wgpdfit_ml',x_start,[],[],data);
    end
    
    
    % Extract estimates
    [f,shape,scale] = wgpdfit_ml(xx,data);
    
    % Calculate the covariance matrix by inverting the observed information. 
    if (shape >= 1.0),
      cov=ones(2)*NaN;
      warning([' The estimate of shape (' num2str(shape) ') is not within the range where the ML estimator is valid (shape<1).'])
    elseif (shape >= 0.5),
      cov=ones(2)*NaN;
      warning([' The estimate of shape (' num2str(shape) ') is not within the range where the ML estimator is asymptotically normal (shape<1/2).'])
    else 
      Vshape = 1-shape;
      Vscale = 2*scale^2;
      Covari = scale;
      cov = (1-shape)/n*[Vshape Covari; Covari Vscale];
    end
  end
% End ML
else
  error(['Unknown method ' method '.']);
end

% --> The parameter estimates: <--

parms = [shape scale]; 

% Plotting,  JR 9909
if plotflag 
  x = sort(data);
  empdistr(data), hold on
  plot(x, wgpdcdf(x,shape,scale)), hold off
  if strcmp(method,'ml')
    str = 'ml';
  elseif strcmp(method,'pwm')
    str = 'pwm';
  elseif strcmp(method,'mom')
    str = 'mom';
  else
    str = 'pkd';
  end
  title([deblank(['Empirical and GPD estimated cdf (',str,' method)'])])
end
