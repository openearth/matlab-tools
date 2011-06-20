function VS=vs_ini(varargin)
%VS_INI Creates a NEFIS file.
%   NFStruct = VS_INI('DataFile','DefFile') creates NEFIS definition and
%   data files. The file is stored in a platform independent format.
%
%   NFStruct = VS_INI('File') creates a NEFIS file containing both
%   definition and data. The file is stored in a platform independent format.
%
%   Optional arguments:
%    * 'version',VERSION
%      Specify whether a NEFIS 4 or NEFIS 5 file will be created. NEFIS 5
%      files can grow bigger than 4GB but are not compatible with somewhat
%      older programs. The default file format is NEFIS 4.
%    * 'byteorder',BYTEORDER
%      The byte order may be specified as 'b' (platform dependent) or 'n'
%      (neutral = big-endian) for NEFIS 4 files. The byte order may be
%      specified as 'b' (big-endian) or 'l' (little-endian) for NEFIS 5
%      files.
%
%   Example
%      NFS1 = vs_ini('myNefis.daf','version',5)
%      %Creates a new combined data/definition NEFIS 5 file.
%
%   See also VS_USE, VS_COPY, VS_DEF, VS_PUT.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
