function handles = ddb_generateGridDelft3DWAVE(handles,id,OPT,varargin)% x, y, z, filename, varargin)
%DDB_GENERATEGRIDDELFT3DWAVE  One line description goes here.
%
%   More detailed description goes here.
%

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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

attName=OPT.filename(1:end-4);

switch OPT.option
    case{'read'}
        [x,y,enc,coord]=ddb_wlgrid('read',OPT.filename);
    case{'write'}
        set(gcf,'Pointer','arrow');
        if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
            coord='Spherical';
        else
            coord='Cartesian';
        end
        x=OPT.x; y=OPT.y;
        ddb_wlgrid('write','FileName',[attName '.grd'],'X',x,'Y',y,'CoordinateSystem',coord);
end

handles.model.delft3dwave.domain.domains(id).coordsyst = coord;
handles.model.delft3dwave.domain.domains(id).grid=[attName '.grd'];
handles.model.delft3dwave.domain.domains(id).bedlevelgrid=[attName '.grd'];
handles.model.delft3dwave.domain.domains(id).gridname=attName;

handles.model.delft3dwave.domain.domains(id).gridx=x;
handles.model.delft3dwave.domain.domains(id).gridy=y;

nans=zeros(size(x));
nans(nans==0)=NaN;
handles.model.delft3dwave.domain.domains(id).depth=nans;

handles.model.delft3dwave.domain.domains(id).mmax=size(x,1);
handles.model.delft3dwave.domain.domains(id).nmax=size(x,2);
