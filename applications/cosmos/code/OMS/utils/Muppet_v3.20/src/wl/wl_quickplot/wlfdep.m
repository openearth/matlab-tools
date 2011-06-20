function varargout=wlfdep(cmd,varargin)
%WLFDEP Read/write Delft3D-MOR field files.
%   WLFDEP can be used to read and write Delft3D-MOR
%   field files.
%
%   FIELD=WLFDEP('read',FILENAME)
%
%   WLFDEP('write',FILENAME,FIELD)

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
