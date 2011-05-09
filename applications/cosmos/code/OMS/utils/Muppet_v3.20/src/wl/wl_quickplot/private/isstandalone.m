function I = isstandalone
%ISSTANDALONE Determines stand alone execution.
%   I = ISSTANDALONE
%   returns 1 if the program is executed in stand
%   alone (compiled) mode and 0 otherwise.
%
%   See also ISRUNTIME.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
