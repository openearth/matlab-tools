function testresult = grid_orth_getDataOnLine_test()
%GRID_ORTH_GETDATAONLINE_TEST  test for grid_orth_getDataOnLine
%  
% 
% See also: grid_orth_getDataOnLine

%% Copyright notice
% --------------------------------------------------------------------
% Copyright (C) 2004-2009 Delft University of Technology
% Version:      Version 1.0, February 2004
%     Mark van Koningsveld
%
%     m.vankoningsveld@tudelft.nl
%
%     Hydraulic Engineering Section
%     Faculty of Civil Engineering and Geosciences
%     Stevinweg 1
%     2628CN Delft
%     The Netherlands
%
% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Lesser General Public
% License as published by the Free Software Foundation; either
% version 2.1 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
% USA
% --------------------------------------------------------------------

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

%% Description (Name = Name of the test goes here)
% Publishable code that describes the test.
% NB1: onderstaande testcases zijn met voorgedefinieerde polygonen. Als je de polygonen niet opgeeft mag je ze zelf selecteren met de crosshair (rechter muisknop om te sluiten)
% NB2: de routines zijn nog niet 100% robuust. Ook is de data op de OpenDAP server nog niet helemaal goed. Met name dit laatste moet zsm verholpen worden!
% NB3: enkele onderdelen van dit script zijn nog vrij sloom: bepalen welke grids er zijn en het ophalen van alle kaartbladomtrekken. Hopelijk is dit te fixen middels de Catalog.xml op de OPeNDAP server

MTestCategory.DataAccess;

% test 1 and 2 are examples/illustrations, and produce figures as result
testresult = all([test3, test4, test5, test6]);

end

function testresult = test1()
%% $Description 

%% $RunCode
% make test data
x = 1:12;
y = 11:28;
[X,Y] = meshgrid(x,y);
alpha = 4/180*pi;
X2 = Y*sin(alpha)+X*cos(alpha);
Y = -X*sin(alpha)+Y*cos(alpha);
X = X2+sin(Y);
Y = Y+sin(X2);
Z = peaks(20);
Z = Z(3:20,5:16);

% define line 
xi = [ 2   21.2];
yi = [11.7 19.2];

[crossing_x,crossing_y,crossing_z,crossing_d] = grid_orth_getDataOnLine(X,Y,Z,xi,yi);

%% plot demo
subplot(1,3,1)


