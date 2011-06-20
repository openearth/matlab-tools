function tba = tekal2tba(Tekal)
%TEKAL2TBA Parses comments of a TEKAL to determine tidal analysis data.
%   TBA = TEKAL2TBA(TEKALFILE) parses the comments in a previously opened
%   TEKAL file to determine whether the file contains Delft3D-TRIANA
%   Table-A tidal analysis data. If it does contain such data it will
%   return a structure containing it.
%
%   TBA = TEKAL2TBA(FILENAME) opens the file and determines whether the
%   file contains Delft3D-TRIANA Table-A tidal analysis data. If it does
%   contain such data it will return a structure containing it.
%
%   See also TBA_PLOTELLIPSES.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
