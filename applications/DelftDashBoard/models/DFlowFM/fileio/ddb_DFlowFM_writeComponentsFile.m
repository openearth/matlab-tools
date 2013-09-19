function ddb_DFlowFM_writeComponentsFile(boundaries,ii,jj)

%ddb_DFlowFM_writeComponentsFile  One line description goes here.

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

fname=boundaries(ii).nodes(jj).componentsfile;

fid=fopen(fname,'wt');

fprintf(fid,'%s\n',['* Delft3D-FLOW boundary segment name: ' boundaries(ii).name]);
fprintf(fid,'%s\n',['* ' boundaries(ii).nodes(jj).componentsfile]);
fprintf(fid,'%s\n','* COLUMNN=3');
fprintf(fid,'%s\n','* COLUMN1=Period (min) or Astronomical Componentname');
fprintf(fid,'%s\n','* COLUMN2=Amplitude (m)');
fprintf(fid,'%s\n','* COLUMN3=Phase (deg)');

for ip=1:length(boundaries(ii).nodes(jj).components)
    cmp=boundaries(ii).nodes(jj).components(ip).component;
    cmp=[repmat(' ',1,12-length(cmp)) cmp]; 
    amp=boundaries(ii).nodes(jj).components(ip).amplitude;
    phi=boundaries(ii).nodes(jj).components(ip).phase;
    fprintf(fid,'%s %11.4f %11.1f\n',cmp,amp,phi);
end

fclose(fid);
