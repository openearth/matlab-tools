function writetekalmap(fname, x, y, z)
%WRITETEKALMAP One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   writetekalmap(fname, x, y, z)
%
%   Input:
%   fname =
%   x     =
%   y     =
%   z     =
%
%   Example
%   writetekalmap
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
x(isnan(x))=-999;
y(isnan(y))=-999;
z(isnan(z))=-999;

fid=fopen(fname,'wt');

fprintf(fid,'%s\n','* column 1 : x');
fprintf(fid,'%s\n','* column 2 : y');
fprintf(fid,'%s\n','* column 3 : z');
fprintf(fid,'%s\n','BL01');
fprintf(fid,'%i %i %i %i\n',size(x,1)*size(x,2),3,size(x,1),size(x,2));
for j=1:size(x,2)
    for i=1:size(x,1)
        fprintf(fid,['%12.4e %12.4e %12.4e\n'],x(i,j),y(i,j),z(i,j));
    end
end
fclose(fid);
