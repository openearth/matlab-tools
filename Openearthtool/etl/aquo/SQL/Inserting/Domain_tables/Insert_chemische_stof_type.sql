-- SELECT * FROM public.chemische_stof_type
-- DELETE FROM public.chemische_stof_type

INSERT INTO public.chemische_stof_type
(id, cas_nr, code, naam, d_begin, d_eind, last_changed_date, d_status)
SELECT
p.id,
p.casnummer,
p.code,
p.omschrijving,
p.d_begin,
p.d_eind,
NOW() as last_changed_date,
p.d_status
FROM public.parameter_aquo_ds_20160105 p
WHERE p.groep = 'ChemischeStof'