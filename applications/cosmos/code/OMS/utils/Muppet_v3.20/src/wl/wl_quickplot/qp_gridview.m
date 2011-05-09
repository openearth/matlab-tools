function [out,out2]=qp_gridview(cmd,varargin)
%QP_GRIDVIEW Helper routine for grid selection interface.
%   FIG = QP_GRIDVIEW(GRID,RANGE) initialise interface with grid and
%   selected range. The RANGE argument is optional. The GRID may be dropped
%   if the RANGE is not specified. The GRID variable should be structure
%   containing fields
%     * X and Y for a 2D structured grid.
%     * XYZ, TRI for a 2D unstructured grid (XYZ array needs to contain XY
%       data only).
%     * XY, SEG for a network.
%   The function returns a figure handle. The RANGE structure should
%   contain fields Type and Range. Valid range types are 'none', 'point',
%   'range', 'line', 'lineseg', 'pwline', 'genline'. See the 'getrange'
%   call output for the contents of the Range field.
%
%   QP_GRIDVIEW('setgrid',FIG,GRID) update the grid used by the grid
%   in the specified grid selection interface FIG.
%
%   QP_GRIDVIEW('setrange',FIG,RANGE) update the selected range of the
%   specified grid selection interface FIG to the specified RANGE.
%
%   RANGE = QP_GRIDVIEW('getrange',FIG) get the currently selected range of
%   the specified grid selection interface FIG. The RANGE structure
%   contains both selection type and selection indices.
%
%   [RANGETYPE,RANGEINDEX] = ... get the currently selected range as a
%   range type and range index instead of one range structure.
%
%   QP_GRIDVIEW('callback',FIG,F,arg1,arg2,...) set the callback function
%   to F with the specified arguments; this function will be called each
%   time selected range changes. The new RANGE should be enquired by means
%   of the 'getrange' call.

%   Obsolete structured grid syntax:
%
%   F = QP_GRIDVIEW(X,Y) initialise interface for a structured grid with
%   given X and Y coordinates.
%
%   F = QP_GRIDVIEW(X,Y,RANGE) initialise interface with grid and range.
%
%   QP_GRIDVIEW('setgrid',F,X,Y) update grid used.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
