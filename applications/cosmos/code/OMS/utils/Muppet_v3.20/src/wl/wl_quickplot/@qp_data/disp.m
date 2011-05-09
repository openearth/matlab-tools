function disp(A)
%DISP Display qp_data object.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

%% Handle exceptional cases
% These cases are useful during debugging but are not really practical for
% any other purpose.


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
