function h=muppet_plot2DSurface(handles,ifig,isub,id)

h=[];

plt=handles.figures(ifig).figure.subplots(isub).subplot;
nr=plt.datasets(id).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(id).dataset;

data.x=data.x(1:opt.fieldthinningfactor1:end,1:opt.fieldthinningfactor1:end);
data.y=data.y(1:opt.fieldthinningfactor1:end,1:opt.fieldthinningfactor1:end);
data.z=data.z(1:opt.fieldthinningfactor1:end,1:opt.fieldthinningfactor1:end);
data.zz=data.z(1:opt.fieldthinningfactor1:end,1:opt.fieldthinningfactor1:end);
%data.zz=data.zz(1:opt.fieldthinningfactor1:end,1:opt.fieldthinningfactor1:end);

if plt.axesequal==0
    vertscale=(plt.ymax-plt.ymin)/plt.position(4);
    horiscale=(plt.xmax-plt.xmin)/plt.position(3);
    multi=horiscale/vertscale;
else
    multi=1.0;
end
multi=1.0;
data.y=multi*data.y;

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
%         zz1=max(data.zz,c1);
%         zz1=min(zz1,c2);
%         zz1(isnan(data.zz))=NaN;
%         xx=data.x(1:end-1,1:end-1);
%         yy=data.y(1:end-1,1:end-1);
%         zz=zz1(2:end,2:end);
%         n=(size(xx,1)-1)*(size(xx,2)-1);
%         x=xx';
%         y=yy';
%         z=zz';
%         xp(1,:)=reshape(x(1:end-1,1:end-1),1,n);
%         xp(2,:)=reshape(x(2:end,1:end-1),1,n);
%         xp(3,:)=reshape(x(2:end,2:end),1,n);
%         xp(4,:)=reshape(x(1:end-1,2:end),1,n);
%         yp(1,:)=reshape(y(1:end-1,1:end-1),1,n);
%         yp(2,:)=reshape(y(2:end,1:end-1),1,n);
%         yp(3,:)=reshape(y(2:end,2:end),1,n);
%         yp(4,:)=reshape(y(1:end-1,2:end),1,n);
%         zp=reshape(z(1:end-1,1:end-1),1,n);
%         xp(1,isnan(zp))=NaN;
%         yp(1,isnan(zp))=NaN;
%         x=xp;
%         y=yp;
%         z=zp;
        x=data.x;
        y=data.y;
        z=data.z;
    case{'plotshadesmap','plotcontourlines'}
        x=data.x;
        y=data.y;
        z=data.z;
    case{'plotcontourmap','plotcontourmaplines'}
        z=max(data.z,c1-dc);
        z=min(z,c2+dc);
        z(isnan(data.z))=NaN;
        x=data.x;
        y=data.y;
        xmean=mean(x(isfinite(x)));
        ymean=mean(y(isfinite(y)));
        z(isnan(x))=NaN;
        x(isnan(x))=xmean;
        y(isnan(y))=ymean;
end

switch(lower(opt.plotroutine)),
    case{'plotpatches'}
        clmap=muppet_getColors(handles.colormaps,plt.colormap,64);
        colormap(clmap);
        h=pcolor(x,y,z);
        shading flat;
        caxis([col(1) col(end)]);
    case{'plotcontourmap','plotcontourmaplines'}
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
        [c,h,wp]=contourf_mvo(x,y,z,contours);
        clmap=muppet_getColors(handles.colormaps,plt.colormap,64);
        caxis(cax);
        colormap(clmap);
    case{'plotshadesmap'}
        ncol=128;
        clmap=muppet_getColors(handles.colormaps,plt.colormap,ncol);
        colormap(clmap);
        h=pcolor(x,y,z);
        shading interp;
        caxis([col(1) col(end)]);
    case{'plotcontourlines'}
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
