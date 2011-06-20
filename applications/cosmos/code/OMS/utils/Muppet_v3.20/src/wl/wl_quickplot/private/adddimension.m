function Dimensions = adddimension(Dimensions,Name,Description,Type,Unit,Values)
%ADDDIMENSION Add a dimension to a dimension list.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

%% Define fields of Dimensions structure
% Possible values for Type are
%
% * 'discrete'
% * 'continuous'
% * 'discrete-time'
% * 'continuous-time'
%

error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
