function [VSNEW,ErrMsg]=vs_pack(varargin)
%VS_PACK Remove inaccessible/unused space from a NEFIS file.
%   NewNFStruct = VS_PACK(NFStruct,'NewFileName',...options...)
%   NewNFStruct = VS_PACK(NFStruct,{'NewDatFile','NewDefFile'},...
%   Creates a copy the original file and transfers all data.
%
%   Possible options are:
%    * 'GroupName',GroupIndex,{ElementList}
%      This transfers the data of the specified group. But only the
%      specified indices and elements are transferred to the new file. The
%      GroupIndex and Element list are optional. Default all indices and
%      elements are transferred. The GroupIndex should be specified in the
%      same way as it is used in the vs_let/vs_get commands: for each group
%      dimension indices specified, combined within braces. For instance
%      {1:3:20} for a group with one dimension or {[1 2 6] 2:4} for a group
%      with two dimensions.
%    * 'GroupName',[]
%      Removes the group from the file.
%    * '*',[]
%      Remove all groups from the file.
%   Options are processed in the specified order.
%
%   Example
%      NFS1 = vs_use('trim-old.dat');
%      NFS2 = vs_pack(NFS1,{'trim-new.dat','trim-new.def'},'*',[],'map-series')
%      % This will copy only the data in the map-series group.
%
%   See also VS_USE, VS_INI, VS_COPY.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
