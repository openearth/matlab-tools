function handles = ddb_sfincs_plot_discharge_points(handles, opt, varargin)
%ddb_sfincs_plotsourcePoints  One line description goes here.

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

% $Id: ddb_sfincs_plotsourcePoints.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 08:06:47 +0100 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/sfincs/plot/ddb_sfincs_plotsourcePoints.m $
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


switch lower(opt)
    
    case{'plot'}
        
        h=handles.model.sfincs.domain(id).discharges.handle;
        
        % First delete old sections
        try
            delete(h);
        end
        
        if handles.model.sfincs.domain(ad).discharges.number>0
            
            for ip=1:handles.model.sfincs.domain(ad).discharges.number
                xy(ip,:)=[handles.model.sfincs.domain(ad).discharges.point(ip).x handles.model.sfincs.domain(ad).discharges.point(ip).y];
                txt{ip}=handles.model.sfincs.domain.discharges.point(ip).name;
            end
            
            h=gui_pointcloud('plot','xy',xy,'selectcallback',@ddb_sfincs_discharge_points,'selectinput','selectfrommap',...
                'tag','sfincs_discharge_points', ...
                'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','y', ...
                'ActiveMarkerSize',6,'ActiveMarkerEdgeColor','k','ActiveMarkerFaceColor','r', ...
                'activepoint',handles.model.sfincs.domain.discharges.activepoint,'text',txt,'FontSize',10,'FontWeight','bold');
            
            handles.model.sfincs.domain(id).discharges.handle=h;
            
            if vis
                set(h,'Visible','on');
            else
                set(h,'Visible','off');
            end
            
        end
        
    case{'delete'}
        
        plothandle=handles.model.sfincs.domain(id).discharges.handle;
        
        % Delete old grid
        try
            delete(plothandle);
        end
        
        % And now (just to make sure) delete all objects with tag
        h=findobj(gcf,'Tag','sfincs_discharge_points');
        if ~isempty(h)
            delete(h);
        end
        
        handles.model.sfincs.domain(id).discharges.handle=[];
        
    case{'update'}
        
        plothandle=handles.model.sfincs.domain(id).discharges.handle;
        
        try
            
            if handles.model.sfincs.domain(ad).discharges.number>0
                
                if iactive
                    gui_pointcloud(plothandle,'change','color','markeredgecolor','k','markerfacecolor','y', ...
                        'activemarkerfacecolor','r','markersize',5,'activemarkersize',6,'textvisible','on');
                    set(plothandle,'HitTest','on');
                    ch=get(plothandle,'Children');
                    for ipp=1:length(ch)
                        set(ch(ipp),'HitTest','on');
                    end
                else
                    gui_pointcloud(plothandle,'change','color','markeredgecolor','k','markerfacecolor','y', ...
                        'activemarkerfacecolor','y','markersize',5,'activemarkersize',6,'textvisible','off');
                    set(plothandle,'HitTest','off');
                    ch=get(plothandle,'Children');
                    for ipp=1:length(ch)
                        set(ch(ipp),'HitTest','off');
                    end
                end
                
            end
            
            if vis
                set(plothandle,'Visible','on');
            else
                set(plothandle,'Visible','off');
            end
        end
end

