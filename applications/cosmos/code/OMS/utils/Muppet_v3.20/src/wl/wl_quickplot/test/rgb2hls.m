function [hout,l,s] = rgb2hls(r,g,b)
%RGB2HLS Convert red-green-blue colors to hue-lightness-saturation.
%   H = RGB2HLS(M) converts an RGB color map to an HLS color map.
%   Hue, lightness, and saturation values scaled between 0 and 1.
%
%   See HLS2RGB, RGB2HSV

%   Based on RGB2HSV by Cleve Moler, The MathWorks

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
