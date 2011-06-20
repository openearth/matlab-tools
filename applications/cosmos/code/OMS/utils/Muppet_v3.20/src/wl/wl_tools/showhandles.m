function showhandles(ax)
%SHOWHANDLES Set handlevisibility to on
%   SHOWHANDLES(AX)
%   sets the handlevisibility of all children
%   of the specified axes to on. When the axes
%   are not specified the function applies to
%   the current axes.

if nargin==0
  ax=gca;
end
set(allchild(ax),'handlevisibility','on')