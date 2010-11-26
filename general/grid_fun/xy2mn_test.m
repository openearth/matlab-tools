function xy2mn_test()
% XY2MN_TEST  test function for XY2MN
%  
% More detailed description of the test goes here.
%
%
%   See also xy2mn

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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
% Created: 23 Jun 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

percentage_gaps = 50;
[x,y]=meshgrid(1:100,1:50);

randomindices = unique(round(rand(round(length(x(:)).*percentage_gaps./100),1).*length(x(:))));
randomindices(randomindices<1) = [];

x(randomindices) = nan;
y(randomindices) = nan;

plot(x(:),y(:),'.','markersize',10,'displayname','active centers grid (x,y)')

xv = [1.5 2.5 2  ];
yv = [4.9 4.2 3.1];

yv = [20.4131
      30.4257
      30.6474
      40.5693
      40.3929
      30.6020
      20.5189
      10.6776
      10.3955
      10.2796
      10.5567];

xv = [70.7830
      80.6071
      60.6126
      50.3269
      30.5797
      20.3434
      10.3709
      20.1456
      40.0907
      70.3049
      80.7720];

hold on
plot(xv,yv,'k-o','displayname','polygon (xv,yv)')

[m,n,mn] = xy2mn(x,y,xv,yv);
%S  = xy2mn(x,y,xv,yv);
%mn = S.mn;
%m  = S.m;
%n  = S.n;

%mmax = size(x,1);
%m    = mod((mn)-1,mmax)+1
%n    = (((mn)-m+mmax))/mmax;
disp('x          x(mn)      y          y(mn)     mn           m          n          ')

plot(x(mn),y(mn),'k--s','displayname','nearest grid nodes (x(mn),y(mn))')

for i=1:length(m)
   if i==1
   plot(x(m(i),n(i)),y(m(i),n(i)),'rx','displayname','nearest grid nodes (x(m,n),y(m,n))')
   else
   plot(x(m(i),n(i)),y(m(i),n(i)),'rx','handlevisibility','off'); % not in legend
   end
   text(x(m(i),n(i)),y(m(i),n(i)),['m = ',num2str(m(i)),' n = ',num2str(n(i))])
   
   disp(num2str([xv(i) x(mn(i)) yv(i) y(mn(i)) mn(i) m(i) n(i) ],'%10f '))
end

xlabel('n')
ylabel('m')

legend('location','NorthEast')
axis equal