function h=muppet_plotUnstructuredPatches(handles,ifig,isub,id)

h=[];

plt=handles.figures(ifig).figure.subplots(isub).subplot;
nr=plt.datasets(id).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(id).dataset;

if strcmpi(plt.contourtype,'limits')
    col=plt.cmin:plt.cstep:plt.cmax;
else
    col=plt.contours;
end

h  = dflowfm.plotMap(data.G,data.z);

clmap=muppet_getColors(handles.colormaps,plt.colormap,64);
colormap(clmap);
% h=pcolor(x,y,z);
% shading flat;
caxis([col(1) col(end)]);

hold on;
