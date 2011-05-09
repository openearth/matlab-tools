function [Out1,Out2]=unibest(cmd,varargin),
%UNIBEST Read Unibest files.
%
%   Struct=UNIBEST('open','FileName')
%   opens the specified Unibest file: combination of .fun and
%   .daf files.
%
%   [Time,Data]=UNIBEST('read',Struct,Location,Quant,TStep)
%   reads the data for the specified location (0 for all),
%   specified quantity (0 for all) and specified time step
%   (0 for all) from the Unibest data file.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
