function ITHK_kmlicons(x,y,class,icons,offset)

global S

for kk=1:length(icons)
    iconclass(kk) = str2double(icons(kk).class);
end

%EPSG = load('EPSG.mat');
for jj = 1:length(S.PP.settings.tvec)
    time    = datenum((S.PP.settings.tvec(jj)+S.PP.settings.t0),1,1);
    for ii=2:length(x)-1
        % dunes to KML  
        [londune,latdune] = convertCoordinates(x(ii)+offset,y(ii)-offset/2,S.EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
        id = find(iconclass==class(ii,jj));
        OPT.icon = icons(id).url;
%         if      S.PP.dunes.duneclassRough(ii,jj)==1
%                 OPT.icon = 'http://viewer.openearth.nl/images/dunes_red.png';
%         elseif  S.PP.dunes.duneclassRough(ii,jj)==2
%                 OPT.icon = 'http://viewer.openearth.nl/images/dunes_orange.png';
%         else    OPT.icon = 'http://viewer.openearth.nl/images/dunes_green.png';
%         end
        S.PP.output.kml = [S.PP.output.kml ITHK_KML_textballoon(londune,latdune,'icon',OPT.icon,'timeIn',time,'timeOut',time+364)];
    end
end