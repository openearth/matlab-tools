function [x,y,OPT]=EHY_convert_coorCheck(x,y,OPT)
if (min(min(y))>max(max(x))) && (~any(any(x<0))) && (~any(any((y<0)))) && (prod(prod(x(~isnan(x))>1000)==1)) % RD in m
    disp('Input coordinations are probably in meter Amersfoort/RD New, EPSG 28992')
    yn=input('Apply conversion from Amersfoort/RD New, EPSG 28992? [Y/N]  ','s');
    if strcmpi(yn,'y')
        fromEPSG='28992';
        OPT.fromEPSG=fromEPSG;
        [x,y]=convertCoordinates(x,y,'CS1.code',fromEPSG,'CS2.code',4326);
    else
        fromEPSG=input('What is the code of the input coordinates? EPSG: ');
        OPT.fromEPSG=fromEPSG;
        [x,y]=convertCoordinates(x,y,'CS1.code',fromEPSG,'CS2.code',4326);
    end
elseif any([any(x<-180),any(x>180),any(y<-90),any(y>90)])
    disp('Input coordinations are probably not in [Longitude,Latitude] - WGS ''84')
    disp('common EPSG-codes: Amersfoort/RD New: 28992')
    disp('                   Panama           : 32617')
    fromEPSG=input('What is the code of the input coordinates? EPSG: ');
    OPT.fromEPSG=fromEPSG;
    [x,y]=convertCoordinates(x,y,'CS1.code',fromEPSG,'CS2.code',4326);
end
end