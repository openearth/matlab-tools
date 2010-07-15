function [x,y,z,ok]=ddb_getBathy(handles,xl,yl,varargin)

ok=0;

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

    case{'netcdf'}
        
        url=handles.Bathymetry.Dataset(iac).URL;
        
%         gridsize=nc_varget(url,'grid_size');
        gridsize=loaddap([url '?grid_size']);
        gridsize=gridsize.grid_size;
               
        gsmin=(xl(2)-xl(1))/800;
        
        igs=find(gridsize<gsmin,1,'last');
        if isempty(igs)
            igs=1;
        end
        
        lonstr=['lon' num2str(igs)];
        latstr=['lat' num2str(igs)];
        varstr=['depth' num2str(igs)];
        
%         lon0=nc_varget(url,lonstr);
%         lat0=nc_varget(url,latstr);
        lon0=loaddap([url '?' lonstr]);
        lon0=lon0.(lonstr);
        lat0=loaddap([url '?' latstr]);
        lat0=lat0.(latstr);
        
        ilon1=find(lon0<=xl(1),1,'last')-1;
        if isempty(ilon1)
            ilon1=1;
        end
        ilon1=max(ilon1,1);

        ilon2=find(lon0>=xl(2),1)+1;
        if isempty(ilon2)
            ilon2=length(lon0);
        end
        ilon2=min(ilon2,length(lon0));

        ilat1=find(lat0<=yl(1),1,'last')-1;
        if isempty(ilat1)
            ilat1=1;
        end
        ilat1=max(ilat1,1);
 
        ilat2=find(lat0>=yl(2),1)+1;
        if isempty(ilat2)
            ilat2=length(lat0);
        end
        ilat2=min(ilat2,length(lat0));

        nlon=ilon2-ilon1+1;
        nlat=ilat2-ilat1+1;
        
%         z=nc_varget(url,varstr,[ilat1-1 ilon1-1],[nlat nlon]);
        z=loaddap([url '?' varstr '[' num2str(ilat1-1) ':1:' num2str(ilat2-1) '][' num2str(ilon1-1) ':1:' num2str(ilon2-1) ']']);
        z=z.(varstr).(varstr);

        z=double(z);
        
        dlon=(lon0(end)-lon0(1))/(length(lon0)-1);
        dlat=(lat0(end)-lat0(1))/(length(lat0)-1);
        lon=lon0(1):dlon:lon0(end);
        lat=lat0(1):dlat:lat0(end);
        lon=lon(ilon1:ilon2);
        lat=lat(ilat1:ilat2);

        [x,y]=meshgrid(lon,lat);

        ok=1;

    case{'netcdftiles'}
        
        % New tile type
        ok=1;

        nLevels=handles.Bathymetry.Dataset(iac).NrZoomLevels;

        for i=1:nLevels
            cellsizex(i)=handles.Bathymetry.Dataset(iac).ZoomLevel(i).dx;
            cellsizey(i)=handles.Bathymetry.Dataset(iac).ZoomLevel(i).dy;
        end
        
        if zoomlev==0
            gsmin=(xl(2)-xl(1))/800;
            ilev=find(cellsizex<gsmin,1,'last');
            if isempty(ilev)
                ilev=1;
            end
        else
            ilev=zoomlev;
        end

        x0=handles.Bathymetry.Dataset(iac).ZoomLevel(ilev).x0;
        y0=handles.Bathymetry.Dataset(iac).ZoomLevel(ilev).y0;
        dx=handles.Bathymetry.Dataset(iac).ZoomLevel(ilev).dx;
        dy=handles.Bathymetry.Dataset(iac).ZoomLevel(ilev).dy;
        nx=handles.Bathymetry.Dataset(iac).ZoomLevel(ilev).nx;
        ny=handles.Bathymetry.Dataset(iac).ZoomLevel(ilev).ny;
        nnx=handles.Bathymetry.Dataset(iac).ZoomLevel(ilev).ntilesx;
        nny=handles.Bathymetry.Dataset(iac).ZoomLevel(ilev).ntilesy;
        tilesizex=dx*nx;
        tilesizey=dy*ny;
        
        xx=x0:tilesizex:x0+(nnx-1)*tilesizex;
        yy=y0:tilesizey:y0+(nny-1)*tilesizey;
        
        ix1=find(xx<xl(1),1,'last');
        if isempty(ix1)
            ix1=1;
        end
        ix2=find(xx>xl(2),1,'first');
        if isempty(ix2)
            ix2=length(xx);
        end

        iy1=find(yy<yl(1),1,'last');
        if isempty(iy1)
            iy1=1;
        end
        iy2=find(yy>yl(2),1,'first');
        if isempty(iy2)
            iy2=length(yy);
        end

        name=handles.Bathymetry.Dataset(iac).Name;
        levdir=['zl' num2str(ilev,'%0.2i')];

        iopendap=0;
        if strcmpi(handles.Bathymetry.Dataset(iac).URL(1:4),'http')
            % OpenDAP
            iopendap=1;
            urlstr=[handles.Bathymetry.Dataset(iac).URL '/' levdir];
            cachedir=[handles.BathyDir name '\' levdir];
        else
            % Local
            dirstr=[handles.Bathymetry.Dataset(iac).URL '\' levdir '\'];
            cachedir=dirstr;
        end

        nnnx=ix2-ix1+1;
        nnny=iy2-iy1+1;
        z=nan(nnny*ny,nnnx*nx);  
        for i=ix1:ix2
            for j=iy1:iy2

                filename=[name '.zl' num2str(ilev,'%0.2i') '.' num2str(i,'%0.5i') '.' num2str(j,'%0.5i') '.nc'];
                
                % First check if file is available locally
                fnametile=[cachedir filename];
                if ~exist(fnametile,'file') && iopendap
                    % Copy file to cache directory
                    if ~exist(cachedir,'dir')
                        mkdir(cachedir);
                    end
                    try
                        copyfile([urlstr filename],cachedir);
                    end
                end
                if exist(fnametile,'file')
%                    zzz=nc_varget(fnametile, 'depth');
                    zzz=nc_varget([urlstr filename], 'depth');
                    zzz=double(zzz);
                    ok=1;
                else
                    zzz=zeros(ny,nx);
                    zzz(zzz==0)=NaN;
                end
                z((j-iy1)*ny+1:(j-iy1+1)*ny,(i-ix1)*nx+1:(i-ix1+1)*nx)=zzz;
            end
        end
        z(z<-15000)=NaN;

        xx=x0+(ix1-1)*tilesizex:dx:x0+ix2*tilesizex-dx;
        yy=y0+(iy1-1)*tilesizey:dy:y0+iy2*tilesizey-dy;
        [x,y]=meshgrid(xx,yy);
        
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
