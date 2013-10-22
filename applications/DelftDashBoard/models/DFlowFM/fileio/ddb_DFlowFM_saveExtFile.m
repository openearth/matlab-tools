function ddb_DFlowFM_saveExtFile(handles)
%ddb_DFlowFM_saveExtForcing

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

% $Id: ddb_DFlowFM_writeComponentsFile.m 9233 2013-09-19 09:19:19Z ormondt $
% $Date: 2013-09-19 11:19:19 +0200 (Thu, 19 Sep 2013) $
% $Author: ormondt $
% $Revision: 9233 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/fileio/ddb_DFlowFM_writeComponentsFile.m $
% $Keywords: $
    
fid=fopen(handles.Model(md).Input.extforcefile,'wt');

fprintf(fid,'%s\n','* QUANTITY    : waterlevelbnd, velocitybnd, dischargebnd, tangentialvelocitybnd, normalvelocitybnd  filetype=9         method=2,3');
fprintf(fid,'%s\n','*             : salinitybnd                                                                         filetype=9         method=2,3');
fprintf(fid,'%s\n','*             : lowergatelevel, damlevel                                                            filetype=9         method=2,3');
fprintf(fid,'%s\n','*             : frictioncoefficient, horizontaleddyviscositycoefficient, advectiontype              filetype=4,10      method=4');
fprintf(fid,'%s\n','*             : initialwaterlevel, initialsalinity                                                  filetype=4,10      method=4');
fprintf(fid,'%s\n','*             : windx, windy, windxy, rain, atmosphericpressure                                     filetype=1,2,4,7,8 method=1,2,3');
fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n','* kx = Vectormax = Nr of variables specified on the same time/space frame. Eg. Wind magnitude,direction: kx = 2');
fprintf(fid,'%s\n','* FILETYPE=1  : uniform              kx = 1 value               1 dim array      uni');
fprintf(fid,'%s\n','* FILETYPE=2  : unimagdir            kx = 2 values              1 dim array,     uni mag/dir transf to u,v, in index 1,2');
fprintf(fid,'%s\n','* FILETYPE=3  : svwp                 kx = 3 fields  u,v,p       3 dim array      nointerpolation');
fprintf(fid,'%s\n','* FILETYPE=4  : arcinfo              kx = 1 field               2 dim array      bilin/direct');
fprintf(fid,'%s\n','* FILETYPE=5  : spiderweb            kx = 3 fields              3 dim array      bilin/spw');
fprintf(fid,'%s\n','* FILETYPE=6  : curvi                kx = ?                                      bilin/findnm');
fprintf(fid,'%s\n','* FILETYPE=7  : triangulation        kx = 1 field               1 dim array      triangulation');
fprintf(fid,'%s\n','* FILETYPE=8  : triangulation_magdir kx = 2 fields consisting of Filetype=2      triangulation in (wind) stations');
fprintf(fid,'%s\n','* FILETYPE=9  : poly_tim             kx = 1 field  consisting of Filetype=1      line interpolation in (boundary) stations');
fprintf(fid,'%s\n','* FILETYPE=10 : inside_polygon       kx = 1 field                                uniform value inside polygon for INITIAL fields');
fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n','* METHOD  =0  : provider just updates, another provider that pointers to this one does the actual interpolation');
fprintf(fid,'%s\n','*         =1  : intp space and time (getval) keep  2 meteofields in memory');
fprintf(fid,'%s\n','*         =2  : first intp space (update), next intp. time (getval) keep 2 flowfields in memory');
fprintf(fid,'%s\n','*         =3  : save weightfactors, intp space and time (getval),   keep 2 pointer- and weight sets in memory');
fprintf(fid,'%s\n','*         =4  : only spatial interpolation');
fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n','* OPERAND =+  : Add');
fprintf(fid,'%s\n','*         =O  : Override');
fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n','* VALUE   =   : Offset value for this provider');
fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n','* FACTOR  =   : Conversion factor for this provider');
fprintf(fid,'%s\n','*');
fprintf(fid,'%s\n','**************************************************************************************************************');
fprintf(fid,'%s\n','');

% Boundaries
for ip=1:handles.Model(md).Input.nrboundaries
    fprintf(fid,'%s\n',['QUANTITY=' handles.Model(md).Input.boundaries(ip).type]);
    fprintf(fid,'%s\n',['FILENAME=' handles.Model(md).Input.boundaries(ip).filename]);
    fprintf(fid,'%s\n','FILETYPE=9');
    fprintf(fid,'%s\n','METHOD=2');
    fprintf(fid,'%s\n','OPERAND=O');
    fprintf(fid,'%s\n','');
end

if ~isempty(handles.Model(md).Input.windufile)
    fprintf(fid,'%s\n',['QUANTITY=windx']);
    fprintf(fid,'%s\n',['FILENAME=' handles.Model(md).Input.windufile]);
    fprintf(fid,'%s\n','FILETYPE=4');
    fprintf(fid,'%s\n','METHOD=1');
    fprintf(fid,'%s\n','OPERAND=O');
    fprintf(fid,'%s\n','');
end

if ~isempty(handles.Model(md).Input.windvfile)
    fprintf(fid,'%s\n',['QUANTITY=windy']);
    fprintf(fid,'%s\n',['FILENAME=' handles.Model(md).Input.windvfile]);
    fprintf(fid,'%s\n','FILETYPE=4');
    fprintf(fid,'%s\n','METHOD=1');
    fprintf(fid,'%s\n','OPERAND=O');
    fprintf(fid,'%s\n','');
end

if ~isempty(handles.Model(md).Input.airpressurefile)
    fprintf(fid,'%s\n',['QUANTITY=atmosphericpressure']);
    fprintf(fid,'%s\n',['FILENAME=' handles.Model(md).Input.airpressurefile]);
    fprintf(fid,'%s\n','FILETYPE=4');
    fprintf(fid,'%s\n','METHOD=1');
    fprintf(fid,'%s\n','OPERAND=O');
    fprintf(fid,'%s\n','');
end

if ~isempty(handles.Model(md).Input.rainfile)
    fprintf(fid,'%s\n',['QUANTITY=rain']);
    fprintf(fid,'%s\n',['FILENAME=' handles.Model(md).Input.rainfile]);
    fprintf(fid,'%s\n','FILETYPE=4');
    fprintf(fid,'%s\n','METHOD=1');
    fprintf(fid,'%s\n','OPERAND=O');
    fprintf(fid,'%s\n','');
end

if ~isempty(handles.Model(md).Input.spiderwebfile)
    fprintf(fid,'%s\n',['QUANTITY=spiderweb']);
    fprintf(fid,'%s\n',['FILENAME=' handles.Model(md).Input.spiderwebfile]);
    fprintf(fid,'%s\n','FILETYPE=5');
    fprintf(fid,'%s\n','METHOD=1');
    fprintf(fid,'%s\n','OPERAND=O');
    fprintf(fid,'%s\n','');
end

fclose(fid);

