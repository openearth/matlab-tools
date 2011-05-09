function [varargout]=aukepc(cmd,varargin)
%AUKEPC Read AUKE/pc files.
%
%   FileInfo = AUKEPC('open','FileName');
%
%   Data = AUKEPC('read',FileInfo,Channel,UseZeroLevel);
%        where Channel is either a channel name or one or
%        more channel numbers. If UseZeroLevel is 0 the
%        zerolevel is not used, otherwise it is used (default).

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
