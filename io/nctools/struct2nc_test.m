%STRUCT2NC_TEST   tets for struct2nc
%
%See also: struct2nc

D.datenum               = datenum(1970,1,1:.1:3);
D.eta                   = sin(2*pi*D.datenum./.5);
M.terms_for_use         = 'These data can be used freely for research purposes provided that the following source is acknowledged: OET.';
M.disclaimer            = 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';
M.units.datenum         = 'time';
M.units.eta             = 'sea_surface_height';
M.standard_name.datenum = 'days since 0000-0-0 00:00:00 +00:00';
M.standard_name.eta     = 'meter';

struct2nc('struct2nc.nc',D,M);

