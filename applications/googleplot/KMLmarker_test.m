function testresult = KMLmarker_test()
% KMLmarker_test  unit test for KMLtext
%  
% See also: KMLmarker

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

disp(['... running test:',mfilename])

%% $Description (Name = KMLmesh)
% Publishable code that describes the test.

%% $RunCode
% Write test code here
%try



   D.x    = linspace(53.10 ,53.75,21);
   D.y    = linspace( 4.75 , 8   ,21);
   D.z    = linspace(-1    , 4   ,21);
   D.txt  = addrowcol(addrowcol(num2str(D.z'),0,-1,' = dum'),0,1,'%');
   D.name = num2str([1:length(D.x)]');
   
   for i=1:length(D.x)
   D.html{i} = ['<hr> <table border="1"> <tr> <td>mud content = </td><td>',num2str(D.x(i)),' %</td></tr>'];
   end

%% name and html empty

   KMLmarker(D.x,D.y,...
        'fileName',KML_testdir('KMLmarker_1.kml'),...
     'description','name and html empty',...
         'kmlName','name and html empty','scalehighlightState',2)

%% name and html empty

   KMLmarker(D.x,D.y,...
        'fileName',KML_testdir('KMLmarker_1b.kml'),...
     'description','name and html empty, mouse-over: default or no',...
         'kmlName','name and html empty, mouse-over: default or no','scalehighlightState',0)

%% name = # and html = table

   KMLmarker(D.x,D.y,...
        'fileName',KML_testdir('KMLmarker_2.kml'),...
            'name',D.name,...
            'html',D.html,...
     'description','name = # and html = table',...
         'kmlName','name = # and html = table','scalehighlightState',2)
             
%% name = # and html empty

   KMLmarker(D.x,D.y,...
        'fileName',KML_testdir('KMLmarker_3.kml'),...
            'name',D.name,...
     'description','name = # and html empty',...
         'kmlName','name = # and html empty','scalehighlightState',2)

%% name empty and html = table

   for i=1:length(D.x)
   D.html{i} = ['<table border="1"> <tr> <td>mud content = </td><td>',num2str(D.x(i)),' %</td></tr>'];
   end

   KMLmarker(D.x,D.y,...
        'fileName',KML_testdir('KMLmarker_4.kml'),...
            'html',D.html,...
     'description','name empty and html = table',...
         'kmlName','name empty and html = table','scalehighlightState',2)

    testresult = true;

%catch
%   testresult = false;
%end

%% $PublishResult
% Publishable code that describes the test.


