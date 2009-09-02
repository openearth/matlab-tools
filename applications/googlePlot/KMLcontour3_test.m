function testresult = KMLcontour3_test()
% KMLCONTOUR3_TEST  One line description goes here
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
    [lat,lon] = meshgrid(54:.1:57,2:.1:5);
    z = peaks(31);
    z = abs(z);
    KMLcontour3(lat   ,lon,   z,'fileName',KML_testdir('KMLcontour3_1.kml'),'zScaleFun',@(z) (z+1)*2000,'writeLabels',true);
    KMLcontour3(lat+5 ,lon,   z,'fileName',KML_testdir('KMLcontour3_2.kml'),'writeLabels',false,'colorMap',@(m) gray(m));
    KMLcontour3(lat+10,lon,   z,'fileName',KML_testdir('KMLcontour3_3.kml'),'writeLabels',false,'cLim',[-10 10],'lineWidth',3,'colorMap',@(m) colormap_cpt('temperature',m));
    KMLcontour3(lat+10,lon*10,z,'fileName',KML_testdir('KMLcontour3_4.kml'),'zScaleFun',@(z) (z.^2)*10000,'writeLabels',true,'cLim',[200 300],'labelDecimals',4);
    testresult = true;
catch
    testresult = false;
end

%% $PublishResult
% Publishable code that describes the test.
end