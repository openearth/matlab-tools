function ITHK_KMLicons(x,y,class,icons,offset)

global S

for kk=1:length(icons)
    iconclass(kk) = str2double(icons(kk).class);
end

for jj = 1:length(S.PP.settings.tvec)
    time    = datenum((S.PP.settings.tvec(jj)+S.PP.settings.t0),1,1);
    for ii=2:length(x)-1
        % dunes to KML  
        [lon,lat] = convertCoordinates(x(ii)+offset,y(ii),S.EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
        id = find(iconclass==class(ii,jj));
        OPT.icon = icons(id).url;
        S.PP.output.kml = [S.PP.output.kml ITHK_KMLtextballoon(lon,lat,'icon',OPT.icon,'timeIn',time,'timeOut',time+364)];
    end
end