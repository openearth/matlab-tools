function Struct = delwaqtimfile(FileName);
%DELWAQTIMFILE Reads in a Delwaq .tim input file (Lex Yacc type).

%   Any spaces, tabs and comma's (outside strings) should be ignored. For the
%   time being I assume that there are no comma's; the rest is handled
%   correctly I think.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
