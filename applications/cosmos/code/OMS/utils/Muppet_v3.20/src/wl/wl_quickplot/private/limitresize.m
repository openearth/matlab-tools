function Changed=limitresize(MinSize,MaxSize)
%LIMITRESIZE Constrained resize.
%
%   LIMITSIZE(MinimumSize,MaximumSize)
%   To be called from resize function to limit window size to
%   range between minimum and maximum size. MinimumSize and
%   MaximumSize should be 1x2 matrices representing the minimum
%   and maximum width/height of the figure. No checking on input
%   arguments performed.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

%
% Should always be called from resize function callback, so use
% callback handle as figure handle.
%

error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
