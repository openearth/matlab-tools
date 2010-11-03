function convertCoordinates_test_RDNAPTRANS
%convertCoordinates_test_RDNAPTRANS   test convertCoordinates with RDNAPTRANS data points
%
%
%See also: CONVERTCOORDINATES, CONVERTCOORDINATES2_TEST

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       <NAME>
%
%       <EMAIL>	
%
%       <ADDRESS>
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Oct 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

EPSG{1} = load('EPSG');
EPSG{2} = load('EPSG_v7_5');

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

for iEPSG = [1 2];
    [RDx,RDy,OPT] = convertcoordinates(ETRS89toRDNAP(1,2),ETRS89toRDNAP(1,1),EPSG{iEPSG},...
        'CS1.name', 'ETRS89','CS1.type','geographic 2D','CS2.code',28992);
    % from the OPT, several alternative methods for the datum transformation
    % can be retrieved. Try them all
    
    for ii = 1:length(OPT.datum_trans.alt_code );
        [RDx,RDy] = convertcoordinates(ETRS89toRDNAP(:,2),ETRS89toRDNAP(:,1),EPSG{iEPSG},...
            'CS1.name', 'ETRS89','CS1.type','geographic 2D','CS2.code',28992,...
            'datum_trans.code',OPT.datum_trans.alt_code(ii));
        max_error  =  max(((RDx - ETRS89toRDNAP(:,4)).^2+(RDy - ETRS89toRDNAP(:,5)).^2).^.5);
        mean_error = mean(((RDx - ETRS89toRDNAP(:,4)).^2+(RDy - ETRS89toRDNAP(:,5)).^2).^.5);
        
        fprintf(1,'ETRS89 to RD using method % 25s, max error =% 8.4f m, mean error =% 8.4f m. Deprecated = %s\n',...
            OPT.datum_trans.alt_name{ii},max_error,mean_error,OPT.datum_trans.alt_deprecated{ii});
    end
    fprintf('ETRS89 to RD default: % 29s\n\n',OPT.datum_trans.name{1})
end
%% from WGS 84 to RD
for iEPSG = [1 2];
    [RDx,RDy,OPT] = convertcoordinates(ETRS89toRDNAP(1,2),ETRS89toRDNAP(1,1),EPSG{iEPSG},...
        'CS1.name', 'WGS 84','CS1.type','geographic 2D','CS2.code',28992);
    % from the OPT, several alternative methods for the datum transformation
    % can be retrieved. Try them all
    
    for ii = 1:length(OPT.datum_trans.alt_code );
        [RDx,RDy] = convertcoordinates(ETRS89toRDNAP(:,2),ETRS89toRDNAP(:,1),EPSG{iEPSG},...
            'CS1.name', 'WGS 84','CS1.type','geographic 2D','CS2.code',28992,...
            'datum_trans.code',OPT.datum_trans.alt_code(ii));
        max_error  =  max(((RDx - ETRS89toRDNAP(:,4)).^2+(RDy - ETRS89toRDNAP(:,5)).^2).^.5);
        mean_error = mean(((RDx - ETRS89toRDNAP(:,4)).^2+(RDy - ETRS89toRDNAP(:,5)).^2).^.5);
        
        fprintf(1,'WGS 84 to RD using method % 25s, max error =% 8.4f m, mean error =% 8.4f m. Deprecated = %s\n',...
            OPT.datum_trans.alt_name{ii},max_error,mean_error,OPT.datum_trans.alt_deprecated{ii});
    end
    fprintf('WGS 84 to RD default: % 29s\n\n',OPT.datum_trans.name{1})
end

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
 for iEPSG = [1 2];
     [lon,lat,OPT] = convertcoordinates(RDNAPtoETRS89(1,1),RDNAPtoETRS89(1,2),EPSG{iEPSG},...
         'CS2.name', 'ETRS89','CS2.type','geographic 2D','CS1.code',28992);
     % from the OPT, several alternative methods for the datum transformation
     % can be retrieved. Try them all
     
     for ii = 1:length(OPT.datum_trans.alt_code );
         [lon,lat] = convertcoordinates(RDNAPtoETRS89(:,1),RDNAPtoETRS89(:,2),EPSG{iEPSG},...
             'CS2.name', 'ETRS89','CS2.type','geographic 2D','CS1.code',28992,...
             'datum_trans.code',OPT.datum_trans.alt_code(ii));
         max_error  =  max(((lat - RDNAPtoETRS89(:,4)).^2+(lon - RDNAPtoETRS89(:,5)).^2).^.5);
         mean_error = mean(((lat - RDNAPtoETRS89(:,4)).^2+(lon - RDNAPtoETRS89(:,5)).^2).^.5);
         
         fprintf(1,'RD to ETRS89 using method % 25s, max error =% 10.8f deg, mean error =% 10.8f deg. Deprecated = %s\n',...
             OPT.datum_trans.alt_name{ii},max_error,mean_error,OPT.datum_trans.alt_deprecated{ii});
     end
     fprintf('RD to ETRS89 default: % 29s\n\n',OPT.datum_trans.name{1})
 end
 %% from RD to WGS 84
 for iEPSG = [1 2];
     [lon,lat,OPT] = convertcoordinates(RDNAPtoETRS89(1,1),RDNAPtoETRS89(1,2),EPSG{iEPSG},...
         'CS2.name', 'WGS 84','CS2.type','geographic 2D','CS1.code',28992);
     % from the OPT, several alternative methods for the datum transformation
     % can be retrieved. Try them all
     
     for ii = 1:length(OPT.datum_trans.alt_code );
         [lon,lat] = convertcoordinates(RDNAPtoETRS89(:,1),RDNAPtoETRS89(:,2),EPSG{iEPSG},...
             'CS2.name', 'WGS 84','CS2.type','geographic 2D','CS1.code',28992,...
             'datum_trans.code',OPT.datum_trans.alt_code(ii));
         max_error  =  max(((lat - RDNAPtoETRS89(:,4)).^2+(lon - RDNAPtoETRS89(:,5)).^2).^.5);
         mean_error = mean(((lat - RDNAPtoETRS89(:,4)).^2+(lon - RDNAPtoETRS89(:,5)).^2).^.5);
         
         fprintf(1,'RD to WGS 84 using method % 25s, max error =% 10.8f deg, mean error =% 10.8f deg. Deprecated = %s\n',...
             OPT.datum_trans.alt_name{ii},max_error,mean_error,OPT.datum_trans.alt_deprecated{ii});
     end
     fprintf('RD to WGS 84 default: % 29s\n\n',OPT.datum_trans.name{1})
 end
