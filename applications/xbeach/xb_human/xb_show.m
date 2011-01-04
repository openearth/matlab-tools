function xb_show(xb, varargin)
%XB_SHOW  Shows contents of a XBeach structure
%
%   WHOS-like display of the contents of a XBeach structure
%
%   Syntax:
%   xb_show(xb)
%
%   Input:
%   xb          = XBeach structure array
%   varargin    = Variables to be included, by default all variables are
%                 included. Filters can be used select multiple variables
%                 at once (exact match, dos-like, regexp, see strfilter).
%                 If a nested XBeach structure array is specifically
%                 requested (exact match), an extra xb_show is fired
%                 showing the contents of the nested struct.
%
%   Output:
%   none
%
%   Example
%   xb_show(xb)
%   xb_show(xb, 'zb', 'zs')
%   xb_show(xb, 'z*')
%   xb_show(xb, '/^z')
%   xb_show(xb, 'bcfile')
%   xb_show(xb, 'bcfile', 'zs')
%
%   See also xb_set, xb_get, xb_empty, strfilter

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 24 Nov 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% show structure contents

if ~xb_check(xb); error('Invalid XBeach structure'); end;

% determine variables to be showed, show xb_show for specifically requested
% XBeach sub-structures
if nargin > 1
    vars = {};
    for i = 1:length(varargin)
        val = xb_get(xb, varargin{i});
        if xb_check(val)
            val.path = [inputname(1) '.' varargin{i}];
            xb_show(val);
        else
            vars = [vars{:} varargin(i)];
        end
    end
else
    vars = {xb.data.name};
end

% parse path in substructure
path = struct('root', inputname(1), 'self', '', 'parent', '', 'obj', inputname(1));
if isfield(xb, 'path')
    p = regexp(xb.path, '\.', 'split');
    path.root = p{1};
    path.self = sprintf('.%s', p{2:end});
    path.self = path.self(2:end);
    path.obj = sprintf('xb_get(%s, ''%s'')', path.root, path.self);
    
    if length(p) > 2
        path.parent = sprintf('.%s', p{2:end-1});
        path.parent = path.parent(2:end);
    end
end

if ~isempty(vars)
    
    % identify data
    f = fieldnames(xb);
    idx = strcmpi('data',f);

    % determine max fieldname length
    max_length = max(cellfun(@length, f));

    % show meta data
    for i = find(~idx)'
        nr_blanks = max_length - length(f{i});
        value = regexprep(xb.(f{i}), '\n', ['\n' blanks(max_length+3)]);
        fprintf('%s%s : %s\n', f{i}, blanks(nr_blanks), value);
    end

    fprintf('\n');

    % show data
    format = '%-15s %-10s %-10s %-10s %-10s %-30s\n';
    fprintf(format, 'variable', 'size', 'bytes', 'class', 'units', 'value');
    for i = 1:length(xb.data)
        if ~any(strfilter(xb.data(i).name, vars)); continue; end;

        var = xb_get(xb, xb.data(i).name);
        info = whos('var');

        % determine display of value
        if ~isstruct(var) && ~iscell(var) && (isscalar(var) || isvector(var))
            if size(var,1) > size(var,2)
                var = var';
            end
            if isnumeric(var) || islogical(var)
                value = num2str(var);
            else
                value = var;
            end
        else
            value = '';
        end

        % remove multiple spaces
        value = regexprep(value, '\s+', ' ');

        % maximize length
        maxl = 30;
        if length(value) > maxl
            value = [value(1:(maxl/2-2)) ' .. ' value(end-(maxl/2-3):end)];
        end

        % link xbeach substructs
        if xb_check(var)
            if isempty(path.self)
                child = {path.root xb.data(i).name};
            else
                child = {path.root [path.self '.' xb.data(i).name]};
            end
            
            cmd = sprintf('matlab:xb_show(%s, ''%s'');', child{:});

            class = ['<a href="' cmd '">nested</a>'];
        else
            class = info.class;
        end
        
        % determine units
        units = '';
        if isfield(xb.data(i), 'units')
            units = xb.data(i).units;
        end

        fprintf(format, xb.data(i).name, ...
            regexprep(num2str(info.size),'\s+','x'), ...
            num2str(info.bytes), ...
            class, ...
            units, ...
            value);
    end
    
    fprintf('\n');
    
    % add action menu
    menu = {};
    
    if ~isempty(path.self)
        if isempty(path.parent)
            cmd = sprintf('matlab:xb_show(%s);', path.root);
        else
            cmd = sprintf('matlab:xb_show(%s, ''%s'');', path.root, path.parent);
        end
        
        menu = [menu{:} {['<a href="' cmd '">parent</a>']}];
    end
    
    cmd = sprintf('matlab:xb_plot(%s);', path.obj);
    menu = [menu{:} {['<a href="' cmd '">plot</a>']}];
    
    if strcmpi(xb.type, 'input')
        cmd = sprintf('matlab:xb_write_input(''params.txt'', %s);', path.obj);
        menu = [menu{:} {['<a href="' cmd '">write</a>']}];
        
        cmd = sprintf('matlab:xb_run(%s);', path.obj);
        menu = [menu{:} {['<a href="' cmd '">run</a>']}];
    end
    
    if ~isempty(menu)
        fprintf('%-14s: %s\n\n', 'options', sprintf('%s ', menu{:}));
    end
end