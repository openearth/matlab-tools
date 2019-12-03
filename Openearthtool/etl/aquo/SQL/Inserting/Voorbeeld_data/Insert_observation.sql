-- SELECT * FROM public.observation
-- DELETE FROM public.observation

INSERT INTO public.observation (
phenomenon_time_begin, phenomenon_time_end, result_time, valid_time_begin, valid_time_end,
numeric_value_uom_id, start_depth, end_depth, numeric_value, observed_property_type, last_change_time, mno_id
)
SELECT
(mw.Begindatum || ' ' || 
(CASE WHEN mw.Begintijd is null THEN '00:00:00'
	ELSE mw.Begintijd
END))::timestamp as phenomenon_time_begin,
(mw.Begindatum || ' ' || 
(CASE WHEN mw.Begintijd is null THEN '00:00:00'
	ELSE mw.Begintijd
END))::timestamp as phenomenon_time_end,
(mw.Begindatum || ' ' || 
(CASE WHEN mw.Begintijd is null THEN '00:00:00'
	ELSE mw.Begintijd
END))::timestamp as result_time,
(mw.Begindatum || ' ' || 
(CASE WHEN mw.Begintijd is null THEN '00:00:00'
	ELSE mw.Begintijd
END))::timestamp as valid_time_begin,
(mw.Begindatum || ' ' || 
(CASE WHEN mw.Begintijd is null THEN '00:00:00'
	ELSE mw.Begintijd
END))::timestamp as valid_time_end,
e.eenh_id as numeric_value_uom_id, --> From public.eenheid_type
mw.begindiepte_m as start_depth,
mw.einddiepte_m as end_depth,
mw.numeriekewaarde as numeric_value,
opt.opt_id as observed_property_type,
NOW() as last_change_time,
mo.mno_id
FROM dump.meetwaarden2 mw
LEFT JOIN public.eenheid_type e ON e.code = mw."Eenheid.code"
LEFT JOIN public.grootheid_type g ON g.code = mw."Grootheid.code"
LEFT JOIN public.monitoring_object mo ON mo.name = mw."Meetobject.lokaalID"
LEFT JOIN public.parameter_aquo_ds_20160105 p ON p.code = mw."Parameter.code"
LEFT JOIN public.substance_group sg ON sg.name = p.omschrijving
LEFT JOIN public.object_group og ON og.name = p.omschrijving
LEFT JOIN public.taxa_group tg ON tg.name = mw."Biotaxon.naam"
LEFT JOIN public.typering_type tp ON tp.code = mw."Typering.code"
LEFT JOIN public.hoedanigheid_type hdh ON hdh.code = mw."Hoedanigheid.code"
LEFT JOIN public.observed_property_type opt
ON
coalesce(opt.quantity_id, -1) = coalesce(g.grh_id, -1)
AND
coalesce(opt.indicator_id, -1) = coalesce(tp.typ_id, -1)
AND
coalesce(opt.hoedanigheid_id, -1) = coalesce(hdh.hdh_id, -1)
AND
coalesce(opt.object_group_id, -1) = coalesce(og.ojg_id, -1)
AND
coalesce(opt.taxa_group_id, -1) = coalesce(tg.txg_id, -1)
AND
coalesce(opt.substance_group_id, -1) = coalesce(sg.ssg_id, -1);


