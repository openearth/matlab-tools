function [x,y,ray_file]=readGKL(GKLfilename)
%read GKL : Reads a UNIBEST gkl-file
%   
%   Syntax:
%     function [x,y,rayfiles]=readGKL(GKLfilename)
%   
%   Input:
%     GKLfilename         String with filename of gkl-file
%   
%   Output:
%     x                   X-coordinate of ray in CL-model
%     y                   Y-coordinate of ray in CL-model
%     ray_file            String with reference to a ray file
%   
%   Example:
%     [GKLdata]=readGKL('test.gkl')
%   
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
%       The Netherlands
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 14 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

fid=fopen(GKLfilename);

%Read comment line
lin=fgetl(fid);
% Read number of locations
lin=fgetl(fid);
nloc=strread(lin,'%d');;
%Read comment line
lin=fgetl(fid);
if isempty(nloc)
    error('Error reading 2nd line of LOC, number of locations. Reserve at least 10 characters for this number!');
    return
end

%Read data
for i=1:nloc
   lin = fgetl(fid);
   [x(i) y(i) ray_file(i) ]=strread(lin,'%f%f%s');
end
fclose(fid);
