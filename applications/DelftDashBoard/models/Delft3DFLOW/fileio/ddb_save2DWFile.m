function ddb_save2DWFile(handles, id)
%DDB_save2DWFile  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_save2DWFile(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%
%
%
%   Example
%   ddb_save2DWFile
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
fname=handles.Model(md).Input(id).w2dFile;

fid=fopen(fname,'w');
for i=1:handles.Model(md).Input(id).nrWeirs2D
    m1=handles.Model(md).Input(id).weirs2D(i).M1;
    n1=handles.Model(md).Input(id).weirs2D(i).N1;
    m2=handles.Model(md).Input(id).weirs2D(i).M2;
    n2=handles.Model(md).Input(id).weirs2D(i).N2;
    uv=handles.Model(md).Input(id).weirs2D(i).UV;
    frc=handles.Model(md).Input(id).weirs2D(i).frictionCoefficient;
    hgt=handles.Model(md).Input(id).weirs2D(i).crestHeight;
    fprintf(fid,'%s %6i %6i %6i %6i %6.3f %6.3f %3.1f\n',uv,m1,n1,m2,n2,frc,hgt,0);
end
fclose(fid);


