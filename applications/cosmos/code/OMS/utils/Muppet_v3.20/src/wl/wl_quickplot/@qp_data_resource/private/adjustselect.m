function Selection = adjustselect(Selection,Location,Dimensions,M)
%ADJUSTSELECT Adjust the selection of spatial dimensions.
%   SEL = ADJUSTSELECT(SEL,LOC,DIM,M) adjusts the selection structure SEL
%   after the user has changed the selection of dimension M. The structures
%   LOC and DIM contain necessary information on the grid and dimensions
%   respectively.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
