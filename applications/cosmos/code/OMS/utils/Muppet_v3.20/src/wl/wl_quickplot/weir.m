function varargout=weir(cmd,varargin),
%WEIR Read/write a weir file.
%   WeirData=WEIR('read','filename')
%   WEIR('write','filename',WeirData) (not yet implemented)

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
