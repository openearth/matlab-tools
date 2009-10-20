%STRUCT2NC_TEST   test for struct2nc & nc2struct
%
%See also: STRUCT2NC, NC2STRUCT

% TO DO: swap fieldnames and attributenames in meta-struct

n = 20;

   D1.datenum               = datenum(1970,1,linspace(1,3,n))';
   D1.eta                   = sin(2*pi*D1.datenum./.5);

   D1.some_numbers          = [1997 1998 1999];
   D1.some_numbersT         = [1997 1998 1999]';

   D1.cell                  = {'abcdef','abcdefghijkl'};
   D1.char                  = char(D1.cell);

   D1.cellwithspace         = {'a b c d e f','a b c d e f g h i j k l'}; % test for any spce delimitation
   D1.charwithspace         = char(D1.cell);

   M1.terms_for_use         = 'These data can be used freely for research purposes provided that the following source is acknowledged: OET.';
   M1.disclaimer            = 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';

%% current implementation
   M1.units.datenum         = 'time';
   M1.units.eta             = 'sea_surface_height';
   M1.standard_name.datenum = 'days since 0000-0-0 00:00:00 +00:00';
   M1.standard_name.eta     = 'meter';
   
%% preferred implementation (swap level of attributes and variables in struct)
  %M1.datenum.units         = 'time';
  %M1.datenum.standard_name = 'days since 0000-0-0 00:00:00 +00:00';
  %M1.eta.units             = 'sea_surface_height';
  %M1.eta.standard_name     = 'meter';

   struct2nc('struct2nc.nc',D1,M1);
   
   [D2] = nc2struct('struct2nc.nc')

   isequal(D1,D2)

  %isequal(M1,M2)