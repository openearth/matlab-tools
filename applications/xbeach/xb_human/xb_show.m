function xb_show(xbSettings, varargin)
%XB_SHOW  Shows contents of a XBeach settings struct
%
%   WHOS-like display of the contents of a XBeach settings struct
%
%   Syntax:
%   xb_show(xbSettings)
%
%   Input:
%   xbSettings  = XBeach settings struct (name/value)
%   varargin    = Variables to be included, by default all variables are
%                 included. If a nested XBeach settings struct is
%                 specifically requested, an extra xb_show is fired showing
%                 the contents of the nested struct.
%
%   Output:
%   none
%
%   Example
%   xb_show(xbSettings)
%
%   See also xb_set, xb_get, xb_empty

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

if ~xb_check(xbSettings); error('Invalid XBeach settings structure'); end;

if nargin > 1
    vars = {}; c = 1;
    for i = 1:length(varargin)
        val = xb_get(xbSettings, varargin{i});
        if xb_check(val)
            xb_show(val);
        else
            vars{c} = varargin{i};
            c = c+1;
        end
    end
else
    vars = {xbSettings.data.name};
end

if ~isempty(vars)
    
    % identify data
    f = fieldnames(xbSettings);
    idx = strcmpi('data',f);

    % determine max fieldname length
    max_length = max(cellfun(@length, f));

    % show meta data
    for i = find(~idx)'
        nr_blanks = max_length - length(f{i});
        value = regexprep(xbSettings.(f{i}), '\n', ['\n' blanks(max_length+3)]);
        fprintf('%s%s : %s\n', f{i}, blanks(nr_blanks), value);
    end

    fprintf('\n');

    % show data
    format = '%-15s %-10s %-10s %-10s %-10s %-30s\n';
    fprintf(format, 'variable', 'size', 'bytes', 'class', 'units', 'value');
    for i = 1:length(xbSettings.data)
        if ~ismember(xbSettings.data(i).name, vars); continue; end;

        var = xb_get(xbSettings, xbSettings.data(i).name);
        info = whos('var');

        % determine display of value
        if ~isstruct(var) && ~iscell(var) && (isscalar(var) || isvector(var))
            if size(var,1) > size(var,2)
                var = var';
            end
            if isnumeric(var)
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

        units = '';
        if isfield('units', xbSettings.data(i))
            units = xbSettings.data(i).units;
        end

        fprintf(format, xbSettings.data(i).name, ...
            regexprep(num2str(info.size),'\s+','x'), ...
            num2str(info.bytes), ...
            info.class, ...
            units, ...
            value);
    end
    
    fprintf('\n');
end
