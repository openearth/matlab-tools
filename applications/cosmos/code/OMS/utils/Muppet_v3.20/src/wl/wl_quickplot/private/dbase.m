function varargout=dbase(cmd,varargin)
%DBASE Read data from a dBase file.
%
%   FI=DBASE('open','filename')
%   Open a dBase file.
%
%   Data=DBASE('read',FI,Records,Fields)
%   Read specified records from the opened dBase file.
%   Support 0 for reading all records / fields.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
