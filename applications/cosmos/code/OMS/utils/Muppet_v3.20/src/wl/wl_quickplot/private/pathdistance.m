function d0=pathdistance(x0,y0,z0),
%PATHDISTANCE Computes the distance along a path.
%   Computes the distance along the path from the first
%   point for every point on the path.
%
%   Distance=PATHDISTANCE(XCoord,YCoord,ZCoord)
%   Distance=PATHDISTANCE(XCoord,YCoord)
%   Distance=PATHDISTANCE(Coord)
%
%   NaNs are skipped in the computation of the path length.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
