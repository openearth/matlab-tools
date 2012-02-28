function varargout = plotbox(xy,varargin)
%PLOTBOX   plots a bounding box
%
% plotbox(axisbox,...)
%
% where axisbox is an array of 4 as returned by axis.
% plotbox has the same syntax as PLOT.
%
% See also: BOX, AXIS, PLOT

h = plot([xy(1) xy(2) xy(2) xy(1) xy(1)],...
         [xy(3) xy(3) xy(4) xy(4) xy(3)],varargin{:});
         
if nargout==1
   varargout = {h};
end
