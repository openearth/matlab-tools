-- SELECT * FROM public.sampling_proces
-- DELETE FROM public.sampling_proces

INSERT INTO public.sampling_proces (
var_id)

SELECT DISTINCT
va.var_id
FROM dump2.meetwaarden mw
JOIN domains.veldapparaat va ON va.description = mw."Meetapparaat.omschrijving" OR va.code = mw."Meetapparaat.omschrijving"
WHERE NOT EXISTS(SELECT * FROM public.sampling_proces sp
WHERE sp.var_id = va.var_id)