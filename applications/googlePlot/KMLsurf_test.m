function testresult = KMLsurf_test()
% KMLSURF_TEST  One line description goes here
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

    KMLsurf(lat   ,lon-5,z,'fileName',KML_testdir('KMLsurf_1.kml'),'zScaleFun',@(z) (z+1).*2000,'extrude',true,'polyOutline',true,'polyFill',false);
    KMLsurf(lat+5 ,lon-5,z,'fileName',KML_testdir('KMLsurf_2.kml'),'colorMap',@(m) gray(m),'zScaleFun',@(z) (z.^2)*1000);
    KMLsurf(lat+10,lon-5,z,'fileName',KML_testdir('KMLsurf_3.kml'),'zScaleFun',@(z) -log(z/100)*1000,'fillAlpha',1,'lineWidth',3,'colorMap',@(m) colormap_cpt('temperature',m),'extrude',true,'polyOutline',true);
    KMLsurf(lat+5,lon*10,z,'fileName',KML_testdir('KMLsurf_4.kml'),'zScaleFun',@(z) (z.^2)*1000,'cLim',[200 300]);
    testresult = true;
catch
    testresult = false;
end

%% $PublishResult
% Publishable code that describes the test.
end