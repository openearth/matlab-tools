function [out1,out2]=zoombox(varargin),
%ZOOMBOX plots zoombox in other axes
%       [X,Y]=ZOOMBOX(AxesHandle)
%       returns a polygon representing the zoombox
%       of the indicated axes object.
%
%       H=ZOOMBOX(AxesHandle1,'plotin',AxHandle2)
%       returns the handle of the line object drawn in
%       axes 2 representing the zoombox of axes 1.

% (c) copyright, H.R.A. Jagers, July 2000

ax1=[];
ax2=[];
i=1;
while i<nargin,
  if ischar(varargin{i}),
    switch lower(varargin{i}),
    case 'plotin',
      if i<nargin,
        i=i+1;
        ax2=varargin{i};
      else,
        ax2=gca;
      end;
    end;
  else,
    ax1=varargin{i};
  end;
  i=i+1;
end;
if isempty(ax1),
  ax1=gca;
end;

if ~ishandle(ax1) | ~isequal(get(ax1,'type'),'axes'),
  error('Invalid axes handle.');
end;

xlim=get(ax1,'xlim');
ylim=get(ax1,'ylim');
% 3D view?

x=[xlim(1) xlim(2) xlim(2) xlim(1) xlim(1)];
y=[ylim(1) ylim(1) ylim(2) ylim(2) ylim(1)];

if ~isempty(ax2),
  out1=line(x,y,'parent',ax2);
else,
  out1=x;
  out2=y;
end;