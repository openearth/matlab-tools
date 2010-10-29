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

try;close(h.fig);end

%% $RunCode
try

  % test with 1 text line
%  KMLcolorbar('CBfileName',KML_testdir('KMLcolorbar_test_1'),'CBcolorMap',@(m) jet(m),'CBcolorSteps',4,'CBcLim',[-2 2],...
%     'CBcolorbarlocation',{'NNW','N','NNE','SSE','S','SSW','ENE','E','ESE','WSW','W','WNW'},...
%     'CBcolorTitle','0123456789 ~!@#$% &*() +');

  % test with 2 text lines
 KMLcolorbar(...
     'CBfileName',          KML_testdir('KMLcolorbar_test_2'),...
     'CBcolorMap',          hsv,...
     'CBcLim',              [-2 2],...
     'CBcolorbarlocation',  {'NNW','N','NNE','SSE','S','SSW','ENE','E','ESE','WSW','W','WNW'},...
     'CBcolorTitle',        {'ABCDEFGHIJKLMNOPQRSTUVWYZ','abcdefghijklmnopqrstuvwyz'},...
     'CBcolorTick',         linspace(-2,2,7),...
     'CBcolorTickLabel',    {'red','yellow','green','cyan','blue','magenta','red'});

  % test with 3 text lines
%  KMLcolorbar('CBfileName',KML_testdir('KMLcolorbar_test_3'   ),'CBcolorMap',@(m) jet(m),'CBcolorSteps',4,'CBcLim',[-2 2],...
%     'CBcolorbarlocation',{'NNW','N','NNE','SSE','S','SSW','ENE','E','ESE','WSW','W','WNW'},...
%     'CBcolorTitle',{'ABCDEFGHIJKLMNOPQRSTUVWYZ','abcdefghijklmnopqrstuvwyz','33333333333'},'CBtitlergb',[0 0 0]);

   testresult = true;
catch
   testresult = false;
end
