-- SELECT * FROM public.bio_observation
-- DELETE FROM public.bio_observation

INSERT INTO public.bio_observation
(obs_id, levensstadium_id, lengte_klasse_id, geslacht_id, verschijningsvorm_id,
levensvorm_id, gedrag_id)
SELECT
o.obs_id,
h1.hdh_id as levensstadium_id,
h2.hdh_id as lengte_klasse_id,
h3.hdh_id as geslacht_id,
h4.hdh_id as verschijningsvorm_id,
h5.hdh_id as levensvorm_id,
h6.hdh_id as gedrag_id
FROM
public.observation o
LEFT JOIN public.eenheid_type e ON e.eenh_id = o.numeric_value_uom_id
LEFT JOIN public.monitoring_object mo ON mo.mno_id = o.mno_id
LEFT JOIN public.observed_property_type opt ON opt.opt_id = o.observed_property_type
LEFT JOIN public.grootheid_type g ON coalesce(g.grh_id, -999) = coalesce(opt.quantity_id, -999)
LEFT JOIN public.substance_group sg ON coalesce(sg.ssg_id, -999) = coalesce(opt.substance_group_id, -999)
LEFT JOIN public.object_group og ON coalesce(og.ojg_id, -999) = coalesce(opt.object_group_id, -999)
LEFT JOIN public.taxa_group tg ON coalesce(tg.txg_id, -999) = coalesce(opt.taxa_group_id, -999)
LEFT JOIN public.typering_type tp ON coalesce(tp.typ_id, -999) = coalesce(opt.indicator_id, -999)
LEFT JOIN public.hoedanigheid_type hdh ON coalesce(hdh.hdh_id, -999) = coalesce(opt.hoedanigheid_id, -999)
LEFT JOIN public.parameter_aquo_ds_20160105 p 
ON coalesce(p.omschrijving, '') = coalesce(og.name, '')
AND
coalesce(p.omschrijving, '') = coalesce(sg.name, '')
LEFT JOIN dump2.meetpunten mp ON mp.Omschrijving = mo.name AND mo.geometry = 
ST_Transform(CASE WHEN mp.geometrie IS NOT NULL THEN ST_GeomFromText(mp.geometrie,
			CASE WHEN substring(mp."Referentiehorizontaal.code" from 6)::int IS NULL THEN 4326
			ELSE substring(mp."Referentiehorizontaal.code" from 6)::int
			END)
		ELSE ST_SetSRID(ST_Point(mp."GeometriePunt.X", mp."GeometriePunt.Y"),
			CASE WHEN substring(mp."Referentiehorizontaal.code" from 6)::int IS NULL THEN 4326
			ELSE substring(mp."Referentiehorizontaal.code" from 6)::int
			END)
		END, 28992)
		
LEFT JOIN dump2.meetwaarden mw
--ON mw."Eenheid.code" = e.code -- Hier moet ook weer coalesce
ON
coalesce(mw."Grootheid.code", '') = coalesce(g.code, '')
AND
coalesce(mw."Typering.code", '') = coalesce(tp.code, '')
AND
coalesce(mw."Hoedanigheid.code", '') = coalesce(hdh.code, '')
AND
coalesce(mw."Parameter.code", '') = coalesce(p.code, '')
AND
coalesce(mw."Biotaxon.naam", '') = coalesce(tg.name, '')
AND
coalesce(mw."meetwaardeopmerking", '') = coalesce(o.remarks, '')
AND
coalesce(mw.numeriekewaarde, -999) = coalesce(o.numeric_value, -999)
AND
coalesce(mw.begindiepte_m, -999) = coalesce(o.start_depth, -999)
AND
coalesce(mw.einddiepte_m, -999) = coalesce(o.end_depth, -999)
AND
coalesce((mw.resultaatdatum || ' ' || 
CASE WHEN mw.resultaattijd IS NULL THEN '00:00:00'
ELSE mw.resultaattijd
END)::timestamp, '1950-01-01 00:00:00') = coalesce(o.result_time, '1950-01-01 00:00:00')
AND
mw."Monster.Opmerking" = mp.Omschrijving 
AND ST_Point(mp."GeometriePunt.X", mp."GeometriePunt.Y") = ST_Point(mw."GeometriePunt.X", mw."GeometriePunt.Y")
LEFT JOIN public.hoedanigheid_type h1 ON h1.code = mw."Levensstadium.code"
LEFT JOIN public.hoedanigheid_type h2 ON h2.code = mw."Lengteklasse.code"
LEFT JOIN public.hoedanigheid_type h3 ON h3.code = mw."Geslacht.code"
LEFT JOIN public.hoedanigheid_type h4 ON h4.code = mw."Verschijningsvorm.code"
LEFT JOIN public.hoedanigheid_type h5 ON h5.code = mw."Levensvorm.code"
LEFT JOIN public.hoedanigheid_type h6 ON h6.code = mw."Gedrag.code"
WHERE 
mw."Levensstadium.code" IS NOT NULL OR
mw."Lengteklasse.code" IS NOT NULL OR
mw."Geslacht.code" IS NOT NULL OR
mw."Verschijningsvorm.code" IS NOT NULL OR
mw."Levensvorm.code" IS NOT NULL OR
mw."Gedrag.code" IS NOT NULL
AND NOT EXISTS
(SELECT bo.obs_id FROM public.bio_observation bo
WHERE bo.obs_id = o.obs_id)