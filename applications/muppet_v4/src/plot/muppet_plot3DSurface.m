function h=muppet_plot3DSurface(handles,ifig,isub,id)

h=[];

plt=handles.figures(ifig).figure.subplots(isub).subplot;
nr=plt.datasets(id).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(id).dataset;

col=plt.cmin:plt.cstep:plt.cmax;
 
clmap=muppet_getColors(handles.colormaps,plt.colormap,64);
colormap(clmap);

x=data.x;
y=data.y;
z=data.z;
% z(x<plt.xmin)=NaN;
% z(x>plt.xmax)=NaN;
% z(y<plt.ymin)=NaN;
% z(y>plt.ymax)=NaN;
% z(z<plt.zmin)=NaN;
% z(z>plt.zmax)=NaN;

% z=z*plt.dataaspectratio(3);
% z=z*10000;
dpplot=surf(x,y,z);

if isfield(data,'rgb')
    if ~isempty(data.rgb)
        set(dpplot,'CData',data.rgb);
        shading flat;
    end
end

set(dpplot,'FaceColor',opt.shading);

if opt.plot3dgrid
    set(dpplot,'EdgeColor',colorlist('getrgb','color',opt.linecolor));
    set(dpplot,'LineWidth',0.2);
else
    set(dpplot,'EdgeColor','none');
end

caxis([col(1) col(end)]);

set(dpplot,'FaceLighting','phong');
 
if opt.onecolor==1
    x=opt.color;
    set(dpplot,'FaceColor',opt.color);
end


set(dpplot,'ambientstrength',plt.lightstrength);
set(dpplot,'specularstrength',opt.specularstrength);
set(dpplot,'SpecularColorReflectance',1);
set(dpplot,'SpecularExponent',100);

if opt.transparency<1
    set(dpplot,'EdgeAlpha',opt.transparency);
    set(dpplot,'FaceAlpha',opt.transparency);
end

hold on;
