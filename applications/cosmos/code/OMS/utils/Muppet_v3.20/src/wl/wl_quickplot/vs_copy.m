function [VSNEW,ErrMsg]=vs_copy(varargin)
%VS_COPY Copy data from one NEFIS file to another.
%   NewNFS2 = VS_COPY(NFS1,NFS2,...options...) copies data from the NEFIS
%   file specified  by NFS1 to the NEFIS file specified by NFS2. The data
%   structures NFS1 and NFS2 may be obtained from VS_USE or VS_INI. NewNFS2
%   equals NFS2, but is updated with the information on the newly added
%   data fields.
%
%   Possible options are:
%    * 'GroupName',GroupIndex,{ElementList}
%      This copies the data of the specified group. But only the specified
%      indices and elements are transferred to the second file. The
%      GroupIndex and Element list are optional. Default all indices and
%      elements are transferred. The GroupIndex should be specified in the
%      same way as it is used in the vs_let/vs_get commands: for each group
%      dimension indices specified, combined within braces. For instance
%      {1:3:20} for a group with one dimension or {[1 2 6] 2:4} for a group
%      with two dimensions.
%    * 'GroupName',[]
%      This excludes the group from the copy operation.
%    * '*',[]
%      This excludes all groups from the copy operation.
%   Options are processed in the specified order.
%
%   Example
%      NFS1 = vs_use('trim-old.dat');
%      NFS2 = vs_ini('trim-new.dat','trim-new.def');
%      NFS2 = vs_copy(NFS1,NFS2,'*',[],'map-series')
%      % This will copy only the data in the map-series group.
%
%   See also VS_USE, VS_INI.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
