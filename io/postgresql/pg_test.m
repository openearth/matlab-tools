function OK = pg_test
%PG_TEST test postgresql toolbox with simple 2-column datamodel:
%
%   -- Table: "TEST01"
%   -- DROP TABLE "TEST01";
%   
%   CREATE TABLE "TEST01"
%   (
%     "ObservationID" serial NOT NULL,
%     "Value" real,
%     CONSTRAINT "TEST01_pkey" PRIMARY KEY ("ObservationID" )
%   )
%   WITH (
%     OIDS=FALSE
%   );
%   ALTER TABLE "TEST01"
%     OWNER TO postgres;
%   
%   -- Column: "ObservationID"
%   -- ALTER TABLE "TEST01" DROP COLUMN "ObservationID";
%   
%   ALTER TABLE "TEST01" ADD COLUMN "ObservationID" integer;
%   ALTER TABLE "TEST01" ALTER COLUMN "ObservationID" SET NOT NULL;
%   ALTER TABLE "TEST01" ALTER COLUMN "ObservationID" SET DEFAULT nextval('"TEST01_ObservationID_seq"'::regclass);
%   
%   -- Sequence: "TEST01_ObservationID_seq"
%   -- DROP SEQUENCE "TEST01_ObservationID_seq";
%   -- | CREATE SEQUENCE "TEST01_ObservationID_seq"
%   -- |  INCREMENT 1
%   -- |  MINVALUE 1
%   -- |  MAXVALUE 9223372036854775807
%   -- |  START 6
%   -- |  CACHE 1;
%   -- |ALTER TABLE "TEST01_ObservationID_seq"
%   -- |  OWNER TO postgres;
%   
%   -- Constraint: "TEST01_pkey"
%   -- ALTER TABLE "TEST01" DROP CONSTRAINT "TEST01_pkey";
%   
%   ALTER TABLE "TEST01"
%     ADD CONSTRAINT "TEST01_pkey" PRIMARY KEY("ObservationID" );
%   
%   -- Column: "Value"
%   -- ALTER TABLE "TEST01" DROP COLUMN "Value";
%   
%   ALTER TABLE "TEST01" ADD COLUMN "Value" real;
%
%See also: postgresql

OK = [];

if ~pg_settings('check',1)
   pg_settings
end

% http://archives.postgresql.org/pgsql-performance/2004-11/msg00350.php
% http://dba.stackexchange.com/questions/322/what-are-the-drawbacks-with-using-uuid-or-guid-as-a-primary-key

[user,pass] = pg_credentials();

conn=pg_connectdb('postgres','user',user,'pass',pass,'schema','public')

tables = pg_gettables(conn);
for itab=1:length(tables)
   table = tables{itab};
   columns = pg_getcolumns(conn,table);
   for icol=1:length(columns)
       column = columns{icol};
       disp([conn.Instance,':',table,':',column])
   end
end

   pg_cleartable(conn,'TEST01') % reset values and serial
pg_insert_struct(conn,'TEST01',struct('Value','3.1416'));        % 1
pg_insert_struct(conn,'TEST01',struct('Value',[3.1416 3.1416])); % 2 3
pg_insert_struct(conn,'TEST01',struct('Value','2'));             % 4
pg_insert_struct(conn,'TEST01',struct('Value',[2 2]));           % 4 5

D = pg_select_struct(conn,'TEST01',struct('Value','2'));
OK(end+1) = isequal(cell2mat({D{:,1}}),[4 5 6]);

D = pg_select_struct(conn,'TEST01',struct('Value',2));
OK(end+1) = isequal(cell2mat({D{:,1}}),[4 5 6]);

D = pg_select_struct(conn,'TEST01',struct('Value','3.1416'));
OK(end+1) = isequal(cell2mat({D{:,1}}),[1 2 3]);

% for reals, the selection does not work if numeric data 
% are supplied, perhaps due to machine precision issues
D = pg_select_struct(conn,'TEST01',struct('Value',3.1416));
%isequal(cell2mat({D{:,1}}),[1 2 3])
