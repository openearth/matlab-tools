%% plot data in Google Earth
% plotting tols are in the googlePlot toolbox. To see it's contents, use
% help:

help googlePlot

%% Plot a Jarkus transect in google earth

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