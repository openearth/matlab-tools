function [G,GridFileName]=get_matching_grid(MapSeg,pn,filterspec)
%GET_MATCHING_GRID Get grid file that matches size of current dataset.
%   [GRIDINFO,GRIDFILENAME] = GET_MATCHING_GRID(MAPSEG) opens a dialog to
%   select a file with MAPSEG elements in the (aggregated) grid.
%
%   [GRIDINFO,GRIDFILENAME] = GET_MATCHING_GRID(GRIDSIZE) opens a dialog to
%   select a grid specified GRIDSIZE.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
