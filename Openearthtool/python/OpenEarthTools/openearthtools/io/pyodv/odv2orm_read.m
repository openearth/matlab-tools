%example how to get one P01 parameter from a postgresql database and plot it
%
%See also:

OPT.db               = 'EMODnetChemistry2d';
OPT.schema           = 'public';
OPT.user             = '';
OPT.pass             = '';
OPT.database_toolbox = 0;
OPT.P01              = 'PSSTTS01'; %'TEMPRTNX';

%% connect

   if ~(pg_settings('check',1)==1)
      pg_settings
   end
   if isempty(OPT.user)
   [OPT.user,OPT.pass] = pg_credentials();
   end
   conn=pg_connectdb(OPT.db,'user',OPT.user,'pass',OPT.pass,'database_toolbox',OPT.database_toolbox);
   
   pg_dump(conn)
   
%% get all meta-data of 1 odv, for one parameter

    odv_columns = pg_getcolumns(conn,'observation');
    for i=1:length(odv_columns)
      col = odv_columns{i};
      strSQL  = pg_query('SELECT', 'observation' ,{col},struct('p01_id',OPT.P01));
      D.(col) = pg_fetch(conn,strSQL);
      try
         D.(col) = char(D.(col)); % fails for numbers
      catch
         D.(col) = cell2mat(D.(col));
      end
    end
    
%% 
    D.p06_id = cellstr(D.p06_id);
    if length(unique(D.p06_id ))==1
        D.p06_id = char(unique(D.p06_id ));
    else
        warning('unit not unqiue, homgenization required')
        D.p06_id_all = D.p06_id;
        D.p06_id = '<undetermined>';
    end
    D.p01_id = D.p01_id(1,:); % unioque by definition due to QUERY    

    D.datetime = pg_datenum(D.datetime);
    nrow = size(D.geom,1);
    D.lon = nan(nrow,1);
    D.lat = nan(nrow,1);
    for row=1:nrow
       [~,~,D.lon(row),D.lat(row)] = pg_ewkb(D.geom(row,:));
    end
%% plot

    subplot(1,2,1)
    plot(D.lon,D.lat,'ko')
    hold on
    scatter(D.lon,D.lat,20,D.value'.','filled')
    climits = caxis;
    axislat
    tickmap('ll')
    title('planview')
    grid on
    
    subplot(1,2,2)
    plot(D.datetime,D.value)
    datetick('x')
    title('timeseries')
    ylim(climits)
    clim(climits)
    ylabel([D.p01_id, '[',D.p06_id,']'])
    colorbarwithvtext([D.p01_id, '[',D.p06_id,']'])
    

% spatial_ref_sys (3911):
%     proj4text (character varying)
%     srtext (character varying)
%     auth_srid (integer)
%     auth_name (character varying)
%     srid (integer) [PK]
%  
% p350 (105):
%     definition (character varying)
%     altLabel (character varying)
%     prefLabel (character varying)
%     externalID (character varying)
%     id (integer) [PK]
%  
% p01 (28430):
%     definition (character varying)
%     altLabel (character varying)
%     prefLabel (character varying)
%     externalID (character varying)
%     id (integer) [PK]
%  
% edmo (4):
%     geom (USER-DEFINED)
%     name (character varying)
%     code (integer)
%     id (integer) [PK]
%  
% cdi (11):
%     edmo_code (integer)
%     local_cdi_id (character varying)
%     cdi (character varying)
%     id (integer) [PK]
%  
% odvfile (12):
%     Size (integer)
%     Sha256Hash (bytea)
%     LastModified (timestamp with time zone)
%     cdi (character varying)
%     suffix (character varying)
%     name (character varying)
%     id (integer) [PK]
%  
% l20 (11):
%     definition (character varying)
%     altLabel (character varying)
%     prefLabel (character varying)
%     externalID (character varying)
%     id (integer) [PK]
%  
% p06 (287):
%     definition (character varying)
%     altLabel (character varying)
%     prefLabel (character varying)
%     externalID (character varying)
%     id (integer) [PK]
%  
% observation (272221):
%     sourcefile_id (integer)
%     cdi_id (character varying)
%     p06_id (character varying)
%     p01_id (character varying)
%     depth (double precision)
%     geom (USER-DEFINED)
%     datetime (timestamp without time zone)
%     flag (character varying)
%     value (double precision)
%     id (integer) [PK]