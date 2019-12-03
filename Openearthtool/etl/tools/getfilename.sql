create schema if not exists tools;

drop function if exists tools.getfilename(file varchar);
CREATE OR REPLACE FUNCTION tools.getfilename(file varchar)
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
	filenameWithExtension := right(file, posLastBackslash-1);
	posLastDot := strpos(reverse(filenameWithExtension),'.');
  	return left(filenameWithExtension, length(filenameWithExtension)-posLastDot);
END 
$$ language plpgsql;


--select tools.getfilename('d:\temp\temp123\temp456\temp.temp\testabc.csv');
--select tools.getfilename('langsdammenmonitoring/1techniek/1.0basisinformatie/2013/do/overzicht tekeningnummers.xls');
