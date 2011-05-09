function Out=bagmap(cmd,varargin),
%BAGMAP Read output files BAGGER-BOS-RIZA bagger option.
%
%   FILEINFO=BAGMAP('open',FILENAME)
%   Open bagger mapfile (bagbgv.<case>, bagcbv.<case>,
%   bagdzi.<case>) and returns a structure containing
%   information about the file.
%
%   MAP=BAGMAP('read',FILEINFO,INDEX,SUBFIELD)
%   Read a map from the bagger file. Time step indicated
%   by index. In case of multiple fields per timestep
%   use subfield to indicate the field number.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
