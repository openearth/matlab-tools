function [I,IAll]=ustrcmpi(Str,StrSet)
%USTRCMPI Find a unique string.
%   Index=USTRCMPI(Str,StrSet)
%   This function compares the string Str with the
%   strings in the string set StrSet and returns the
%   index of the string in the set that best matches
%   the string Str. The best match is determined by
%   checking in the following order:
%        1. exact match
%        2. exact match case insensitive
%        3. starts with Str
%        4. starts with Str case insensitive
%   If no string is found or if there is no unique
%   match, the function returns -1.
%
%   [Index,IndexAll]=USTRCMPI(Str,StrSet)
%   Returns the indices of all matches when there are
%   multiple.
%
%   See also STRCMP, STRCMPI, STRNCMP, STRNCMPI, STRMATCH.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
