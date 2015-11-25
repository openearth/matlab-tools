function write_spiderweb_file_delft3d(fname, tc, gridunit, reftime, radius, varargin)
%WRITED3DMETEO  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   writeD3Dmeteo(fname, s, par, quantity, unit, gridunit, reftime, vsn)
%
%   Input:
%   fname    =
%   s        =
%   par      =
%   quantity =
%   unit     =
%   gridunit =
%   reftime  =
%
%
%
%
%   Example
%   writeD3Dmeteo
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: writeD3Dmeteo.m 9300 2013-09-30 14:31:09Z ormondt $
% $Date: 2013-09-30 16:31:09 +0200 (Mon, 30 Sep 2013) $
% $Author: ormondt $
% $Revision: 9300 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/meteo/writeD3Dmeteo.m $
% $Keywords: $

%%

vsn='1.03';

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'version'}
                vsn=varargin{ii+1};
        end
    end
end

ncols=size(tc.track(1).wind_speed,1);
nrows=size(tc.track(1).wind_speed,2);

fid=fopen(fname,'wt');

fprintf(fid,'%s\n',['FileVersion    = ' vsn '                                               # Version of meteo input file, to check if the newest file format is used']);
fprintf(fid,'%s\n','filetype       = meteo_on_spiderweb_grid #from TRACK file: trackfile.trk');
fprintf(fid,'%s\n','NODATA_value   = -999.000');
fprintf(fid,'%s\n',['n_cols         =    ' num2str(ncols) '                                                # Number of columns used for wind datafield']);
fprintf(fid,'%s\n',['n_rows         =    ' num2str(nrows) '                                                # Number of rows used for wind datafield']);
fprintf(fid,'%s\n',['grid_unit      =    ' gridunit]);
fprintf(fid,'%s\n',['spw_radius     =   ' num2str(radius)]);
fprintf(fid,'%s\n','spw_rad_unit   = m');
fprintf(fid,'%s\n','n_quantity     = 3');
fprintf(fid,'%s\n','quantity1      = wind_speed');
fprintf(fid,'%s\n','quantity2      = wind_from_direction');
fprintf(fid,'%s\n','quantity3      = p_drop');
fprintf(fid,'%s\n','unit1          = m s-1');
fprintf(fid,'%s\n','unit2          = degree');
fprintf(fid,'%s\n','unit3          = Pa');

fmt1='%9.2f';
fmt1=[repmat(fmt1,1,ncols) '\n'];
fmt1=repmat(fmt1,1,nrows);

fmt2='%9.2f';
fmt2=[repmat(fmt2,1,ncols) '\n'];
fmt2=repmat(fmt2,1,nrows);

fmt3='%9.2f';
fmt3=[repmat(fmt3,1,ncols) '\n'];
fmt3=repmat(fmt3,1,nrows);

for it=1:length(tc.track)
    tim=1440*(tc.track(it).time-reftime);
    tc.track(it).wind_speed(isnan(tc.track(it).wind_speed))=-999;
    tc.track(it).wind_from_direction(isnan(tc.track(it).wind_from_direction))=-999;
    tc.track(it).pressure_drop(isnan(tc.track(it).pressure_drop))=-999;
    fprintf(fid,'%s\n',['TIME           =   ' num2str(tim,'%10.2f') '   minutes since ' datestr(reftime,'yyyy-mm-dd HH:MM:SS') ' +00:00']);
    fprintf(fid,'%s\n',['x_spw_eye      =     ' num2str(tc.track(it).x) ]);
    fprintf(fid,'%s\n',['y_spw_eye      =     ' num2str(tc.track(it).y) ]);
    fprintf(fid,'%s\n',['pdrop_spw_eye  =     ' num2str(max(max(tc.track(it).pressure_drop))) ]);
    fprintf(fid,fmt1,tc.track(it).wind_speed);
    fprintf(fid,fmt2,tc.track(it).wind_from_direction);
    fprintf(fid,fmt3,tc.track(it).pressure_drop);
end
fclose(fid);
