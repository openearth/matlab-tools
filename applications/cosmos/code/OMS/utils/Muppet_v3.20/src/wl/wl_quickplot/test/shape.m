function varargout=shape(cmd,varargin)
%SHAPE Read ESRI shape files.
%
%   FI = SHAPE('open','filename')
%   Open the ESRI shape file and return a File Information Structure to
%   be used in the SHAPE read command described below.
%
%   data = SHAPE('read',FI,objectnumbers,datatype)
%   Read data from the ESRI shape file. The input arguments are to be
%   specified as follows:
%      FI            - File Information Structure as obtained from SHAPE
%                      open file command (explained above).
%      objectnumbers - list of object numbers in shape file to be
%                      retreived; use 0 to load all objects
%      datatype      - currently supported: 'points' or 'lines'

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
