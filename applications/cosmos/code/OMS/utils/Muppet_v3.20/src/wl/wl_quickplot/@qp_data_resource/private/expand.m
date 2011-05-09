function [Resource,Key] = expand(Key,Data)
%EXPAND Creates resource structure from Key/FileName

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
