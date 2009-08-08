function [pt,shortname,fname,date,f] = visdiffReadFromFile(fname)
%VISDIFFREADFROMFILE Helper function for visdiff and mdbvisdiffbuffer that
%   reads file contents.
%
%   This file is for internal use only and is subject to change without
%   notice.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $

fname=visdiffGetFullPathname(fname);
[pt,nm,xt] = fileparts(fname);
shortname = [nm xt];
d = dir(fname);
date = d.date; 
f = getmcode(fname);
