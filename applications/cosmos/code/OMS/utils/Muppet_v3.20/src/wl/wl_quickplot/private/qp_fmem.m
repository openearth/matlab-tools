function [FI,FileName,Tp,Otherargs]=qp_fmem(cmd,varargin)
%QP_FMEM Routine for opening data files.
%   [FileInfo,FileName,FileType,Otherargs]=QP_FMEM('open',FilterSpec)

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
