function Out=waqua(cmd,varargin)
%WAQUA Read SIMONA SDS files (low level).
%
%   FileData = WAQUA('openpro-r',FileName)
%   Open and read data from a WAQPRO result file.
%
%   FileData = waqua('open',FileName)
%   Open a SIMONA SDS file.
%
%   Bool = WAQUA('exists',FileData,ExperimentName,Characteristic);
%   Check whether the specified characteristic is located on the
%   SDS file.
%
%   Data = WAQUA('read',FileData,ExperimentName,Characteristic,Timesteps,Index);
%   Read data from an SDS file given the experiment name and the name of
%   of the characteristic. For time dependent data a timestep is required.
%   By default all timesteps are loaded, specify [] to read the timesteps but
%   not the data itself. Using the Index command a subset of the array can be
%   obtained.
%
%   WAQUA('sidsview',FileData)
%   Give standard listing of file contents.
%
%   See also WAQUAIO

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
