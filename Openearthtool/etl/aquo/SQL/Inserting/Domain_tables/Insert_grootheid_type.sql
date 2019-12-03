-- SELECT * FROM public.grootheid_type
-- DELETE FROM public.grootheid_type

INSERT INTO public.grootheid_type
(id, code, omschrijving, d_begin, d_eind, last_changed_date, d_status)
SELECT
p.id,
p.code,
p.omschrijving,
p.d_begin,
p.d_eind,
NOW() as last_changed_date,
p.d_status
FROM public.parameter_aquo_ds_20160105 p
WHERE p.groep = 'Grootheid'