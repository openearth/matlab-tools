function choice = nc_kickstarter_optionlist(url, varargin)
%NC_KICKSTARTER_OPTIONLIST  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = nc_kickstarter_optionlist(varargin)
%
%   Input: For <keyword,value> pairs call nc_kickstarter_optionlist() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   nc_kickstarter_optionlist
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
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
% Created: 27 Aug 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'format','{name}', ...
    'pref_group','netcdfKickstarter', ...
    'pref_key','', ...
    'default',1, ...
    'prompt','Choose option');

OPT = setproperty(OPT, varargin);

%% get data

data = urlread(url);
options = json.load(data);

for i = 1:length(options)
    if iscell(options)
        opt = options{i};
    else
        opt = options(i);
    end
    
    if isstruct(opt)
        fprintf('[%2d] %s\n',i,option_format(OPT.format,opt));
    else
        fprintf('[%2d] %s\n',i,opt);
    end
end

fprintf('\n');

v = OPT.default;
if ~isempty(OPT.pref_key)
    if ispref(OPT.pref_group,OPT.pref_key)
        v = getpref(OPT.pref_group,OPT.pref_key);
    end
end

choice = input(sprintf('%s [%d]: ',OPT.prompt,v) ,'s');

if isempty(choice)
    choice = v;
elseif regexp(choice,'^\d+$')
    choice = str2double(choice);
    if choice <= 0 || choice > length(options)
        error('Invalid choice [%d]',choice);
    end
else
    error('Invalid choice [%s]',choice);
end

if ~isempty(OPT.pref_key)
    setpref(OPT.pref_group,OPT.pref_key,choice);
end

if ~isempty(choice)
    if iscell(options)
        choice = options{choice};
    else
        choice = options(choice);
    end
end

fprintf('\n');

function fmt = option_format(fmt, s)
    if isstruct(s)
        f = fieldnames(s);
        for i = 1:length(f)
            val = s.(f{i});
            if ~ischar(val)
                val = num2str(val);
            end
            fmt = strrep(fmt,sprintf('{%s}',f{i}),val);
        end
    else
        fmt = '?';
    end
