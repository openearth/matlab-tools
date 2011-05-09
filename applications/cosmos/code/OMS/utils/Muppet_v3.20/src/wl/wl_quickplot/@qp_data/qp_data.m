function X = qp_data(varargin)
% QUICKPLOT Data Object.
%
% Object construction
%   qp_data    - Construct qp_data object.
%
% General
%   disp       - Display qp_data object.
%   display    - Display qp_data object.
%   subsref    - Subscripted reference qp_data object.
%   fieldnames - Get object property names.
%
% Graphics
%   plot       - Plot qp_data object.
%
% Helper routines
%   classic    - Convert qp_data object to classic QUICKPLOT data structure.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

%% Create basic structure

error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
