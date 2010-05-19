function [x,y,z,ok]=ddb_getBathy(handles,xl,yl,varargin)

zoomlev=0;

if nargin>3
    zoomlev=varargin{1};
end

x=[];
y=[];
z=[];

tic
disp('Getting bathymetry data ...');

iac=strmatch(lower(handles.ScreenParameters.BackgroundBathymetry),lower(handles.Bathymetry.Datasets),'exact');
xsz=xl(2)-xl(1);

tp=handles.Bathymetry.Dataset(iac).Type;

switch lower(tp)

    case{'tiles'}

        if isempty(handles.Bathymetry.Dataset(iac).RefinementFactor)

            if zoomlev==0
                ok=0;
                for i=1:handles.Bathymetry.Dataset(iac).NrZoomLevels
                    zmmin=handles.Bathymetry.Dataset(iac).ZoomLevel(i).ZoomLimits(1);
                    zmmax=handles.Bathymetry.Dataset(iac).ZoomLevel(i).ZoomLimits(2);
                    if xsz>=zmmin && xsz<=zmmax
                        iacz=i;
                        ok=1;
                        break;
                    end
                end
                if ok==0
                    return
                end
            else
                ok=1;
                iacz=zoomlev;
            end

            tilesize=handles.Bathymetry.Dataset(iac).ZoomLevel(iacz).TileSize;
            gridsize=handles.Bathymetry.Dataset(iac).ZoomLevel(iacz).GridCellSize;

            if strcmpi(handles.Bathymetry.Dataset(iac).HorizontalCoordinateSystem.Type,'geographic')
                tilesize=dms2degrees(tilesize);
                gridsize=dms2degrees(gridsize);
            end

            x0=tilesize*floor(xl(1)/tilesize);
            x1=tilesize*ceil(xl(2)/tilesize);
            y0=tilesize*floor(yl(1)/tilesize);
            y1=tilesize*ceil(yl(2)/tilesize);
            nx=round((x1-x0)/tilesize);
            ny=round((y1-y0)/tilesize);

            dirname1=handles.Bathymetry.Dataset(iac).DirectoryName;
            dirname2=handles.Bathymetry.Dataset(iac).ZoomLevel(iacz).DirectoryName;
            fname=handles.Bathymetry.Dataset(iac).ZoomLevel(iacz).FileName;

            dirstr=[handles.BathyDir '\' dirname1 '\' dirname2 '\'];

            z=[];
            for i=1:nx
                zz=[];
                for j=1:ny

                    xsrc=x0+(i-1)*tilesize;
                    ysrc=y0+(j-1)*tilesize;

                    dms=degrees2dms(xsrc);
                    dms=abs(dms);
                    if round(dms(3))==60
                        dms(3)=0;
                        dms(2)=dms(2)+1;
                    end
                    if xsrc<0
                        ewstr='W';
                    else
                        ewstr='E';
                    end
                    xdeg=[ewstr num2str(dms(1),'%0.3i') 'd'];
                    xmin=[num2str(dms(2),'%0.2i') 'm'];
                    xsec=[num2str(round(dms(3)),'%0.2i') 's'];
                    lonstr=[xdeg xmin xsec];

                    dms=degrees2dms(ysrc);
                    dms=abs(dms);
                    if round(dms(3))==60
                        dms(3)=0;
                        dms(2)=dms(2)+1;
                    end

                    if ysrc<0
                        nsstr='S';
                    else
                        nsstr='N';
                    end
                    ydeg=[nsstr num2str(dms(1),'%0.3i') 'd'];
                    ymin=[num2str(dms(2),'%0.2i') 'm'];
                    ysec=[num2str(round(dms(3)),'%0.2i') 's'];
                    latstr=[ydeg ymin ysec];
                    
                    fnametile=[dirstr fname '_' lonstr '_' latstr '.mat'];
                    
                    if exist(fnametile,'file')
                        a=load(fnametile);
                        zzz=a.d.interpz;
                    else
                        zzz=zeros(tilesize/gridsize,tilesize/gridsize);
                        zzz(zzz==0)=NaN;
                    end
                    zz=[zz;zzz];
                end
                z=[z zz];
            end

            dx=gridsize;
            dy=dx;
            xx=x0:dx:x0+nx*tilesize-dx;
            yy=y0:dy:y0+ny*tilesize-dy;
            [x,y]=meshgrid(xx,yy);

            z(z<-15000)=NaN;

        else

            % New tile type
            ok=1;

            tileMax=handles.Bathymetry.Dataset(iac).MaxTileSize;
            nLevels=handles.Bathymetry.Dataset(iac).NrZoomLevels;
            nRef=handles.Bathymetry.Dataset(iac).RefinementFactor;
            nCell=handles.Bathymetry.Dataset(iac).NrCells;

            tileSizes(1)=tileMax;
            for i=2:nLevels
                tileSizes(i)=tileSizes(i-1)/nRef;
            end
            cellSizes=tileSizes/nCell;

            dx=xl(2)-xl(1);

            if zoomlev==0
                ilev=find(tileSizes/dx<0.5,1,'first');
                if isempty(ilev)
                    ilev=handles.Bathymetry.Dataset(iac).NrZoomLevels;
                end
            else
                ilev=zoomlev;
            end

            tilesize=tileSizes(ilev);
            gridsize=cellSizes(ilev);

            x0=tilesize*floor(xl(1)/tilesize);
            x1=tilesize*ceil(xl(2)/tilesize);
            y0=tilesize*floor(yl(1)/tilesize);
            y1=tilesize*ceil(yl(2)/tilesize);
            nx=round((x1-x0)/tilesize);
            ny=round((y1-y0)/tilesize);

            dirname1=handles.Bathymetry.Dataset(iac).DirectoryName;
            dirname2=['zoomlevel' num2str(ilev,'%0.2i')];
            fname=[handles.Bathymetry.Dataset(iac).DirectoryName '.z' num2str(ilev,'%0.2i')];

            dirstr=[handles.BathyDir '\' dirname1 '\' dirname2 '\'];

            z=[];
            for i=1:nx
                zz=[];
                for j=1:ny
                    iindex=i+floor((xl(1)-handles.Bathymetry.Dataset(iac).XOrigin)/tilesize);
                    jindex=j+floor((yl(1)-handles.Bathymetry.Dataset(iac).YOrigin)/tilesize);
                    fnametile=[dirstr fname '.' num2str(iindex,'%0.6i') '.' num2str(jindex,'%0.6i') '.mat'];
                    if exist(fnametile,'file')
                        a=load(fnametile);
                        zzz=double(a.d.interpz);
                        ok=1;
                    else
                        zzz=zeros(tilesize/gridsize,tilesize/gridsize);
                        zzz(zzz==0)=NaN;
                    end
                    zz=[zz;zzz];
                end
                z=[z zz];
            end

            dx=gridsize;
            dy=dx;
            xx=x0:dx:x0+nx*tilesize-dx;
            yy=y0:dy:y0+ny*tilesize-dy;
            [x,y]=meshgrid(xx,yy);

            z(z<-15000)=NaN;

        end

    case{'gridded'}
        try
            [x,y]=meshgrid(handles.Bathymetry.Dataset(iac).x, handles.Bathymetry.Dataset(iac).y);
            z=handles.Bathymetry.Dataset(iac).z;
            ok=1;
        catch
            ok=0;
        end

    case{'vaklodingen'}
        pol(1,1)=xl(1);
        pol(2,1)=xl(2);
        pol(3,1)=xl(2);
        pol(4,1)=xl(1);
        pol(5,1)=xl(1);
        pol(1,2)=yl(1);
        pol(2,2)=yl(1);
        pol(3,2)=yl(2);
        pol(4,2)=yl(2);
        pol(5,2)=yl(1);
        in=1;
        [x,y,z,Ztemps,in] = getDataInPolygon('1',2007,0601,-10*12,10,pol,in);

        %     case{'arcinfo file'}
        %         [xx,yy,z]=ReadArcInfo('sfo6_8261.asc');
        %         [x,y]=meshgrid(xx,yy);
        %         ithin=1;
        %         x=x(1:ithin:end,1:ithin:end);
        %         y=y(1:ithin:end,1:ithin:end);
        %         z=z(1:ithin:end,1:ithin:end);
end

toc
