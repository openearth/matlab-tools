function varargout=writeavi(varargin)
%WRITEAVI  MEX interface to Windows AVI functions
%
%    AVIHandle = WRITEAVI('initialize')
%    AVIHandle = WRITEAVI('open', AVIHandle, FileName)
%    AVIOps = WRITEAVI('getoptions', NBits)
%            NBits = 8 or 24
%    AVIHandle = WRITEAVI('addvideo', AVIHandle, BaseFrameRate, Width,
%                Height, 8, ColorMap, AVIOps)
%    AVIHandle = WRITEAVI('addvideo', AVIHandle, BaseFrameRate, Width,
%                Height, 24, AVIOps)
%    AVIHandle = WRITEAVI('addframe', AVIHandle, Bitmap, FrameNr)
%    AVIHandle = WRITEAVI('close', AVIHandle)
%    Flag = WRITEAVI('finalize', AVIHandle)

% Copyright (c) 1/7/2004 by H.R.A. Jagers
%               WL | Delft Hydraulics, The Netherlands

%#mex
error('Missing MEX-file WRITEAVI');
