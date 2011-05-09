function out = fieldnames(obj)
%FIELDNAMES Get object property names.
%
%    NAMES = FIELDNAMES(OBJ) returns a cell array of strings containing 
%    the names of the properties associated with the object, OBJ.
%    For qp_data_resource objects this function hides the structure fields.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

% Error checking.

error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
