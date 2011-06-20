function Out=tecplot(cmd,varargin),
%TECPLOT Read/write for Tecplot files.
%
%   FileInfo=TECPLOT('write',FileName,Data)
%      Writes the matrix Data to a Tecplot file.
%   NewFileInfo=TECPLOT('write',FileName,FileInfo)
%      Writes a Tecplot file based on the information
%      in the FileInfo. FileInfo should be a structure
%      with at least a field Zone having two subfields
%      Title and Data. For example
%        FI.Zone(1).Title='B001';
%        FI.Zone(1).Data=Data1;
%        FI.Zone(2).Title='B002';
%        FI.Zone(2).Data=Data2;
%      Optional fields Title (overall title) and Variables
%      (cell array of variable names) will also be processed.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
