function [FI,Info]=qp_unwrapfi(Info)
%QP_UNWRAPFI Remove QuickPlot wrapper from file structure.
%
%   [FI,Info] = QP_WRAPFI(FI)

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
