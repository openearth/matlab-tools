-- SELECT * FROM public.monitored_compartiment

-- DELETE FROM public.monitored_compartiment

INSERT INTO public.monitored_compartiment
(mno_id, cptm_id, last_change_time)
SELECT DISTINCT
mo.mno_id,
ct.cptm_id,
NOW()
FROM public.monitoring_object mo
JOIN dump2.meetpunten mp ON mp.Omschrijving = mo.name AND mo.geometry = 
ST_Transform(CASE WHEN mp.geometrie IS NOT NULL THEN ST_GeomFromText(mp.geometrie,
			CASE WHEN substring(mp."Referentiehorizontaal.code" from 6)::int IS NULL THEN 4326
			ELSE substring(mp."Referentiehorizontaal.code" from 6)::int
			END)
		ELSE ST_SetSRID(ST_Point(mp."GeometriePunt.X", mp."GeometriePunt.Y"),
			CASE WHEN substring(mp."Referentiehorizontaal.code" from 6)::int IS NULL THEN 4326
			ELSE substring(mp."Referentiehorizontaal.code" from 6)::int
			END)
		END, 28992)

JOIN dump2.meetwaarden mw ON mw."Monster.Opmerking" = mp.Omschrijving AND ST_Point(mp."GeometriePunt.X", mp."GeometriePunt.Y") = ST_Point(mw."GeometriePunt.X", mw."GeometriePunt.Y")
JOIN public.compartiment_type ct ON ct.code = mw."MonsterCompartiment.code"

WHERE NOT EXISTS (
SELECT mc.mno_id FROM public.monitored_compartiment mc
WHERE
mc.mno_id = mo.mno_id and mc.cptm_id = ct.cptm_id
)