function Out=gsharp(cmd,varargin)
%GSHARP Read/write GSharp files.
%
%   FileInfo=GSHARP('read',FileName)
%   Writes the structure Data to a GSharp folder file.
%
%   FileInfoOut=GSHARP('write',FileName,FileInfoIn)
%   Writes the structure Data to a GSharp folder file.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
