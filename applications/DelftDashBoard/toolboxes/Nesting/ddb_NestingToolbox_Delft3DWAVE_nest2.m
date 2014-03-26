function ddb_NestingToolbox_Delft3DWAVE_nest2(varargin)
%ddb_NestingToolbox_Delft3DWAVE_nest2

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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    setInstructions({'','Click Merge SP2 Files in order to generate boundary conditions from the overall model', ...
                'The detailed model domain must be selected!'});
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'nest2'}
            nest2;
    end
end

%%
function nest2

handles=getHandles;

if handles.model.delft3dwave.domain.nrboundaries>0
    
    ButtonName = questdlg('Existing boundary sections will be removed! Continue?', ...
        '', ...
        'Cancel', 'OK', 'OK');
    switch ButtonName,
        case 'Cancel',
            return;
    end
end

[filename, pathname, filterindex] = uigetfile('*.sp2', 'Select files to merge (select just one file)','');

if pathname~=0

    fname=filename;
%    dr=fileparts(fname);
    dr=pathname;

    ii=strfind(fname,'.');
    prefix=fname(1:ii-1);
    
    [filename, pathname, filterindex] = uiputfile('*.sp2', 'Boundary SP2 File Name',handles.model.delft3dwave.domain.boundaries(1).spectrum);
    
    handles = ddb_Delft3DWAVE_plotBoundaries(handles,'delete');

    handles.model.delft3dwave.domain.nrboundaries=1;
    handles.model.delft3dwave.domain.boundarynames{1}=filename;
    handles.model.delft3dwave.domain.activeboundary=1;
    handles.model.delft3dwave.domain.boundaries=[];
    handles.model.delft3dwave.domain.boundaries=ddb_initializeDelft3DWAVEBoundary(handles.model.delft3dwave.domain.boundaries,1);
    handles.model.delft3dwave.domain.boundaries(1).definition='fromsp2file';
    handles.model.delft3dwave.domain.boundaries(1).overallspecfile=filename;
    handles.model.delft3dwave.domain.boundaries(1).name=filename;
    
    fout=handles.model.delft3dwave.domain.boundaries(1).overallspecfile;

    swan_io_mergesp2(dr,fout,'prefix',prefix);
        
    setHandles(handles);
    
end

