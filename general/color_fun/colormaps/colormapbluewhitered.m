function col = colormapbluewhitered(m)
%BLUEWHITERED  colors from blue to red via white.
%
% The middle color(s) is/are always white (1 1 1). BlueWhiteRed, by itself, is the same length as the current figure's colormap. If no figure exists, MATLAB creates one.
%
% Syntax:
% col = BlueWhiteRed (m)
%
% Input:
% m = (Optional)
%
% Output:
% col = colormap
%
% See also: JET,HSV, HOT, PINK, FLAG, COLORMAP, RGBPLOT.
 
%--------------------------------------------------------------------------------
% Copyright(c) Deltares 2004 - 2007  FOR INTERNAL USE ONLY
% Version:  Version 1.0, September 2008 (Version 1.0, September 2008)
% By:      <Thijs Damsma (email:t.damsma@student.tudelft.nl)>
%--------------------------------------------------------------------------------

if nargin < 1
   m = size(get(gcf,'colormap'),1);
end

n = ceil(m/2)-1;
col = ones(m,3);
col(1:n+1,1)=(0:n)/n;
col(1:n+1,2)=(0:n)/n;
col(end-n:end,2)=(n:-1:0)/n;
col(end-n:end,3)=(n:-1:0)/n;











