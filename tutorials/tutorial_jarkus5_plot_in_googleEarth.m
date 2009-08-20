%% plot data in Google Earth
% plotting tols are in the googlePlot toolbox. To see it's contents, use
% help:

help googlePlot

%% 
% 
lat = [70 40 40 70 70];
lon = [4,4,16,16, 4];
z = [1 1 1 1 1]*1e5;
KMLline(lat,lon,z)
%% Plot a Jarkus transect in google earth
% the objective is to plot a jarkus transect in OpenEarth. 

%% 
% extract lat, lon, z, data from the netCDF database. See the read JarKus
% tutorial if this is new to you.

url         = jarkus_url;
id          = nc_varget(url,'id');
transect_nr = find(id==6001200)-1;
year        = nc_varget(url,'time');
year_nr     = find(year == 1979)-1;
lat         = nc_varget(url,'lat',[transect_nr,0],[1,-1]);
lon         = nc_varget(url,'lon',[transect_nr,0],[1,-1]);
z           = nc_varget(url,'altitude',[year_nr,transect_nr,0],[1,1,-1]);



lat = 54:.1:55;
lon = 4:.1:5;
z = 10000*(1+rand(1,11));
KMLline(lat,lon,z)
z([3 6]) = nan

xRSP = 1:11

%%
% we will check the data with matlab line:
line(lat,lon,z)
view([-160 40])
grid on
%% 
% because of the NaN values in data, not al datapoints are connected. We
% can overcome this problem by linear interpolation of z to xRSP.

xRSP        = nc_varget(url,'cross_shore');
not_nan     = ~isnan(z);
zi          = interp1(xRSP(not_nan),z(not_nan),xRSP);

%%
% we will check the data again with matlab line:
line(lat,lon,zi)
view([-160 40])
grid on


%% 
% This works as expected, so now we will plot the data
KMLline(lat,lon',(z'+20).*5,'text',labels,'latText',lat(:,500),'lonText',(lon(:,500)));





url         = jarkus_url;
no_of_trans = 20; 
id          = nc_varget(url,'id');
transect_nr = find(id==6001200)-1;
year        = nc_varget(url,'time');
year_nr     = find(year == 1979)-1;
lat         = nc_varget(url,'lat',[transect_nr,0],[no_of_trans,-1]);
lon         = nc_varget(url,'lon',[transect_nr,0],[no_of_trans,-1]);
z           = nc_varget(url,'altitude',[year_nr,transect_nr,0],[1,no_of_trans,-1]);
xRSP        = nc_varget(url,'cross_shore');
codes       = nc_varget(url,'alongshore',transect_nr,no_of_trans);
labels      = cellstr(num2str(codes));

% interp z to all x values
for ii = 1:size(z,1)
    not_nan = ~isnan(z(ii,:));
    if sum(not_nan)~=0
        z(ii,:) = interp1q(xRSP(not_nan),z(ii,not_nan)',xRSP)';
    end
end

%%
KMLline(lat',lon',(z'+20).*5,'text',labels,'latText',lat(:,500),'lonText',(lon(:,500)));