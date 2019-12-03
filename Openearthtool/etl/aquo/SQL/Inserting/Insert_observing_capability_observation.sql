--SELECT * FROM public.observing_capability_observation

--DELETE FROM public.observing_capability_observation

INSERT INTO public.observing_capability_observation
(obs_id, osc_id, last_change_time)
SELECT
o.obs_id,
oc.osc_id,
NOW()
FROM public.observation o
LEFT JOIN public.monitoring_object mo ON mo.mno_id = o.mno_id

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
(SELECT * FROM observing_capability_observation oco
WHERE oco.osc_id = oc.osc_id AND oco.obs_id = o.obs_id)
GROUP BY o.obs_id, oc.osc_id

