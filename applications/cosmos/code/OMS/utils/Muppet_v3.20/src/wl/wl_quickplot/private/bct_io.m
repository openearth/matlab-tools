function Info=bct_io(cmd,varargin),
%BCT_IO Read/write boundary condition tables.
%
%   Info=bct_io('read',filename);
%
%   bct_io('write',filename,Info);

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
