function Out=telemac(cmd,varargin)
%TELEMAC Read Telemac selafin files.
%   F = TELEMAC('open',FileName)
%   Opens the file and returns structure containing file
%   information.
%
%   Data = TELEMAC('read',F,TimeIndex,VarNr,PntNrs)
%   Read data from file for specified time indices, variable
%   indices and point numbers.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
