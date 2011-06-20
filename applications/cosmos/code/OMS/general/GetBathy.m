function [x,y,z]=GetBathy(xl,yl,res,BathyType)

switch lower(BathyType),
    case{'srtm'}
        res=round(3600*res);
        res=max(res,30);
        [x,y,z]=GetSRTM(xl,yl,res);
    case{'etopo2'}
        xavg=0.5*(xl(1)+xl(2));
        yavg=0.5*(yl(1)+yl(2));
        xavg=7+floor(12*xavg/360);
        yavg=4+floor(6*yavg/180);
        str=['d:\data\etopo2\etopo2_' num2str(xavg,'%0.3i') '_' num2str(yavg,'%0.3i') '.mat'];
        a=load(str);
        ithin=max(1,round(res/(3600*a.data.cellsize(1))));
        x=a.data.interpx(1:ithin:end,1:ithin:end);
        y=a.data.interpy(1:ithin:end,1:ithin:end);
        z=a.data.interpz(1:ithin:end,1:ithin:end);
        clear a
    case{'gebco'}
        xavg=0.5*(xl(1)+xl(2));
        yavg=0.5*(yl(1)+yl(2));
        xavg=7+floor(12*xavg/360);
        yavg=4+floor(6*yavg/180);
        imin=7+floor(12*xl(1)/360);
        imax=min(7+floor(12*xl(2)/360),12);
        jmin=4+floor(6*yl(1)/180);
        jmax=min(4+floor(6*yl(2)/180),6);
        x=[];
        y=[];
        z=[];
        for i=imin:imax
            xx=[];
            yy=[];
            zz=[];
            for j=jmin:jmax
                if xl(2)-xl(1)>300
                    str=['c:\delft3d\w32\delftalmighty\bathy\gebco\30deg\20min\gebco_20min_' num2str(i,'%0.3i')  num2str(j,'%0.3i') '.mat'];
                elseif xl(2)-xl(1)>150
                    str=['c:\delft3d\w32\delftalmighty\bathy\gebco\30deg\10min\gebco_10min_' num2str(i,'%0.3i')  num2str(j,'%0.3i') '.mat'];
                elseif xl(2)-xl(1)>75
                    str=['c:\delft3d\w32\delftalmighty\bathy\gebco\30deg\5min\gebco_5min_' num2str(i,'%0.3i')  num2str(j,'%0.3i') '.mat'];
                elseif xl(2)-xl(1)>30 | (imax>imin & jmax>jmin)
                    str=['c:\delft3d\w32\delftalmighty\bathy\gebco\30deg\2min\gebco_2min_' num2str(i,'%0.3i')  num2str(j,'%0.3i') '.mat'];
                else
                    str=['c:\delft3d\w32\delftalmighty\bathy\gebco\30deg\1min\gebco_1min_' num2str(i,'%0.3i')  num2str(j,'%0.3i') '.mat'];
                end                    
                a=load(str);
                ithin=max(1,round(res/(a.d.cellsize(1))));
                [xxx,yyy]=meshgrid(a.d.interpx(1:ithin:end),a.d.interpy(1:ithin:end));
                zzz=a.d.interpz(1:ithin:end,1:ithin:end);
%                 iimin=max(find(xxx(1,:)<xl(1)));
%                 iimax=min(find(xxx(1,:)>xl(2)));
%                 jjmin=max(find(yyy(:,1)>yl(2)));
%                 jjmax=min(find(yyy(:,1)<yl(1)));
%                 if length(iimin)==0
%                     iimin=1;
%                 end
%                 if length(iimax)==0
%                     iimax=size(xxx,2);
%                 end
%                 if length(jjmin)==0
%                     jjmin=1;
%                 end
%                 if length(jjmax)==0
%                     jjmax=size(xxx,1);
%                 end
%                 iimin
%                 iimax
%                 jjmin
%                 jjmax
%                 xxx=xxx(iimin:iimax,jjmin:jjmax);
%                 yyy=yyy(iimin:iimax,jjmin:jjmax);
%                 zzz=zzz(iimin:iimax,jjmin:jjmax);
                clear a
                xx=[xxx;xx];
                yy=[yyy;yy];
                zz=[zzz;zz];
            end
            x=[x xx];
            y=[y yy];
            z=[z zz];
        end
%        str=['d:\data\gebco\tmp\gebco_' num2str(xavg,'%0.3i') '_' num2str(yavg,'%0.3i') '.mat'];
%        str=['d:\data\gebco\tmp\30deg\1min\gebco_1min_' num2str(xavg,'%0.3i')  num2str(yavg,'%0.3i') '.mat'];
%        str=['d:\data\gebco\tmp\30deg\10min\gebco_10min_' num2str(xavg,'%0.3i')  num2str(yavg,'%0.3i') '.mat'];
%        ithin=max(1,round(res/(3600*a.data.cellsize(1))))
%         ithin=max(1,round(res/(a.data.cellsize(1))));
%         x=a.data.interpx(1:ithin:end,1:ithin:end);
%         y=a.data.interpy(1:ithin:end,1:ithin:end);
%         z=a.data.interpz(1:ithin:end,1:ithin:end);
%          ithin=max(1,round(res/(a.d.cellsize(1))));
%          x=a.d.interpx(1:ithin:end,1:ithin:end);
%          y=a.d.interpy(1:ithin:end,1:ithin:end);
%          z=a.d.interpz(1:ithin:end,1:ithin:end);
        clear xx yy zz xxx yyy zzz
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
end

