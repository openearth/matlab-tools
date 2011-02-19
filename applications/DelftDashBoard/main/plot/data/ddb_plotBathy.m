function bathy=ddb_plotBathy(x,y,z)

handles=getHandles;

clims=get(gca,'CLim');
zmin=clims(1);
zmax=clims(2);
colormap(ddb_getColors(handles.mapData.colorMaps.earth,64)*255);
caxis([zmin zmax]);

z0=zeros(size(z));
bathy=surface(x,y,z);
set(bathy,'FaceColor','flat');
set(bathy,'HitTest','off');
set(bathy,'Tag','Bathymetry');
set(bathy,'EdgeColor','none');
set(bathy,'ZData',z0);
