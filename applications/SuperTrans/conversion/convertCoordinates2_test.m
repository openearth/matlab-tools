function OK = convertCoordinates2_test
%CONVERTCOORDINATES2_TEST   test convertCoordinates
%
% This test converts from all systems to GEO-WGS84 and back and it checks than if the output compares well with the input coordinates.
% Results are printed to output file convertCoordinate_errorMessages.txt
%
%See also: CONVERTCOORDINATES, CONVERTCOORDINATES_TEST

MTestCategory.DataAccess;

% load coordinate systems
load('EPSG_v7_5');
codes = coordinate_reference_system.coord_ref_sys_code;
kinds = coordinate_reference_system.coord_ref_sys_kind;

geo_wgs84_code = 4326;

% test coordinates for geographic systems
lon = 05+24/60+02.5391/3600;
lat = 53+25/60+13.2124/3600;

% test coordinates for projected systems
x = 100000;
y = 100000;

% create file for printing error messages
pat = fileparts(which('convertCoordinates2_test'))
fid = fopen([pat filesep 'convertCoordinate_errorMessages.txt'],'w');

% preacclocate testresult
testresult = nan(size(codes));

% start loop over all systems
for s = 1:length(codes)
% check what kind of system this is
    switch kinds{s}
        case 'geographic 2d'
        try
            [lon2,lat2] = convertcoordinates(lon ,lat ,'CS1.code',codes(s),'CS2.code', 4326);
            [lon3,lat3] = convertcoordinates(lon2 ,lat2 ,'CS1.code', 4326,'CS2.code',codes(s));
            testresult(s) = abs(lon - lon3) < 0.0001 & abs(lat -lat3) < 0.0001;
            fprintf(fid,'%s\n',['Converting using system ' coordinate_reference_system.coord_ref_sys_name{s} ', with code ' num2str(codes(s)) ':']);
            if testresult(s)
                fprintf(fid,'%s\n\n','Test result is OK!');
            else
                fprintf(fid,'%s\n\n',['Test result is not OK: diff(lon) = ' num2str(abs(lon-lon3)) ' deg and diff(lat) = ' num2str(abs(lat-lat3)) ' deg']);
            end
        catch
            testresult(s) = nan;
            fprintf(fid,'%s\n',['Error using system ' coordinate_reference_system.coord_ref_sys_name{s} ', with code ' num2str(codes(s)) ':']);
            fprintf(fid,'%s\n\n',lasterr);
        end
        case 'projected'
        try
            [lon2,lat2] = convertcoordinates(x ,y ,'CS1.code',codes(s),'CS2.code', 4326);
            [x3,y3]     = convertcoordinates(lon2 ,lat2 ,'CS1.code', 4326,'CS2.code',codes(s));
            testresult(s) = abs(x - x3) < 10 & abs(y -y3) < 10;
            fprintf(fid,'%s\n',['Converting using system ' coordinate_reference_system.coord_ref_sys_name{s} ', with code ' num2str(codes(s)) ':']);
            if testresult(s)
                fprintf(fid,'%s\n\n','Test result is OK!');
            else
                fprintf(fid,'%s\n\n',['Test result is not OK: diff(x) = ' num2str(abs(x-x3)) ' m and diff(y) = ' num2str(abs(y-y3)) ' m']);
            end

        catch
            testresult(s) = nan;
            fprintf(fid,'%s\n',['Error using system ' coordinate_reference_system.coord_ref_sys_name{s} ', with code ' num2str(codes(s)) ':']);
            fprintf(fid,'%s\n\n',lasterr);
        end
    end
end

fclose(fid);
OK = all(testresult);