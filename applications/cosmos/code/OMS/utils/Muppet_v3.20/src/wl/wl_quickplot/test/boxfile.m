function varargout=boxfile(cmd,varargin),
%BOXFILE Read/write SIMONA box files.
%   BOXFILE can be used to read and write Waqua/Triwaq
%   field files used for depth and roughness data.
%
%   DEPTH=BOXFILE('read',FILENAME)
%   read the data from the boxfile. This call uses
%   creates a matrix that tightly fits the data.
%   Use ...,SIZE) or ...,GRID) where GRID was generated
%   by WLGRID to get a depth array corresponding to the
%   indicated grid (or larger when the grid indices in
%   the datafile indicate that).
%
%   BOXFILE('write',FILENAME,MATRIX)
%   write the MATRIX to the file in boxfile format.
%   Missing values (NaN's) are replaced by 999.999.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
