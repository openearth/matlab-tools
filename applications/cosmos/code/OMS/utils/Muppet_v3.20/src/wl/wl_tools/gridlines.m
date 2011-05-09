function H=gridlines(x0,y0,varargin)
%GRIDLINES draw grid lines (don't change the tickmarks)
%     GRIDLINES(X,Y, ...)
%     draws grid lines at specified X and Y coordinates
%     in the current axes. Optional arguments may be
%     used to specify line properties and to select
%     another parent axes for plotting.
%     H=GRIDLINES(...) returns the handles of the grid
%     lines.

% (c) 2002, H.R.A. Jagers, WL | Delft Hydraulics
% bert.jagers@wldelft.nl

 if ischar(x0)
  error('Invalid x ticks. No string expected.');
else
  x0=x0(:)';
end
if ischar(y0)
  error('Invalid y ticks. No string expected.');
else
  y0=y0(:)';
end
if mod(length(varargin),2)~=0
  error('Invalid parameter/value pair arguments.')
end
Parent=[];
for i=1:2:length(varargin)
  if ~ischar(varargin{i})
    error('Invalid parameter/value pair arguments.')
  else
    iarg=ustrcmpi(lower(varargin{i}),{'parent'});
    switch iarg
    case 1, %parent
      Parent=varargin{i+1};
    end
  end
end

if isempty(Parent)
  Parent=gca;
end
LS=get(Parent,'GridLineStyle');

COL=get(Parent,'XColor');
x=repmat(x0,2,1);
y=repmat(get(Parent,'ylim')',1,length(x0));
x(end+1,:)=NaN;
y(end+1,:)=NaN;
h(1)=line(x(:),y(:),'linestyle',LS,'color',COL,varargin{:});

COL=get(Parent,'YColor');
x=repmat(get(Parent,'xlim')',1,length(y0));
y=repmat(y0(:)',2,1);
x(end+1,:)=NaN;
y(end+1,:)=NaN;
h(2)=line(x(:),y(:),'linestyle',LS,'color',COL,varargin{:});

if nargout>0
  H=h;
end