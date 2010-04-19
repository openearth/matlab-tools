function testresult = KMLfig2pngNew_test(varargin)
%KMLFIG2PNGNEW_TEST  unit test for KMLfig2png
%
% See also : googleplot

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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 20 Jan 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

disp(['... running test:',mfilename])

%% $Description (Name = KMLpcolor)
% Publishable code that describes the test.

%% $RunCode
try
[lat,lon] = meshgrid(40:.03:42,-10:.03:-8);

   z = peaks(67)+rand(size(lat));
   surf(lat,lon,z)
       
   FIG = figure('Visible','Off')
   h               = surf(peaks-.1);
   shading    interp;
   material  ([.9 0.08 .07]);
   lighting   phong
   axis       off;
   axis       tight;
   view      (0,90);
   lightangle(0,90)
   clim      ([-50 25]);
   colormap  (colormap_cpt('bathymetry_vaklodingen',500));
   
   KMLfig2pngNew(h,lat,lon,z,...
             'highestLevel',6,...
              'lowestLevel',14,...
       'mergeExistingTiles',true,...
                  'bgcolor',[255 0 255],...
                 'fileName',KML_testdir('KMLfig2pngNew.kml'))
   
   try;close(FIG);end

   testresult = true;
catch
   testresult = false;
end
