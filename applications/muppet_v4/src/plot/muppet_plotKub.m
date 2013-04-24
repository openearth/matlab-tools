function h=muppet_plotKub(handles,i,j,k)

h=[];

plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;
 
xmin=plt.cmin;
xmax=plt.cmax;
cstep=plt.cstep;
 
[x,y]=landboundary('read',data.polygonfile);
 
polno=1;
jj=1;
for ii=1:size(x,1)
    if (isnan(x(ii)))
        polno=polno+1;
        jj=1;
    else
        xldb{polno}(jj)=x(ii);
        yldb{polno}(jj)=y(ii);
        jj=jj+1;
    end
end
 
sz=size(data.z,1);
 
clmap=muppet_getColors(handles.colormaps,plt.colormap,100);
colormap(clmap);
 
for ii=1:sz;
    x0=data.z(ii);
    x0=max(min(x0,xmax),xmin);
    x=(x0-xmin)/(xmax-xmin);
    ix=round(99*x)+1;
    col{ii}(1)=clmap(ix,1);
    col{ii}(2)=clmap(ix,2);
    col{ii}(3)=clmap(ix,3);
end
 
for ii=1:sz
 
    switch opt.kubfill
        case 1
            % Filled polygons
            ldbplt=fill(xldb{ii},yldb{ii},'r');hold on;
            set(ldbplt,'FaceColor',[col{ii}(1) col{ii}(2) col{ii}(3)]);
            set(ldbplt,'EdgeColor',colorlist('getrgb','color',opt.edgecolor));
            set(ldbplt,'LineWidth',opt.linewidth);
        case 0
            % No fill color
            xxxx=xldb{ii};
            yyyy=yldb{ii};
            ldbplt=plot(xxxx,yyyy);hold on;
            set(ldbplt,'LineWidth',opt.linewidth,'Color',colorlist('getrgb','color',opt.edgecolor));
    end

    xtxt=0.5*(max(xldb{ii}(1:end-1))+min(xldb{ii}(1:end-1)));
    ytxt=0.5*(max(yldb{ii}(1:end-1))+min(yldb{ii}(1:end-1)));

    switch opt.areatext
        case 1
            % Plot actual values
            frmt=['%0.' num2str(opt.decimals) 'f'];
            tx=num2str(data.z(ii)*opt.multiply,frmt);
        case 2
            % Just plot indices of polygons
            tx=num2str(ii);
    end
    txt=text(xtxt,ytxt,3000,tx);
    set(txt,'HorizontalAlignment','center','VerticalAlignment','middle','Clipping','on');
    set(txt,'FontName',opt.Font);
    set(txt,'FontWeight',opt.FontWeight);
    set(txt,'FontAngle',opt.FontAngle);
    set(txt,'FontSize',opt.FontSize);
    set(txt,'Color',colorlist('getrgb','color',opt.font.color));

end
 
caxis([xmin xmax]);
