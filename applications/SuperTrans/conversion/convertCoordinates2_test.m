function OK = convertCoordinates2_test
%CONVERTCOORDINATES2_TEST   test convertCoordinates
%
% This test converts from all systems to GEO-WGS84 and back and it checks than if the output compares well with the input coordinates.
% Results are printed to output file convertCoordinate_errorMessages.txt
%
%See also: CONVERTCOORDINATES, CONVERTCOORDINATES_TEST

MTestCategory.DataAccess;

% Test is shortened to run in 1 minute
% if TeamCity.running
%     TeamCity.ignore('Test takes very long');
%     OK = 1;
%     return;
% end

% load coordinate systems
EPSG = load('EPSG');
codes = EPSG.coordinate_reference_system.coord_ref_sys_code;
kinds = EPSG.coordinate_reference_system.coord_ref_sys_kind;

geo_code = 4326; % 4326 = WGS 84

% create file for printing error messages
pat = fileparts(which('convertCoordinates2_test'));
fid = fopen([pat filesep 'convertCoordinate_errorMessages.txt'],'w');

% preacclocate testresult
testresult = nan(size(codes));

% start loop over all systems
for s = 1:length(codes)
    % check what kind of system this is
    switch kinds{s}
        case {'geographic 2D', 'projected'}
            fprintf(fid,'Code :%-9.0f| Name:%-68s| ',codes(s), EPSG.coordinate_reference_system.coord_ref_sys_name{s});
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
                                
                [x   ,   y]   = convertCoordinates(lon ,lat ,EPSG,'CS1.code', geo_code,'CS2.code', codes(s));
                [lon2,lat2]   = convertCoordinates(x   ,y   ,EPSG,'CS2.code', geo_code,'CS1.code', codes(s));
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
end

fclose(fid);
OK = all(testresult);