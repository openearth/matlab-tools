addpath mexnc
addpath snctools
javaaddpath ( './toolsUI-2.2.22.jar' )
setpref ('SNCTOOLS', 'USE_JAVA', true); % this requires SNCTOOLS 2.4.8 or better


%%remote file
info = nc_info('http://iridl.ldeo.columbia.edu/SOURCES/.WORLDBATH432/.bath/dods');

x = nc_varget('http://iridl.ldeo.columbia.edu/SOURCES/.WORLDBATH432/.bath/dods', 'X');
X = repmat(x,1,217)';
y = nc_varget('http://iridl.ldeo.columbia.edu/SOURCES/.WORLDBATH432/.bath/dods', 'Y');
Y = repmat(y, 1,432);
bath = nc_varget('http://iridl.ldeo.columbia.edu/SOURCES/.WORLDBATH432/.bath/dods', 'bath');
Z = bath;
% Set up axes
axesm ('globe','Grid', 'on');
view(60,60)
axis off
% Display a surface
% load geoid
% meshm(Z,[(427)/360 90 0], [427 227], Z);
% geoshow(y, x, Z, 'DisplayType', 'surface')
% surfm(y,x,geoid,bath/100000)
% plot3m(x,y,bath/10000)
surfacem(Y,X,Z,Z/100000);


yearArray = nc_varget('output.nc', 'year');
seawardDistanceArray =  nc_varget('output.nc', 'seaward_distance');
idArray =  nc_varget('output.nc', 'id');

% for i = 1:length(yearArray)
%     year = yearArray(i);
%     h = nc_varget('output.nc', 'height', [i-1, 0, 0], [1, length(idArray), length(seawardDistanceArray)]);
%     image(squeeze(h));
%     pause(5)
% end


find(yearArray == 2004);
find(idArray == 7003800);
X = nc_varget('output.nc', 'x');
Y = nc_varget('output.nc', 'y');

for i = 1:length(yearArray)
    year = yearArray(i);
    d = readTransectDataNetcdf('output.nc', 3000380, year);
    plot(d.x,  d.height);
    pause(1);
end

% d = readTransectdata('JARKUS data', 'Noord-Holland', '03800', '2004')


x = 1:20000;
y = 1:20000;

x_index = find(x >= 1000 & x < 1020);
y_index = find(x >= 1380 & x < 1400);

h = randn(2000,2000);

h(x_index, y_index)
