function testresult = KMLpcolor_test()
% KMLPCOLOR_TEST  One line description goes here
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
    c = peaks(31);
    KMLpcolor(lat   ,lon-15, c,'fileName',KML_testdir('KMLpcolor_1.kml'));
    KMLpcolor(lat+5 ,lon-15, c,'fileName',KML_testdir('KMLpcolor_2.kml'),'colorMap',@(m) gray(m));
    KMLpcolor(lat+10,lon-15, c,'fileName',KML_testdir('KMLpcolor_3.kml'),'fillAlpha',1,'lineWidth',3,'colorMap',@(m) colormap_cpt('temperature',m),'polyOutline',true);
    KMLpcolor(lat+5 ,lon*-10,c,'fileName',KML_testdir('KMLpcolor_4.kml'),'polyOutline',true,'polyFill',false,'lineColor','fillColor');
    testresult = true;
catch
    testresult = false;
end

%% $PublishResult
% Publishable code that describes the test.
end
