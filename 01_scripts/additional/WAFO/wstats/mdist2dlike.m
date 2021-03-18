function [LL, cov] = mdist2dlike(params,data1,data2,dist)
%MDIST2DLIKE MDIST log-likelihood function.
%
% CALL:  [L, cov] = mdist2dlike(params,x1,x2,dist)
%
%      L = the MDIST log-likelihood 
%   cov  = Asymptotic covariance matrix of phat (if phat is estimated by
%                  a maximum likelihood method).
% params = [phat.x{:}] is the distribution parameters 
%  x,x2  = data vector or matrices with common size.
%  dist  = list of marginal distributions of x1 and x2, respectively 
%          Options are: 'tgumbel', 'gumbel', 
%          'lognormal','rayleigh','weibull','gamma'.
%
%   MDIST2DLIKE is a utility function for maximum likelihood estimation. 
%
% Example: 
%  [L, C] = mdist2dlike([1 2 2 10],x1,x2,{'weibull','rayleigh'})
%
% See also   mdist2dfit, mdist2dpdf, mdist2dcdf, mdist2drnd
%


%  tested on: matlab 5.2
% history
% revised  pab 03.11.2000
% - improved the calculation of cov
% revised pab 8.11.1999
%  - updated header info
%  by Per A. Brodtkorb 01.02.99 


if nargin < 3, 
    error('Requires at least FOUR input arguments'); 
end

if (nargin< 4)|isempty(dist), 
  error('Too few inputs')
else
  HDIST=lower(dist{2});
  VDIST=lower(dist{1});
end



switch VDIST(1:2),
  case 'ra', nv=1;
 otherwise, nv=2;
end
switch HDIST(1:2),
  case 'ra', nh=1;
 otherwise, nh=2;
end

if nv+nh+1~=length(params)
 error('param is not the right size')
end
 
data1=data1(:);
data2=data2(:);
[n, m] = size(data1);
[n2, m2] = size(data2);
if n~=n2
  error('data1 and data2  must have equal size')
end

if nargout == 2 & max(m,n) == 1
  error('To compute the 2nd output, the 2nd input must have at least two elements.');
end
phat.x{1}=params(1:nv);phat.x{2}=params(nv+1:end-1);phat.x{3}=params(end);
phat.dist=dist;

x = mdist2dpdf(data1,data2,phat,0)+eps;
LL = -sum(log(x)); % log likelihood function

if nargout > 1
  np=nv+nh+1; % # of parameters we estimate
  sparam=params;
  delta = eps^.4;
  delta2=delta^2;

  dist0 ='mdist2dpdf';
  % Approximate 1/(nE( (d L(x|theta)/dtheta)^2)) with
  %             1/(d^2 L(theta|x)/dtheta^2) 
  %  using central differences
    
  H = zeros(np);             % Hessian matrix
  for ix=1:np,
    sparam = params;
    sparam(ix)= params(ix)+delta;
    phat.x{1}=params(1:nv);phat.x{2}=params(nv+1:end-1);phat.x{3}=params(end);
    x  = feval(dist0,data1,data2,phat)+eps; 
    fp = sum(log(x));
    sparam(ix) = params(ix)-delta;
    phat.x{1}=params(1:nv);phat.x{2}=params(nv+1:end-1);phat.x{3}=params(end);
    x  = feval(dist0,data1,data2,phat)+eps; 
    fm = sum(log(x));
    H(ix,ix) = (fp+2*LL+fm)/delta2;
    for iy=ix+1:np,
      sparam(ix) = params(ix)+delta;
      sparam(iy) = params(iy)+delta;
      phat.x{1}=params(1:nv);phat.x{2}=params(nv+1:end-1);phat.x{3}=params(end);
      
      x   = feval(dist0,data1,data2,phat)+eps; 
      fpp = sum(log(x));
      sparam(iy) = params(iy)-delta;
      phat.x{1}=params(1:nv);phat.x{2}=params(nv+1:end-1);phat.x{3}=params(end);
      x   = feval(dist0,data1,data2,phat)+eps; 
      fpm = sum(log(x));
      sparam(ix) = params(ix)-delta;
      phat.x{1}=params(1:nv);phat.x{2}=params(nv+1:end-1);phat.x{3}=params(end);
      x   = feval(dist0,data1,data2,phat)+eps; 
      fmm = sum(log(x));
      sparam(iy) = params(iy)+delta;
      phat.x{1}=params(1:nv);phat.x{2}=params(nv+1:end-1);phat.x{3}=params(end);
      x   = feval(dist0,data1,data2,phat)+eps; 
      fmp = sum(log(x));
      H(ix,iy) = (fpp-fmp-fpm+fmm)/(4*delta2);
      H(iy,ix) = H(ix,iy);
    end
  end
  % invert the Hessian matrix (i.e. invert the observed information number)
  cov = -H\eye(np); 
  
end
