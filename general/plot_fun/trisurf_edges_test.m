function testresult = trisurf_edges_test()
% TRISURF_EDGES_TEST  One line description goes here
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
% Created: 04 Mar 2010
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

[x,y] = meshgrid(1.1:100.1,201.2:300.2);
x = x+sin(y).^3;
y = y+sin(x);
z = abs(peaks(100));
tri = delaunay(x,y);

tri(any((((x(tri)-50).^2 + (y(tri)-250).^2).^.5)>44,2),:)=[];
tri(any((((x(tri)-70).^2 + (y(tri)-270).^2).^.5)<7,2),:)=[];
tri(any((((x(tri)-30).^2 + (y(tri)-220).^2).^.5)<7,2),:)=[];
tri(any((((x(tri)-40).^2 + (y(tri)-260).^2).^.5)<7,2),:)=[];

tri(any(x(tri)>49&x(tri)<51,2),:)=[];
tri(any(y(tri)>249&y(tri)<251,2),:)=[];
for ii = 1200:-1:1100
    tri(ii:ii:end,:)=[];
end
trisurf(tri,x,y,z,1)
view(90,90)

E = trisurf_edges(tri,x,y,z);

colors = jet(size(E,1));
E(:,9)=0;
jj = find(E(:,7)==1);
ii = 0;
while any((~E(:,9)))
    ii = ii+1;
    hl = line(E(jj,[1 4]),E(jj,[2 5]),E(jj,[3 6]));
    set(hl,'Color',colors(ii,:),'LineWidth',2)
    E(jj,9) = 1;
    jj = E(jj,7);
    if E(jj,9)
        jj = find(~E(:,9),1);
    end
end

testresult = true;

%% $PublishResult
% Publishable code that describes the test.

