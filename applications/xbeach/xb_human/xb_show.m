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

is_interactive = xb_getpref('interactive');

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
path = struct('root', inputname(1), 'self', '', 'parent', '', 'obj', inputname(1), ...
    'fullself', inputname(1), 'fullparent', '');
if isfield(xb, 'path')
    p = regexp(xb.path, '\.', 'split');
    path.root = p{1};
    path.self = sprintf('.%s', p{2:end});
    path.self = path.self(2:end);
    path.fullself = sprintf('%s, ''%s''', path.root, path.self);
    path.obj = sprintf('xb_get(%s, ''%s'')', path.root, path.self);
    
    path.parent = path.root;
    path.fullparent = path.root;
    
    if length(p) > 2
        path.parent = sprintf('.%s', p{2:end-1});
        path.parent = path.parent(2:end);
        path.fullparent = sprintf('%s, ''%s''', path.root, path.parent);
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
    format = '%-15s %-10s %-10s %-10s %-10s %-30s';
    fprintf([format '\n'], 'variable', 'size', 'bytes', 'class', 'units', 'value');
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
        
        maxl = 30;

        % remove multiple spaces
        if length(value) > 2*maxl
            value = regexprep(value(1:2*maxl), '\s+', ' ');
        else
            value = regexprep(value, '\s+', ' ');
        end

        % maximize length
        if length(value) > maxl
            value = [value(1:(maxl/2-2)) ' .. ' value(end-(maxl/2-3):end)];
        end
        
        % determine current child
        if isempty(path.self)
            child = xb.data(i).name;
        else
            child = [path.self '.' xb.data(i).name];
        end

        % link xbeach substructs
        if xb_check(var)
            if ~isempty(path.root) && is_interactive
                cmd = sprintf('matlab:xb_show(%s, ''%s'');', path.root, child);
                class = ['<a href="' cmd '">nested</a>    '];
            else
                class = 'nested    ';
            end
        else
            class = info.class;
        end
        
        % determine units
        units = '';
        if isfield(xb.data(i), 'units')
            units = xb.data(i).units;
        end
        
        % add commands
        menu = {};
        if ~isempty(path.root) && is_interactive
            cmd = sprintf('matlab:xb_get(%s, ''%s'')', path.root, child);
            menu = [menu{:} {['<a href="' cmd '">get</a>']}];
            
            cmd = sprintf('matlab:%s = xb_set(%s, ''%s''); xb_show(%s);', path.root, path.root, child, path.fullself);
            menu = [menu{:} {['<a href="' cmd '">set</a>']}];
            
            cmd = sprintf('matlab:%s = xb_del(%s, ''%s''); xb_show(%s);', path.root, path.root, child, path.fullself);
            menu = [menu{:} {['<a href="' cmd '">del</a>']}];
            
            cmd = sprintf('matlab:%s = xb_rename(%s, ''%s''); xb_show(%s);', path.root, path.root, child, path.fullself);
            menu = [menu{:} {['<a href="' cmd '">ren</a>']}];
        end
        cmds = sprintf(' %s', menu{:});

        fprintf([format cmds '\n'], xb.data(i).name, ...
            regexprep(num2str(info.size),'\s+','x'), ...
            num2str(info.bytes), ...
            class, ...
            units, ...
            value);
    end
    
    fprintf('\n');
    
    % add action menu
    if ~isempty(path.root) && is_interactive
        menu = {};

        if ~isempty(path.fullparent)
            cmd = sprintf('matlab:xb_show(%s);', path.fullparent);
            menu = [menu{:} {['<a href="' cmd '">parent</a>']}];
        end

        cmd = sprintf('matlab:xb_plot(%s);', path.obj);
        menu = [menu{:} {['<a href="' cmd '">plot</a>']}];

        if strcmpi(xb.type, 'input')
            cmd = sprintf('matlab:xb_write_input(''params.txt'', %s);', path.obj);
            menu = [menu{:} {['<a href="' cmd '">write</a>']}];

            cmd = sprintf('matlab:xb_run(%s);', path.obj);
            menu = [menu{:} {['<a href="' cmd '">run</a>']}];

            cmd = sprintf('matlab:xb_run_remote(%s, ''ssh_prompt'', true);', path.obj);
            menu = [menu{:} {['<a href="' cmd '">run remote</a>']}];
        end

        if ~isempty(menu)
            fprintf('%-14s: %s\n\n', 'options', sprintf('%s ', menu{:}));
        end
    end
end