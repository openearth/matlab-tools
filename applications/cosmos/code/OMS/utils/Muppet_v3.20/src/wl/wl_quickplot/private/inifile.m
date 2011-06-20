function varargout=inifile(cmd,varargin)
%INIFILE Read/write INI files.
%   Info=INIFILE('open',FileName)
%   Open and read the INI file; return the data to the workspace in a
%   set of nested cell arrays.
%
%   Info=INIFILE('new')
%   Create a new INI file structure.
%
%   Info=INIFILE('write',FileName,Info)
%   Open and write the INI file; the data in the file is overwritten
%   without asking.
%
%   ListOfChapters=INIFILE('chapters',Info)
%   Retrieve list of Chapters (cell array of strings).
%
%   Val=INIFILE('get',Info,Chapter,Keyword,Default)
%   Retrieve Chapter/Keyword from the Info data set. The Default value is
%   optional. If the Chapter ID is '*', the Keyword is searched for in
%   all chapters in the file.
%
%   Info=INIFILE('set',Info,Chapter,Keyword,Value)
%   Set Chapter/Keyword in the data set to the indicated value. The
%   updated data set is returned. Data is not written to file. If the
%   chapter and/or keyword do not exist, they are created. If Value equals
%   [], the keyword is deleted (see below). Use the 'write' option to
%   write the data to file.
%
%   Info=INIFILE('delete',Info,Chapter,Keyword)
%   Info=INIFILE('set',Info,Chapter,Keyword,[])
%   Delete Chapter/Keyword from the data set. The updated data set is
%   returned. Data is not written to file. Use the 'write' option to
%   write the data to file.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
