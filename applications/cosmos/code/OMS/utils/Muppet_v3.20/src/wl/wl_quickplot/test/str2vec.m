function vec=str2vec(str,varargin)
%STR2VEC Convert string into a vector.
%   Colon processing to be used with the compiler
%   of MATLAB 5 for standalone programs.
%
%   V=STR2VEC(S)
%   Converts the string S containing a space separated
%   list of integers into a (numeric) vector V. The
%   string may contain the MATLAB colon operator.
%
%   ...,'%f')
%   Retrieve a list of floating point values.
%   ...,'%d')
%   Retrieve a list of integers (default).
%
%   ...,'range',[Min Max])
%   Checks also whether all integers of V are within
%   the specified range. If the string starts with a
%   colon, the Min value is assumed to preceed, if
%   the string ends with a colon, the Max value is
%   assumed to follow. That is, :2: equals Min:2:Max.
%
%   ...,'applylimit')
%   Applies the limits instead of producing an error.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
