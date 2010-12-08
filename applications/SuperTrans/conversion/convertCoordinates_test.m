function OK = convertCoordinates_test
%CONVERTCOORDINATES2_TEST   test convertCoordinates
% 
% Several tests to check the coordinate conversion routines. 
% The EPSG database s loaded only once for speed. Not all tests have a hard
% criterium, the first tests passes if only 75% percent of operations
% succeed. 
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
OK(4)       = test4(EPSG);
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

function OK = test4(EPSG)
%% comparison with RDNAPTRANS reference coordinates

% Errors should be smaller than maximum the distortion in the RD system,
% which is less than 25 cm.  
% To convert coordinates including the distortion in the RD grid a
% dedicated program with the distortion grid must be used, such as
% RDNAPTRANS

%from: http://www.kadaster.nl/index_frames.html?inhoud=/rijksdriehoeksmeting/homepage.html&navig=/rijksdriehoeksmeting/nav_serverside.html%3Fscript%3D1
% Appendix		RDNAPTRANSTM2008 test sheet 
% 
% The RDNAPTRANSTM2008 procedure should be tested in both directions. 
% The differences with the coordinates listed below should not exceed:
% RD x and y coordinates:			0.001 meters
% NAP heights and ETRS89 ellipsoidal heights:	0.001 meters
% ETRS89 latitude and longitude:			0.00000001 degrees
% 
% From ETRS89 to RD/NAP
%                         |-----------ETRS89--------------------|--------------RD/NAP----------------|                 		
% No.   Name              | latitude (°)  longitude (°)  h (m)  |      x (m)        y (m)    NAP (m) |
% 01    Texel             | 53.160753042  4.824761912   42.8614 | 117380.1200  575040.3400    1.0000 |
% 02    Noord-Groningen   | 53.419482050  6.776726674   42.3586 | 247380.5600  604580.7800    2.0000 |
% 03    Amersfoort        | 52.155172897  5.387203657   43.2551 | 155000.0000  463000.0000    0.0000 |
% 04    Amersfoort 100m   | 52.155172910  5.387203658  143.2551 | 155000.0000  463000.0000  100.0000 |
% 05    Zeeuws-Vlaanderen | 51.368607152  3.397588595   47.4024 |  16460.9100  377380.2300    3.0000 |
% 06    Zuid-Limburg      | 50.792584916  5.773795548  245.9478 | 182260.4500  311480.6700  200.0000 |
% 07    Maasvlakte        | 51.947393898  4.072887101   47.5968 |  64640.8900  440700.0101    4.0000 |
% 08*   outside           | 48.843030210  8.723260235   52.0289 | 400000.2300  100000.4500    5.0000 |
% 09*   no_rd&geoid       | 50.687420392  4.608971813   51.6108 | 100000.6700  300000.8900    6.0000 |
% 10*   no_geoid          | 51.136825197  4.601375361   50.9672 | 100000.6700  350000.8900    6.0000 |
% 11*   no_rd             | 52.482440839  4.268403889   49.9436 |  79000.0100  500000.2300    7.0000 |
% 12*   edge_rd           | 51.003976532  3.891247830   52.7427 |  50000.4500  335999.6700    8.0000 |
% 

ETRS89toRDNAP = [
    53.160753042  4.824761912   42.8614  117380.1200  575040.3400    1.0000
    53.419482050  6.776726674   42.3586  247380.5600  604580.7800    2.0000
    52.155172897  5.387203657   43.2551  155000.0000  463000.0000    0.0000
    52.155172910  5.387203658  143.2551  155000.0000  463000.0000  100.0000
    51.368607152  3.397588595   47.4024   16460.9100  377380.2300    3.0000
    50.792584916  5.773795548  245.9478  182260.4500  311480.6700  200.0000
    51.947393898  4.072887101   47.5968   64640.8900  440700.0101    4.0000
    48.843030210  8.723260235   52.0289  400000.2300  100000.4500    5.0000
    50.687420392  4.608971813   51.6108  100000.6700  300000.8900    6.0000
    51.136825197  4.601375361   50.9672  100000.6700  350000.8900    6.0000
    52.482440839  4.268403889   49.9436   79000.0100  500000.2300    7.0000
    51.003976532  3.891247830   52.7427   50000.4500  335999.6700    8.0000
    ];


