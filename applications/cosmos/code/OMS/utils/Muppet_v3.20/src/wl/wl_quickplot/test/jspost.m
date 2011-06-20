function [Out1,Out2]=jspost(cmd,varargin)
%JSPOST Read JSPost files.
%
%   Struct=JSPOST('open','FileName')
%   opens the specified JSPOST files (pair of STU and PST files).
%
%   [Time,Data]=JSPOST('read',Struct,Substance,Segment,TStep)
%   reads the specified substance (0 for all), specified
%   segment (0 for all) and specified time step (0 for all)
%   from the Delwaq HIS or MAP file.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
