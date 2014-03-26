function handles = ddb_DFlowFM_readObsFile(handles, id)
%ddb_DFlowFM_readObsFile  One line description goes here.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
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
[x,y,name] = textread(handles.model.dflowfm.domain(id).obsfile,'%f%f%s','delimiter','''"');

handles.model.dflowfm.domain(id).observationpoints=[];

for ip=1:length(x)
    handles.model.dflowfm.domain(id).observationpoints(ip).name=name{ip};
    handles.model.dflowfm.domain(id).observationpoints(ip).x=x(ip);
    handles.model.dflowfm.domain(id).observationpoints(ip).y=y(ip);
    handles.model.dflowfm.domain(id).observationpointnames{ip}=handles.model.dflowfm.domain(id).observationpoints(ip).name;
end

handles.model.dflowfm.domain(id).activeobservationpoint=1;
handles.model.dflowfm.domain(id).nrobservationpoints=length(x);

