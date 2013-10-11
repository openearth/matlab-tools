function tc = readBestTrackJTWC(fname)
%READBESTTRACKJTWC  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   tc = readBestTrackJTWC(fname)
%
%   Input:
%   fname =
%
%   Output:
%   tc    =
%
%   Example
%   readBestTrackJTWC
%
%   See also

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
% Reads JTWC best track file and returns Matlab structure

name='unknown';
goon=1;
k=0;
%% Read file
fid=fopen(fname,'r');
while goon
    s=fgetl(fid);
    if s==-1
        break
    end
    a = strread(s,'%s','delimiter',',');
    for n=1:length(a)
        k=k+1;
        str{k}=a{n};
    end
end
fclose(fid);

k=0;
for i=1:length(str)
    switch str{i}
        case{'WP','IO','SH','CP','EP','AL'}
%    if strcmpi(str{i},'WP')
        % New line
        k=k+1;
        iline(k)=i;
    end
end
iline(k+1)=length(str)+1;
for i=1:length(iline)-1
    nstr=iline(i+1)-iline(i);
    for j=1:nstr
        line(i).str{j}=str{iline(i)+j-1};
    end
end

nrlines=length(line);

for i=1:nrlines
    t(i)=datenum(line(i).str{3},'yyyymmddHH');
    lat(i)=str2double(line(i).str{7}(1:end-1))/10;
    if line(i).str{7}(end)=='S'
        lat(i)=lat(i)*-1;
    end
    lon(i)=str2double(line(i).str{8}(1:end-1))/10;
    if line(i).str{8}(end)=='W'
        lon(i)=lon(i)*-1;
    end
    vmax(i)=str2double(line(i).str{9});
    p(i)=-999;
    cat{i}=-999;
    vr(i)=-999;
    r1(i)=-999;
    r2(i)=-999;
    r3(i)=-999;
    r4(i)=-999;
    rmax(i)=-999;
    if length(line(i).str)==10
        p(i)=str2double(line(i).str{10})*100;
    elseif length(line(i).str)==11
        p(i)=str2double(line(i).str{10})*100;
        cat{i}=line(i).str{11};
    elseif length(line(i).str)>11
        p(i)=str2double(line(i).str{10})*100;
        cat{i}=line(i).str{11};
        vr(i)=str2double(line(i).str{12});
        r1(i)=str2double(line(i).str{14});
        r2(i)=str2double(line(i).str{15});
        r3(i)=str2double(line(i).str{16});
        r4(i)=str2double(line(i).str{17});
        if length(line(i).str)>=20
            rmax(i)=str2double(line(i).str{20});
        else
            rmax(i)=-999;
        end
        if length(line(i).str)>=28
            name=line(i).str{28};
        end
    end
end

k=1;
tc.r34(k,:)=[-999 -999 -999 -999];
tc.r50(k,:)=[-999 -999 -999 -999];
tc.r64(k,:)=[-999 -999 -999 -999];
tc.r100(k,:)=[-999 -999 -999 -999];

for i=1:nrlines
    if i>1
        if abs(t(i)-t(i-1))>0.001
            % New time
            k=k+1;
            tc.r34(k,1:4)=[-999 -999 -999 -999];
            tc.r50(k,1:4)=[-999 -999 -999 -999];
            tc.r64(k,1:4)=[-999 -999 -999 -999];
            tc.r100(k,1:4)=[-999 -999 -999 -999];
        end
    end
    tc.time(k)=t(i);
    tc.lon(k)=lon(i);
    tc.lat(k)=lat(i);
    tc.vmax(k,1:4)=vmax(i);
    tc.p(k,1:4)=p(i);
    tc.cat{k}=cat{i};
    if vr(i)>0
        rstr=['r' num2str(vr(i))];
        tc.(rstr)(k,1)=r1(i);
        tc.(rstr)(k,2)=r2(i);
        tc.(rstr)(k,3)=r3(i);
        tc.(rstr)(k,4)=r4(i);
    end
    tc.rmax(k,1:4)=rmax(i);
end

tc.name=name;


