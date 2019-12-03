-- create schema
create schema if not exists import;

-- tabel met overzicht van ingelezen bestanden
drop table if exists import._file cascade;
create table import._file (file varchar, header varchar);

-- view met kolommen o.b.v. ingelezen titelregel
drop view if exists import._file_headercolumns cascade;
create or replace view import._file_headercolumns as
select * 
, replace(lower(column_name),'.','_') as column_name_clean
from import._file f, unnest(string_to_array(header,';')) with ordinality col(column_name,column_nr);


drop table if exists import._columnlist cascade;
create table import._columnlist (column_name varchar, data_type varchar, column_nr int);

drop view if exists import._columnlist_extended cascade;
create or replace view import._columnlist_extended as
select *
,replace(lower(column_name),'.','_') as column_name_clean
from import._columnlist
;

-- view die verschillen in kolomnamen en -volgorde toont t.o.v. verwachte formaat
drop view if exists import._columnlist_comparison cascade;
create or replace view import._columnlist_comparison as 
select 
 fhc.file
,coalesce(cle.column_nr, fhc.column_nr) as column_nr
,cle.column_name_clean as column_name_clean_expected
,fhc.column_name_clean as column_name_clean_file
,cle.column_name as column_name_expected
,fhc.column_name as column_name_file
,case when fhc.column_name_clean=cle.column_name_clean then 0 else 1 end difference
,cle_alt.column_nr as column_nr_expected
from import._columnlist_extended cle
full join import._file_headercolumns fhc on fhc.column_nr=cle.column_nr
left join import._columnlist_extended cle_alt on cle_alt.column_name_clean=fhc.column_name_clean and cle_alt.column_nr<>fhc.column_nr
order by 1,2;

drop view if exists import._columnlist_difference cascade;
create or replace view import._columnlist_difference as 
select 
 file
,column_nr
,column_name_expected
,column_name_file
,column_nr_expected
from import._columnlist_comparison
where difference=1;

-- function to get filename (without extension) from a path
drop function if exists import.getfilename(file varchar);
CREATE OR REPLACE FUNCTION import.getfilename(file varchar)
RETURNS varchar
AS
$$
DECLARE
	posLastBackslash int;
	posLastDot int;
	filenameWithExtension varchar;
