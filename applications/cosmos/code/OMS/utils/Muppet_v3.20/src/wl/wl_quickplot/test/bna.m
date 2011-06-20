function varargout=bna(cmd,varargin)
%BNA Read/write for ArcInfo (un)generate files.
%
%   FileInfo=BNA('open',FileName)
%      Opens the specified file and reads its contents.
%
%   XY=BNA('read',FileInfo)
%   [X,Y]=BNA('read',FileInfo)
%      Returns the X and Y data in the file. If instead of the FileInfo
%      structure a file name is provided then the indicated file is
%      opened and the data is returned.
%
%   BNA('write',FileName,XY)
%   BNA('write',FileName,X,Y)
%      Writes the line segments to file. X,Y should either
%      contain NaN separated line segments or X,Y cell arrays
%      containing the line segments.
%   BNA(...,'-1')
%      Doesn't write line segments of length 1.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
