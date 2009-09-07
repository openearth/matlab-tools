function testresult = delaunay_simplified_test()
% DELAUNAY_SIMPLIFIED_TEST  One line description goes here
%  
% More detailed description of the test goes here.
%
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 <Deltares>
%       Thijs Damsma
%
%       <Thijs.Damsma@Deltares.nl>	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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
% Created: 07 Sep 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

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
    % some input
    [lat,lon] = meshgrid(54:.1:57,2:.1:5);
    z = peaks(31);
    z = abs(z);
    z(z<1) = nan;
   
    % call function
     tolerance = .5;
    tri1 = delaunay_simplified(lat,lon,z,tolerance);
    [tri2,x1,y1,z1] = delaunay_simplified(lat,lon,z,tolerance);


    h1 = subplot(2,1,1);
    trisurf(tri1,lat,lon,z);
  
    h2 = subplot(2,1,2);
    trisurf(tri2,x1,y1,z1);
    
    testresult = true;
catch
    testresult = false;
end

%% $PublishResult
% Publishable code that describes the test.
end

