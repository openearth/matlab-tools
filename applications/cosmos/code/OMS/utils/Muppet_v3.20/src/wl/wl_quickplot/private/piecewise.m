function [mn0,mn]=piecewise(mn,mnmax)
%PIECEWISE Checks and fixes a piecewise grid line.
%   A piecewise grid line follows either a grid line or a diagonal line
%   across the grid. The function PIECEWISE checks whether each line
%   segment is either horizontal, vertical or diagonal on the grid.
%
%   [MN0,MN2] = PIECEWISE(MN1)
%   The input array MN1 should consist of the grid points intended to be
%   on the line; each line should contain an M,N pair (integers). The
%   output array MN0 will contain all points on the line (expanded list)
%   fixing possible deviations from horizontal, vertical or diagonal
%   lines in the original MN1 array. The output array MN2 contains only
%   those points at which the line changes direction.
%
%   [MN0,MN2] = PIECEWISE(MN1,MNMAX)
%   The line is restricted to the area defined by 1:MNMAX(1) and
%   1:MNMAX(2).

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
