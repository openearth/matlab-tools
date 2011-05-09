function z=asciiload(filename,skpcmd,skpnm)
%ASCIILOAD A compiler compatible version of LOAD -ASCII.
%   X=ASCIILOAD('FileName')
%   Load data from specified ASCII file into the
%   variable X.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
