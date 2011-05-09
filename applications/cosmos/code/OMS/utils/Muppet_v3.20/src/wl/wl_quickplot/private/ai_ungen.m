function varargout=ai_ungen(cmd,varargin),
%AI_UNGEN Read/write ArcInfo (un)generate files.
%
%   FileInfo=AI_UNGEN('open',FileName)
%      Opens the specified file and reads its contents.
%
%   XY=AI_UNGEN('read',FileInfo)
%   [X,Y]=AI_UNGEN('read',FileInfo)
%      Returns the X and Y data in the file. If instead of the FileInfo
%      structure a file name is provided then the indicated file is
%      opened and the data is returned.
%
%   AI_UNGEN('write',FileName,XY)
%   AI_UNGEN('write',FileName,X,Y)
%      Writes the line segments to file. X,Y should either
%      contain NaN separated line segments or X,Y cell arrays
%      containing the line segments.
%   AI_UNGEN(...,'-1')
%      Doesn't write line segments of length 1.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
