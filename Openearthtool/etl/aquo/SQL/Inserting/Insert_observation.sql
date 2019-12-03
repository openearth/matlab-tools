-- SELECT * FROM public.observation
-- DELETE FROM public.observation

INSERT INTO public.observation (
phenomenon_time_begin, phenomenon_time_end, result_time, valid_time_begin, valid_time_end,
numeric_value_uom_id, limit_symbol_id, start_depth, end_depth, numeric_value, description, remarks, observed_property_type, last_change_time, mno_id
)
SELECT
(mw.Begindatum || ' ' || 
(CASE WHEN mw.Begintijd is null THEN '00:00:00'
	ELSE mw.Begintijd
END))::timestamp as phenomenon_time_begin,
(CASE WHEN mw.einddatum is null THEN 
	(mw.begindatum || ' ' ||
	(CASE WHEN mw.begintijd is null THEN '00:00:00'
		ELSE mw.begintijd
	END))::timestamp
	ELSE (mw.einddatum || ' ' || 
		(CASE WHEN mw.eindtijd is null THEN '00:00:00'
			ELSE mw.eindtijd
		END))::timestamp
	END) as phenomenon_time_end,
(mw.Resultaatdatum || ' ' || 
(CASE WHEN mw.Resultaattijd is null THEN '00:00:00'
	ELSE mw.Resultaattijd
END))::timestamp as result_time,
(mw.Begindatum || ' ' || 
(CASE WHEN mw.Begintijd is null THEN '00:00:00'
	ELSE mw.Begintijd
END))::timestamp as valid_time_begin,
(CASE WHEN mw.einddatum is null THEN 
	(mw.begindatum || ' ' ||
	(CASE WHEN mw.begintijd is null THEN '00:00:00'
		ELSE mw.begintijd
	END))::timestamp
	ELSE (mw.einddatum || ' ' || 
		(CASE WHEN mw.eindtijd is null THEN '00:00:00'
			ELSE mw.eindtijd
		END))::timestamp
	END) as valid_time_end,
e.eenh_id as numeric_value_uom_id, --> From public.eenheid_type
bgt.bpg_id as limit_symbol_id,
mw.begindiepte_m as start_depth,
mw.einddiepte_m as end_depth,
mw.numeriekewaarde as numeric_value,
mw.alfanumeriekewaarde as description,
mw."meetwaardeopmerking" as remarks,
opt.opt_id as observed_property_type,
NOW() as last_change_time,
mo.mno_id
FROM dump2.meetwaarden mw
LEFT JOIN public.eenheid_type e ON e.code = mw."Eenheid.code"
LEFT JOIN public.grootheid_type g ON g.code = mw."Grootheid.code"

LEFT JOIN dump2.meetpunten mp ON mw."Monster.Opmerking" = mp.Omschrijving AND ST_Point(mp."GeometriePunt.X", mp."GeometriePunt.Y") = ST_Point(mw."GeometriePunt.X", mw."GeometriePunt.Y")
LEFT JOIN public.monitoring_object mo ON mo.name = mp.Omschrijving AND mo.geometry = 

ST_Transform(CASE WHEN mp.geometrie IS NOT NULL THEN ST_GeomFromText(mp.geometrie,
			CASE WHEN substring(mp."Referentiehorizontaal.code" from 6)::int IS NULL THEN 4326
			ELSE substring(mp."Referentiehorizontaal.code" from 6)::int
			END)
		ELSE ST_SetSRID(ST_Point(mp."GeometriePunt.X", mp."GeometriePunt.Y"),
			CASE WHEN substring(mp."Referentiehorizontaal.code" from 6)::int IS NULL THEN 4326
			ELSE substring(mp."Referentiehorizontaal.code" from 6)::int
			END)
		END, 28992)

LEFT JOIN public.bepaling_grens_type bgt ON bgt.code = mw."limietsymbool"

LEFT JOIN public.parameter_aquo_ds_20160105 p ON p.code = mw."Parameter.code" OR p.omschrijving = mw."Parameter.omschrijving"
LEFT JOIN public.substance_group sg ON sg.name = p.omschrijving
LEFT JOIN public.object_group og ON og.name = p.omschrijving
LEFT JOIN public.taxa_group tg ON tg.name = mw."Biotaxon.naam" OR tg.name = mw."Organisme.naam" OR tg.name = mw."Parameter.omschrijving"
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
coalesce(opt.substance_group_id, -1) = coalesce(sg.ssg_id, -1)
AND
coalesce(opt.remarks, '') = coalesce(mw."Biotaxon.naam", mw."Organisme.naam", '')
WHERE NOT EXISTS(
SELECT obs_id FROM observation o
WHERE o.numeric_value = mw.numeriekewaarde
AND
o.numeric_value_uom_id = e.eenh_id
AND
o.result_time = (mw.Resultaatdatum || ' ' || 
(CASE WHEN mw.Resultaattijd is null THEN '00:00:00'
	ELSE mw.Resultaattijd
END))::timestamp
AND
o.observed_property_type = opt.opt_id
AND
o.mno_id = mo.mno_id)