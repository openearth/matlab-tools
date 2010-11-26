function testresult = rws_getDataInPolygon_test()
warning('This function is deprecated in favour of grid_orth_getDataInPolygon_test')
% RWS_GETDATAINPOLYGON_TEST  test for rws_getdatainpolygon
%  
% % See also: rws_getDataInPolygon_test
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

MTestCategory.DataAccess;

testresult = [];
if TeamCity.running, TeamCity.ignore('Test requires user input'); return; end

%% $Description (Name = Name of the test goes here)
% Publishable code that describes the test.
% NB1: onderstaande testcases zijn met voorgedefinieerde polygonen. Als je de polygonen niet opgeeft mag je ze zelf selecteren met de crosshair (rechter muisknop om te sluiten)
% NB2: de routines zijn nog niet 100% robuust. Ook is de data op de OpenDAP server nog niet helemaal goed. Met name dit laatste moet zsm verholpen worden!
% NB3: enkele onderdelen van dit script zijn nog vrij sloom: bepalen welke grids er zijn en het ophalen van alle kaartbladomtrekken. Hopelijk is dit te fixen middels de Catalog.xml op de OPeNDAP server

%% $RunCode

tr(1) = test1;
tr(2) = test2;
tr(3) = test3;

testresult = all(tr);


%% $PublishResult
% Publishable code that describes the test.

end

function testresult = test1()
%% $Description 

%% $RunCode
% Test 1: work on JARUS grids
rws_getDataInPolygon(...
    'datatype', 'jarkus', ...
    'starttime', datenum([1997 01 01]), ...
    'searchwindow', -2*365, ...
    'polygon', [70796.8 438560
    78910.8 438779
    78618.4 461001
    70869.9 461001
    70796.8 438560], ...
    'datathinning', 1); %#ok<*UNRCH>
testresult = nan;
%% $PublishResult

end

function testresult = test2()
%% $Description (Name = Undefined)
% Test 2: work on VAKLODINGEN grids

%% $RunCode
rws_getDataInPolygon(...
    'datatype', 'vaklodingen', ...
    'starttime', datenum([1997 01 01]), ...
    'searchwindow', -5*365, ...
    'polygon', [50214.6 425346
    50318.5 441438
    60440.5 441386
    60129 425398
    50214.6 425346], ...
    'datathinning', 1);
testresult = nan;
%% $PublishResult

end

function testresult = test3()
%% $Description (Name = Undefined)
% Test 1: work on VAKLODINGEN grids

%% $RunCode
[X, Y, Z, Ztime] = rws_getDataInPolygon(...
    'datatype', 'vaklodingen', ...
    'starttime', datenum([2009 01 01]), ...
    'searchwindow', -20*365, ...
    'datathinning', 1);
testresult = nan;
%% $PublishResult

end