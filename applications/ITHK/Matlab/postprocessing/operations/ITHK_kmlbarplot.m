function ITHK_kmlbarplot(x,y,z,offset)

global S

%EPSG                = load('EPSG.mat');

for jj = 1:length(S.PP.settings.tvec)
    time    = datenum((S.PP.settings.tvec(jj)+S.PP.settings.t0),1,1);
    for ii=2:length(S.PP.settings.sgridRough)-1
        alpha    = atan((y(ii+1)-y(ii-1))/(x(ii+1)-x(ii-1)));
        if alpha>0
            x1       = x(ii)+offset;  
            y1       = y(ii)-offset/2;
            xtip     = x(ii)+offset+z(ii,jj)*S.PP.settings.sVectorLength*cos(alpha+pi()/2);
            ytip     = y(ii)-offset/2+z(ii,jj)*S.PP.settings.sVectorLength*sin(alpha+pi()/2);
        elseif alpha<=0
            x1       = x(ii)+offset;%*cos(alpha-pi()/2);  
            y1       = y(ii)-offset/2;%+offset*sin(alpha-pi()/2);
            xtip     = x(ii)+offset+z(ii,jj)*S.PP.settings.sVectorLength*cos(alpha-pi()/2);
            ytip     = y(ii)-offset/2+z(ii,jj)*S.PP.settings.sVectorLength*sin(alpha-pi()/2);
        end
        xpoly(1)    = x1+S.PP.settings.widthRough/2*cos(alpha);
        xpoly(2)    = xtip+S.PP.settings.widthRough/2*cos(alpha);
        xpoly(3)    = xtip-S.PP.settings.widthRough/2*cos(alpha);
        xpoly(4)    = x1-S.PP.settings.widthRough/2*cos(alpha);
        xpoly(5)    = xpoly(1);
        ypoly(1)    = y1+S.PP.settings.widthRough/2*sin(alpha);
        ypoly(2)    = ytip+S.PP.settings.widthRough/2*sin(alpha);
        ypoly(3)    = ytip-S.PP.settings.widthRough/2*sin(alpha);
        ypoly(4)    = y1-S.PP.settings.widthRough/2*sin(alpha);
        ypoly(5)    = ypoly(1);
        % convert coordinates
        [lonpoly,latpoly] = convertCoordinates(xpoly,ypoly,S.EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
        lonpoly     = lonpoly';
        latpoly     = latpoly';
        % color of polygon
        if z(ii,jj) < 0 % red
            S.PP.output.kml = [S.PP.output.kml KML_stylePoly('name','default','fillColor',[1 0 0],'lineColor',[0 0 0],'lineWidth',1,'fillAlpha',0.7)];
        else % green
            S.PP.output.kml = [S.PP.output.kml KML_stylePoly('name','default','fillColor',[0 1 0],'lineColor',[0 0 0],'lineWidth',1,'fillAlpha',0.7)]; 
        end
        % polygon to KML
        S.PP.output.kml = [S.PP.output.kml KML_poly(latpoly ,lonpoly ,'timeIn',time,'timeOut',time+364,'styleName','default')];
        clear lonpoly latpoly
    end   
end