function [Data,NewFI] = getdata(FI,Quantity,DimSelection)
%GETDATA Default implementation for getdata.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

%% Return file structure unchanged

error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
