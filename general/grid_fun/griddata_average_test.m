function testresult = griddata_average_test()
% GRIDDATA_AVERAGE_TEST  One line description goes here
%  
% More detailed description of the test goes here.
%
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       tda
%
%       <EMAIL>	
%
%       <ADDRESS>
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
% Created: 26 Mar 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% $Description (Name = Name of the test goes here)
% Publishable code that describes the test.

%% $RunCode
% Write test code here
try
    close gcf
    figure
    x = (randn(200)-.5).*2;
    y = (rand(200)-.5).*6;
    z = peaks(x,y);
    x = x(1:10,:);
    y = y(1:10,:);
    z = z(1:10,:);
    nn = 30;
    [XI,YI] = meshgrid(linspace(-4,4,nn),linspace(-4,4,nn*2));
    ZI = griddata_average(x,y,z,XI,YI);
    subplot(2,1,1)
    hold on
    plot3(x,y,z,'g.')
    line(XI,YI,ZI)
    line(XI',YI',ZI')
    plot3(XI,YI,ZI,'bo')
    title 'griddata average'
    hold off
    subplot(2,1,2)
    ZI = griddata(x,y,z,XI,YI); %#ok<FPARK>
        hold on
    plot3(x,y,z,'g.')
    line(XI,YI,ZI)
    line(XI',YI',ZI')
    plot3(XI,YI,ZI,'bo')
    title griddata
    hold off
    testresult = true;
catch
    testresult = false;    
end

%% $PublishResult
% Publishable code that describes the test.

