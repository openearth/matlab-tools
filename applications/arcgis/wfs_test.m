%WFS_test test for wcs
%
% test using these servers:
% 
% With dimensions
%   1.1.0 4326=?? DescribeCoverage=1 http://geo.vliz.be/geoserver/wfs?service=WFS&request=GetCapabilities
%
%  see also: http://disc.sci.gsfc.nasa.gov/services/ogc_wms

warning('WIP')

 server = 'http://geo.vliz.be/geoserver/wfs?';
 [url,OPT,lims] = wfs('server',server,...
                    'typename','World:worldcities');%,...
                        %'axis',[4 51 5 55]) % swap ??
url
urlwrite(url,[OPT.cachedir,'json.xml']);
%%
F = xml_read([OPT.cachedir,'json.xml'],struct('Str2Num',0,'KeepNS',0))
%%
clear P
P.n   = length(F.featureMembers.worldcities);
P.lon = nan(P.n,1);
P.lat = nan(P.n,1);
P.txt = cell(P.n,1);

for i=1:P.n
    ll = str2num(F.featureMembers.worldcities(i).the_geom.Point.pos);
    P.lon(i) = ll(2);
    P.lat(i) = ll(1);
    P.txt{i} = F.featureMembers.worldcities(i).city_name;
end

plot(P.lon,P.lat,'.')
hold on
text(P.lon,P.lat,P.txt)
