function Category(cat)
%CATEGORY  sets the category of the test that is currently running
%
%   This function can be used to set the category of a test.
%
%   Syntax:
%   Category(cat)
%
%   Input:
%   cat  = One of the TestCategories or an int representing that category
%          (see TestCategory for an overview). The possibility of
%          specifying an int is included because of backwards
%          compatibility. If you would like to be able to run a test in a
%          matlab version prior to 2008a, please specify the integer that
%          is returned by TestCategory.(CategoryName);
%
%   Example
%   Category(TestCategory.Unit);
%   Category(0); % This meant TestCategory.Unit
%   Category(TestCategory.WorkInProgress);
%
%   See also TestCategory

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Pieter van Geer
%
%       Pieter.VanGeer@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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
% Created: 26 Nov 2010
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% TODO
% Check version ? If we want to run the test in a version prior to 2008a,
% it should be possible to do so command line (in other words the test code
% should not crash on classdef problems (Is that even possible Whereas the TestCategory is a class?).

%% 
if TeamCity.running
    currentTest = TeamCity.currenttest;
    if ~isempty(currentTest)
        currentTest.Category = cat;
    end
end