function [ll,cov] = wgevlike(p,sample)  
%WGEVLIKE Is an internal routine for wgevfit
%        
% CALL:  [L,cov] = wgevlike(phat,sample);
%
%    L    = -log(f(phat|sample)), i.e., the log-likelihood function
%           with parameters phat given the data.
%    cov  = Asymptotic covariance matrix of phat (if phat is estimated by
%           a maximum likelihood method).
%  phat   = Parameters in distribution
%           [k s m] = [shape scale location].  (see wgevcdf)
%  sample = the vector of data points.
%
% WGEVLIKE is a utility function for maximum likelihood estimation
% and is used by routine wgevfit.
%
% Example:
%   R = wgevrnd(-0.2,3,0,1,100);                      
%   phat0 = [-0.2 3 0];       % initial guess
%   phat = fminsearch('wgevlike',phat0,[],R)
%   [L, cov] = wgevlike(phat,R)
%
% See also  wgevfit, wgevcdf

% Tested  on Matlab  5.3
%
% History:
% Revised by PJ (Pär Johannesson) 08-Mar-2000
%   updated for WAFO
%   Needed by GEVFIT for method 'ml'.
% Copied from WAT Ver. 1.1
% revised ms 14.06.2000
% - updated header info
% - changed name to wgevlike (from gevll)
% revised pab 01.11.2000
% - added cov (from wgevfit)

error(nargchk(2,2,nargin))

sample = sample(:); % make sure it is a vector
N=length(sample);
y = -log(1-p(1)*(sample-p(3))/p(2))/p(1);
ll=N*log(p(2))+(1-p(1))*sum(y)+sum(exp(-y));

if nargout>1,
  % Calculate the covariance matrix by inverting the observed information. 
    shape = p(1);
    scale = p(2);
    location = p(3);
    y = -log(1-shape*(sample-location)/scale)/shape;
    P = N-sum(exp(-y));
    Q = sum(exp((shape-1)*y)+(shape-1)*exp(shape*y));
    R = N-sum(y.*(1-exp(-y)));
    dLda = -(P+Q)/scale/shape;
    dLdb = -Q/scale;
    dLdk = -(R-(P+Q)/shape)/shape;
    dPdb = -sum(exp((shape-1)*y))/scale;
    dPda = sum(exp(-y))/scale/shape+dPdb/shape;
    dQdb = sum(exp((2*shape-1)*y));
    dQdb = (dQdb+shape*sum(exp(2*shape*y)))*(1-shape)/scale;
    dQda = sum(exp((shape-1)*y));
    dQda = -(dQda+shape*sum(shape*y))*(1-shape)/scale/shape + dQdb/shape;    
    dRda = N-sum(exp(shape*y))+sum(y.*exp(-y))-sum(exp(-y));
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
