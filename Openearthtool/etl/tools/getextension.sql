create schema if not exists tools;

drop function if exists tools.getextension(file varchar);
CREATE OR REPLACE FUNCTION tools.getextension(file varchar)
RETURNS varchar
AS
$$
DECLARE
	posLastBackslash int;
	filenameWithExtension varchar;
	posLastDot int;
	extension varchar;
BEGIN
	posLastBackslash := strpos(reverse(file),'\');
	filenameWithExtension := right(file, posLastBackslash-1);
	posLastDot := strpos(reverse(filenameWithExtension),'.');
	extension := right(file, posLastDot);
	extension := case when length(extension)<9 then extension end;
	return extension;
END 
$$ language plpgsql;


--   select tools.getextension('d:\temp\testabc.csv');
