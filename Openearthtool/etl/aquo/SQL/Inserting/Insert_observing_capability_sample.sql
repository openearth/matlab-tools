--SELECT * FROM public.observing_capability_sample

--DELETE FROM public.observing_capability_sample

INSERT INTO public.observing_capability_sample
(smpl_id, osc_id, last_change_time)
SELECT 
sa.smpl_id,
oc.osc_id,
NOW()
FROM public.sample sa
LEFT JOIN public.monitoring_object mo ON mo.mno_id = sa.smpl_id

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
LEFT JOIN dump2.meetwaarden mw ON mw."Monster.Opmerking" = mp.Omschrijving and ST_Point(mp."GeometriePunt.X", mp."GeometriePunt.Y") = ST_Point(mw."GeometriePunt.X", mw."GeometriePunt.Y")
LEFT JOIN public.observing_capability oc ON oc.name = mw."Dataset.naam"
WHERE oc.osc_id IS NOT NULL
AND NOT EXISTS
(SELECT * FROM observing_capability_sample ocs
WHERE ocs.osc_id = oc.osc_id AND ocs.smpl_id = sa.smpl_id)
GROUP BY sa.smpl_id, oc.osc_id