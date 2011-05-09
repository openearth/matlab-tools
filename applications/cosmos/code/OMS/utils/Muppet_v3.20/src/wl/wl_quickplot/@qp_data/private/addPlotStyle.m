function PS = addPlotStyle(PS,Name,TimeDependent,Function)
%addPlotStyle Append to list of plot styles.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

%
% TimeDependent = 0 : no time associated with quantity
%                 1 : one time available
%                 2 : one time selected, multiple available
%                 3 : multiple times selected
%

error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