%% from ETRS 89 to RD

    [RDx,RDy,OPT] = convertcoordinates(ETRS89toRDNAP(1,2),ETRS89toRDNAP(1,1),EPSG,...
        'CS1.name', 'ETRS89','CS1.type','geographic 2D','CS2.code',28992);
    % from the OPT, several alternative methods for the datum transformation
    % can be retrieved. Try them all
    max_error = [];
    for ii = 1:length(OPT.datum_trans.alt_code );
        
        [RDx,RDy] = convertcoordinates(ETRS89toRDNAP(:,2),ETRS89toRDNAP(:,1),EPSG,...
            'CS1.name', 'ETRS89','CS1.type','geographic 2D','CS2.code',28992,...
            'datum_trans.code',OPT.datum_trans.alt_code(ii));
        max_error(end+1)  =  max(((RDx - ETRS89toRDNAP(:,4)).^2+(RDy - ETRS89toRDNAP(:,5)).^2).^.5);
        % mean_error = mean(((RDx - ETRS89toRDNAP(:,4)).^2+(RDy - ETRS89toRDNAP(:,5)).^2).^.5);

        % fprintf(1,'ETRS89 to RD using method % 25s, max error =% 8.4f m, mean error =% 8.4f m. Deprecated = %s\n',...
        %    OPT.datum_trans.alt_name{ii},max_error,mean_error,OPT.datum_trans.alt_deprecated{ii});
    end
    
    % fprintf('ETRS89 to RD default: % 29s\n\n',OPT.datum_trans.name{1})
    
    % OK is if all conversions give a max error smaller than 25cm
    OK(1) = all(max_error < 0.25);
%% from WGS 84 to RD

    [RDx,RDy,OPT] = convertcoordinates(ETRS89toRDNAP(1,2),ETRS89toRDNAP(1,1),EPSG,...
        'CS1.name', 'WGS 84','CS1.type','geographic 2D','CS2.code',28992);
    % from the OPT, several alternative methods for the datum transformation
    % can be retrieved. Try them all
    max_error = [];
    for ii = 1:length(OPT.datum_trans.alt_code );
        [RDx,RDy] = convertcoordinates(ETRS89toRDNAP(:,2),ETRS89toRDNAP(:,1),EPSG,...
            'CS1.name', 'WGS 84','CS1.type','geographic 2D','CS2.code',28992,...
            'datum_trans.code',OPT.datum_trans.alt_code(ii));
        max_error(end+1)  =  max(((RDx - ETRS89toRDNAP(:,4)).^2+(RDy - ETRS89toRDNAP(:,5)).^2).^.5);
%         mean_error = mean(((RDx - ETRS89toRDNAP(:,4)).^2+(RDy - ETRS89toRDNAP(:,5)).^2).^.5);
%         
%         fprintf(1,'WGS 84 to RD using method % 25s, max error =% 8.4f m, mean error =% 8.4f m. Deprecated = %s\n',...
%             OPT.datum_trans.alt_name{ii},max_error,mean_error,OPT.datum_trans.alt_deprecated{ii});
    end
%     fprintf('WGS 84 to RD default: % 29s\n\n',OPT.datum_trans.name{1})

% OK is if all but the first conversion give a max error smaller than 25cm
OK(2) = all(max_error(2:end) < 0.25);

%% From RD/NAP to ETRS89
% 
% No.    Name    RD/NAP            ETRS89
%                         |-----------ETRS89-------------------|--------------RD/NAP------------------|
%                         |      x (m)        y (m)    NAP (m) | latitude (°)  longitude (°)   h (m)  |
% 01    Texel             | 117380.1200  575040.3400    1.0000 | 53.160753042   4.824761912   42.8614 |
% 02    Noord-Groningen   | 247380.5600  604580.7800    2.0000 | 53.419482050   6.776726674   42.3586 |
% 03    Amersfoort        | 155000.0000  463000.0000    0.0000 | 52.155172897   5.387203657   43.2551 |
% 04    Amersfoort_100m   | 155000.0000  463000.0000  100.0000 | 52.155172910   5.387203658  143.2551 |
% 05    Zeeuws-Vlaanderen |  16460.9100  377380.2300    3.0000 | 51.368607152   3.397588595   47.4024 |
% 06    Zuid-Limburg      | 182260.4500  311480.6700  200.0000 | 50.792584916   5.773795548  245.9478 |
% 07    Maasvlakte        |  64640.8900  440700.0100    4.0000 | 51.947393898   4.072887101   47.5968 |
% 08*   outside           | 400000.2300  100000.4500    5.0000 | 48.843030210   8.723260235   52.0289 |
% 09*   no_rd&geoid       | 100000.6700  300000.8900    6.0000 | 50.687420392   4.608971813   51.6108 |
% 10*   no_geoid          | 100000.6700  350000.8900    6.0000 | 51.136825197   4.601375361   50.9672 |
% 11*   no_rd             |  79000.0100  500000.2300    7.0000 | 52.482440839   4.268403889   49.9436 |
% 12*   edge_rd           |  50000.4500  335999.6700    8.0000 | 51.003976532   3.891247830   52.7427 |
% 							      
% 
% *) Points 08 - 12 are outside the region where interpolation between either the NLGEO2004 geoid or the RD correction grid points is possible. If coordinates are computed for these points, the output should be accompanied by a warning.


