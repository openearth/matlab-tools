function handles = ddb_Delft3DWAVE_plotGrid(handles, opt, varargin)
%DDB_delft3dwave_PLOTGRID  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_delft3dwave_plotGrid(handles, opt, varargin)
%
%   Input:
%   handles  =
%   opt      =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_delft3dwave_plotGrid
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%

col=[0.35 0.35 0.35];
vis=1;
id=awg;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'color'}
                col=varargin{i+1};
            case{'visible'}
                vis=varargin{i+1};
            case{'wavedomain'}
                id=varargin{i+1};
        end
    end
end

switch lower(opt)
    
    case{'plot'}
        
        % First delete old grid
        try
            delete(handles.model.delft3dwave.domain(id).grid.plotHandles);
        end
        
        % Now plot new grid
        x=handles.model.delft3dwave.domain.domains(id).gridX;
        y=handles.model.delft3dwave.domain.domains(id).gridY;
        handles.model.delft3dwave.domain.domains(id).grid.plotHandles=ddb_plotCurvilinearGrid(x,y,'color',col);
        if vis
            set(handles.model.delft3dwave.domain.domains(id).grid.plotHandles,'Color',col,'Visible','on');
        else
            set(handles.model.delft3dwave.domain.domains(id).grid.plotHandles,'Color',col,'Visible','off');
        end
        
    case{'delete'}
        
        % Delete old grid
        try
            delete(handles.model.delft3dwave.domain.domains(id).grid.plotHandles);
        end
%        hh=findobj(gcf,'tag','delft3dwavegrid');
%        if ~isempty(hh)
%            try
%                delete(hh);
%            end
%        end
        
    case{'update'}
        if isfield(handles.model.delft3dwave.domain.domains(id).gridplot,'plothandles')
            if ~isempty(handles.model.delft3dwave.domain.domains(id).gridplot.plothandles)
                try
                    set(handles.model.delft3dwave.domain.domains(id).gridplot.plothandles,'Color',col);
                    if vis
                        set(handles.model.delft3dwave.domain.domains(id).gridplot.plothandles,'Color',col,'Visible','on');
                    else
                        set(handles.model.delft3dwave.domain.domains(id).gridplot.plothandles,'Color',col,'Visible','off');
                    end
                end
            end
        end
end

