function cosmos_makeColorBar(fname,varargin)
% Generates colorbar png for kml files

labl='';
colorBarDecimals=1;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'contours'}
                contours=varargin{i+1};
            case{'label'}
                labl=varargin{i+1};
            case{'colormap'}
                clmap=varargin{i+1};
            case{'decimals'}
                colorBarDecimals=varargin{i+1};
        end
    end
end

notick=length(contours);
pos=[1 1 1 5];

nocol=64;
clmap=eval([clmap '(nocol)']);

% Make the figure

h=figure('Visible','off');

set(h,'Units','centimeters');
set(h,'Position',[0 0 1 9]);

clrbar=axes;
 
for i=1:nocol
    col=clmap(i,:);
    x(1)=0;x(2)=1;x(3)=1;x(4)=0;x(5)=0;
    y(1)=(i-1)/nocol;
    y(2)=y(1);
    y(3)=i/nocol;
    y(4)=y(3);
    y(5)=y(1);
    fl=fill(x,y,'b');hold on;
    set(fl,'FaceColor',col,'LineStyle','none');
end

set(clrbar,'xlim',[0 1],'ylim',[0 1]);
set(clrbar,'Units','centimeters');
set(clrbar,'Position',[1 0.5 0.5 8]);
set(clrbar,'XTick',[]);
set(clrbar,'YTick',0:(1/(notick-1)):1);
set(clrbar,'YAxisLocation','right');

fmt=['%0.' num2str(colorBarDecimals) 'f'];
for i=1:notick
    ylabls{i}=num2str(contours(i),fmt);
end

set(clrbar,'yticklabel',ylabls);
set(clrbar,'FontSize',12);
set(clrbar,'YColor',[1 1 0]);

txx=-0.7/(pos(3));
txy=0.5;
ylab=text(txx,txy,labl);

set(ylab,'Rotation',90);
set(ylab,'HorizontalAlignment','center','VerticalAlignment','middle');

set(ylab,'FontSize',12);
set(ylab,'Color',[1 1 0]);

set(h,'Color','none');
set(clrbar,'Color','none');

export_fig(h,fname);

close(h);
