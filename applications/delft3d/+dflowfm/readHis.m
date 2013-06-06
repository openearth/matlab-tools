function hisdata = readHis(varargin)
%unstruc.readHis    Read timeseries data from an Unstruc history file.
%   hisdata = unstruc.readHis(filename) reads all station names, locations
%       and waterlevel data into a struct.
%   hisdata = unstruc.readHis(filename, stationname) reads only one
%       specific station into a similar struct.

%   $Id: readHis.m 23738 2012-09-03 12:14:47Z pijl $

filename = varargin{1};

if nargin >= 2
    statname = varargin{2};
else
    statname = [];
end



hisdata=struct();
hisdata.time       = nc_varget(filename, 'time');

station_name       = nc_varget(filename, 'station_name');
station_x_coord    = nc_varget(filename, 'station_x_coordinate');
station_y_coord    = nc_varget(filename, 'station_y_coordinate');

if isempty(statname)
    hisdata.station_name    = station_name;
    hisdata.station_x_coord = station_x_coord;
    hisdata.station_y_coord = station_y_coord;
	hisdata.waterlevel      = nc_varget(filename, 'waterlevel');
	hisdata.x_velocity      = nc_varget(filename, 'x_velocity');
	hisdata.y_velocity      = nc_varget(filename, 'y_velocity');
    hisdata.cross_section_discharge = nc_varget(filename, 'cross_section_discharge');
    hisdata.cross_section_area      = nc_varget(filename, 'cross_section_area');
    hisdata.cross_section_velocity  = nc_varget(filename, 'cross_section_velocity');
else
    idx = [];
    for i=1:size(station_name,1)
        if strcmpi(deblank(station_name(i,:)), statname)
            idx = i;
        end
    end
    if isempty(idx)
        warning('Station ''%s'' not found.', statname);
    else
        waterlevel              = nc_varget(filename, 'waterlevel');
        hisdata.station_name    = deblank(station_name(idx,:));
        hisdata.station_x_coord = station_x_coord(idx);
        hisdata.station_y_coord = station_y_coord(idx);
        hisdata.waterlevel = waterlevel(:,idx);
    end
end


end