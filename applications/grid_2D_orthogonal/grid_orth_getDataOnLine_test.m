function testresult = grid_orth_getDataInPolygon_test()
%GRID_ORTH_GETDATAINPOLYGON_TEST  test for grid_orth_getdatainpolygon
%  
% 
% See also: grid_orth_getDataInPolygon_test

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 11 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% $Description (Name = Name of the test goes here)
% Publishable code that describes the test.
% NB1: onderstaande testcases zijn met voorgedefinieerde polygonen. Als je de polygonen niet opgeeft mag je ze zelf selecteren met de crosshair (rechter muisknop om te sluiten)
% NB2: de routines zijn nog niet 100% robuust. Ook is de data op de OpenDAP server nog niet helemaal goed. Met name dit laatste moet zsm verholpen worden!
% NB3: enkele onderdelen van dit script zijn nog vrij sloom: bepalen welke grids er zijn en het ophalen van alle kaartbladomtrekken. Hopelijk is dit te fixen middels de Catalog.xml op de OPeNDAP server

%% $RunCode

tr(1) = test1;
tr(2) = test2;
testresult = all(tr);


%% $PublishResult
% Publishable code that describes the test.

end

function testresult = test1()
%% $Description 

%% $RunCode
% make test data
x = -10:29;
y = -20:39;
[X,Y] = meshgrid(x,y);
alpha = 1108.8466/180*pi;
X2 = Y*sin(alpha)+X*cos(alpha);
Y = -X*sin(alpha)+Y*cos(alpha);
X = X2;
Z = repmat(peaks(20),3,2);

% define line 
xi = [0 1000];
yi = [0 -250];

[crossing_x,crossing_y,crossing_z,crossing_dist] = grid_orth_getDataOnLine(X,Y,Z,xi,yi);

% plot demo
subplot(1,3,1)
mesh(X,Y,Z)

hold on
plot3(crossing_x,crossing_y,crossing_z,'.');
% plot3(xi([1 1 ]),yi([1 1]),[-10 10])
% plot3(xi([2 2 ]),yi([2 2]),[-10 10])
hold off
view(0,90)
axis([-10 50 -30 30])
axis square

subplot(1,3,2)
plot(crossing_dist,crossing_z,crossing_dist,crossing_z,'.')
axis square
axis([0 60 -8 8])
%
testresult = true;
%% $PublishResult

end


function testresult = test2()
%% $Description 

%% $RunCode
% make test data

x = -10:29;
y = -20:39;
[X,Y] = meshgrid(x,y);
Z = repmat(peaks(20),3,2);


x = nan(360,100);
y = nan(360,100);
z = nan(360,100);
d = nan(360,100);
for ii = 1:5:360
alpha = ii+0.1/180*pi;
X2 = Y*sin(alpha)+X*cos(alpha);
Y2 = -X*sin(alpha)+Y*cos(alpha);

% define line 
xi = [0 1000];
yi = [0 -250];

[crossing_x,crossing_y,crossing_z,crossing_d] = grid_orth_getDataOnLine(X2,Y2,Z,xi,yi);
x(ii,1:length(crossing_x)) =  crossing_y*sin(alpha)+crossing_x*cos(alpha);
y(ii,1:length(crossing_x)) = -crossing_x*sin(alpha)+crossing_y*cos(alpha);
z(ii,1:length(crossing_x)) = crossing_z;
d(ii,1:length(crossing_x)) = crossing_d;
end
subplot(1,3,3)
plot3(x',y',z')
testresult = true;
%% $PublishResult

end
