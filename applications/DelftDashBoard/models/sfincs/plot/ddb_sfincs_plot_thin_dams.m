function handles = ddb_sfincs_plot_thin_dams(handles, opt, varargin)
%ddb_sfincs_plotObservationPoints  One line description goes here.

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

% $Id: ddb_sfincs_plotObservationPoints.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 08:06:47 +0100 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/sfincs/plot/ddb_sfincs_plotObservationPoints.m $
% $Keywords: $

%%

vis=1;
id=ad;
iactive=1;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'color'}
                col=varargin{i+1};
            case{'visible'}
                vis=varargin{i+1};
            case{'domain'}
                id=varargin{i+1};
            case{'active'}
                iactive=varargin{i+1};
        end
    end
end

for ib=1:handles.model.sfincs.domain(id).nrthindams
    if isfield(handles.model.sfincs.domain(id).thindams(ib),'handle')
        plothandles(ib)=handles.model.sfincs.domain(id).thindams(ib).handle;
    end
end

if iactive
    linecolor='g';
    markercolor='r';
else
    linecolor=[0.5 0.5 0.5];
    markercolor=[0.5 0.5 0.5];
end

switch lower(opt)
    
    case{'plot'}
        
        % First delete old sections
        try
            delete(plothandles);
        end

        plothandles=[];
        
        if handles.model.sfincs.domain(id).nrthindams>0

            for isec=1:length(handles.model.sfincs.domain(id).thindams)
                x=handles.model.sfincs.domain(id).thindams(isec).x;
                y=handles.model.sfincs.domain(id).thindams(isec).y;
                if isec==handles.model.sfincs.domain(id).activethindam
                    markercolor='r';
                else
                    markercolor=[1 1 0];
                end
                p=gui_polyline('plot','x',x,'y',y,'tag','sfincsthindam', ...
                    'changecallback',@ddb_sfincs_obstacles,'changeinput','changethindam','closed',0, ...
                    'Marker','o','color',linecolor,'markeredgecolor',markercolor,'markerfacecolor',markercolor);
                handles.model.sfincs.domain(id).thindams(isec).handle=p;

                plothandles(isec)=p;
                
            end
            
            if vis
                set(plothandles,'Visible','on');
            else
                set(plothandles,'Visible','off');
            end
        end
        
        
    case{'delete'}
        
        % Delete old grid
        try
            delete(plothandles);
        end
        
        % And now (just to make sure) delete all objects with tag
        h=findobj(gcf,'Tag','sfincsthindam');
        if ~isempty(h)
            delete(h);
        end
        
    case{'update'}
        try

            if handles.model.sfincs.domain(id).nrthindams>0
                
                for ip=1:length(plothandles)

                    if iactive
                        if ip==handles.model.sfincs.domain(id).activethindam
                            markercolor='r';
                        else
                            markercolor=[1 1 0];
                        end
                        set(plothandles(ip),'HitTest','on');
                        ch=get(plothandles(ip),'Children');
                        for ipp=1:length(ch)
                            set(ch(ipp),'HitTest','on');
                        end
                    else
                        markercolor=[0.5 0.5 0.5];
                        set(plothandles(ip),'HitTest','off');
                        ch=get(plothandles(ip),'Children');                        
                        for ipp=1:length(ch)
                            set(ch(ipp),'HitTest','off');
                        end                        
                    end
                    
                    gui_polyline(plothandles(ip),'change','color',linecolor,'markeredgecolor',markercolor,'markerfacecolor',markercolor);
                    
                end
                
                if vis
                    set(plothandles,'Visible','on');
                else
                    set(plothandles,'Visible','off');
                end
            end
        end
end


