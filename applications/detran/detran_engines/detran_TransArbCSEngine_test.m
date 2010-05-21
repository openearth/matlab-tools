function testresult = detran_TransArbCSEngine_test()
% DETRAN_DETRAN_TRANSARBCSENGINE_TEST One line description goes here
%  
% More detailed description of the test goes here.
%
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
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
% Created: 07 May 2010
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% $Description (Name = detran_TransArbCSEngine_test)
% Publishable code that describes the test.

%% $RunCode
% Write test code here

% create a grid
[x,y]=meshgrid([1:5],[1:5]);

% specify transport rates
xt = repmat(0,size(x));
yt = repmat(1,size(x));

% specify transect
transect=[0 3; 6 3];

try
    % calculate transport through transect
    [tr, trPlus, trMin] = detran_TransArbCSEngine(x,y,xt,yt,transect(1,:),transect(2,:));
    
    % this should result in a transport rate of 4
    testresult = tr==4;
catch
    testresult = false;
end

%% $PublishResult
% Publishable code that describes the test.
figure;
hold on;
grid_plot(x,y);
axis equal;
[p,h1,t1]=detran_plotTransportThroughTransect(transect(1,:),transect(2,:),tr,1);

