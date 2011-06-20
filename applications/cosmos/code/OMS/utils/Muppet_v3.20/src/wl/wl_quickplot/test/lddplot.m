function h=lddplot(PCR,AxesHandle)
%LDDPLOT Plot local drainage direction for PC-Raster LDD data file.
%   LDDPLOT(PCR,AxesHandle)
%   where PCR is a PC-Raster LDD data file structure, and
%   AxesHandle is an optional axes handle to be plotted in.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