hold on
plot3(X,Y,Z,'k');
plot3(X',Y',Z','k');
plot3(crossing_x,crossing_y,crossing_z,'.');
plot3(crossing_x(  1),crossing_y(  1),crossing_z(  1),'ro');
plot3(crossing_x(end),crossing_y(end),crossing_z(end),'k*');
plot3(crossing_x,crossing_y,crossing_z,'b');
line('XDATA',xi,'YDATA',yi,'linewidth',2,'color','r','linestyle',':')
line('XDATA',xi(1),'YDATA',yi(1),'linewidth',2,'color','r','linestyle','none','marker','+')
line('XDATA',xi(2),'YDATA',yi(2),'linewidth',2,'color','k','linestyle','none','marker','+')
hold off

subplot(1,3,2)
plot(crossing_d,crossing_z,crossing_d,crossing_z,'*')


testresult = true;
%% $PublishResult

end


function testresult = test2()
%% $Description 

%% $RunCode
% make test data

x = -10:29;
y = -20:59;
[X,Y] = meshgrid(x,y);
Z = repmat(peaks(40),2,1)+X/10-Y/10;
Z(20:30,15:25) = nan;


x = nan(360,100);
y = nan(360,100);
z = nan(360,100);
d = nan(360,100);
for ii = 1:10:360
alpha = ii+0.1/180*pi;
X2 = -Y*sin(alpha)+X*cos(alpha);
Y2 = X*sin(alpha)+Y*cos(alpha);

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
hold on
mesh(X,Y,Z)
hold off
testresult = true;
%% $PublishResult

end


function testresult = test3()
%% $Description 

%% $RunCode
% make test data
x =  0.5:.5:10;
y = 20.5:.5:32;

[X,Y] = meshgrid(x,y);
Z = sin(sqrt((X).^2+(Y-20).^2));

% define line
xi = [0 9];
yi = [20 29];

[crossing_x,crossing_y,crossing_z,crossing_d] = grid_orth_getDataOnLine(X,Y,Z,xi,yi);
    
testresult = max(abs(sin(crossing_d) - crossing_z))<eps(100);


%% $PublishResult

end

function testresult = test4()
%% $Description 
%same as test3, but with a distorted grid
%% $RunCode
% make test data
x =  0.5:.5:10;
y = 20.5:.5:32;

[X,Y] = meshgrid(x,y);
X = X+sin(X+Y.^2)/4;
Y = Y+cos(X.^2+Y)/4;
Z = sin(sqrt((X).^2+(Y-20).^2));

% define line
xi = [0 9];
yi = [20 29];

[crossing_x,crossing_y,crossing_z,crossing_d] = grid_orth_getDataOnLine(X,Y,Z,xi,yi);
    
testresult = max(abs(sin(crossing_d) - crossing_z))<0.05;
%% $PublishResult

end

function testresult = test5()
%% $Description 

%% $RunCode
% make test data
x =  -10:.5:10;
y =   -2:.5:32;

[X,Y] = meshgrid(x,y);
Z = sin(sqrt(X.^2+Y.^2));

% define line
xi = [0 10];
yi = [0 0];

[crossing_x,crossing_y,crossing_z,crossing_d] = grid_orth_getDataOnLine(X,Y,Z,xi,yi);
    
testresult = max(abs(sin(crossing_d) - crossing_z))<eps(100);


%% $PublishResult

end

function testresult = test6()
%% $Description 
    % test if the outcome is identical for all sign combinations of x and y;

%% $RunCode
% make test data
x =  -10:.5:10;
y =   -2:.5:32;

[X,Y] = meshgrid(x,y);
Z = sin(sqrt(X.^2+Y.^2));

% define line
xi = [0 10; 0.1 9.9; 2  2; 2     2; 0 10;0.1 9.3];
yi = [2 2 ; 2     2; 0 10; 0.1 9.9; 2  2;0.6 9.8];

testresult = nan(1,5);

for ii = 1:5
    [crossing_x1,crossing_y1,crossing_z1,crossing_d1] = grid_orth_getDataOnLine( X, Y,Z, xi(ii,:), yi(ii,:));
    [crossing_x2,crossing_y2,crossing_z2,crossing_d2] = grid_orth_getDataOnLine( X,-Y,Z, xi(ii,:),-yi(ii,:));
    [crossing_x3,crossing_y3,crossing_z3,crossing_d3] = grid_orth_getDataOnLine(-X, Y,Z,-xi(ii,:), yi(ii,:));
    [crossing_x4,crossing_y4,crossing_z4,crossing_d4] = grid_orth_getDataOnLine(-X,-Y,Z,-xi(ii,:),-yi(ii,:));
    testresult(ii) = isequalwithequalnans(crossing_z1, crossing_z2, crossing_z3, crossing_z4);
end

testresult = all(testresult);

%% $PublishResult

end

function testresult = test7()
%% $Description 

%% $RunCode
[X,Y] = meshgrid([1:20],[1:20]);
X = flipud(X);
Y = flipud(Y);
alpha = -4/180*pi;
X = Y*sin(alpha)+X*cos(alpha);
Y= -X*sin(alpha)+Y*cos(alpha);
Y(end,1) = nan;
X(end,1) = nan;

xi = [10.5 18.7];
yi = [4.1 15.5];

[crossing_x,crossing_y,crossing_z]=grid_orth_getDataOnLine(X,Y,repmat(1,size(X)),[10.5 18.7],[4.1 15.5]);

figure;grid_plot(X,Y,'k');hold on;
plot(xi,yi,'b');
plot(crossing_x,crossing_y,'or');

testresult = 1;

%% $PublishResult

end