function testResult = jarkus_identify_first_dunerow_test()
% JARKUS_IDENTIFY_FIRST_DUNEROW_TEST  Test detection of dunerows
%  
% Several testcases for dune row detection.
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
% Created: 28 Jul 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $


testresult = [];

x = (1:7) * 100; % 100 m intervals
z = [0 15 0 10 0 5 0]; % 3 dune rows of 15, 10, 5 m
a = jarkus_identify_first_dunerow(x, z);
subplot(2,4,1)
plot(x,z,'bl',a,0, 'ro')
if (a == 5*100)    
    testresult(end+1) = true;
    title('ok')
else
    testresult(end+1) = false;
    title('not ok')
end



x = (1:8) * 100; % 100 m intervals
z = [5 15 5 10 5 5.5 5 0]; % 3 dune rows of 15, 10, 1 m (1/2 *100 < 60)
a = jarkus_identify_first_dunerow(x, z);
subplot(2,4,2)
plot(x,z,'bl',a,0, 'ro')
if (a == 3*100)
    testresult(end+1) = true;
    title('ok')
else
    testresult(end+1) = false;
    title('not ok')
end


x = (1:7) * 100; % 100 m intervals
z = [0 15 0 10 5 10 0]; % 1 big dune of 15 and 2 tops of 10 with a valley at 5
a = jarkus_identify_first_dunerow(x, z);
subplot(2,4,3)
plot(x,z,'bl',a,0, 'ro')
if (a == 5*100)
    testresult(end+1) = true;
    title('ok')
else
    testresult(end+1) = false;
    title('not ok')
end

x = (1:7) * 100; % 100 m intervals
z = [0 15 5 10 5 6 5]; % 1 big dune of 15 and 2 tops of 10 and 6 with a valley at 5
a = jarkus_identify_first_dunerow(x, z);
subplot(2,4,4)
plot(x,z,'bl',a,0, 'ro')
if (a == 5*100)
    testresult(end+1) = true;
    title('ok')
else
    testresult(end+1) = false;
    title('not ok')
end

x = (1:10) * 100;
z = [1 10 0 7 5.2 6 5.1 5.5 5 0]; % several small dunes which combine into a big one before another big one
a = jarkus_identify_first_dunerow(x, z);
subplot(2,4,5)
plot(x,z,'bl',a,0, 'ro')
if (a == 5*100)
    testresult(end+1) = true;
    title('ok')
else
    testresult(end+1) = false;
    title('not ok')
end

x = (1:7) * 100; % 100 m intervals
z = [0 15 0 10 0 4 0]; % 3 dune rows of 15, 10, 4 m
a = jarkus_identify_first_dunerow(x, z);
subplot(2,4,6)
plot(x,z,'bl',a,0, 'ro')
if (a == 3*100)
    testresult(end+1) = true;
    title('ok')
else
    testresult(end+1) = false;
    title('not ok')
end

% derive the overall result
testResult = all(testresult);