RDNAPtoETRS89 = [
	117380.1200  575040.3400    1.0000  53.160753042   4.824761912   42.8614
	247380.5600  604580.7800    2.0000  53.419482050   6.776726674   42.3586
	155000.0000  463000.0000    0.0000  52.155172897   5.387203657   43.2551
	155000.0000  463000.0000  100.0000  52.155172910   5.387203658  143.2551
	 16460.9100  377380.2300    3.0000  51.368607152   3.397588595   47.4024
	182260.4500  311480.6700  200.0000  50.792584916   5.773795548  245.9478
	 64640.8900  440700.0100    4.0000  51.947393898   4.072887101   47.5968
	400000.2300  100000.4500    5.0000  48.843030210   8.723260235   52.0289
	100000.6700  300000.8900    6.0000  50.687420392   4.608971813   51.6108
	100000.6700  350000.8900    6.0000  51.136825197   4.601375361   50.9672
	 79000.0100  500000.2300    7.0000  52.482440839   4.268403889   49.9436
	 50000.4500  335999.6700    8.0000  51.003976532   3.891247830   52.7427
	 ];

 %% from RD to ETRS89

     [lon,lat,OPT] = convertcoordinates(RDNAPtoETRS89(1,1),RDNAPtoETRS89(1,2),EPSG,...
         'CS2.name', 'ETRS89','CS2.type','geographic 2D','CS1.code',28992);
     % from the OPT, several alternative methods for the datum transformation
     % can be retrieved. Try them all
     max_error = [];
     for ii = 1:length(OPT.datum_trans.alt_code );
         [lon,lat] = convertcoordinates(RDNAPtoETRS89(:,1),RDNAPtoETRS89(:,2),EPSG,...
             'CS2.name', 'ETRS89','CS2.type','geographic 2D','CS1.code',28992,...
             'datum_trans.code',OPT.datum_trans.alt_code(ii));
         max_error(end+1)  =  max(((lat - RDNAPtoETRS89(:,4)).^2+(lon - RDNAPtoETRS89(:,5)).^2).^.5);
%          mean_error = mean(((lat - RDNAPtoETRS89(:,4)).^2+(lon - RDNAPtoETRS89(:,5)).^2).^.5);
         
%          fprintf(1,'RD to ETRS89 using method % 25s, max error =% 10.8f deg, mean error =% 10.8f deg. Deprecated = %s\n',...
%              OPT.datum_trans.alt_name{ii},max_error,mean_error,OPT.datum_trans.alt_deprecated{ii});
     end
%      fprintf('RD to ETRS89 default: % 29s\n\n',OPT.datum_trans.name{1})

OK(3) = all(max_error < 1e-5);

 %% from RD to WGS 84

     [lon,lat,OPT] = convertcoordinates(RDNAPtoETRS89(1,1),RDNAPtoETRS89(1,2),EPSG,...
         'CS2.name', 'WGS 84','CS2.type','geographic 2D','CS1.code',28992);
     % from the OPT, several alternative methods for the datum transformation
     % can be retrieved. Try them all
     max_error = [];
     for ii = 1:length(OPT.datum_trans.alt_code );
         [lon,lat] = convertcoordinates(RDNAPtoETRS89(:,1),RDNAPtoETRS89(:,2),EPSG,...
             'CS2.name', 'WGS 84','CS2.type','geographic 2D','CS1.code',28992,...
             'datum_trans.code',OPT.datum_trans.alt_code(ii));
         max_error(end+1)  =  max(((lat - RDNAPtoETRS89(:,4)).^2+(lon - RDNAPtoETRS89(:,5)).^2).^.5);
%          mean_error = mean(((lat - RDNAPtoETRS89(:,4)).^2+(lon - RDNAPtoETRS89(:,5)).^2).^.5);
%          
%          fprintf(1,'RD to WGS 84 using method % 25s, max error =% 10.8f deg, mean error =% 10.8f deg. Deprecated = %s\n',...
%              OPT.datum_trans.alt_name{ii},max_error,mean_error,OPT.datum_trans.alt_deprecated{ii});
     end
%      fprintf('RD to WGS 84 default: % 29s\n\n',OPT.datum_trans.name{1})
% OK is if all but the first conversion give a max error smaller 1e-5
OK(4) = all(max_error(2:end) < 1e-5);

%% 
OK = all(OK);