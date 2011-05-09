function aList2aStr = inlist(aStr,aList)
%INLIST Match cell arrays of strings.
%   I = INLIST(C1,C2) returns for every string in the cell array of strings
%   C1 the index of the matching string in the cell array of strings C2. If
%   the string does not occur in C2 then NaN is returned. If the string
%   occurs multiple times in C2 then the last index is returned.
%
%   See also STRMATCH.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
