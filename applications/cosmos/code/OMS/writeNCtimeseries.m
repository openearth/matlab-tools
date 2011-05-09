function writeNCtimeseries(ncfile,s,varargin)

for i=1:length(varargin)
    if ischar(lower(varargin{i}))
        switch lower(varargin{i})
            case{'parametername'}
                name=lower(varargin{i+1});
            case{'type'}
                tp=lower(varargin{i+1});
        end
    end
end

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



% create netcdf file
nc_create_empty(ncfile,nc_clobber_mode);

% set global attributes
attr=fieldnames(s.global);
for i=1:length(attr)
    nc_attput(ncfile,nc_global,attr{i},s.global.(attr{i}));
end

% First add time
for i=1:length(s.datasets)
    switch lower(s.datasets(i).Name)
        case{'time'}
            nc_add_dimension(ncfile,'time',length(s.datasets(i).data));
            v2=rmfield(s.datasets(i),'data');            
            nc_addvar(ncfile,v2);
            nc_varput(ncfile,'time',round((s.datasets(i).data-datenum('1970-01-01 00:00:00')))*86400);
    end
end

for i=1:length(s.datasets)
    name=s.datasets(i).Name;
    switch lower(name)
        case{'time'}
        otherwise
            v2=rmfield(s.datasets(i),'data');            
            nc_addvar(ncfile,v2);
            nc_varput(ncfile,name,s.datasets(i).data);
    end
end
