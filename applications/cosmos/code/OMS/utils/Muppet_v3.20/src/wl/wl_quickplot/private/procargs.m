function [Struct,Err]=procargs(VARARGIN,CellFields,CellValues)
%PROCARGS General function for argument processing.
%   Function to process/parse the input arguments of a function in a
%   standardized manner. Generally, this function will be used to process
%   the input arguments grouped together by "varargin".
%
%   [Struct,Err]=PROCARGS(VARARGIN,Args)
%   VARARGIN is a cell array of the arguments to be processed. The
%   argument list may contain either a number of keyword-less arguments
%   in a fixed order, or a list of keyword-value pairs. Args is a
%   structure array containing fields Name, HasDefault, Default and
%   optionally List. Each element of the structure array defines one
%   keyword/parameter:
%      Args(i).Name      : the name/keyword
%      Args(i).HasDefault: boolean that indicates whether a default value
%                          is associated with this parameter.
%      Args(i).Default   : the default value (when HasDefault is true)
%      Args(i).List      : cell array (strings) or vector of acceptable
%                          values for parameter i.
%   Keyword-less arguments are assigned to the keywords in the order in
%   which they occur in the structure array. Parameters/keywords that do
%   not have an associated default value should be specified first in the
%   structure array Args. Keywords in keyword-value pairs may be
%   abbreviated or they case may be changed as long as the intended
%   keyword can be identified uniquely. The same holds for values of
%   keywords that can be assigned only a limited number of possible
%   string values (List field is a cell array).
%
%   The function returns an error string if an error is detected while
%   processing the arguments (errors in the syntax of the PROCARGS call
%   are handled as normal exceptions). The normal output will be a
%   structure containing a field for every parameter in the structure
%   array Args.
%
%   Example
%      arg(1).Name='parent';
%      arg(1).HasDefault=0;
%      %
%      arg(2).Name='type';
%      arg(2).HasDefault=1;
%      arg(2).Default='bar';
%      arg(2).List={'area','bar'};
%      %
%      arg(3).Name='color';
%      arg(3).HasDefault=1;
%      arg(3).Default='none';
%      %
%      [options,err]=procargs({1,'color','b'},arg);
%
%      returns
%
%      options =
%
%          parent: 1               % the keyword-less value 1
%            type: 'bar'           % the default value for "type"
%           color: 'b'             % from the keyword-value pair by the user
%
%
%   Note on the abbreviation of keywords
%
%      [options,err]=procargs({1,'C','b'},arg);
%
%   would have given the same result since 'C' uniquely identifies the
%   keyword 'color' in the list of keywords 'parent','type' and 'color'.
%
%
%   ALTERNATIVE SYNTAX:
%
%   [Struct,Err]=PROCARGS(VARARGIN,CellFields,CellValues)
%   CellFields and CellValues arguments together define the structure
%   array as used by CELL2STRUCT.
%
%   Same example
%
%      [options,err]=procargs({1,'color','b'}, ...
%         {'Name'  ,'HasDefault','Default','List'}, ...
%         {'parent',0  ,[]     ,[]
%          'type'  ,1  ,'bar'  ,{'area','bar'}
%          'color' ,1  ,'none' ,[]             });
%
%
%   Limitations: keyword-less parameters should not be strings because
%   they can easily be confused with keywords.
%
%
%   See also VARARGIN, CELL2STRUCT.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
