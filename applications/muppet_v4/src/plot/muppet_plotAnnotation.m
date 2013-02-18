function handles=muppet_plotAnnotation(handles,i,j,k)

fig=handles.figures(i).figure;
plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

x=data.x;
y=data.y;

for ii=1:length(x)
    
    if ~strcmpi(opt.marker,'none')
        sc=scatter3(x(ii),y(ii),1000,opt.markersize,opt.marker);
        set(sc,'markeredgecolor',colorlist('getrgb','color',opt.markeredgecolor),'markerfacecolor',colorlist('getrgb','color',opt.markerfacecolor));
        set(sc,'Clipping','on');
    else
        sc=scatter3(x(ii),y(ii),1000);
        set(sc,'markeredgecolor','none','markerfacecolor','none');
    end
    
    hold on;
    
    if opt.addtext
        dist=0.001*plt.scale;
        switch lower(opt.textposition),
            case{'northeast','east','southeast'}
                x1=x(ii)+dist;
                horal='left';
            case{'north','middle','south'}
                x1=x(ii);
                horal='center';
            case{'northwest','west','southwest'}
                x1=x(ii)-dist;
                horal='right';
        end
        switch lower(opt.textposition),
            case{'northeast','north','northwest'}
                y1=y(ii)+dist;
                veral='bottom';
            case{'east','middle','west'}
                y1=y(ii);
                veral='middle';
            case{'southeast','south','southwest'}
                y1=y(ii)-dist;
                veral='top';
        end
        tx=text(x1,y1,1000,[data.text{ii}]);
        set(tx,'FontName',opt.font.name);
        set(tx,'FontWeight',opt.font.weight);
        set(tx,'FontAngle',opt.font.angle);
        set(tx,'Fontsize',opt.font.size*fig.fontreduction);
        set(tx,'color',colorlist('getrgb','color',opt.font.color));
        set(tx,'HorizontalAlignment',horal,'VerticalAlignment',veral);
        set(tx,'Rotation',data.rotation(ii));
        set(tx,'Clipping','on');
    end
end

% Set handle
handles.figures(i).figure.subplots(j).subplot.datasets(k).dataset.handle=sc;
