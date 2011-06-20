function [VSNEW,ErrMsg]=vs_def(varargin)
%VS_DEF Changes the groups, cells and element definitions.
%   DataInfoOut = VS_DEF(DataInfo,Type,Name, ...) adds a new element, cell,
%   group definition or data group as indicated by the Type:
%   'elm','cell','grp','data' with the specified Name.
%
%   The further arguments depend on the data type:
%    * elm : DataType, NBytesPerValue, Size, QuantityName, UnitsName, Description
%      The last three arguments are optional; if not specified then they
%      default to the empty string. The data types can be specified either
%      by their name (character, complex, integer, logical, real) or by
%      the typenumber (1--5 for above mentioned types). Valid values of
%      NBytesPerValue are:
%                    character : any larger than zero
%                    complex   : 8, 16
%                    integer   : 4, 8
%                    logical   : 4, 8
%                    real      : 4, 8
%    * cell: ElementList
%      The ElementList is a cell array containing the names of the elements
%      to be included in the cell: {'NameOfElement1','NameOfElment2', ...}.
%      The cell definition is only added when all elements have been
%      defined.
%    * grp : CellName, Size, Order
%      The Size is a vector of length in the range 1--5, the Order is
%      optional; when specified it should be a vector of the same length as
%      Size containing the numbers 1:length(Size). The Size vector may
%      contain one element 0 or inf to specify a dimension that may vary in
%      size. The group definition is only added when the cell refered to by
%      CellName exists.
%    * data: GrpDefName, AttribName1, Value1, AttribName2, Value2, ...
%      The AttributeNames and Values are optional. When attributes are
%      specified at most 5 attributes with a scalar real value, 5
%      attributes with scalar integer, and 5 attributes with string value
%      can be specified. Attributes may be changed later using VS_PUT. The
%      data group is only added when the specified group definition exists.
%    * data: {ElementList}, Size, Order, AttribName1, Value1, AttribName2, Value2, ...
%      The Order, AttributeNames and Values are optional. Restrictions as
%      mentioned above. The same string is used for name of the data group,
%      the name of the group definition, and the name of the cell.
%
%   In none of the cases will the function overwrite existing
%   data/definitions. Redefining groups, cells and elements is only
%   possible after removing the old definition, using the following
%   command:
%
%   DataInfoOut=vs_def(DataInfo,Command,Type,Name) removes an element,
%   cell, group definition or data group as indicated by the Type:
%   'elm','cell','grp','data' with the specified Name. The Command
%   determines the behaviour of the function in case of cross linking:
%    * 'remove': removes definitions only if they are not in use. Removing
%                data groups will result in loss of the data in that group.
%                Lower levels of definitions are not removed.
%    * 'purge' : same as remove, but also recursively removes all
%                definitions below if not used by other data groups, or
%                group or cell definitions. Purging a data group will
%                result in loss of the data stored in that group.
%    * '*remove' and '*purge':
%                remove higher levels first if definition is in use. When
%                this requires removing one (or more) data groups, data
%                stored in those groups is lost.
%
%   In both cases the DataInfo argument is optional; if it is not specified
%   the function will use the last opened or created NEFIS file(s).
%
%   See also VS_USE, VS_INI, VS_PUT.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

% DataInfoOut=vs_def(DataInfo,Type,Name, ...)
% DataInfoOut=vs_def(Type,Name, ...)
% DataInfoOut=vs_def(DataInfo,Command,Type,Name)
% DataInfoOut=vs_def(Command,Type,Name)

% debug?


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
