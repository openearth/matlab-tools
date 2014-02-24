% EXAMPLE Example script that shows how to inpect a custom class
%
% See also: metaprop.example_classdef

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Van Oord
%       Thijs Damsma
%
%       Thijs.Damsma@VanOord.com
%
%       Schaardijk 211
%       3063 NH
%       Rotterdam
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
% Created: 21 Feb 2014
% Created with Matlab version: 8.3.0.73043 (R2014a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% instantiate a class
% an example class
obj = metaprop.example_classdef;

% View the properties of the object
properties(obj)

% Input verification 
try
    obj.Date = '2002/09/01';
catch ME
    disp(ME.message)
end

obj.Date = datenum(2002,9,1);

%% Interactive inspection of class
% open the inspector by calling the objects inspect method
inspector = obj.inspect;
% wait for output
uiwait(inspector.Figure)

fprintf('Date is now set to %s', datestr(obj.Date))