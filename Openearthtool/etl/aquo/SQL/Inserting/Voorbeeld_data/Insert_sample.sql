-- SELECT * FROM public.sample
-- DELETE FROM public.sample

INSERT INTO public.sample (
smpl_id, name, material_class_id, sampling_time, sampling_location,
upper_depth_value, upper_depth_uom_id, lower_depth_value, lower_depth_uom_id, smp_id
)
SELECT
mo.mno_id as smpl_id,
mo.name as name,
ct.cptm_id as material_class_id,
(mw.Begindatum || ' ' || 
(CASE WHEN mw.Begintijd is null THEN '00:00:00'
	ELSE mw.Begintijd
END))::timestamp as sampling_time,
mo.geometry as sampling_location,
MIN(mw.begindiepte_m) as upper_depth_value,
et.eenh_id as upper_depth_uom_id, --> From public.eenheid_type
MAX(mw.einddiepte_m) as lower_depth_value,
et.eenh_id as lower_depth_uom_id, --> From public.eenheid_type
sp.var_id as smp_id
FROM dump.meetwaarden2 mw
JOIN public.eenheid_type e ON e.code = mw."Eenheid.code"
JOIN public.grootheid_type g ON g.code = mw."Grootheid.code"
JOIN public.monitoring_object mo ON mo.name = mw."Monster.Opmerking"
JOIN public.compartiment_type ct ON ct.code = mw."MonsterCompartiment.code"
JOIN domains.veldapparaat va ON va.code = mw."Bemonsteringsapparaat.code"
JOIN public.sampling_proces sp ON sp.var_id = va.var_id,
public.eenheid_type et
WHERE et.code = 'm'
GROUP BY mo.mno_id, mo.name, ct.cptm_id, mo.geometry, mw.Begindatum, mw.Begintijd, sp.var_id, et.eenh_id