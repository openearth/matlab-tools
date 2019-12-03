-- drop function if exists tools.dynamic_crosstab(sourcetable varchar, keycolumn varchar, namecolumn varchar, valuecolumn varchar);
drop function if exists tools.dynamic_crosstab(sourceschema varchar, sourcetable varchar, keycolumn varchar, namecolumn varchar, valuecolumn varchar, targetview varchar);
CREATE OR REPLACE FUNCTION tools.dynamic_crosstab(sourceschema varchar, sourcetable varchar, keycolumn varchar, namecolumn varchar, valuecolumn varchar, targetview varchar) RETURNS text AS
$$
DECLARE
	qpart1 text;
	qpart2 text;
-- 	qpart3 text;
	qresult text;
	qcolumnlist text;
	qcolumnlist_base text;
	qcolumnlist_datatype text;
	columnlist text;
	columnlist_datatype text;
 	sourceobject text;
 	dollars text;
BEGIN
	-- account for non-identifier characters:
 	sourceschema := quote_ident(sourceschema);
	sourcetable := quote_ident(sourcetable);
	keycolumn := quote_ident(keycolumn);
	namecolumn := quote_ident(namecolumn);
	valuecolumn := quote_ident(valuecolumn);
	targetview := targetview;
	
	-- sourceobject: schema + table
	sourceobject := sourceschema || '.' || sourcetable;

-- 	qcolumnlist := format('select string_agg(distinct '', "''||%1$s||''" varchar '','''') from %2$s ', namecolumn, sourceobject);
	qcolumnlist_base := 'select string_agg(distinct '', "''||%1$s||''" %2$s '','''') from %3$s ';
	qcolumnlist := format(qcolumnlist_base, namecolumn, '', sourceobject);
	qcolumnlist_datatype := format(qcolumnlist_base, namecolumn, 'varchar', sourceobject);

 	execute qcolumnlist into columnlist;
 	execute qcolumnlist_datatype into columnlist_datatype;
  	columnlist_datatype := keycolumn || ' varchar' || columnlist_datatype;
 	columnlist := substring(columnlist, 2, 999);
 	dollars := '$'||'$';
	qpart1 := format('select %1$s, %2$s, %3$s from %4$s order by 1,2 asc', keycolumn, namecolumn, valuecolumn, sourceobject);
	qpart2 := format(dollars||'select unnest (''{%1$s}''::text[])'||dollars, columnlist);
 	qresult := format('select * from crosstab (''%1$s'', %2$s) as ct(%3$s);', qpart1, qpart2, columnlist_datatype);

	if(targetview) is not null then
		qresult := 'drop view if exists '||targetview||';'
 			'create view ' ||targetview|| ' as ' ||qresult;
 			execute (qresult);
	end if;

	return qresult;
END 
$$ language plpgsql;

