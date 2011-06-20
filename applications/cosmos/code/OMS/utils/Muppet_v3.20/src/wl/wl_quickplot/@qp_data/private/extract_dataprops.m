function [timdep,nval,stagger,PlotDim] = extract_dataprops(A,V,vDims,gDims)
%EXTRACT_DATAPROPS Determine characteristics of object.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

%TODO: hasZlevel???


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
