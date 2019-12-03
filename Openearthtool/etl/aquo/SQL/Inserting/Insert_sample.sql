-- SELECT * FROM public.sample
-- DELETE FROM public.sample

INSERT INTO public.sample (
smpl_id, name, material_class_id, sampling_time, sampling_location,
upper_depth_value, upper_depth_uom_id, lower_depth_value, lower_depth_uom_id, smp_id,
organ_id
)

SELECT
mo.mno_id as smpl_id,
-- Oorspronkelijk had ik hier mo.name staan, maar het is waarschijnlijk beter om dit als "Monster.Identificatie" In te vullen.
-- Dit kan wel tot problemen leiden omdat dit per meetpunt wordt meegegeven, maar niet voor alle monitoring objecten wordt opgeslagen.
-- Ik denk dat het wel kan. Maar heb nog geen use-case gevonden om dit te testen.
-- EDIT 2: Use-case gevonden :). Ik heb het nu zo aangepast dat mo.name gelijk is aan monster.identificatie
mo.name as name,
ct.cptm_id as material_class_id,
(mw.Begindatum || ' ' || 
(CASE WHEN mw.Begintijd is null THEN '00:00:00'
	ELSE mw.Begintijd
END))::timestamp as sampling_time,
mo.geometry as sampling_location,
MIN(mw.begindiepte_m) as upper_depth_value,
e.eenh_id as upper_depth_uom_id, --> From public.eenheid_type since, it will take the unit of the depth (m)
MAX(mw.einddiepte_m) as lower_depth_value,
e.eenh_id as lower_depth_uom_id, --> From public.eenheid_type
sp.smp_id as smp_id,
org.org_id as organ_id
FROM dump2.meetwaarden mw
JOIN public.eenheid_type et ON et.code = mw."Eenheid.code"
JOIN public.grootheid_type g ON g.code = mw."Grootheid.code"

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
LEFT JOIN domains.orgaan org ON org.code = mw."Orgaan.code"

JOIN public.compartiment_type ct ON ct.code = mw."MonsterCompartiment.code"
JOIN domains.veldapparaat va ON va.description = mw."Meetapparaat.omschrijving" OR va.code = mw."Meetapparaat.omschrijving"
JOIN public.sampling_proces sp ON sp.var_id = va.var_id,

public.eenheid_type e
WHERE e.code = 'm'
AND NOT EXISTS
(SELECT sa.smpl_id FROM sample sa
WHERE sa.smpl_id = mo.mno_id)
GROUP BY mo.mno_id, mo.name, ct.cptm_id, mo.geometry, mw.Begindatum, mw.Begintijd, sp.smp_id, e.eenh_id, org.org_id
