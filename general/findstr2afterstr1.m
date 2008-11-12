function [k] = findstr2afterstr1(str, str1, str2)
% FINDSTR2AFTERSTR1 searches occurences of str2 after str1 within str
%
% searches within string 'str' for any occurrences of 'str2' after the first 
% occurence of 'str1', returning the starting index of each such occurrence 
% in the double array k.
%
% Syntax:
% [k] = findstr2afterstr1(str, str1, str2)
%
% Input:
% str  = string to search in
% str1 = string after which will be searched
% str2 = string to search for
%
% Output:
% k    = starting index of occurrences
%
% See also: findstr
 
%--------------------------------------------------------------------------------
% Copyright(c) Deltares 2004 - 2008  FOR INTERNAL USE ONLY
% Version:  Version 1.0, June 2008 (Version 1.0, June 2008)
% By:      <C. (Kees) den Heijer (email:Kees.denHeijer@deltares.nl)>
%--------------------------------------------------------------------------------
 
 
str1loc = min(findstr(str, str1));
if isempty(str1loc)
    k = [];
else
    str2loc = findstr(str, str2);

    k = str2loc(str2loc>str1loc);
end

