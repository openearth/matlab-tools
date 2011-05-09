function Out=bil(cmd,varargin)
%BIL Read bil/hdr files.
%   FileData = bil('open',filename);
%      Opens the file and interprets and verifies the header
%      information.
%
%   Data = bil('read',FileData,Idx,Precision);
%      Reads data field Idx from the selected file.
%      Returns the data as a variable of the specified precision.
%      By default, the function returns the data in the same precision
%      as stored in the file.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
