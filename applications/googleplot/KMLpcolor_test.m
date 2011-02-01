function testresult = KMLpcolor_test()
%KMLPCOLOR_TEST  unit test for KMLpcolor
%
%See also: googleplot, pcolor

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

try

% test lon/lat sticks/grid AND color data at corners of at centres
% the 4 resulting files should identical (and they are if you leave out the colorbar) !!

   lon1     = [-1 0 1]; 
   lat1     = [-2 -1 0 1 2];
  [lat,lon] = meshgrid(lat1,lon1);
  
   c = lat + lon;


   KMLpcolor(lat1,lon1,c               ,'fileName',KML_testdir('KMLpcolor_stick_corner.kml'),'kmlName','KMLpcolor test','colorbar',0,'disp',0);
   KMLpcolor(lat1,lon1,corner2center(c),'fileName',KML_testdir('KMLpcolor_stick_center.kml'),'kmlName','KMLpcolor test','colorbar',0,'disp',0);
   KMLpcolor(lat ,lon ,c               ,'fileName',KML_testdir('KMLpcolor_grid_corner.kml' ),'kmlName','KMLpcolor test','colorbar',0,'disp',0);
   KMLpcolor(lat ,lon ,corner2center(c),'fileName',KML_testdir('KMLpcolor_grid_center.kml' ),'kmlName','KMLpcolor test','colorbar',0,'disp',0);

% test colorscaling

  [lat,lon] = meshgrid(54:.1:57,2:.1:5);
   c        = peaks(31);
   KMLpcolor(lat   ,lon-15, c,'fileName',KML_testdir('KMLpcolor_1.kml' ),'disp',0);
   KMLpcolor(lat   ,lon-10, c,'fileName',KML_testdir('KMLpcolor_1f.kml'),'cLim',[-2 4],'disp',0);

   KMLpcolor(lat+5 ,lon-15, c,'fileName',KML_testdir('KMLpcolor_2.kml' ),'colorMap',@(m) gray(m),'disp',0);
   KMLpcolor(lat+5 ,lon-10, c,'fileName',KML_testdir('KMLpcolor_2f.kml'),'colorMap',@(m) gray(m),'cLim',[-2 4],'disp',0);

   KMLpcolor(lat+10,lon-15, c,'fileName',KML_testdir('KMLpcolor_3.kml'),'fillAlpha',1,'lineWidth',3,'colorMap',@(m) colormap_cpt('temperature',m),'polyOutline',true,'disp',0);
   KMLpcolor(lat+5 ,lon*-10,c,'fileName',KML_testdir('KMLpcolor_4.kml'),'polyOutline',true,'polyFill',false,'lineColor','fillColor','disp',0);
   
   testresult = true;
catch
   testresult = false;
end
