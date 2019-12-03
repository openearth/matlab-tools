create schema if not exists tools;

drop function if exists tools.importcsv(file varchar, columndelimiter varchar);
CREATE OR REPLACE FUNCTION tools.importcsv(file varchar, columndelimiter varchar)
RETURNS text
AS
$$
DECLARE
	header text;
	columnlist text;
	tablename text;
	qcreateheadertable text;
	qimportheader text;
	qcreatetable text;
	qcopy text;
	rowsaffected int;
	crlf text = E'\r\n';
BEGIN
	tablename := tools.getfilename(file);
	tablename := quote_ident(tablename);	-- account for spaces
	qcreateheadertable := 'create table if not exists tools.header(column0 varchar);'
		'truncate table tools.header';
	EXECUTE qcreateheadertable;
	qimportheader := 'copy tools.header from ''' || file || ''';';
	execute qimportheader;
	header := (select column0 from tools.header limit 1);
	-- correct empty column names: <column_name> + <number_of_column>:
	columnlist := 	(select array_to_string(array_agg(case when elem='' then 'column'||nr::varchar else elem end ),';')
						from unnest(string_to_array(header, ';')) with ordinality unn(elem,nr));

	qcreatetable := 'create schema if not exists import;'
		'drop table if exists import.' || tablename || ';'
		'create table import.'|| tablename ||'("' || replace(columnlist, columndelimiter,'" varchar, "') || '" varchar);';
	execute qcreatetable;
	qcopy := 'copy import.' || tablename || ' from ''' || file || ''' delimiter ''' || columndelimiter || ''' csv header;';
	execute qcopy;
	get diagnostics rowsaffected := ROW_COUNT;
-- 	return rowsaffected||' records: import.'||tablename;
	return 'import.'||tablename||' '||crlf||rowsaffected|| ' records. '||crlf||qcreatetable||crlf||qcopy;
END 
$$ language plpgsql;

-- select tools.importcsv('d:\temp\testxyz.csv',';');

-- select * from import.testxyz;
