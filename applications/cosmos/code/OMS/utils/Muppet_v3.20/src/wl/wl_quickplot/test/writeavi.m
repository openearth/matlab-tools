function varargout=writeavi(varargin)
%WRITEAVI MEX interface to Windows AVI functions.
%
%   AVIHandle = WRITEAVI('initialize')
%   AVIHandle = WRITEAVI('open', AVIHandle, FileName)
%   AVIOps = WRITEAVI('getoptions', NBits)
%           NBits = 8 or 24
%   AVIHandle = WRITEAVI('addvideo', AVIHandle, BaseFrameRate, Width,
%               Height, 8, ColorMap, AVIOps)
%   AVIHandle = WRITEAVI('addvideo', AVIHandle, BaseFrameRate, Width,
%               Height, 24, AVIOps)
%   AVIHandle = WRITEAVI('addframe', AVIHandle, Bitmap, FrameNr)
%   AVIHandle = WRITEAVI('close', AVIHandle)
%   Flag = WRITEAVI('finalize', AVIHandle)

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

%#mex

error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
