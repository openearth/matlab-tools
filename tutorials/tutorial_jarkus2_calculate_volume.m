%% get some arbitrary profile data 
% see the previous JarKus tutorial

url         = jarkus_url
id          = nc_varget(url,'id')
transect_nr = find(id==7003800)-1;
year        = nc_varget(url,'time');
year_nr     = find(year == 1966)-1;
xRSP        = nc_varget(url,'cross_shore');
z           = nc_varget(url,'altitude',[year_nr,transect_nr,1],[1,1,-1]);
x    = xRSP(~isnan(z));
z    =    z(~isnan(z));


%% 
jarkus_getVolumeFast(x,z,2,1,100,600,'plot')

result.xold = data.x;
result.zold = data.y;

plotVolume(result, figure);
xlabel('Crossshore distance (m wrt. RSP = 0)')
ylabel('Surface elevation (m wrt. NAP = 0)')
title('Example plot getVolume: seaward and landward boundaries set');

