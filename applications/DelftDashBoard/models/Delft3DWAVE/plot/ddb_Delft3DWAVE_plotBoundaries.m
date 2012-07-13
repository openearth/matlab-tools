function handles = ddb_Delft3DWAVE_plotBoundaries(handles, opt, varargin)
%DDB_DELFT3DFLOW_PLOTBOUNDARIES  One line description goes here.

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
imd=strmatch('Delft3DWAVE',{handles.Model(:).name},'exact');

active=1;
vis=1;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'color'}
                col=varargin{i+1};
            case{'visible'}
                vis=varargin{i+1};
            case{'active'}
                active=varargin{i+1};
        end
    end
end

switch lower(opt)
    
    case{'plot'}
        
        % First delete old obstacles
        for ii=1:handles.Model(imd).Input.nrboundaries
            try
                h=handles.Model(imd).Input.boundaries(ii).plothandle;
                delete(h);
            end
        end
        
        % Now plot new obstacles
        for ii=1:handles.Model(imd).Input.nrboundaries
            switch lower(handles.Model(imd).Input.boundaries(ii).definition)
                case{'xy-coordinates'}
                    x=[handles.Model(imd).Input.boundaries(ii).startcoordx handles.Model(imd).Input.boundaries(ii).endcoordx];
                    y=[handles.Model(imd).Input.boundaries(ii).startcoordy handles.Model(imd).Input.boundaries(ii).endcoordy];
                    h=gui_polyline('plot','x',x,'y',y,'Tag','delft3dwaveobstacle','Marker','o', ...
                        'changecallback',@ddb_Delft3DWAVE_boundaries,'changeinput','changexyboundary','closed',0, ...
                        'color','g','markeredgecolor','g','markerfacecolor','g');
                    if active && ii==handles.Model(imd).Input.activeboundary
                        gui_polyline(h,'change','color','r','markeredgecolor','r','markerfacecolor','r');
                    end
                    handles.Model(imd).Input.boundaries(ii).plothandle=h;
                case{'grid-coordinates'}
                    x=[handles.Model(imd).Input.boundaries(ii).startcoordx handles.Model(imd).Input.boundaries(ii).endcoordx];
                    y=[handles.Model(imd).Input.boundaries(ii).startcoordy handles.Model(imd).Input.boundaries(ii).endcoordy];
                    h=gui_polyline('plot','x',x,'y',y,'Tag','delft3dwaveobstacle','Marker','o', ...
                        'changecallback',@ddb_Delft3DWAVE_boundaries,'changeinput','changexyboundary','closed',0, ...
                        'color','g','markeredgecolor','g','markerfacecolor','g');
                    if active && ii==handles.Model(imd).Input.activeboundary
                        gui_polyline(h,'change','color','r','markeredgecolor','r','markerfacecolor','r');
                    end
                    handles.Model(imd).Input.boundaries(ii).plothandle=h;
            end
        end
        
    case{'delete'}
        
        % Delete old obstacles
        for ii=1:handles.Model(imd).Input.nrboundaries
            try
                h=handles.Model(imd).Input.boundaries(ii).plothandle;
                if ishandle(h)
                    delete(handles.Model(imd).Input.boundaries(ii).plothandle);
                end
            end
        end
        hh=findobj(gcf,'tag','delft3dwaveboundary');
        if ~isempty(hh)
            delete(hh);
        end
        
    case{'update'}

        try
            for ii=1:handles.Model(imd).Input.nrboundaries
                h=handles.Model(imd).Input.boundaries(ii).plothandle;
                if ishandle(h)
                    if ii==handles.Model(imd).Input.activeboundary && active
                        gui_polyline(h,'change','color','r','markeredgecolor','r','markerfacecolor','r');
                    else
                        gui_polyline(h,'change','color','g','markeredgecolor','g','markerfacecolor','g');
                    end
                    if vis
                        set(h,'Visible','on');
                    else
                        set(h,'Visible','off');
                    end
                    mh=getappdata(h,'markerhandles');
                    if active
                        set(mh,'HitTest','on');
                    else
                        set(mh,'HitTest','off');
                    end
                end
                try
                    uistack(h,'top');
                end

            end
            
        end
end

