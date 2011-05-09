function Out=mike(cmd,varargin)
%MIKE Read/write DHI Mike files.
%   FILEINFO = MIKE('open',FILENAME) opens a DHI Mike DFS? file or a pair
%   of CT?/DT? files.
%
%   DATA = MIKE('read',FILEINFO,ITEM,TIMESTEP) reads data for the selected
%   ITEM from a Mike file. If no TIMESTEP is specified then the last
%   timestep for the ITEM in the file is returned. If the data files
%   contains just one dataset, the ITEM number is not required.
%
%   DATA = MIKE('read',FILEINFO,ITEM,-1) read the grid from the data file.
%
%   DATA = MIKE(...,SELECTION) where SELECTION equals {M} for 1D, {M N} for
%   2D and {M N K} for 3D returns only the selected m,n,k-indices. The
%   number of indices should match the dimension of the data file.
%
%   See also QPFOPEN, QPREAD.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
