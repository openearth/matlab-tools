function Out = qpfopen(varargin)
%QPFOPEN General routine for open various types of data files.
%   FILE = QPFOPEN('Filename') opens the specified output file and returns
%   a structure containing data used by the QPREAD function.
%
%   For Delwaq/par MAP files the user should also specify a grid file:
%   FILE = QPFOPEN('DataFile','GridFile')
%   If no grid file is specified then the MAP file is treated as a history
%   file with an observation point for each segment.
%
%   When no arguments are passed to the function, the user is asked to
%   specify the file using a standard file selection dialog window.
%
%   See also QPREAD, D3D_QP.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
