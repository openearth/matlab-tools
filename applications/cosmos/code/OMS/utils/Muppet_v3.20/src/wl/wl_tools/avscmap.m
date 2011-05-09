function map = avscmap(m)
%AVSCMAP    Default color map of AVS/Express.
%   AVSCMAP(M) returns an M-by-3 matrix containing an HSV colormap.
%   AVSCMAP, by itself, is the same length as the current colormap.
%
%   An AVSCMAP colormap varies the hue component of the hue-saturation-value
%   color model.  The colors begin with red, pass through yellow, green,
%   cyan, blue, magenta, and return to red.  The map is particularly
%   useful for displaying periodic functions.  
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(hsv)
%
%   See also GRAY, HOT, COOL, BONE, COPPER, PINK, FLAG, PRISM, JET, HSV,
%   COLORMAP, RGBPLOT, HSV2RGB, RGB2HSV.

if nargin < 1, m = size(get(gcf,'colormap'),1); end
h = 2/3*((m-1):-1:0)'/max(m-1,1);
if isempty(h)
  map = [];
else
  map = hsv2rgb([h ones(m,2)]);
end
