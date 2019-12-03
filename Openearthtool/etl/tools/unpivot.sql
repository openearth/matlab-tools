/*
create table public.test2 (id serial, "test2001" int, "test2002" int, "test2003" int);
insert into test2 ("test2001","test2002","test2003") values (1,2,3),(101,102,103);

create table public.test3 (id serial, "test2001" decimal(18,9), "test2002" decimal(18,9), "test2003" decimal(18,9));
insert into test3 ("test2001","test2002","test2003") values (1.0,2.2,3.14),(101,102,103);
*/

drop function if exists tools.unpivot(_tablename regclass, _key_column varchar, _column_prefix varchar, VARIADIC _column_numbers varchar[]);
CREATE OR REPLACE FUNCTION tools.unpivot(_tablename regclass, _key_column varchar, _column_prefix varchar, VARIADIC _column_numbers varchar[])
  RETURNS TABLE(_key varchar, _column_nr int, _column_name varchar, _column_value varchar) AS
$func$
BEGIN
   RETURN QUERY EXECUTE '
   SELECT '||_key_column||'::varchar as _key_column
        , replace(unnest($1), '''||_column_prefix||''','''')::int AS _column_nr
        , unnest($1) AS _column_name
        , unnest(ARRAY["'|| array_to_string(_column_numbers, '","') || '"])::varchar AS _column_value
   FROM   ' || _tablename || '
   ORDER  BY 1, 2'
   USING _column_numbers;
END
$func$  
LANGUAGE plpgsql;

--same, but with extra columns:
drop function if exists tools.unpivot(_tablename regclass, _key_column varchar, _extra_column1 varchar, _extra_column2 varchar, _extra_column3 varchar, _column_prefix varchar, VARIADIC _column_numbers varchar[]);
CREATE OR REPLACE FUNCTION tools.unpivot(_tablename regclass, _key_column varchar, _extra_column1 varchar, _extra_column2 varchar, _extra_column3 varchar, _column_prefix varchar, VARIADIC _column_numbers varchar[])
  RETURNS TABLE(_key varchar, _column_nr int, _column_name varchar, _column_value varchar, _extra1 varchar, _extra2 varchar, _extra3 varchar) AS
$func$
BEGIN
   RETURN QUERY EXECUTE '
   SELECT '||_key_column||'::varchar as _key_column
        , replace(unnest($1), '''||_column_prefix||''','''')::int AS _column_nr
        , unnest($1) AS _column_name
        , unnest(ARRAY["'|| array_to_string(_column_numbers, '","') || '"])::varchar AS _column_value
        , '||coalesce(_extra_column1,'null')||'::varchar as _extra1
        , '||coalesce(_extra_column2,'null')||'::varchar as _extra2
        , '||coalesce(_extra_column3,'null')||'::varchar as _extra3
   FROM   ' || _tablename || '
   ORDER  BY 1, 2'
   USING _column_numbers;
END
$func$  
LANGUAGE plpgsql;


-- select * from tools.unpivot('public.test3','id','test', variadic array(select 'test'||generate_series(2001,2003)));
-- select * from public.unpivot('test3','id', variadic array(select generate_series(2001,2003)));
-- with extra column:
-- select * from tools.unpivot('public.test3','id','test', variadic array(select 'test'||generate_series(2001,2003)));
