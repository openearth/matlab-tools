function testresult = KMLpatch3_test()
% KMLPATCH3_TEST  test for KMLpatch3
%  
% See also : googlPlot, KMLpatch, patch

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

lat = {[50   50   50.9 50.9 50  ]'-4,...
       [50.9 50.9 50   50   50.9]'-4,...
       [52   52   51.1 51.1 52  ]'-4,...
       [51.1 51.1 52   52   51.1]'-4};

lon = {[1.1 2   2   1.1 1.1]'+8,...
       [0   0.9 0.9 0   0  ]'+8,...
       [1.1 2   2   1.1 1.1]'+8,...
       [0   0.9 0.9 0   0  ]'+8};
       
z   = {[0 1 2 3 0]'.*1E3,...
       [0 1 2 3 0]'.*1E3,...
       [0 1 2 3 0]'.*1E3,...
       [0 1 2 3 0]'.*1E3};

c   = [0 1 2 3];

f   = {[1 0 0],[0 1 0],[0 0 1],[1 1 1]};
	
% one patch: manually picked rgb color

    KMLpatch3(lat{1},lon{1},z{1},'fileName',KML_testdir('KMLpatch3_test1a.kml'),'fillColor',f{1},'polyOutline',false,'lineOutline',true );
    KMLpatch3(lat{2},lon{2},z{2},'fileName',KML_testdir('KMLpatch3_test2a.kml'),'fillColor',f{2},'polyOutline',false,'lineOutline',false);
    KMLpatch3(lat{3},lon{3},z{3},'fileName',KML_testdir('KMLpatch3_test1b.kml'),'fillColor',f{3},'polyOutline',true ,'lineOutline',false);
    KMLpatch3(lat{4},lon{4},z{4},'fileName',KML_testdir('KMLpatch3_test2b.kml'),'fillColor',f{4},'polyOutline',true ,'lineOutline',true );

% one patch: interpolated colors from colormap

    KMLpatch3(lat{1},lon{1},z{1},c(1),'fileName',KML_testdir('KMLpatch3_test3a.kml'),'cLim',[0 3],'colorMap',@(m) jet(m),'colorSteps',20);
    KMLpatch3(lat{2},lon{2},z{2},c(2),'fileName',KML_testdir('KMLpatch3_test3b.kml'),'cLim',[0 3],'colorMap',@(m) jet(m),'colorSteps',20);
    KMLpatch3(lat{3},lon{3},z{3},c(3),'fileName',KML_testdir('KMLpatch3_test3c.kml'),'cLim',[0 3],'colorMap',@(m) jet(m),'colorSteps',20);
    KMLpatch3(lat{4},lon{4},z{4},c(4),'fileName',KML_testdir('KMLpatch3_test3d.kml'),'cLim',[0 3],'colorMap',@(m) jet(m),'colorSteps',20);
    
% multi-patch: ONE manually picked rgb color
    
    KMLpatch3(lat,lon,z,'fileName',KML_testdir('KMLpatch3_testflat.kml'),'fillColor',[1 1 0]);
   %KMLpatch3(lat,lon,z,'fileName',KML_testdir('KMLpatch3_test12ab.kml'),'fillColor',f); % not implemented (yet)

% multi-patch: interpolated colors from colormap
    
    KMLpatch3(lat,lon,z,2,'fileName',KML_testdir('KMLpatch3_test3flat.kml'),...
    'cLim',[0 3],'colorMap',@(m) jet(m),'colorSteps',20,'lineOutline',0);

    KMLpatch3(lat,lon,z,c,'fileName',KML_testdir('KMLpatch3_test3abcd.kml'),...
    'cLim',[0 3],'colorMap',@(m) jet(m),'colorSteps',20,'lineOutline',0);
    

    testresult = true;
catch
    testresult = false;
end
