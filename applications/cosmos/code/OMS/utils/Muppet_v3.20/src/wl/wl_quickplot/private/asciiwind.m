function varargout = asciiwind(cmd,varargin)
%ASCIIWIND Read operations for ascii wind files.
%   FileData = ASCIIWIND('open',filename) opens the ascii wind file and
%   determines the wind time series characteristics.
%
%   See also ARCGRID.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
