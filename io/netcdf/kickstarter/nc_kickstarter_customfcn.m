function v = nc_kickstarter_customfcn(host, var, m, m_all)
%NC_KICKSTARTER_CUSTOMFCN  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   v = nc_kickstarter_customfcn(host, var, m, m_all)
%
%   Input: For <keyword,value> pairs call nc_kickstarter_customfcn() without arguments.
%   host  =
%   var   =
%   m     =
%   m_all =
%
%   Output:
%   v     =
%
%   Example
%   nc_kickstarter_customfcn
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

%% code

v = m.default;

switch m.category
    case 'var'
        switch m.key
            case 'name'
                v = regexprep(var,'\W+','_');
            case 'long_name'
                v = var;
            case 'standard_name'
                names = json.load(urlread(fullfile(host,'json',['standardnames?search=' var])));
                if isempty(names)
                    names = json.load(urlread(fullfile(host,'json','standardnames')));
                end
                
                for i = 1:length(names)
                    fprintf('[%2d] %s [%s]\n',i,names(i).standard_name, names(i).units);
                end
                
                fprintf('\n');
                
                while true
                    name_id = input(sprintf('Choose standard name: ') ,'s');

                    if ~isempty(name_id)
                        if regexp(name_id,'^\d+$')
                            name_id = str2num(name_id);
                            if name_id > 0 && name_id <= length(names)
                                break;
                            end
                        end
                    end
                end
                
                v = names(name_id).standard_name;

                fprintf('\n');
            case 'units'
                m_stdname = get_m(m_all,'var','standard_name');
                names = json.load(urlread(fullfile(host,'json',['standardnames?search=' m_stdname.value])));
                
                v = names(1).units;
        end
end

if ~ischar(v)
    v = num2str(v);
end

function mi = get_m(m, cat, key)
    for i = 1:length(m)
        if strcmpi(m(i).category,cat) && strcmpi(m(i).key,key)
            mi = m(i);
            return;
        end
    end
    mi = struct();