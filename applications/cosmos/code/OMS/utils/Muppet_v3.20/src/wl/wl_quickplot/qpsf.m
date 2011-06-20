function handleOut=qpsf(handleIn)
%QPSF Get handle to the current QuickPlot figure.
%   H = QPSF returns the handle to the figure currently selected in the
%   PlotManager of QuickPlot.
%
%   See also QPSA, GCF, GCA.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
