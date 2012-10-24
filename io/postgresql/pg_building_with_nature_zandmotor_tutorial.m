%PG_ZANDMOTOR_TUTORIAL  extract all tables with all columns into one struct
%
% You cna request a dump without data of the BwN/Zandmotor
% database. This dump contains all meta-data tables.
% This tutorial loads all those tables into one struct
% if the table is shorter then a specified criterion.
%
%See also: postgresql, netcdf

OPT.db     = 'BWN';
OPT.schema = 'public';
OPT.user   = '';
OPT.pass   = '';

%% connect

   if ~(pg_settings('check',1)==1)
      pg_settings
   end
   if isempty(OPT.user)
   [OPT.user,OPT.pass] = pg_credentials();
   end
   
   conn=pg_connectdb(OPT.db,'user',OPT.user,'pass',OPT.pass,'schema',OPT.schema);

%% List all table names, but exclude PostGIS table 'spatial_ref_sys'
% exclude 'observation' for filled databases!!

   tables  = {'location','method','observation','observation_type','parameter',...
               'parameter_hilucs','parameter_physical','parameter_sediment','parameter_worms',...
               'quality','unit',...
               'value_age_class','value_broken','value_length_class'};

   for i=1:length(tables)
   
      table = tables{i};

      [nams,typs,table_size(i)]= pg_getcolumns(conn,table);
      
      if table_size(i) > 42524 % current size of subset of WoRMS species list
          
           D.(table) = [];
           
      else
   
         R = pg_select_struct(conn,table,struct([]));
      
         D.(table) = pg_fetch2struct(R,nams, typs);
         
      end
   
   end
