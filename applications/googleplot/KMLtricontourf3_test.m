function testresult = KMLtricontourf3_test()
% KMLTRICONTOURF3_TEST  One line description goes here
%  
% More detailed description of the test goes here.
%
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Thijs
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
% Created: 16 Mar 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

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
    %test 1
    clc
    [x,y] = meshgrid(1:10,21:30);
    z = peaks(10);
    tri = delaunay(x,y);
    tri(1:28,:)=[];
%    tri(60:84,:)=[];
    nn=9;
    tricontour3(tri,y,x,z,nn);
    E = trisurf_edges(tri,x,y,z);
    for ii=1:E(end,4)
        jj = find(E(:,4)==ii);
             line(E(jj,1),E(jj,2),E(jj,3));
    end
    for ii=1:E(end,4)
        jj = find(E(:,4)==ii);
             line(E(jj,2),E(jj,1),E(jj,3));
    end
    h = text(E(:,2),E(:,1),reshape(sprintf('%5d',1:size(E,1)),5,[])');
    set(h,'color','r','FontSize',6,'VerticalAlignment','top')
    view(0,90)
    KMLtricontourf3(tri,x./10,y./10,z,'levels',nn,'fileName',KML_testdir('KMLtricontourf3 - 1.kml'),...
        'zScaleFun',@(z) (z+6)*1000,'staggered',false)

%% $PublishResult
% Publishable code that describes the test.