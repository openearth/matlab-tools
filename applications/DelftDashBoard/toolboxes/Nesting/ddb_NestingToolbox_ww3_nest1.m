function ddb_NestingToolbox_ww3_nest1(varargin)
%ddb_NestingToolbox_ww3_nest1

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
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

% $Id: ddb_NestingToolbox_Delft3DWAVE_nest1.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 08:06:47 +0100 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Nesting/ddb_NestingToolbox_Delft3DWAVE_nest1.m $
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    setInstructions({'','Click Make Nesting Sections in order to generate observation points in the overall grid', ...
                'The overall model domain must be selected!'});
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'nest1'}
            nest1;
    end
end

%%
function nest1

handles=getHandles;

if isempty(handles.toolbox.nesting.ww3_grid_file)
    ddb_giveWarning('text','Please first load ww3_shel file of nested model!');
    return
end

if handles.model.ww3.domain.nx<=0
    ddb_giveWarning('text','Please first load or create model grid!');
    return    
end

[x0,y0,dx,dy,np]=ww3_define_nesting_sections(handles.toolbox.nesting.ww3_grid_file);
nsec=length(x0);

% Store in domain structure
ww3=handles.model.ww3.domain;
nobp=length(ww3.output_boundary_points);
nobp=nobp+1;
for ii=1:nsec
    ww3.output_boundary_points(nobp).line(ii).x0=x0(ii);
    ww3.output_boundary_points(nobp).line(ii).y0=y0(ii);
    ww3.output_boundary_points(nobp).line(ii).dx=dx(ii);
    ww3.output_boundary_points(nobp).line(ii).dy=dy(ii);
    ww3.output_boundary_points(nobp).line(ii).np=np(ii);
end
handles.model.ww3.domain=ww3;

setHandles(handles);

