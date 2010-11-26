function testresult = GetAreaTriangle_test()
% GETAREATRIANGLE_TEST  test for getareacurvilineargrid
%  
% See also: GETAREATRIANGLE
%
%
%   See also 

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

X = [ 0  2; 1 3];
Y = [-1 -2; 0 1];

plot(X,Y,'-o');
hold on
plot(X',Y',':+');
axis([-1 5 -3 3]);
grid on
set(gca,'xtick',-10:1:10);
set(gca,'ytick',-10:1:10);

AreaA(:,:) = GetAreaTriangle(X(1:end-1,1:end-1),Y(1:end-1,1:end-1),...
X(2:end  ,1:end-1),Y(2:end  ,1:end-1),...
X(2:end  ,2:end  ),Y(2:end  ,2:end  ));

AreaB(:,:) = GetAreaTriangle(X(1:end-1,1:end-1),Y(1:end-1,1:end-1),...
X(1:end-1,2:end  ),Y(1:end-1,2:end  ),...
X(2:end  ,2:end  ),Y(2:end  ,2:end  ));

Area(:,:)  = AreaA + AreaB;

disp('o---------o')
disp('| B     . |')
disp('|    .    |')
disp('| .     A |')
disp('o---------o')
disp(num2str(AreaA))
disp(num2str(AreaB))
disp(num2str(Area ))

disp('---------------------------------------------')


AreaA(:,:) = GetAreaTriangle(X(1:end-1,1:end-1),Y(1:end-1,1:end-1),...
X(2:end  ,1:end-1),Y(2:end  ,1:end-1),...
X(1:end-1,2:end  ),Y(1:end-1,2:end  ));

AreaB(:,:) = GetAreaTriangle(X(2:end  ,1:end-1),Y(2:end  ,1:end-1),...
X(1:end-1,2:end  ),Y(1:end-1,2:end  ),...
X(2:end  ,2:end  ),Y(2:end  ,2:end  ));

Area(:,:)  = AreaA + AreaB;

disp('o---------o')
disp('| .    B  |')
disp('|    .    |')
disp('| A     . |')
disp('o---------o')
disp(num2str(AreaA))
disp(num2str(AreaB))
disp(num2str(Area ))

testresult = nan;