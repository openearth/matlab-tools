-- SELECT * FROM public.substance_group
-- DELETE FROM public.substance_group

INSERT INTO public.substance_group
(name, group_type, d_begin, d_eind, last_changed_date, d_status)
SELECT
p.omschrijving,
'I', -- Gokje Enumeratie: I=Individual, O=Observation, N=Normal
p.d_begin,
p.d_eind,
NOW() as last_changed_date,
p.d_status
FROM public.parameter_aquo_ds_20160105 p
WHERE p.groep = 'ChemischeStof'