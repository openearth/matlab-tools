function p=qp_basedir(t)
%QP_BASEDIR Get various base directories.
%
%   PATH=QP_BASEDIR(TYPE)
%   where TYPE=
%      'base' returns base directory of installation (default).
%      'exe'  returns directory of executable.
%      'pref' returns preference directory of installation.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
