%README Readme file for module WSTATS in WAFO Toolbox.
%
% Version 2.1.1   07-Jul-2005
%
%  FIXES
%  ~~~~~
%  wgpdpdf - fixed bug for k==0 now fixed
%  wgpdcdf - distribution for k==0 was wrong, now fixed

%  kdeplot - Default kernel used in the call to hldpi changed from 'epan'
%            to 'gauss' because gauss kernel is the only supported one.  
%  mdist2dfit   - replaced fmins with fminsearch  
%  weib2dfit    - replaced fmins with fminsearch  
%  wggamstat    - fixed a bug
%  wggamfit     - Added secret option of C0
%  wtweibfit    - minor fix
%  dist2dsmfun  - minor fix
%  dist2dsmfun2 - minor fix
%  dist2dfit    - Added secret option of C0 to wggamfit 
%  
%-------------------------------------------------------------------
% Version 2.1.0   07-Apr-2004
%
% Bug fixes, some new and/or updated routines.
%  
%  FIXES
%  ~~~~~
%  wnormpdf - Fixed a bug
%  wnormcdf - changed call from erf to erfc in order  
%              to get more accurate lower tail probabilities
%  wnorminv - replaced erfinv with PHIINV which perform more accurate 
%             inversion in the lower tail. This also results in faster execution.
%  wtcdf    - added new methods for df==1 or df==2 and for region1= x^2<df^2 
%  wtinv    - added new method for df==2 
%   
% 
%  NEW FUNCTIONS
%  ~~~~~~~~~~~~~
%  MVNORMPDF  multivariate Normal probability density function
%
%-------------------------------------------------------------------
% Version 2.0.5   14-Jun-2003
%
% Bug fixes, some new and/or updated routines.
% 
%  NEW FUNCTIONS
%  ~~~~~~~~~~~~~
%  WEXPPLOT   plots data on a Exponential distribution paper
%  WFRECHCDF  Frechet cumulative distribution function
%  WFRECHPDF  Frechet probability density function
%  WFRECHINV  Inverse of the Frechet distribution function
%  WFRECHSTAT Mean and variance for the Frechet distribution.
%
%--------------------------------------------------------------------
% Version 2.0.4   11-Apr-2001
% 
% This file describes new features, bug fixes, and changes in this version 
% of the WAFO/wstats Toolbox.
%
% List of changes:
% 
% NOTE:
% Items marked with:
%       (N)  : needs a new  name 
%        *   : not yet available
%        +   : needs more work
%        **  : have changed in a way which might affect your code!
%
% 
%  FIXES
%  ~~~~~
%   Some but too small to mention.
%
%
%  ENHANCEMENTS
%  ~~~~~~~~~~~~
%   - All the PDF's, CDF's and STAT's function now check if the input arguments
%    are either scalar or of common size. Scalar inputs are transformed to 
%    to a constant matrix with size equal to the common size of the non-scalar arguments.
%    This is useful for implementing functions where arguments can either
%    be scalars or of common size. 
%
%   - (**) wggampdf,wggamcdf, wggamfit, wggamstat: The order of the distribution parameters 
%     are changed so that they have the same order as wgamXXX.m functions, i.e.,
%     wgampdf(x,a,b) is now the same as wggampdf(x,a,b,1).
%
%   - (**) the order of input arguments to wgumbrnd are changed  in order to implement
%     a more flexible sizing of the output. New CALL: R = wgumbrnd(a,b,trunc,sz) 
%  
%   - cempdistr and empdistr now allows to overplot the figure. Also different 
%     plot symbols may be given.
%   
%   - LOGLIKE is a utility function for maximum likelihood estimation. 
%     This works on any PDF having the following calling syntax:
%
%       f = testpdf(x1,x2,..,xN,A1,A2,..,Am)
%
%     where x1,x2,...,xN contain the points to be evaluated and A1,A2... are
%     the distribution parameters. 
%     LOGLIKE also calculates the asymptotic covariance matrix of phat=[A1,...,Am] 
%     (if phat is estimated by a maximum likelihood method). This estimate is 
%     usually better than the estimates returned by the log-likelihood functions
%     implemented in MATLAB's  STATS toolbox.
%
%   - An option for Maximum Likelihood estimation added in wgpdfit. The ML estimates usually 
%     gives best results. One problem with the other methods of estimation (pkd/mom/pwm) is 
%     that the estimates may be inconsistant with the data, i.e. when k>0 the estimated upper 
%     end point (=s/k) of the distribution is often lower than the maximal observation. Try:
%       sample = wgpdrnd(0.3,1,0,200,1);
%       [phat] = wgpdfit(sample,'pwm');
%       [phat(2)/phat(1) max(sample)]  % Estimated upper end point  AND  maximal observation
%
%   - New routines for Design of Experiments (see list of new functions).
%
%
%  NEW FUNCTIONS
%  ~~~~~~~~~~~~~
%  
% Parameter estimation
%   dist2dfit  - Parameter estimates for DIST2D data.
%   mdist2dfit - Parameter estimates for MDIST2D data. 
%   dist2dsmfun - Smooths the conditional DIST2D distribution parameters. 
%   dist2dsmfun2 - Smooths the conditional DIST2D distribution parameters.
%   mdist2dlike - MDIST log-likelihood function. 
%   loglike    - Log-likelihood function. 
%   wbetafit   - Parameter estimates for Beta data.
%   wchi2fit   - Parameter estimates for Chi squared data.
%   weib2dfit   - Parameter estimates for 2D Weibull data. 
%   wtfit      - Parameter estimates for Student's T data.
%   weib2dlike - 2D Weibull log-likelihood function.
%   iqr        - Computes the Inter Quartile Range 
%   range      - Calculates the difference between the maximum and minimum values.
%
% Probability density functions (pdf)
%   dist2dpdf  - Joint 2D PDF computed as f(x1|X2=x2)*f(x2) 
%   dist2dpdf2 - Joint 2D PDF computed as f(x1|X2=x2)*f(x2)
%   mdist2dpdf - Joint 2D PDF due to Plackett given as  f{x1}*f{x2}*G(x1,x2;Psi). 
%   mdist2dpdf2 - Joint 2D PDF due to Plackett given as  f{x1}*f{x2}*G(x1,x2;Psi). 
%   wbetapdf   - Beta probability density function 
%   weib2dpdf  - 2D Weibull probability density function (pdf). 
%   weib2dpdf2 - Joint 2D Weibull probability density function 
%   wfpdf      - Snedecor's F probability density function
%   wtpdf      - Student's T probability density function 
%
% Cumulative distribution functions (cdf)
%   dist2dcdf  - Joint 2D CDF computed as int F(X1<v|X2=x2).*f(x2)dx2 
%   dist2dfun  - Is an internal function to dist2dcdf dist2dprb.
%   dist2dprb  - Returns the probability for rectangular regions.
%   mdist2dcdf - Joint 2D CDF due to Plackett
%   wbetacdf   - Beta cumulative distribution function 
%   weib2dcdf  - Joint 2D Weibull cumulative distribution function 
%   weib2dprb  - Returns the probability for rectangular regions. 
%   wfcdf      - Snedecor's F cumulative distribution function 
%   wtcdf      - Student's T  cumulative distribution function 
%
% Inverse cumulative distribution functions
%   mdist2dcinv - Inverse of the conditional cdf of X2 given X1.
%   wbetainv   - Inverse of the Beta distribution function 
%   wchi2inv   - Inverse of the Chi squared distribution function
%   weib2dcinv - Inverse of the conditional 2D weibull cdf of X2 given X1.
%   wfinv      - Inverse of the Snedecor's F distribution function
%   wtinv      - Inverse of the Student's T distribution function
%
% Random number generators
%   dist2drnd  - Random points from a bivariate DIST2D distribution
%   mdist2drnd - Random points from a bivariate MDIST2D distribution 
%   wbetarnd   - Random matrices from a Beta distribution 
%   wfrnd      - Random matrices from a Snedecor's F distribution
%   wtrnd      - Random matrices from a Student's T distribution
%
% Statistical plotting
%   dist2dcdfplot - Plot conditional empirical CDF of X1 given X2=x2 
%   dist2dparamplot - Plot parameters of the conditional distribution 
%   dist2dstatplot - Computes and plots the conditional mean and standard deviation 
%   identify   - Identify points on a plot by clicking with the mouse. 
%   mdist2dcdfplot - Plot conditional empirical CDF of X1 given X2=x2 
%   mdist2dstatplot - Computes and plots the conditional mean and standard deviation. 
%   weib2dcdfplot - Plot conditional empirical CDF of X1 given X2=x2 
%   weib2dstatplot - Computes and plots the conditional mean and standard deviation
%   pairs      - Pairwise scatter plots.
%
% Statistics
%   dist2dstat - Mean and variance for the DIST2D distribution 
%   mdist2dstat - Mean and variance for the MDIST2D distribution 
%   wbetastat  - Mean and variance for the Beta distribution.
%   weib2dstat - Mean and variance for the 2D Weibull distribution 
%   wfstat     - Mean and variance for the Snedecor's F distribution.
%   wtstat     - Mean and variance for the Student's T  distribution.
%
% Design of Experiments
%   yates      - Calculates main and interaction effects using Yates' algorithm.
%   ryates     - Reverse Yates' algorithm to give estimated responses
%   fitmodel   - Fits response by polynomial
%   alias      - Alias structure of a fractional design
%   cdr        - Complete Defining Relation
%   cl2cnr     - Column Label to Column Number
%   cnr2cl     - Column Number to Column Label
%   ffd        - Two-level Fractional Factorial Design
%   sudg       - Some Useful Design Generators
%   cplot      - Cubic plot of responses
%   nplot      - Normal probability plot of effects
%
% Misc
%   comnsize   - Check if all input arguments are either scalar or of common size. 

