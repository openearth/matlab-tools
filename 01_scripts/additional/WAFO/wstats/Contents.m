% Module WSTATS in WAFO Toolbox. 
% Version 2.1.1  07-Sep-2005
%
% What's new
%   Readme     - New features, bug fixes, and changes in WSTATS. 
%
% Parameter estimation
%   loglike    - Log-likelihood function
%   wbetafit   - Parameter estimates for Beta data
%   wchi2fit   - Parameter estimates for Chi squared data
%   wexpfit    - Parameter estimates for Exponential data
%   wgamfit    - Parameter estimates for Gamma data
%   wgamafit   - Is an internal routine for wgamfit
%   wgevfit    - Parameter estimates for GEV data
%   wgevlike   - Is an internal routine for wgevfit
%   wggamfit   - Parameter estimates for Generalized Gamma data
%   wggambfit  - Is an internal routine for wggamfit
%   wgpdfit    - Parameter estimates for GPD data
%   wgpdfit_ml - Internal routine for wgpdfit (ML estimates for GPD data)
%   wgumbfit   - Parameter estimates for Gumbel data
%   wgumbafit  - Is an internal routine for wgumbfit
%   winvgfit   - Parameter estimates for Inverse Gaussian data
%   wlognfit   - Parameter estimates for Lognormal data
%   wnormfit   - Parameter estimates for Normal data
%   wraylfit   - Parameter estimates for Rayleigh data
%   wtraylfit  - Parameter estimates for Truncated Rayleigh data
%   wtfit      - Parameter estimates for Student's T data
%   wweibfit   - Parameter estimates for Weibull data
%   wweibcfit  - Is an internal routine for wweibfit
%   wtweibfit  - Parameter estimates for Truncated Weibull data
%   wtweibfun  - Is an internal routine for wtweibfit
%   weib2dfit  - Parameter estimates for 2D Weibull data
%   weib2dlike - 2D Weibull log-likelihood function
%   dist2dfit  - Parameter estimates for DIST2D data
%   dist2dsmfun  - Smooths the conditional DIST2D distribution parameters
%   dist2dsmfun2 - Smooths the conditional DIST2D distribution parameters
%   mdist2dfit   - Parameter estimates for MDIST2D data
%   mdist2dlike  - MDIST log-likelihood function
%
% Probability density functions (pdf)
%   wbetapdf   - Beta probability density function 
%   wchi2pdf   - Chi squared probability density function
%   wexppdf    - Exponential probability density function
%   wfpdf      - Snedecor's F probability density function 
%   wfrechpdf  - Frechet probability density function
%   wgampdf    - Gamma probability density function
%   wggampdf   - Generalized Gamma probability density function
%   wgevpdf    - Generalized Extreme Value probability density function
%   wgpdpdf    - Generalized Pareto probability density function
%   wgumbpdf   - Gumbel probability density function
%   winvgpdf   - Inverse Gaussian probability density function
%   wlognpdf   - Lognormal probability density function
%   wnormpdf   - Normal probability density function
%   mvnormpdf  - Multivariate Normal probability density function
%   wraylpdf   - Rayleigh probability density function
%   wtraylpdf  - Truncated Rayleigh probability density function
%   wtpdf      - Student's T probability density function 
%   wweibpdf   - Weibull probability density function
%   wtweibpdf  - Truncated Weibull probability density function
%   weib2dpdf  - 2D Weibull probability density function (pdf)
%   weib2dpdf2 - Joint 2D Weibull probability density function 
%   dist2dpdf  - Joint 2D PDF computed as f(x1|X2=x2)*f(x2) 
%   dist2dpdf2 - Joint 2D PDF computed as f(x1|X2=x2)*f(x2)
%   mdist2dpdf - Joint 2D PDF due to Plackett given as  f{x1}*f{x2}*G(x1,x2;Psi)
%   mdist2dpdf2 - Joint 2D PDF due to Plackett given as  f{x1}*f{x2}*G(x1,x2;Psi)
%
% Cumulative distribution functions (cdf)
%   wbetacdf   - Beta cumulative distribution function 
%   wchi2cdf   - Chi squared cumulative distribution function
%   wexpcdf    - Exponential cumulative distribution function
%   wfcdf      - Snedecor's F cumulative distribution function 
%   wfrechcdf  - Frechet cumulative distribution function
%   wgamcdf    - Gamma cumulative distribution function
%   wggamcdf   - Generalized Gamma cumulative distribution function
%   wgevcdf    - Generalized Extreme Value cumulative distribution function
%   wgpdcdf    - Generalized Pareto cumulative distribution function
%   wgumbcdf   - Gumbel cumulative distribution function
%   winvgcdf   - Inverse Gaussian cumulative distribution function
%   wlogncdf   - Lognormal cumulative distribution function
%   wnormcdf   - Normal cumulative distribution function
%   wraylcdf   - Rayleigh cumulative distribution function
%   wtraylcdf  - Truncated Rayleigh cumulative distribution function
%   wtcdf      - Student's T  cumulative distribution function 
%   wweibcdf   - Weibull cumulative distribution function
%   wtweibcdf  - Truncated Weibull cumulative distribution function
%   weib2dcdf  - Joint 2D Weibull cumulative distribution function 
%   weib2dprb  - Returns the probability for rectangular regions. 
%   dist2dcdf  - Joint 2D CDF computed as int F(X1<v|X2=x2).*f(x2)dx2 
%   dist2dfun  - Is an internal function to dist2dcdf dist2dprb.
%   dist2dprb  - Returns the probability for rectangular regions.
%   mdist2dcdf - Joint 2D CDF due to Plackett
%
% Inverse cumulative distribution functions
%   wbetainv   - Inverse of the Beta distribution function 
%   wchi2inv   - Inverse of the Chi squared distribution function
%   wexpinv    - Inverse of the Exponential distribution function
%   wfinv      - Inverse of the Snedecor's F distribution function
%   wgaminv    - Inverse of the Gamma distribution function
%   wggaminv   - Inverse of the Generalized Gamma distribution function
%   wgevinv    - Inverse of the Generalized Extreme Value distribution function
%   wgpdinv    - Inverse of the Generalized Pareto distribution function
%   wgumbinv   - Inverse of the Gumbel distribution function
%   winvginv   - Inverse of the Inverse Gaussian distribution function
%   wlogninv   - Inverse of the Lognormal distribution function
%   wnorminv   - Inverse of the Normal distribution function
%   wraylinv   - Inverse of the Rayleigh distribution function
%   wtinv      - Inverse of the Student's T distribution function
%   wweibinv   - Inverse of the Weibull distribution function
%   weib2dcinv - Inverse of the conditional 2D weibull cdf of X2 given X1.
%   mdist2dcinv - Inverse of the conditional cdf of X2 given X1.
%
% Random number generators
%   walpharnd  - Random matrices from a symmetric alpha-stable distribution
%   wbetarnd   - Random matrices from an Beta distribution 
%   wchi2rnd   - Random matrices from a Chi squared distribution
%   wexprnd    - Random matrices from an Exponential distribution
%   wfrnd      - Random matrices from a Snedecor's F distribution
%   wfrechinv  - Inverse of the Frechet distribution function
%   wgamrnd    - Random matrices from a Gamma distribution
%   wggamrnd   - Random matrices from a Generalized Gamma distribution
%   wgevrnd    - Random matrices from a Generalized Extreme-Value distribution
%   wgpdrnd    - Random matrices from a Generalized Pareto Distribution
%   wgumbrnd   - Random matrices from a Gumbel distribution
%   winvgrnd   - Random matrices from an Inverse Gaussian distribution
%   wlognrnd   - Random matrices from a Lognormal distribution
%   wmnormrnd  - Random vectors from a multivariate Normal distribution
%   wnormrnd   - Random matrices from a Normal distribution
%   wraylrnd   - Random matrices from a Rayleigh distribution
%   wtrnd      - Random matrices from a Student's T distribution
%   wweibrnd   - Random matrices from a Weibull distribution
%   weib2drnd  - Random numbers from the 2D Weibull distribution.
%   dist2drnd  - Random points from a bivariate DIST2D distribution
%   mdist2drnd - Random points from a bivariate MDIST2D distribution 
%
% Statistics
%   wbetastat  - Mean and variance for the Beta distribution.
%   wchi2stat  - Mean and variance for the Chi squared distribution
%   wexpstat   - Mean and variance for the Exponential distribution
%   wfstat     - Mean and variance for the Snedecor's F distribution
%   wfrechstat - Mean and variance for the Frechet distribution
%   wgamstat   - Mean and variance for the Gamma distribution
%   wggamstat  - Mean and variance for the Generalized Gamma distribution
%   wgevstat   - Mean and variance for the GEV distribution
%   wgpdstat   - Mean and variance for the Generalized Pareto distribution
%   wgumbstat  - Mean and variance for the Gumbel distribution
%   winvgstat  - Mean and variance for the Inverse Gaussian distribution
%   wlognstat  - Mean and variance for the Lognormal distribution
%   wnormstat  - Mean and variance for the Normal distribution
%   wraylstat  - Mean and variance for the Rayleigh
%   wtstat     - Mean and variance for the Student's T  distribution
%   wweibstat  - Mean and variance for the Weibull distribution
%   weib2dstat - Mean and variance for the 2D Weibull distribution 
%   dist2dstat - Mean and variance for the DIST2D distribution 
%   mdist2dstat - Mean and variance for the MDIST2D distribution 
%
% Descriptive Statistics
%   mean       - Computes sample mean (in matlab toolbox)
%   median     - Computes sample median value (in matlab toolbox)
%   std        - Computes standard deviation (in matlab toolbox)
%   var        - Computes sample variance (in matlab toolbox)
%   cov        - Computes sample covariance matrix (in matlab toolbox)
%   corrcoef   - Computes sample correlation coefficients (in matlab toolbox)
%   wkurtosis  - Computes sample kurtosis
%   wskewness  - Computes sample skewness
%   iqr        - Computes the Inter Quartile Range 
%   range      - Calculates the difference between maximum and minimum values
%
% Statistical plotting
%   wgumbplot  - Plots data on a Gumbel distribution paper
%   wnormplot  - Plots data on a Normal distribution paper
%   wweibplot  - Plots data on a Weibull distribution paper
%   wexpplot   - Plots data on a Exponential distribution paper
%   wraylplot  - Plots data on a Rayleigh distribution paper
%   wqqplot    - Plots empirical quantile vs empirical quantile 
%   distplot   - Displays a 1D distribution probability plot
%   empdistr   - Computes and plots the empirical CDF
%   cempdistr  - Computes and plots the conditional empirical CDF
%   whisto     - Plots a histogram
%   kdeplot    - Computes and plots a kernel estimate of PDF
%   identify   - Identify points on a plot by clicking with the mouse. 
%   pairs      - Pairwise scatter plots.
%   weib2dcdfplot   - Plot conditional empirical CDF of X1 given X2=x2 
%   weib2dstatplot  - Computes and plots the conditional mean and standard deviation
%   dist2dcdfplot   - Plot conditional empirical CDF of X1 given X2=x2 
%   dist2dparamplot - Plot parameters of the conditional distribution 
%   dist2dstatplot  - Computes and plots the conditional mean and standard deviation 
%   mdist2dcdfplot  - Plot conditional empirical CDF of X1 given X2=x2 
%   mdist2dstatplot - Computes and plots the conditional mean and standard deviation 
%
% Hypothesis Tests
%   wgumbtest  - Tests whether the shape parameter in a GEV is equal to zero
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
%   getmodel   - Return the model parameters
%   sudg       - Some Useful Design Generators
%   cplot      - Cubic plot of responses
%   nplot      - Normal probability plot of effects
%
% Misc
%   comnsize   - Check if all input arguments are either scalar or of common size. 





