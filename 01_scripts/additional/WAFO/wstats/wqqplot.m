function h=wqqplot(x,y,ps);
%WQQPLOT   Plot empirical quantile of X vs empirical quantile of Y
%
% CALL:  h = wqqplot(x,y,ps)
%
%  h   = handle to the plotted figure
%  x,y = data 
%  ps  = plot symbol (default '+')
%
% If two distributions are the same (or possibly linearly 
% transformed) the points should form an approximately straight 
% line.
%
% Example:
%   R1=wgumbrnd(1,0,[],1,100);
%   R2=wgumbrnd(2,2,[],1,100);
%   wqqplot(R1,R2)
%
% See also  wquantile

% testen on: matlab 5.3
% History:
% revised pab 24.10.2000
% added nargchk
% updated header to comform to wafo style
error(nargchk(2,3,nargin))
if nargin<3, ps = '+'; end
x = sort(x);
y = sort(y);
if length(x) < length(y)
   n = length(x);
   h=plot(x, wquantile(y, ((1:n)-0.5)/n, 1), ps);
elseif length(y) < length(x)
   n = length(y);
   h=plot(wquantile(x, ((1:n)-0.5)/n, 1), y, ps);
else
   h=plot(x,y,ps);
end
xlabel('Data X')
ylabel('Data Y')
