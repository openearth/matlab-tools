function testresult = KMLsurf_test()
% KMLSURF_TEST  unit tets for KMLsurf
%  
% See also: googleplot

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) $date(yyyy) $Company
%       $author
%
%       $email	
%
%       $address
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
% Created: 02 Sep 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

disp(['... running test:',mfilename])

%% $Description (Name = KMLsurf)
% Publishable code that describes the test.

%% $RunCode
try
    [lat,lon] = meshgrid(54:.1:57,2:.1:5);
    z = peaks(31);
    z = abs(z);

    KMLsurf(lat   ,lon-5,z,'fileName',KML_testdir('KMLsurf_1.kml'),'zScaleFun',@(z) (z+1).*2000,'extrude',true,'polyOutline',true,'polyFill',false);
    KMLsurf(lat+5 ,lon-5,z,'fileName',KML_testdir('KMLsurf_2.kml'),'colorMap' ,@(m) gray(m),'zScaleFun',@(z) (z.^2)*1000);
    KMLsurf(lat+10,lon-5,z,'fileName',KML_testdir('KMLsurf_3.kml'),'zScaleFun',@(z) -log(z/100)*1000,'fillAlpha',1,'lineWidth',3,'colorMap',@(m) colormap_cpt('temperature',m),'extrude',true,'polyOutline',true);
    for ii =4:9;
         KMLsurf(lat+5,lon*10,z*(1+sin(ii)),'fileName',KML_testdir(['KMLsurf_' num2str(ii) '.kml']),'zScaleFun',@(z) (z.^2)*1000,'cLim',[-3+sin(ii) 15+10*sin(ii)],'timeIn',ii,'timeOut',ii+1);
    end
    testresult = true;
catch
    testresult = false;
end

%% $PublishResult
% Publishable code that describes the test.