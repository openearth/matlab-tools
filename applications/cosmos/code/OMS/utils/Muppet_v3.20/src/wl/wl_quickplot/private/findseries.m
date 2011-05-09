function bs=findseries(bool);
%FINDSERIES  Find series of nonzero elements.
%   I=FINDSERIES(X) returns an Nx2 array of
%   pairs of indices referring to the start
%   and end of series of nonzero elements.
%   First column of I: start index.
%   Second column of I: end index.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
