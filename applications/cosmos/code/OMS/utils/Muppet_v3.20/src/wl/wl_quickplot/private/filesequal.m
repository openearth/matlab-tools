function [Equal,Msg]=filesequal(File1,File2,varargin)
%FILESEQUAL Determines whether the contents of two files is the same.
%   FILESEQUAL(FILENAME1,FILENAME2) is 1 if the contents of the two files
%   are the same.
%
%   See Also ISEQUAL, VARDIFF, MATDIFF.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
