function testresult = KMLtext_test()
% KMLtext_test  unit test for KMLtext
%  
% See also: KMLtext

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

try

   lat = [52 52; 53 53];
   lon = [ 2  4;  4  2];
   z   = [1 10 ;100 1e3];
   
   
   KMLtext(lat ,lon ,num2str(z(:))  ,'fileName',KML_testdir('KMLtext_text1.kml'));
   KMLtext(lat ,lon ,z              ,'fileName',KML_testdir('KMLtext_text2.kml'));
   testresult = true;
catch
   testresult = false;
end
