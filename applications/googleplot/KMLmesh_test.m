function testresult = KMLmesh_test()
% KMLmesh_test  unit test for KMLmesh
%  
% See also: KMLmesh, mesh

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

if TeamCity.running, TeamCity.ignore('Test requires user input'); return; end

disp(['... running test:',mfilename])

%% $Description (Name = KMLmesh)
% Publishable code that describes the test.

%% $RunCode
% Write test code here
%try

   [lat,lon] = meshgrid(-90:1:90,[-180:1:180]+30);
   
   a = 5e5;
   b = 5e5;
   
   z = a.*sin(5*(2*pi).*lon./180) + b.*sin(8.*(2*pi).*lon./360) + max(abs(a),abs(b));
   
   KMLmesh(lat ,lon ,  'fileName',KML_testdir('KMLmesh_test2d.kml'),'lineColor',hsv);
   KMLmesh(lat ,lon ,z,'fileName',KML_testdir('KMLmesh_test3d.kml'),'lineColor',hsv);
    testresult = true;
%catch
%    testresult = false;
%end

%% $PublishResult
% Publishable code that describes the test.


