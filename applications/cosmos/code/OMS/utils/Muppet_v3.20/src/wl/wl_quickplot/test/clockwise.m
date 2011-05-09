function CW=clockwise(x,y)
%CLOCKWISE Determines polygon orientation.
%   CW=CLOCKWISE(X,Y)
%   returns 1 if the polygon (X,Y) is
%   clockwise and -1 if the polygon is
%   anticlockwise.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
