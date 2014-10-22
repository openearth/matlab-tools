function tc = readBestTrackUnisys(fname)
%READBESTTRACKUNISYS  Reads the best cyclone track from a Unisys file
%
%   see http://weather.unisys.com/hurricane/ for best track files
%
%   Syntax:
%   tc = readBestTrackUnisys(fname)
%
%   Input:
%   fname = filename string
%
%   Output:
%   tc    = struct with date, name, meta, time, lon, lat, vmax and p
%
%   Example
%       tc_fname = 'Haiyan_track_unisys.dat'
%       readBestTrackUnisys(tc_fname)
%
%   See also writeBestTrackUnisys DelftDashBoard

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
fid=fopen(fname,'r');

n=0;

tx0=fgets(fid);
v0=strread(tx0,'%s','delimiter',' ');
nn=length(v0);
y=str2double(v0{nn});
tc.date = strtrim(tx0);

tx0=fgets(fid);
name=tx0(1:end-1);

tc.name=strtrim(name);

tx0=fgets(fid);
tc.meta = strtrim(tx0);

for i=1:10000
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        v0=strread(tx0,'%s','delimiter',' ');
        lat=str2double(v0{2});
        lon=str2double(v0{3});
        tstr=v0{4};
        vel=str2double(v0{5});
        pr=v0{6};
        if isnan(str2double(pr))
            pr=1012;
        else
            pr=str2double(pr);
        end
        pr=pr*100;
        mm=str2double(tstr(1:2));
        dd=str2double(tstr(4:5));
        hh=str2double(tstr(7:8));
        tnew=datenum(y,mm,dd,hh,0,0);
        if n>1
            % If two identical consecutive times are found, only use the
            % first one!
            if tnew>tc.time(n)+0.001
                n=n+1;
            end
        else
            n=n+1;
        end
        tc.time(n)=tnew;
        tc.lon(n)=lon;
        tc.lat(n)=lat;
        tc.vmax(n,:)=[vel vel vel vel];
        tc.p(n,:)=[pr pr pr pr];
    else
        break;
    end
end

fclose(fid);

