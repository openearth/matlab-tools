function f = wtpdf(x,df,disable)
%WTPDF  Student's T probability density function
%
% CALL:  f = wtpdf(x,df)
%
%   f = density function evaluated at x
%   x = matrix
%   df = degrees of freedom (1,2,....)
%
% Example:
%   x = linspace(-5,5,200);
%   p1 = wtpdf(x,1); p2 = wtpdf(x,5);
%   plot(x,p1,x,p2)

% tested on matlab 5.3
%History:
%revised pab 29.10.2000
% adapted from stixbox changed name to wtpdf
% -added nargchk + check on floor(df)==df
% - changed from gamma to gammaln for more stable computation
% - added the secret option disable in order to use this function for MLE
%   estimation 
%  by Anders Holtsberg, 18-11-93
%     Copyright (c) Anders Holtsberg

error(nargchk(2,3,nargin))
[errorcode x,df]=comnsize(x,df);
if errorcode>0,
  error('x and df must be of common size or scalar');
end
if nargin<3|isempty(disable), disable=0;end

f=zeros(size(x));
mxdf=10^7;

if disable,
  ok = (0<df); % disable check on df
else
  ok = (0<df & df==floor(df));
end
k=find(ok & df<mxdf);
if any(k), % use gammaln for more stable computation for large df
  tmp = exp(gammaln((df(k)+1)/2)-gammaln(df(k)/2))./sqrt(df(k));
  f(k) = tmp./sqrt(pi).*(1+x(k).^2./df(k)).^(-(df(k)+1)/2);  
end


k1=find(ok & df>mxdf);
if any(k1)
  f(k1)=wnormpdf(x(k1),0,1);
end
  
k2 = find(~ok);
if any(k2)
  f(k2)=NaN;
end
