function mt_definitionwithdescription_newstyle_test()
% MT_DEFINITIONWITHDESCRIPTION_NEWSTYLE_TEST  One line description goes here
%  
% More detailed description of the test goes here.
%
%
%   See also MTest

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
% Created: 18 Jun 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Give this test a category
MTest.category('UnCategorized');

%% Publish a description
TeamCity.publishdescription(@test_testdescription,...
    'IncludeCode',true,...
    'EvaluateCode',true);

b = a.*5;

%% Publish a result
TeamCity.publishresult(@test_publishresult,...
    'IncludeCode',true,...
    'EvaluateCode',true);

end

function test_testdescription()
%% Publishable Description code Test Title
a = [1, 2, 3];
plot(a);
end

function test_publishresult()
%% Titel bovenaan de pagina
% Dit is een test

%% Eerste hoofdstuk, plot a nog een keertje (zou in het geheugen moeten staan)
disp('Dit is een test');
plot(b);
disp('Nog een keertje');
end