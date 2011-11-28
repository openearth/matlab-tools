function err = getMeteoFromMatroos(meteoname, cycledate, cyclehour, tdummy, xlim, ylim, dirstr)
%GETMETEOFROMMATROOS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   err = getMeteoFromMatroos(meteoname, cycledate, cyclehour, tdummy, xlim, ylim, dirstr)
%
%   Input:
%   meteoname =
%   cycledate =
%   cyclehour =
%   tdummy    =
%   xlim      =
%   ylim      =
%   dirstr    =
%
%   Output:
%   err       =
%
%   Example
%   getMeteoFromMatroos
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
err=[];

try
    
    url='http://matroos.deltares.nl:8080/opendap/maps/normal/knmi_hirlam_maps/';
    
    ncfile=[datestr(cycledate+cyclehour/24,'yyyymmddHHMM') '.nc'];
    
    urlstr=[url ncfile];
    
    sx=nc_varget([url ncfile],'x');
    sy=nc_varget([url ncfile],'y');
    ny=length(sy);
    nx=length(sx);
    
    tdummy=tdummy(1):0.125:tdummy(2);
    
    nt = length(tdummy);
    
    urlasc=[urlstr '.ascii'];
    
    % Available Times
    
    url=[urlasc '?time' '[0:1:' num2str(nt-1) ']'];
    s=urlread(url);
    
    a = strread(s,'%s','delimiter','\n');
    
    b=strread(a{2},'%s','delimiter',',');
    for jj=1:nt
        t0=str2double(b{jj+1});
        t(jj)=datenum(1970,1,1)+t0/1440;
    end
    
    % Longitudes
    
    url=[urlasc '?x' '[0:1:' num2str(nx-1) ']'];
    s=urlread(url);
    
    a = strread(s,'%s','delimiter','\n');
    
    b=strread(a{2},'%s','delimiter',',');
    for jj=1:nx
        x(jj)=str2double(b{jj+1});
    end
    dx=(x(end)-x(1))/(nx-1);
    x=x(1):dx:x(end);
    
    % Latitudes
    
    url=[urlasc '?y' '[0:1:' num2str(ny-1) ']'];
    s=urlread(url);
    
    a = strread(s,'%s','delimiter','\n');
    
    b=strread(a{2},'%s','delimiter',',');
    for jj=1:ny
        y(jj)=str2double(b{jj+1});
    end
    dy=(y(end)-y(1))/(ny-1);
    y=y(1):dy:y(end);
    
    
    parstr={'wind_u','wind_v','p'};
    pr={'u','v','p'};
    
    npar=3;
    
    for ipar=1:npar
        
        url=[urlasc '?' parstr{ipar} '[0:1:' num2str(nt-1) '][0:1:' num2str(ny-1) '][0:1:' num2str(nx-1) ']'];
        s=urlread(url);
        a = strread(s,'%s','delimiter','\n');
        
        nl=2;
        for it=1:nt
            for ii=1:ny
                nl=nl+1;
                b=strread(a{nl},'%s','delimiter',',');
                for jj=1:nx
                    d.(pr{ipar})(ii,jj,it)=str2double(b{jj+1});
                end
            end
        end
        
    end
    
    %% Output
    k=0;
    for ii=1:nt
        k=k+1;
        tstr=datestr(t(ii),'yyyymmddHHMMSS');
        for j=1:npar
            s=[];
            s.t=t(ii);
            s.dLon=x(2)-x(1);
            s.dLat=y(2)-y(1);
            s.lon=x;
            s.lat=y;
            s.(pr{j})=squeeze(d.(pr{j})(:,:,k));
            if ~isnan(max(max(s.(pr{j}))))
                fname=[meteoname '.' pr{j} '.' tstr '.mat'];
                disp([dirstr fname]);
                save([dirstr fname],'-struct','s');
            end
        end
    end
    
    
catch
    disp('Something went wrong downloading HIRLAM data ...');
    a=lasterror;
    for i=1:length(a.stack)
        disp(a.stack(i));
    end
end

