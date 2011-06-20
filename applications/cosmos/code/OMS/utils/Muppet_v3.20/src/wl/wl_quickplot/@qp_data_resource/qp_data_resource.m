function X=qp_data_resource(varargin)
%QUICKPLOT Data Resource Object.
%
% Object construction
%   qp_data_resource - Construct qp_data_resource object.
%
% General
%   disp             - Display qp_data_resource object.
%   display          - Display qp_data_resource object.
%   subsref          - Subscripted reference qp_data_resource object.
%   fieldnames       - Get object property names.
%
% Helper routines
%   classic          - Convert qp_data object to classic QUICKPLOT data structure.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

%% Open resource
% Opening the resource will provide
%
% * a resource structure, and
% * a key
%
% The key is contains all information necessary to recreate/reopen the
% resource; it is stored as part of the plot. The resource structure is
% stored by the resourcemanager for reuse during the current session.

error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
