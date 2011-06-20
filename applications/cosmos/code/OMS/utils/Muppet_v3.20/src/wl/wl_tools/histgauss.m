function hOut=histgauss(varargin)
%HISTGAUSS Histogram plot with fitted Gauss curve
%     HISTGAUSS(Y)
%     Plots the normalized histogram of Y and
%     a fitted Gauss curve (normal distribution)
%
%     HISTGAUSS(...,'thresholds',X)
%     uses thresholds X instead of 20 automatically
%     chosen bins.
%
%     HISTGAUSS(...,'parent',Ax)
%     uses axes Ax for plotting

% (c) 2001/2002 H.R.A.Jagers, bert.jagers@wldelft.nl
%     WL | Delft Hydraulics, The Netherlands

Ax=[];
u1='dummy';
thresholds=[];
i=1;
while i<=nargin
  if ~ischar(varargin{i})
    if ~ischar(u1)
      error(sprintf('Unexpected argument %i',i))
    else
      u1=varargin{i};
      i=i+1;
    end
  else
    switch lower(varargin{i})
    case 'thresholds'
      thresholds=varargin{i+1};
      i=i+2;
    case 'parent'
      Ax=varargin{i+1};
      i=i+2;
    otherwise
      error(sprintf('Unrecognized keyword: %s',varargin{i}))
    end
  end
end
if ischar(u1), error('Missing data set'); end    
u1=u1(:);
if isempty(thresholds)
  thresholds=20;
end
mx=max(u1);
mn=min(u1);
if isequal(size(thresholds),[1 1]) & isequal(round(thresholds),thresholds)
  dx=(mx-mn)/thresholds;
  thresholds=transpose(mn:dx:mx);
else
  thresholds=sort(thresholds(:));
  if mn<thresholds(1), thresholds=[mn;thresholds]; end
  if mx>thresholds(end), thresholds=[thresholds;mx]; end
end

% compute the histogram
h=histc(u1,thresholds);
h(end-1)=h(end-1)+h(end); h(end)=0;
dx=diff(thresholds);
h(1:end-1)=h(1:end-1)/length(u1)./dx;

% start by plotting the histogram, make sure it ends up
% in the correct axes without changing the current settings ...
if isempty(Ax),
  Ax=gca;
end
Fg=get(Ax,'parent');
cFg=get(0,'currentfigure');
set(0,'currentfigure',Fg);
cAx=get(Fg,'currentaxes');
set(Fg,'currentaxes',Ax);
if sscanf(version,'%f',1)<6 % force bar-graph with non-constant spacing
  thresholds(end+1)=thresholds(end)+0;
  h(end+1)=0;
end
hold on
handles(1)=bar(thresholds,h,'histc');
box on
set(0,'currentfigure',cFg);
set(cFg,'currentaxes',cAx);

% compute the best fit Gauss curve
sigma=std(u1);
mu=mean(u1);
xl=get(Ax,'xlim');
x=xl(1):(xl(2)-xl(1))/200:xl(2);
G=exp(-.5*(((x-mu)/sigma).^2))/(sigma*sqrt(2*pi));

% plot Gauss curve ...
handles(2)=line(x,G,'parent',Ax);

% add text in upper left corner ...
if strcmp(get(Ax,'ylimmode'),'auto')
  ylm=limits(Ax,'ylim');
  maxhist=ylm(2);
  set(Ax,'ylim',[0 maxhist*1.05]); % five percent extra space
end
str=sprintf(' \\mu=%.3f\n \\sigma=%.3f',mu,sigma);
yl=get(Ax,'ylim');
handles(3)=text(min(xl),max(yl)-0.03*(max(yl)-min(yl)),str,'horizon','left','vertic','top','parent',Ax);

if nargout>0
  hOut=handles;
end