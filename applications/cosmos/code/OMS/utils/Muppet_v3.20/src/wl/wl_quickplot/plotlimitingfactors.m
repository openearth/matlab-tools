function hNew=plotlimitingfactors(FI,varargin)
%PLOTLIMITINGFACTORS  Create a limiting factors plot.
%   This function creates a limiting factors plot for Chlorophyll in
%   algae.
%   PLOTLIMITINGFACTORS(FileInfo,AX,Location)
%   where FileInfo is a structure obtained from a QPFOPEN call, AX
%   specifies the axes in which the limiting factors should be plot, and
%   Location specified the station (either specified by name or number)
%   for which the plot should be made.
%
%   See also QPFOPEN.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
