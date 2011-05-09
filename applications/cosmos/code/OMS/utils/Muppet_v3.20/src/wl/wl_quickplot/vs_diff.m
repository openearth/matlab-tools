function out=vs_diff(VS1,VS2,fid)
%VS_DIFF Locates the differences between two NEFIS files.
%   VS_DIFF(VS1,VS2) displays the names of the groups/elements that are
%   different.
%
%   VS_DIFF(VS1,VS2,FID) writes the information to an already opened text
%   file with handle FID.
%
%   Diff=VS_DIFF(VS1,VS2) returns 1 if there are differences, 0 if there
%   are none. In this case no listing is produced.
%
%   Example
%      F1 = vs_use('trim-xx1.dat','trim-xx1.def');
%      F2 = vs_use('trim-xx2.dat','trim-xx2.def');
%      vs_diff(F1,F2)
%
%   See also VS_USE, VS_DISP, VS_LET, VS_GET, VS_FIND, VS_TYPE.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
