function tc = readBestTrackHURDAT2(fname)
%READBESTTRACKHURDAT2  Reads the best cyclone track from a HURDAT2 file
%
%   Syntax:
%   tc = readBestTrackHURDAT2(fname)
%
%   Input:
%   fname = filename string
%
%   Output:
%   tc    = struct with date, name, meta, time, lon, lat, vmax and p
%
%   Example
%       tc_fname = 'Haiyan_track_unisys.dat'
%       readBestTrackHURDAT2(tc_fname)
%

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2016 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: readBestTrackUnisys.m 11277 2014-10-22 10:03:03Z bartgrasmeijer.x $
% $Date: 2014-10-22 12:03:03 +0200 (Wed, 22 Oct 2014) $
% $Author: bartgrasmeijer.x $
% $Revision: 11277 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/meteo/readBestTrackUnisys.m $
% $Keywords: $

%%
fid=fopen(fname,'r');
tx0=fgets(fid);
v0=strread(tx0,'%s','delimiter',',');
tc.name=v0{2};
tc.basin=v0{1}(1:2);
tc.number=num2str(v0{1}(3:4));
tc.year=num2str(v0{1}(5:8));
it=0;
while 1
    tx0=fgets(fid);
    if tx0==-1
        break
    end
    v0=strread(tx0,'%s','delimiter',',');
    it=it+1;

    str=[v0{1} ' ' v0{2} '00'];
    tc.time(it)=datenum(str,'yyyymmdd HHMMSS');

    tc.record_identifier{it}=v0{3};
    tc.status{it}=v0{4};
        
    if strcmpi(v0{5}(end),'n')
        tc.lat(it)=str2double(v0{5}(1:end-1));
    else
        tc.lat(it)=-str2double(v0{5}(1:end-1));
    end
    if strcmpi(v0{6}(end),'e')
        tc.lon(it)=str2double(v0{6}(1:end-1));
    else
        tc.lon(it)=-str2double(v0{6}(1:end-1));
    end
    tc.vmax(it,1:4)=str2double(v0{7});
    tc.p(it,1:4)=100*str2double(v0{8});
    
    tc.r34(it,1)=str2double(v0{9});
    tc.r34(it,2)=str2double(v0{10});
    tc.r34(it,3)=str2double(v0{11});
    tc.r34(it,4)=str2double(v0{12});

    tc.r50(it,1)=str2double(v0{13});
    tc.r50(it,2)=str2double(v0{14});
    tc.r50(it,3)=str2double(v0{15});
    tc.r50(it,4)=str2double(v0{16});

    tc.r64(it,1)=str2double(v0{17});
    tc.r64(it,2)=str2double(v0{18});
    tc.r64(it,3)=str2double(v0{19});
    tc.r64(it,4)=str2double(v0{20});

    tc.r100(it,1)=-999;
    tc.r100(it,2)=-999;
    tc.r100(it,3)=-999;
    tc.r100(it,4)=-999;
    
end
fclose(fid);

