function testresult = KMLline_test()
% KMLLINE_TEST  One line description goes here
%  
% More detailed description of the test goes here.
%
%
%   See also 

%% Credentials
%   --------------------------------------------------------------------
%   2009 <Deltares>
%       Thijs Damsma
%
%       <Thijs.Damsma@Deltares.nl>	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   --------------------------------------------------------------------
% This test is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
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

%% $Description (Name = Name of the test goes here)
% Publishable code that describes the test.

%% $RunCode
try
    lat = linspace(-90,90,1000)'; lon = linspace(0,5*360,1000)';
    KMLline(lat,lon,'fileName',fullfile(tempdir,'line1.kml'));

    [lat,lon] = meshgrid(10:.1:20,50:.1:60);
    z = 30*(sin(lat)+cos(lon));
    KMLline(lat ,lon ,z ,'fileName',KML_testdir('line2.kml'),'fillColor',  [1 0 0],'zScaleFun',@(z) (z+30)*100);
    KMLline(lat',lon',z','fileName',KML_testdir('line3.kml'),'zScaleFun',@(z) (z+30)*120);
    testresult = true;
catch
    testresult = false;
end

%% $PublishResult
% Publishable code that describes the test.
end