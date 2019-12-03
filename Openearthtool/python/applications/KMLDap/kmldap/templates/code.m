%% Run open earth tools settings so we have snctools loaded
oetsettings
url = '${config.get("jarkus.url")}'
nc_dump(url)
ids = nc_varget(url, 'id');
transect_index = find(ids == ${transect.id})-1;
%% Read all the years
year = nc_varget(url,'time')
%% Read all the altitude data for this transect
z = nc_varget(url,'altitude',[0,transect_index,0],[-1,1,-1]);
%% Read all the cross shore distances
cross_shore = nc_varget(url,'cross_shore');
%% Remove nan's
cross_shore_nonan = cross_shore(any(~isnan(z),1));
z_nonan = z(:,any(~isnan(z),1));
%% Create a plot.
surf(z_nonan)
shading flat