BEGIN
	file := replace(file, '/', '\');		-- replace slash by backslash
	posLastBackslash := strpos(reverse(file),'\');
	filenameWithExtension := case when posLastBackslash > 0 then right(file, posLastBackslash-1) else file end;
	posLastDot := strpos(reverse(filenameWithExtension),'.');
  	return left(filenameWithExtension, length(filenameWithExtension)-posLastDot);
END 
$$ language plpgsql;

-- function to get path (without the filename)	
drop function if exists import.getpath(file varchar);
CREATE OR REPLACE FUNCTION import.getpath(file varchar)
RETURNS varchar
AS
$$
DECLARE
	posLastBackslash int;
	posLastDot int;
	filenameWithExtension varchar;
BEGIN
	file := replace(file, '/', '\');		-- replace slash by backslash
	posLastBackslash := length(file) - strpos(reverse(file),'\');
  	return left(file, posLastBackslash+1);
--   	return posLastBackslash;
END 
$$ language plpgsql;

drop function if exists import.gettablename(file varchar);
CREATE OR REPLACE FUNCTION import.gettablename(file varchar)
RETURNS varchar
AS
$$
DECLARE
	tablename varchar;
BEGIN
	tablename := import.getfilename(file);
	tablename := lower(tablename);
	tablename := replace(tablename, '.','_');
	tablename := replace(tablename, ' ','_');

  	return tablename;
END 
$$ language plpgsql;

-- function voor aanmaken lege view als template voor de data (getypeerd)
drop function if exists import.create_template();
create or replace function import.create_template() returns text as
$f$
declare q text;
	cl text;
begin
	-- build list of columns for create statement
	execute($$
 		select substring(string_agg(',null::'||data_type||' as '||column_name_clean,E'\r\n'),2,9999) ||E'\r\n'
	-- select *
		from import._columnlist_extended;
	$$) into cl;
	
	-- create (empty) view with list of columns
	q:= 'drop view if exists import.template_import_table;'	||E'\r\n'||
		'create or replace view import.template_import_table as' ||E'\r\n'|| 'select '||cl;	--||',null::int as _recordnr';
	execute(q);
 	return q;
end
$f$ language plpgsql;

-- function voor aanmaken nieuwe importtabel 
drop function if exists import.create_import_table(tablename varchar);
create or replace function import.create_import_table(tablename varchar) returns text as
$f$
declare
	q text;
	columnlist text;
  	crlf varchar=E'\r\n';
begin
	-- prepare tablename: lower case and no dots, no extension
-- tablename := import.getfilename(tablename);
--  	tablename := replace(lower(tablename), '.','_');

	-- build list of columns for create statement	
	execute ($$
 		select substring(string_agg(',"'||column_name_clean,'" varchar'||E'\r\n'),2,9999) || '" varchar'||E'\r\n'
		from import._columnlist_extended
		;
	$$) into columnlist;

	-- build create table script
	q := 'drop table if exists import."%1$s" cascade;' || crlf ||	'create table import."%1$s"(%2$s);' || crlf || 'alter table import."%1$s" add column _recordnr serial;';
  	q := format(q, tablename, columnlist);
 	execute q;
 	return q;
end
$f$ language plpgsql;

CREATE OR REPLACE FUNCTION import.check_datatype(x text, datatype text)
  RETURNS text AS
$f$
DECLARE	
	q text;
	y text;
BEGIN
	q := 'select '''|| x || '''::' || datatype;
	execute(q) into y;
	return x;
EXCEPTION WHEN OTHERS THEN
   RETURN NULL;  -- NULL for other invalid input
END
$f$  LANGUAGE plpgsql;

-- function to return data that is not compatible with expected data type
drop function if exists import.create_view_invalid_data(tablename varchar);
CREATE OR REPLACE FUNCTION import.create_view_invalid_data(tablename varchar)
  RETURNS text AS
$f$
DECLARE	
	q text;
	cl text;
	crlf text :=E'\r\n';
BEGIN
	execute($$
  		select substring(string_agg('or ('||column_name_clean||' is not null and import.check_datatype('||column_name_clean||','''||data_type||''') is null)',E'\r\n'),4,9999) ||E'\r\n'
		from import._columnlist_extended
		where data_type not like '%char%'
	$$) into cl;	

	q:= 'drop view if exists import.invalid_data;'	||crlf||
		'create or replace view import.invalid_data as' ||crlf||
		'select * from import.'||tablename ||crlf|| 'where '||cl;
	execute(q);
	return q;
END
$f$  LANGUAGE plpgsql;

-- function voor aanmaken view met getypeerde data (excl ongeldige data)
drop function if exists import.create_view_typed(tablename varchar);
create or replace function import.create_view_typed(tablename varchar) returns text as
$f$
declare q text;
	cl text;
	viewname text;
	crlf text = E'\r\n';
begin
	tablename:= import.gettablename(tablename);
	viewname := 'import.'|| import.gettablename(tablename)||'_typed';

	-- build list of columns for create statement
	execute($$
 		select substring(string_agg(',x.'||column_name_clean||'::'||data_type||' as '||column_name_clean,E'\r\n'),2,9999) ||E'\r\n'
--  		select substring(string_agg(',null::'||data_type||' as '||column_name_clean,E'\r\n'),2,9999) ||E'\r\n'
		from import._columnlist_extended;
	$$) into cl;
	
	-- create (empty) view with list of columns
	q:= 'drop view if exists '||viewname||';'	||E'\r\n'||
		'create or replace view '||viewname||' as' ||E'\r\n'|| 'select '||cl ||crlf|| 'FROM import.'||tablename||' x '||crlf||
		'left join import.invalid_data y on y._recordnr=x._recordnr where y._recordnr is null;';
	execute(q);
 	return q;
end
$f$ language plpgsql;
