function testresult = abspath_test()
% ABSPATH_TEST  Test function of abspath
%  
% More detailed description of the test goes here.
%
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 03 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTestCategory.WorkInProgress;

testresult = [];

%% test 1
% most basic test
testresult(end+1) = strcmp(cd, abspath(cd));

%% test 2
%
testresult(end+1) = strcmp(cd, abspath(''));

%% test 3
% unix test for root
if isunix
    testresult(end+1) = strcmp(filesep, abspath(filesep));
end

%% test 4
% unix test for home directory
if isunix
    testresult(end+1) = strcmp('~', abspath('~'));
end

%% test 5
% windows test
if ispc
    testresult(end+1) = strcmp('C:', abspath('C:'));
end

%% test 6
% test for an arbitrary relative path
testresult(end+1) = strcmp(cd, abspath(fullfile(cd, 'test', '..', '.', 'test', 'test', '.', '..', '..')));

%% collect test results
testresult = all(testresult);