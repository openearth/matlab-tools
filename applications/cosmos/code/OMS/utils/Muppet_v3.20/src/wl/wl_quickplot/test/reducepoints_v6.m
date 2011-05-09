function I = reducepoints(thresh,X,Y,Z);
%REDUCEPOINTS Filters a set points using a distance threshold.
%   I = REDUCEPOINTS(Thresh_Dist,X,Y,Z)
%   returns an array I of indices of points that form
%   together a set of points that are mutually separated
%   by at least a distance Thresh_Dist. The function
%   works in 1 (X), 2 (X and Y) and 3 (X, Y and Z) dimensions.
%
%   See also REDUCEPNTSQ.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

%#mex

error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
