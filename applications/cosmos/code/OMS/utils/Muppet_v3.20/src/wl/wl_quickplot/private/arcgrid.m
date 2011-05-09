function [Out,Out2]=arcgrid(cmd,varargin)
%ARCGRID Read/write operations for arcgrid files.
%   FileData = arcgrid('open',filename);
%      Opens data from an arcgrid file
%      and determines the dimensions of
%      the grid. Detects the presence of
%      multiple arcgrid-files (for FLS).
%
%   Data = arcgrid('read',filename);
%      Reads data from a not-opened
%      arcgrid file.
%
%   Data = arcgrid('read',FileData);
%      Reads data from an opened
%      arcgrid file.
%   Data = arcgrid('read',FileData,i);
%      Reads data from the i-th data
%      file in a series.
%
%   arcgrid('write',FileData,filename);
%      Writes data to an arcgrid file.
%
%   AxesHandle = arcgrid('plot',FileData);
%      Plots arcgrid data as elevations.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
