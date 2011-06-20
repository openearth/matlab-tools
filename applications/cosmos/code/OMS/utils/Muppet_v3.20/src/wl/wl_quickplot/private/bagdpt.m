function Out=bagdpt(cmd,varargin),
%BAGDPT Read output files BAGGER-BOS-RIZA bagger option.
%
%   FILEINFO=BAGDPT('read',FILENAME)
%   Open bagger dpt-file (bagdpt.<case>) and returns a
%   structure containing the data in the file.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
