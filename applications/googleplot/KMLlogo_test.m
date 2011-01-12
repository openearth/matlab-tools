function testresult = KMLlogo_test()
% KMLlogo_TEST  unit test for KMLlogo
%
% See also: KMLlogo, line, plot

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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 22 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

disp(['... running test:',mfilename])

%% $Description (Name = KMLline)
% Publishable code that describes the test.

%% $RunCode
% Write test code here
try
    srcfile = [matlabroot '\sys\perl\win32\lib\Tk\demos\images\mickey.gif'];
    destfile = [KML_testdir,filesep, 'matlab.ico'];
    copyfile(srcfile,destfile,'f')
    kmlfilename = [KML_testdir,filesep,'KMLlogo_test.kml'];
    KMLlogo (destfile,'fileName',kmlfilename,'invertblackwhite',1,'kmlName','mickey');
    
    testresult = true;
catch
    testresult = false;
end

%% $PublishResult
% Publishable code that describes the test.

