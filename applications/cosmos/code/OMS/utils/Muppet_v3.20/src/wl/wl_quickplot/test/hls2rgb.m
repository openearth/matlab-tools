function [rout,g,b] = hls2rgb(h,l,s)
%HLS2RGB Convert hue-lightness-saturation to red-green-blue colors.
%   H = HLS2RGB(M) converts an HLS color map to an RGB color map.
%   Hue, lightness, and saturation values scaled between 0 and 1.
%
%   See RGB2HLS

%   Based on RGB2HSV by Cleve Moler, The MathWorks

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
