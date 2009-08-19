%% convert coordinates to RD (Amersfoort)

url         = jarkus_url;
id          = nc_varget(url,'id');
transect_nr = find(id==6001200)-1;
year        = nc_varget(url,'time');
year_nr     = find(year == 1969)-1;
xRSP        = nc_varget(url,'cross_shore');
z           = nc_varget(url,'altitude',[year_nr,transect_nr,0],[1,1,-1]);
x           = xRSP(~isnan(z));
z    =    z(~isnan(z));


%[MKL.xRD,MKL.yRD] = xRSP2xyRD(MKL.x,7,3800);
