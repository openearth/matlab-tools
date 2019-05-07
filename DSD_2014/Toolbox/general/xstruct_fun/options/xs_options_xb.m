function menu = xs_options_xb(xs,path)
%XS_OPTIONS_XB  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xs_options_xb(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xs_options_xb
%
%   See also

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
% Created: 15 May 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: xs_options_xb.m 4147 2014-10-31 10:12:42Z bieman $
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/xbeach/Courses/DSD_2014/Toolbox/general/xstruct_fun/options/xs_options_xb.m $
% $Keywords: $

%% create menu options

menu = {};

cmd = sprintf('matlab:xb_view(%s);', path.obj);
menu = [menu{:} {['<a href="' cmd '">view</a>']}];

if strcmpi(xs.type, 'input')
    cmd = sprintf('matlab:xb_write_input(''params.txt'', %s);', path.obj);
    menu = [menu{:} {['<a href="' cmd '">write</a>']}];

    cmd = sprintf('matlab:xb_run(%s);', path.obj);
    menu = [menu{:} {['<a href="' cmd '">run</a>']}];

    cmd = sprintf('matlab:xb_run_remote(%s, ''ssh_prompt'', true);', path.obj);
    menu = [menu{:} {['<a href="' cmd '">run remote</a>']}];
end
