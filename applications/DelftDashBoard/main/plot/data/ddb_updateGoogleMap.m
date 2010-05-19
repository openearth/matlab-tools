function ddb_updateGoogleMap

handles=getHandles;

xl=get(gca,'xlim');
yl=get(gca,'ylim');

% Bathymetry

BathyCoord.Name='WGS 84';
BathyCoord.Type='Geographic';
if strcmpi(handles.SourceBathymetry,'vaklodingen')
    BathyCoord.Name='Amersfoort / RD New';
    BathyCoord.Type='Cartesian';
end

Coord=handles.ScreenParameters.CoordinateSystem;

if strcmpi(Coord.Name,BathyCoord.Name)
    [xl0,yl0]=ddb_coordConvert(xl,yl,Coord,BathyCoord);
else
    dx=(xl(2)-xl(1))/100;
    dy=(yl(2)-yl(1))/100;
    [xtmp,ytmp]=meshgrid(xl(1)-dx:dx:xl(2)+dx,yl(1)-dy:dy:yl(2)+dy);
    [xtmp2,ytmp2]=ddb_coordConvert(xtmp,ytmp,Coord,BathyCoord);
    xl0(1)=min(min(xtmp2));
    xl0(2)=max(max(xtmp2));
    yl0(1)=min(min(ytmp2));
    yl0(2)=max(max(ytmp2));
end

clear xtmp ytmp xtmp2 ytmp2

pos=get(gca,'Position');
%res=(xl0(2)-xl0(1))/(1*pos(3));

% Get bathymetry
tic
disp('Getting data ...');
%dataset=handles.SourceBathymetry;
%[x0,y0,z]=ddb_getBathy(xl0,yl0,res,dataset);

xcen=(xl(2)+xl(1))/2
ycen=(yl(2)+yl(1))/2
szx=640
szy=round(szx*(yl(2)-yl(1))/(xl(2)-xl(1)))
%szy=320;
spanx=xl(2)-xl(1)
spany=yl(2)-yl(1)

str=['http://maps.google.com/staticmap?center=' num2str(ycen) ',' num2str(xcen) '&span=' num2str(spany) ',' num2str(spanx) '&size=' num2str(szx) 'x' num2str(szy) '&maptype=terrain&key=ABQIAAAADGuF_unGzuNVVJQZC3lmZxSAJxQB3HoUbkYz4DATYbtuKGQHERSoHbmKZk6c1pYqGAiE4O2aApvLbA'];

[I map]=imread(str);
RGB=ind2rgb(I,map);

RGB(:,:,1)=flipud(RGB(:,:,1));
RGB(:,:,2)=flipud(RGB(:,:,2));
RGB(:,:,3)=flipud(RGB(:,:,3));

xx=[xcen-0.5*spanx xcen+0.5*spanx]
yy=[ycen-0.5*spany ycen+0.5*spany]
% xx=[xcen-spanx xcen+spanx]
% yy=[ycen-spany ycen+spany]
%figure(2)
image(xx,yy,RGB);
%axis equal
set(gca,'ydir','normal');
toc
%figure(1);



