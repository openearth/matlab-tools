function varargout=landboundary(cmd,varargin)
%LANDBOUNDARY Read/write land boundary files.
%   XY = LANDBOUNDARY('read',FILENAME) reads the specified file and returns
%   the data as one Nx2 array.
%
%   [X,Y] = LANDBOUNDARY(...) returns separate X and Y arrays.
%
%   LANDBOUNDARY('write',FILENAME,XY) writes a the landboundary to file. XY
%   should either be a Nx2 array containing NaN separated line segments or
%   a cell array containing one line segment per cell.
%
%   LANDBOUNDARY('write',FILENAME,X,Y) writes a the landboundary to file. X
%   and Y supplied as separate Nx1 arrays containing NaN separated line
%   segments or cell arrays containing one line segment per cell. The X and
%   Y line segments should correspond in length.
%
%   LANDBOUNDARY(...,'-1') does not write line segments of length 1.
%
%   LANDBOUNDARY(...,'dosplit') saves line segments as separate TEKAL
%   blocks instead of saving them as one long line interrupted by missing
%   values. This approach is well suited for spline files, but less suited
%   for landboundaries with a large number of segments.
%
%   FILE = LANDBOUNDARY('write',...) returns a file info structure for the
%   file written. This structure can be used to read the file using the
%   TEKAL function.
%
%   See also TEKAL.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
