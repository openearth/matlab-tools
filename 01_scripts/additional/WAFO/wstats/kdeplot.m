function [fx] = kdeplot(data,g,plotflag,h)
%KDEPLOT Computes and plots a kernel density estimate of PDF
%          and optionally compares it with density g.
%
%  CALL:  f = kdeplot(data,g,plotflag,h);
%
%         f = kernel density estimate of data, two column matrix.
%      data = data vector.
%         g = pdf, two column matrix (optional).
%  plotflag = 0  no plotting
%             1 plot pdf (default)
%         h = user specified bandwidth (optional)
%             if not specified kdefun uses a two-stage
%             direct plug-in method (see hldpi).
%
% Example:
%   R = wgumbrnd(2,12,[],1,100);
%   x = linspace(5,30,200);
%   kdeplot(R,[x;wgumbpdf(x,2,12)]')
%
% See also  kdefun, hldpi

% Tested on: Matlab 5.3
% History:
% revised pab oct2005
%  -changed call to kdefun due to new options structure
% revised pab 4 nov. 2004
%  -kernel used in the call to hldpi changed from 'epan' to 'gauss'
%  because gauss kernel is the only supported one.  
% added ms 2000.08.22

error(nargchk(1,4,nargin))
data=data(:);

if nargin<3|isempty(plotflag),
  plotflag=1;
end

if nargin<2
  g=[];
end

kernel = 'gauss';
if nargin<4
  h=hldpi(data,kernel);
end


x=linspace(min(data)-h,max(data)+h,200);

options = { 'kernel', kernel,'hs', h};
f = kdefun(data,options,x);

if plotflag
    plot(x,f)
    title('PDF')
    ylabel(['f(x)'])
     xlabel('x')
    if ~isempty(g),
      hold on,
      plot(g(:,1),g(:,2),'r--'),hold off
    end
end

x=x(:);
f=f(:);
if nargout>0
  fx=[x f];
end

   
