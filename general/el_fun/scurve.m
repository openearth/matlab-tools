function s = scurve(x,varargin)
%SCURVE
%
% scurve(x,yinf,ymininf,x0,L)
%
% Gives the following s-curve 
%
% y = (ymininf + yinf*exp((x-dx)./L))./...
%     (1       +    1*exp((x-dx)./L));
%
% with default values (as in figure)
%
% yinf    = +1;ymininf = -1;
% x0      =  0;L       =  1;
% 
% This gives an scurve centered at (0,0)
% with y = yinf    for x/xo towards +Inf  
% with y = ymininf for x/xo towards -Inf  
%
%            y       
% yinf       ^           -------
%            |      x0 /
%        ----+-------/---------> x
%            |     /  
% ymininf --------   
%            |    <-----> ~ 2 L
%            |

%
% G.J. de Boer, TU Delft
% Copyright nov 2004


yinf    =  1;
ymininf = -1;
x0      =  0;
L       =  1;

if nargin>1
   yinf     = varargin{1};
end
if nargin>2
   ymininf = varargin{2};
end
if nargin>3
   x0      = varargin{3};
end
if nargin>4
   L       = varargin{4};
end

s = (ymininf + yinf.*exp((x-x0)./L))./...
    (1       +       exp((x-x0)./L));
