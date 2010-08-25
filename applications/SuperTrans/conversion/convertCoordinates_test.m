function OK = convertCoordinates_test
%CONVERTCOORDINATES_TEST   test convertCoordinates with kadaster data pointy
%
%See also: CONVERTCOORDINATES

%% Van een Kernnetpunt
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

[lon,lat] = convertcoordinates(D.X,D.Y,'CS1.code',28992,'CS2.code', 4326);
[X  ,Y  ] = convertcoordinates(lon,lat,'CS1.code', 4326,'CS2.code',28992); % and back

% WGS84 and ETRS89 are not identical. WGS84 is < 1 m accurate
% The difference in 2004 is say 35 centimeter, see http://www.rdnap.nl/stelsels/stelsels.html
% So for testing less < 0.5 m error is OK.

OK = abs(X-D.X) < 0.5 & ...
     abs(Y-D.Y) < 0.5; 
