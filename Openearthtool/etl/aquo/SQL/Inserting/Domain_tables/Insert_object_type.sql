-- SELECT * FROM public.object_type
-- DELETE FROM public.object_type

INSERT INTO public.object_type
(code, omschrijving, d_begin, d_eind, last_changed_date, d_status, id)
SELECT
p.code,
p.omschrijving,
p.d_begin,
p.d_eind,
NOW() as last_changed_date,
p.d_status,
p.id
FROM public.parameter_aquo_ds_20160105 p
WHERE p.groep = 'Object'