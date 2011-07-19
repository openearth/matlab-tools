function ddb_plotInitialTsunami(handles,xx,yy,zz)

fig3 = figure('Tag','Figure3','Name', 'Result');
set(fig3,'menubar','none');
set(fig3,'toolbar','figure');
set(fig3,'renderer','opengl');
tbh = findall(fig3,'Type','uitoolbar');
delete(findall(tbh,'TooltipString','Edit Plot'));
delete(findall(tbh,'TooltipString','Rotate 3D'));
delete(findall(tbh,'TooltipString','Show Plot Tools and Dock Figure'));
delete(findall(tbh,'TooltipString','New Figure'));
delete(findall(tbh,'TooltipString','Open File'));
delete(findall(tbh,'TooltipString','Save Figure'));
delete(findall(tbh,'TooltipString','Print Figure'));
delete(findall(tbh,'TooltipString','Data Cursor'));
delete(findall(tbh,'TooltipString','Insert Colorbar'));
delete(findall(tbh,'TooltipString','Insert Legend'));
delete(findall(tbh,'TooltipString','Hide Plot Tools'));
delete(findall(tbh,'TooltipString','Show Plot Tools'));

title('Initial Tsunami');
pcolor(xx,yy,zz);
shading flat;
grid on;
hold on;

load([handles.settingsDir 'geo\worldcoastline.mat']);
xldb=wclx;
yldb=wcly;
z=zeros(size(xldb))+10;
landb=plot3(xldb,yldb,z,'k');

load([handles.Toolbox(tb).miscDir 'plates.mat']);
platesz=zeros(size(platesx))+10;
h=plot3(platesx,platesy,platesz);
set(h,'Color',[1.0 0.5 0.00]);
set(h,'LineWidth',1.5);
set(h,'HitTest','off');

xlabel ('X');
ylabel ('Y');
clbar=colorbar;
set(get(clbar,'YLabel'),'String','Initial water level (m w.r.t. MSL)');
%axis equal;
view(2);

xl=get(handles.GUIHandles.mapAxis,'xlim');
yl=get(handles.GUIHandles.mapAxis,'ylim');

if ~strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    oldSys=handles.screenParameters.coordinateSystem;
    newSys.name='WGS 84';
    newSys.type='geographic';
    [xl(1),yl(1)]=ddb_coordConvert(xl(1),yl(1),oldSys,newSys);
    [xl(2),yl(2)]=ddb_coordConvert(xl(2),yl(2),oldSys,newSys);
end

axis equal;
set(gca,'Xlim',xl,'ylim',yl);

figure(handles.GUIHandles.mainWindow);
