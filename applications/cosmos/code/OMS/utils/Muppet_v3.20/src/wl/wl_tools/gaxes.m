function A=gaxes(h),
%GAXES Graphical input new axes position.
%
%    GAXES add new axes to current figure
%    GAXES([width height]) adds a new axes to
%          the current figure with the specified
%          width and height and user specified
%          position. Width and height specified
%          in normalized units.
%    GAXES(FigHandle) add new axes to the figure
%          indicated by FigHandle.
%    GAXES(AxHandle) specify new position for the
%          axes indicated by AxHandle.
%
%    See also: AXES, SUBPLOT, SUBPLOTS, RELAXES

sz=[];
if nargin==0,
  h=gcf;
elseif isequal(size(h),[1 2]),
  sz=h;
  h=gcf;
end;
A=[];

switch get(h,'type'),
case 'axes',
  fig=get(h,'parent');
  A=h;
case 'figure',
  fig=h;
otherwise,
  error('Invalid input handle.');
end;
  
NormPos=getnormpos(fig);
if ~isempty(sz), NormPos(3:4)=sz; end;
if isempty(A),
  A=axes('parent',fig, ...
         'units','normalized', ...
         'position',NormPos);
else,
  set(A,'units','normalized', ...
        'position',NormPos);
end;

