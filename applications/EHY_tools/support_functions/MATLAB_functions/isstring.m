%ISSTRING Determine whether input is string array
%   ISSTRING(S) returns true if S is a string array and 0 otherwise.
%
%   Examples:
%       S = string({'Smith','Burns','Jones'});
%       isstring(S)                             % returns 1
%
%       S = 'Mary Jones';
%       isstring(S)                             % returns 0
%
%   See also STRING, ISCHAR, ISCELLSTR.

%   Copyright 2016 The MathWorks, Inc.

%   Built-in function.