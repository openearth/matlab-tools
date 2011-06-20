function [U,V]=dir2uv(mag,alf)
%DIR2UV Convert magnitude and angle to (x,y) components.
%   [U,V]=DIR2UV(mag,alf)
%   Converts magnitude and angle (in degrees) into
%   (x,y) components.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
