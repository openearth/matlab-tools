function ITHK_io_writeKML(kmltxt,addtxt,sens)
% ITHK_KMLdisclaimer(sens)
%
% writes kml-txt to a KMLfile
% addtxt is the extension that can be provided to the filename.

%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares for Building with Nature
%       Bas Huisman
%
%       Bas.Huisman@deltares.nl	
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

global S

%% WRITE KML
S.PP(sens).output.kmlFileName  = [S.settings.outputdir S.userinput.name addtxt '.kml'];  % KML filename settings
KMLmapName                     = S.userinput.name;
fid                            = fopen(S.PP(sens).output.kmlFileName,'w');
kmltxt                         = strrep(kmltxt,'\','\\');
kmltxt                         = strrep(kmltxt,'%','\%');
fprintf(fid,[KML_header('kmlName',KMLmapName), ...
            kmltxt, ...
            KML_footer],'interpreter','off');
fclose(fid);
