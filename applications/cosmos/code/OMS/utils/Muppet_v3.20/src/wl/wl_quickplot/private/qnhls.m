function varargout=qnhls(cmd,varargin)
%QNHLS Read/write Quickin HLS files.
%   Read/write Quickin HLS file and convert it
%   into/from RGB colormap.
%
%   [CMAP,LABEL]=QNHLS('read',FILENAME)
%   OK=QNHLS('write',FILENAME,CMAP,LABEL)
%
%   See also RGB2HLS, HLS2RGB.

%   [CMAP,LABEL]=QNHLS(FILENAME) % read assumed

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
