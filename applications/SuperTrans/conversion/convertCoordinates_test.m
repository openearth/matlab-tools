function OK = convertCoordinates2_test
%CONVERTCOORDINATES2_TEST   test convertCoordinates
%

%
%See also: CONVERTCOORDINATES, CONVERTCOORDINATES_TEST

MTestCategory.DataAccess;

% Test is shortened to run in 1 minute
% if TeamCity.running
%     TeamCity.ignore('Test takes very long');
%     OK = 1;
%     return;
% end
EPSG        = load('EPSG');
OK(1)       = test1(EPSG);
OK(2)       = test2(EPSG);
OK(3)       = test3(EPSG);
OK          = all(OK);

function OK = test1(EPSG)
% This test converts from all systems to GEO-WGS84 and back and it checks than if the output compares well with the input coordinates.
% Results are printed to output file convertCoordinate_errorMessages.txt
% The succes criteria is that this goes well on at least 75% of the
% conversions

% load coordinate systems
codes       = EPSG.coordinate_reference_system.coord_ref_sys_code;
kinds       = EPSG.coordinate_reference_system.coord_ref_sys_kind;
deprecated  = EPSG.coordinate_reference_system.deprecated;
names       = EPSG.coordinate_reference_system.coord_ref_sys_name;
% only check non-deprecated geographic 2D and projected sytems, ignore
% others
codes = codes(ismember(kinds,{'geographic 2D', 'projected'}) & strcmpi(deprecated,'FALSE'));
names = names(ismember(kinds,{'geographic 2D', 'projected'}) & strcmpi(deprecated,'FALSE'));

geo_code = 4326; % 4326 = WGS 84

% create file for printing error messages
pat = fileparts(which('convertCoordinates2_test'));
fid = fopen([pat filesep 'convertCoordinate_errorMessages.txt'],'w');

% preacclocate testresult
testresult = nan(size(codes));

% start loop over all systems
for s = 1:length(codes)
    fprintf(fid,'Code :%-9.0f| Name:%-68s| ',codes(s), names{s});
    try
        % try conversion at the center and the limits of the
        % area_of_use (area where coordinate system should be valid)
        
        ind           = find(EPSG.coordinate_reference_system.coord_ref_sys_code == codes(s),1,'first');
        ind           = find(EPSG.area.area_code == EPSG.coordinate_reference_system.area_of_use_code(ind),1,'first');
        
        [lat,lon]     = meshgrid(...
            linspace(EPSG.area.area_north_bound_lat(ind),EPSG.area.area_south_bound_lat(ind),3),...
            linspace(EPSG.area.area_east_bound_lon(ind) ,EPSG.area.area_west_bound_lon(ind) ,3));
        lat = lat([5 1 3 7 9]); % center and corners
        lon = lon([5 1 3 7 9]); % center and corners
        
        [x   ,y   , OPT]   = convertCoordinates(lon ,lat ,EPSG,'CS1.code', geo_code,'CS2.code', codes(s),...
            'CS1.UoM.name','degree'); % with 'CS1.UoM.name','degree' the input is forced to be in degrees
        
        [lon2,lat2]        = convertCoordinates(x   ,y   ,EPSG,'CS2.code', geo_code,'CS1.code',codes(s),...
            'CS2.UoM.name','degree',...       % make sure the output is in degree, and the input
            'CS1.UoM.name',OPT.CS2.UoM.name); % is in the same system as the output of the previous conversion   
                 
        testresult(s) = all(abs(lon - lon2) < 0.0001 & abs(lat -lat2) < 0.0001);
        if testresult(s)
            fprintf(fid,'Test result is OK!\n');
        else
            % check if correct at the center
            if abs(lon(1) - lon2(1)) < 0.0001 && lat(1) -lat2(1) < 0.0001
                fprintf(fid,'Test result is OK in center, but not in corners: diff(lon) =%s | diff(lat) =%s \n',sprintf('% 10.4f',lon(:)-lon2(:)), sprintf('% 10.4f',lat(:)-lat2(:)));
            else
                fprintf(fid,'Test result is not OK: diff(lon) =%s | diff(lat) =%s \n',sprintf('% 10.4f',lon(:)-lon2(:)), sprintf('% 10.4f',lat(:)-lat2(:)));
            end
        end
    catch
        testresult(s) = nan;
        fprintf(fid,'%s\n',strrep(lasterr,char(10),' '));
    end
end

fprintf(fid,'\nTotal score: %-4.1f%% passed this simple test',sum(testresult==1)/numel(testresult)*100);

fclose(fid);

OK = sum(testresult==1)/numel(testresult)*100 > 75;

function OK = test2(EPSG)
% test to see if unit conversions work

geo_code = 4326; % 4326 = WGS 84

lon = [-116.5950 -115.0000 -118.1900 -115.0000 -118.1900];
lat =[   38.5000   41.0000   41.0000   36.0000   36.0000];
        
[x1,y1]   = convertCoordinates(lon ,lat ,EPSG,'CS1.code', geo_code,...
    'CS2.name', 'NAD83(NSRS2007) / Nevada Central'); 

[x2,y2]   = convertCoordinates(lon ,lat ,EPSG,'CS1.code', geo_code,...
    'CS2.name', 'NAD83(NSRS2007) / Nevada Central (ft US)',...
    'CS2.UoM.name','metre'); % with 'CS2.UoM.name', the output is forced to be in metres
OK = all(x1-x2 < 0.001) && all(y1-y2 < 0.001);

function OK = test3(EPSG)
%%Van een Kernnetpunt
%  https://rdinfo.kadaster.nl/?inhoud=/rd/info.html%23publicatie&navig=/rd/nav_serverside.html%3Fscript%3D1
%  https://rdinfo.kadaster.nl/pics/publijst2.gif

D.Puntnummer        = '019111';
D.Actualiteitsdatum = datenum(1999,6,1);
D.Nr                = 17;
D.X                 = 155897.26;
D.Y                 = 603783.39;
D.H                 = 3.7;
D.NB                = 53+25/60+13.2124/3600;
D.OL                = 05+24/60+02.5391/3600;
D.h                 = 44.83;

[lon,lat] = convertCoordinates(D.X ,D.Y ,EPSG,'CS1.code',28992,'CS2.code', 4326);
[X  ,Y  ] = convertCoordinates(D.OL,D.NB,EPSG,'CS1.code', 4326,'CS2.code',28992);
[X2 ,Y2 ] = convertCoordinates(lon ,lat ,EPSG,'CS1.code', 4326,'CS2.code',28992); % and back

% WGS84 and ETRS89 are not identical. WGS84 is < 1 m accurate
% The difference in 2004 is say 35 centimeter, see http://www.rdnap.nl/stelsels/stelsels.html
% So for testing less < 0.5 m error is OK.

% num2str(D.OL - lon) check projection onesided
% num2str(D.NB - lat)
% 
% num2str(D.X - X)    check projection onesided
% num2str(D.Y - Y)
% 
% num2str(D.X - X2)   check projection twosided: internal consistensy
% num2str(D.Y - Y2)

OK = abs(D.OL - lon) < 1e-5 & abs(D.NB - lat) < 1e-5 & ...
     abs(X -D.X)     < 0.5  & abs(Y -D.Y)     < 0.5  & ...
     abs(X2-D.X)     < 0.5  & abs(Y2-D.Y)     < 0.5;


