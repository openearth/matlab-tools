clear variables;close all;

s.global.title='Delft3D history output';
s.global.source='OMS';
s.global.history=['Created : ' datestr(now)];
s.global.type='scalar';

% Time
s.datasets(1).Name='time';
s.datasets(1).Datatype = 'int';
s.datasets(1).Attribute(1).Name = '_FillValue';
s.datasets(1).Attribute(1).Value = -999;
s.datasets(1).Attribute(2).Name = 'units';
s.datasets(1).Attribute(2).Value = 'seconds since 1970-01-01 00:00:00 +00:00';
s.datasets(1).Dimension = {'time'};
%s.datasets(1).Chunking = 10;
%s.datasets(1).Deflate = 9;
t0=datenum(1970,1,1);
s.datasets(1).data=t0:t0+10;

% Other data
s.datasets(2).Name='significant_wave_height';
s.datasets(2).Datatype = 'float';
s.datasets(2).Attribute(1).Name = '_FillValue';
s.datasets(2).Attribute(1).Value = -999;
s.datasets(1).Attribute(2).Name = 'units';
s.datasets(1).Attribute(2).Value = 'm';
s.datasets(2).Dimension = {'time'};
%s.datasets(2).Chunking = 10;
%s.datasets(2).Deflate = 9;
s.datasets(2).data=single(rand(11,1));

writeNCtimeseries('x:\test.nc',s);


f='x:\test.nc';

d=nc_varget(f,'significant_wave_height');
