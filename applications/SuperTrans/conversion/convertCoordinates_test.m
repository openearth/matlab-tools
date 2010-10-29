function OK = convertCoordinates_test
%CONVERTCOORDINATES_TEST   test convertCoordinates with kadaster data pointy
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

[lon,lat] = convertcoordinates(D.X ,D.Y ,'CS1.code',28992,'CS2.code', 4326);
[X  ,Y  ] = convertcoordinates(D.OL,D.NB,'CS1.code', 4326,'CS2.code',28992);
[X2 ,Y2 ] = convertcoordinates(lon ,lat ,'CS1.code', 4326,'CS2.code',28992); % and back

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

OK = abs(X -D.X) < 0.5 & abs(Y -D.Y) < 0.5 & ...
     abs(X2-D.X) < 0.5 & abs(Y2-D.Y) < 0.5;
