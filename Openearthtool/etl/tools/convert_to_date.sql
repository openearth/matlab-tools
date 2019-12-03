CREATE OR REPLACE FUNCTION tools.convert_to_date(text)
  RETURNS date AS
$func$
BEGIN
-- IF $1 = '' THEN  -- special case for empty string like requested
-- RETURN 0;
--    ELSE
      RETURN $1::date;
--    END IF;

EXCEPTION WHEN OTHERS THEN
   RETURN NULL;  -- NULL for other invalid input

END
$func$  LANGUAGE plpgsql IMMUTABLE;