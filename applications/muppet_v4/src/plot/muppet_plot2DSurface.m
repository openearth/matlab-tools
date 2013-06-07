function h=muppet_plot2DSurface(handles,ifig,isub,id)

h=[];

plt=handles.figures(ifig).figure.subplots(isub).subplot;
nr=plt.datasets(id).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(id).dataset;

data.x=data.x(1:opt.fieldthinningfactor1:end,1:opt.fieldthinningfactor1:end);
data.y=data.y(1:opt.fieldthinningfactor1:end,1:opt.fieldthinningfactor1:end);
data.z=data.z(1:opt.fieldthinningfactor1:end,1:opt.fieldthinningfactor1:end);
data.zz=data.zz(1:opt.fieldthinningfactor1:end,1:opt.fieldthinningfactor1:end);

switch(lower(opt.plotroutine)),
    case{'plotpatches','plotshadesmap','plotcontourmap','plotcontourmaplines'}
        if strcmpi(plt.contourtype,'limits')
            col=plt.cmin:plt.cstep:plt.cmax;
        else
            col=plt.contours;
        end
    case{'plotcontourlines'}
        if strcmpi(opt.contourtype,'limits')
            col=opt.cmin:opt.cstep:opt.cmax;
        else
            col=opt.contours;
        end
end

c1=col(1);
c2=col(end);
dc=col(2)-col(1);

switch(lower(opt.plotroutine)),
    case{'plotpatches'}
        x=data.x;
        y=data.y;
        z=data.zz;
        clmap=muppet_getColors(handles.colormaps,plt.colormap,64);
        colormap(clmap);
        h=pcolor(x,y,z);
        shading flat;
        caxis([col(1) col(end)]);
    case{'plotcontourmap','plotcontourmaplines'}
        z=max(data.z,c1-dc);
        z=min(z,c2+dc);
        z(isnan(data.z))=NaN;
        x=data.x;
        y=data.y;
        xmean=mean(x(isfinite(x)));
        ymean=mean(y(isfinite(y)));
        x(isnan(x))=xmean;
        y(isnan(y))=ymean;
        z(isnan(x))=NaN;
        if strcmpi(opt.contourtype,'limits')
            zc=z;
            cax=[col(1)-dc col(end)];
            contours=col(1)-dc:dc:col(end)+dc;
        else
            isn=isnan(z);
            zc=z;
            zc=max(zc,col(1));
            zc=min(zc,col(end));
            zc=interp1(col,1:length(col),zc);
            zc(isn)=NaN;
            cax=[1 length(col)-1];
            contours=1:length(col)-1;
        end
        [c,h,wp]=muppet_contourf_mvo(x,y,zc,contours);
        clmap=muppet_getColors(handles.colormaps,plt.colormap,64);
        caxis(cax);
        colormap(clmap);
    case{'plotshadesmap'}
        x=data.x;
        y=data.y;
        z=data.z;
        ncol=128;
        clmap=muppet_getColors(handles.colormaps,plt.colormap,ncol);
        colormap(clmap);
        h=pcolor(x,y,z);
        shading interp;
        caxis([col(1) col(end)]);
    case{'plotcontourlines'}
        x=data.x;
        y=data.y;
        z=data.z;
        [c,h]=contour(x,y,z,col);
        if strcmpi(opt.linecolor,'auto')==0
            set(h,'LineColor',colorlist('getrgb','color',opt.linecolor));
        end
        set(h,'LineStyle',opt.linestyle);
        set(h,'LineWidth',opt.linewidth);
end

hold on;

if strcmpi(opt.plotroutine,'plotcontourmaplines')
    [c,h]=contour(x,y,z,col);
    if strcmpi(opt.linecolor,'auto')==0
        set(h,'LineColor',colorlist('getrgb','color',opt.linecolor));
    else
        set(h,'LineColor','k');
    end
    set(h,'LineStyle',opt.linestyle);
    set(h,'LineWidth',opt.linewidth);
end

if opt.contourlabels
    switch lower(opt.plotroutine)
        case{'plotcontourmap','plotpatches'}
            [c,h]=contour(x,y,z,col);
            set(h,'LineStyle','none');
    end
    hh=clabel(c,h,'LabelSpacing',opt.labels.spacing);
    set(hh,'FontName',opt.labels.font.weight,'FontSize',opt.labels.font.size*handles.figures(ifig).figure.fontreduction, ...
        'FontWeight',opt.labels.font.weight,'FontAngle',opt.labels.font.angle);
    set(hh,'Color',colorlist('getrgb','color',opt.labels.font.color));
end
