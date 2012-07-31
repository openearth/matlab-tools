function varargout = pg_value2sql(varargin)
%PG_VALUE2SQL  Makes a cell array of arbitrary values suitable for the use in an SQL query
%
%   Makes a cell array of arbitrary values suitable for the use in an SQL
%   query by converting each variable to a string representation.
%   Quotes are escaped. Function handles are called and the result is
%   re-inserted in this function. Cell arrays are treated item-by-item and
%   subsequently concatenated.
%
%   Syntax:
%   varargout = pg_value2sql(varargin)
%
%   Input:
%   varargin  = Values to be used in a SQL query
%
%   Output:
%   varargout = String representations of given variables suitable for the
%               use within a SQL query
%
%   Example
%   vals = cell(1,8);
%   [vals{:}] = pg_value2sql(123, 0.23, 'Let''s go!', {@num2str, 3}, true, {}, false, {123, 0.23, 'Let''s go!'});
%
%   See also pg_query, pg_select_struct, pg_insert_struct, pg_update_struct

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
%       Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 27 Jul 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% convert values

varargout = cell(size(varargin));

for i = 1:length(varargin)
    
    switch class(varargin{i})
        case 'char'
            varargout{i} = ['''' escape(varargin{i}) ''''];
        case 'logical'
            if varargin{i}
                varargout{i} = 'TRUE';
            else
                varargout{i} = 'FALSE';
            end
        case 'double'
            varargout{i} = num2str(varargin{i});
        case 'cell'
            if ~isempty(varargin{i})
                if isa(varargin{i}{1}, 'function_handle')
                    varargout{i} = pg_value2sql(feval(varargin{i}{:}));
                else
                    warning('Concatenate cell array to string');
                    
                    varargout{i} = concat(cellfun(@(x) pg_value2sql(x),varargin{i},'UniformOutput',false),', ');
                end
            else
                warning('Treat empty cell array as empty string');
                
                varargout{i} = '''''';
            end
        case 'function_handle'
            varargout{i} = pg_value2sql(feval(varargin{i}));
        otherwise
            error('Unsupported variable type [%s]', class(varargin{i}));
    end
    
end

function str = escape(str)

str = strrep(str, '''', '''''');