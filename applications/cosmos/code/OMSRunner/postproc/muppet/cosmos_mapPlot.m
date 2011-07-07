function cosmos_mapPlot(fname,data,varargin)

clmap='jet';

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'xlim'}
                xlim=varargin{i+1};
            case{'ylim'}
                ylim=varargin{i+1};
            case{'clim'}
                clim=varargin{i+1};
            case{'colormap'}
                clmap=varargin{i+1};
        end
    end
end

% data.y=merc(data.y);
% ylim=merc(ylim);

szx=8;
szy=szx*(ylim(2)-ylim(1))/(xlim(2)-xlim(1));

pps=[szx szy];

h=figure('Visible','off');

set(h,'Units','centimeters');
set(h,'Position',[0 0 pps]);

ax=axes;
set(ax,'Units','centimeters');

pcolor(data.x,data.y,data.z);caxis(clim);shading flat;
colormap(clmap);

set(ax,'XLim',xlim,'YLim',ylim);
set(ax,'Box','off');
set(ax,'XTick',-1e6,'YTick',-1e6);
set(ax,'Position',[-0.02 -0.02 szx+0.04 szy+0.04]);
set(h,'Color','none');
set(ax,'Color','none');

export_fig(h,fname,'-nocrop','-a1');

close(h);

