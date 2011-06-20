function Out = qpfile(DataRes)
%QPFILE Get information about the active file in QuickPlot.
%   FILE = QPFILE returns a structure containing for the data file
%   currently selected in QuickPlot. The structure may be used to call
%   QPREAD to read data.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
