function Out=morf(cmd,varargin);
%MORF Read Delft3D-MOR morf files.
%   FileData = morf('read',filename);
%     reads and checks data from a morf file.
%   morf('read',filename);
%     reads,checks and plots data from a morf file.
%
%   CheckOK  = morf('check',FileData);
%     checks data for morf file.
%
%   AxesHandle = morf('plot',FileData);
%     plots the tree structure of a morf file.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
