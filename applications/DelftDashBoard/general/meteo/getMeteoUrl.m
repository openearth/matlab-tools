function urlstr = getMeteoUrl(meteosource,cycledate,cyclehour,varargin)
%GETMETEOURL  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = getMeteoUrl(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   getMeteoUrl
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 <COMPANY>
%       Wiebe de Boer
%
%       <EMAIL>
%
%       <ADDRESS>
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
% Created: 11 Oct 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
% OPT.keyword=value;
% OPT = setproperty(OPT,varargin{:});
% 
% if nargin==0;
%     varargout = OPT;
%     return;
% end
%% code
switch lower(meteosource)
    case{'ncep_gfs_analysis'}
        urlstr='http://nomads.ncdc.noaa.gov/dods/NCEP_GFS_ANALYSIS/analysis_complete';
    case{'ncep_gfs'}
        urlstr=['http://nomads.ncdc.noaa.gov/dods/NCEP_GFS/' datestr(cycledate,'yyyymm') '/' datestr(cycledate,'yyyymmdd') '/gfs_3_' datestr(cycledate,'yyyymmdd')  '_' num2str(cyclehour,'%0.2i') '00_fff'];
    case{'gfs1p0'}
        urlstr=['http://nomads.ncep.noaa.gov:9090/dods/gfs/gfs' datestr(cycledate,'yyyymmdd') '/gfs_' num2str(cyclehour,'%0.2i') 'z'];
    case{'gfs0p5'}
        urlstr=['http://nomads.ncep.noaa.gov:9090/dods/gfs_hd/gfs_hd' datestr(cycledate,'yyyymmdd') '/gfs_hd_' num2str(cyclehour,'%0.2i') 'z'];
    case{'nam'}
        urlstr=['http://nomads.ncep.noaa.gov:9090/dods/nam/nam' datestr(cycledate,'yyyymmdd') '/nam_' num2str(cyclehour,'%0.2i') 'z'];
    case{'gdas'}
        if year(now)~=year(cycledate)
            ystr=num2str(year(cycledate));
            mstr=num2str(month(cycledate),'%0.2i');
            dr=[ystr mstr '/'];
            extstr='';
        else
            dr='';
            extstr='.grib2';
        end
        urlstr=['http://nomad3.ncep.noaa.gov:9090/dods/gdas/rotating/' dr 'gdas' datestr(cycledate,'yyyymmdd')  num2str(cyclehour,'%0.2i') extstr];
%        urlstr=['http://nomad3.ncep.noaa.gov:9090/pub/gdas/rotating/' dr 'gdas' datestr(cycledate,'yyyymmdd')  num2str(cyclehour,'%0.2i') extstr];
    case{'ncep_nam'}
        ystr=num2str(year(cycledate));
        mstr=num2str(month(cycledate),'%0.2i');
        dr=[ystr mstr '/'];
        urlstr=['http://nomads.ncdc.noaa.gov/dods/NCEP_NAM/' dr datestr(cycledate,'yyyymmdd') '/nam_218_' datestr(cycledate,'yyyymmdd') '_' num2str(cyclehour,'%0.2i') '00_fff'];
    case{'ncepncar_reanalysis'}
        urlstr='http://nomad3.ncep.noaa.gov:9090/dods/reanalyses/reanalysis-1/6hr/grb2d/grb2d';
    case{'ncep_nam_analysis'}
        urlstr='http://nomads.ncdc.noaa.gov/dods/NCEP_NAM_ANALYSIS/Anl_Complete';
    case{'ncep_nam_analysis_precip'}
        urlstr='http://nomads.ncdc.noaa.gov/dods/NCEP_NAM_ANALYSIS/3hr_Pcp';
    case{'ncep_gfs_analysis_precip'}
        urlstr='http://nomads.ncdc.noaa.gov/dods/NCEP_GFS_ANALYSIS/3hrPrecip';
    case{'hirlam'}
        url='http://matroos.deltares.nl:8080/opendap/maps/normal/knmi_hirlam_maps/';
        ncfile=[datestr(cycledate+cyclehour/24,'yyyymmddHHMM') '.nc'];
        urlstr=[url ncfile];
end
