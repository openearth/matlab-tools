drop function if exists tools.alter_column_type(schemaname varchar, tablename varchar, columnname varchar, datatype varchar);

CREATE or replace FUNCTION tools.alter_column_type(schemaname varchar, tablename varchar, columnname varchar, datatype varchar)
RETURNS text
as
$$ 
DECLARE q text;
BEGIN
-- 	preconversion := 'replace(';
	q := format('update %1$s.%2$s set "%3$s"= replace("%3$s", '','',''.'');
	alter table %1$s.%2$s alter column "%3$s" type %4$s using "%3$s"::%4$s;'
	, schemaname, tablename, columnname, datatype); 

 	execute q;
	return q;
END 
$$ language plpgsql;


