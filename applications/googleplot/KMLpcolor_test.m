function testresult = KMLpcolor_test()
%KMLPCOLOR_TEST  test for KMLpcolor
%
% More detailed description of the test goes here.
%
%
%See also: KMLPCOLOR, KMLCOLORBAR_TEST

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

%% $Description (Name = KMLpcolor)
% Publishable code that describes the test.

%% $RunCode
try
  [lat,lon] = meshgrid(54:.1:57,2:.1:5);
   c        = peaks(31);
   KMLpcolor(lat   ,lon-15, c,'fileName',KML_testdir('KMLpcolor_1.kml' ));
   KMLpcolor(lat   ,lon-10, c,'fileName',KML_testdir('KMLpcolor_1f.kml'),'cLim',[-2 4]);

   KMLpcolor(lat+5 ,lon-15, c,'fileName',KML_testdir('KMLpcolor_2.kml' ),'colorMap',@(m) gray(m));
   KMLpcolor(lat+5 ,lon-10, c,'fileName',KML_testdir('KMLpcolor_2f.kml'),'colorMap',@(m) gray(m),'cLim',[-2 4]);

   KMLpcolor(lat+10,lon-15, c,'fileName',KML_testdir('KMLpcolor_3.kml'),'fillAlpha',1,'lineWidth',3,'colorMap',@(m) colormap_cpt('temperature',m),'polyOutline',true);
   KMLpcolor(lat+5 ,lon*-10,c,'fileName',KML_testdir('KMLpcolor_4.kml'),'polyOutline',true,'polyFill',false,'lineColor','fillColor');
   testresult = true;
catch
   testresult = false;
end

%% $PublishResult
% Publishable code that describes the test.

