function testresult = KMLcolorbar_test()
%KMLCOLORBAR_TEST   unit test for KMLcolorbar
%
%See also: googleplot, KML_colorbar, colorbarlegend

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

%% $Description (Name = KMLpcolor)
% Publishable code that describes the test.

h.fig = figure;
OPT.colormap = hsv;
try;close(h.fig);end

%% $RunCode
try
  KMLcolorbar('fileName',KML_testdir('KMLcolorbar_test_halo'   ),'colorMap',OPT.colormap,'clim',[-2 2],'halo',0,...
     'colorTitle','ABCDEFGHIJKLMNOPQRSTUVWYZ abcdefghijklmnopqrstuvwyz 0123456789 ~!@#$% &*() +','titlergb',[0 0 0]);
  KMLcolorbar('fileName',KML_testdir('KMLcolorbar_test_vanilla'),'colorMap',OPT.colormap,'clim',[-2 2],'halo',1,...
     'colorbarlocation',{'W','N','S','E'},...
     'colorTitle','ABCDEFGHIJKLMNOPQRSTUVWYZ abcdefghijklmnopqrstuvwyz 0123456789 ~!@#$% &*() +');
   testresult = true;
catch
   testresult = false;
end
