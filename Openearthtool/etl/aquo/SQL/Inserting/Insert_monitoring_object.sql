-- SELECT * FROM public.monitoring_object
-- DELETE FROM public.monitoring_object

INSERT  INTO public.monitoring_object
(wkrv_id, inspire_id_local_id, inspire_id_namespace_id, primary_geodetic_reference_id, monitoring_object_type,
name, additional_description, geometry, last_change_time, geometry_etrs89, begin_lifespan_version, end_lifespan_version,
primary_geo_column, reason_change)

SELECT DISTINCT
	wk.wkrv_id,
	'0001' as inspire_id_local_id, --> Gokje
	4 as inspire_id_namespace_id, --> Gokje
	h.hdh_id as primary_geodetic_reference_id, --> Op basis van huidige CRS
	'Sample' as monitoring_object_type, --> Gokje
	mp.Omschrijving as name,
	'' as additional_description,

	ST_Transform(CASE WHEN mp.geometrie IS NOT NULL THEN ST_GeomFromText(mp.geometrie, 
		CASE WHEN substring(mp."Referentiehorizontaal.code" from 6)::int IS NULL THEN 4326
		ELSE substring(mp."Referentiehorizontaal.code" from 6)::int
		END)
	ELSE ST_SetSRID(ST_Point(mp."GeometriePunt.X", mp."GeometriePunt.Y"),
		CASE WHEN substring(mp."Referentiehorizontaal.code" from 6)::int IS NULL THEN 4326
		ELSE substring(mp."Referentiehorizontaal.code" from 6)::int
		END)
	END, 28992) as geometry,
	NOW() as last_change_time,
	--st_transform(ST_SetSRID(ST_Point(mp."GeometriePunt.X", mp."GeometriePunt.Y"), 28992) ,4258) as geometry_etrs89,
	
	ST_Transform((CASE WHEN mp.geometrie IS NOT NULL THEN ST_GeomFromText(mp.geometrie, 
		CASE WHEN substring(mp."Referentiehorizontaal.code" from 6)::int IS NULL THEN 4326
		ELSE substring(mp."Referentiehorizontaal.code" from 6)::int
		END)
	ELSE ST_SetSRID(ST_Point(mp."GeometriePunt.X", mp."GeometriePunt.Y"),
		CASE WHEN substring(mp."Referentiehorizontaal.code" from 6)::int IS NULL THEN 4326
		ELSE substring(mp."Referentiehorizontaal.code" from 6)::int
		END)
	END),4258) as geometry_etrs89,
	wk.begin_lifespan_version,
	wk.end_lifespan_version,
	'geometry' as primary_geo_column,
	'' as reason_change
FROM dump2.meetpunten mp
JOIN dump2.meetwaarden mw ON mw."Monster.Opmerking" = mp.Omschrijving AND ST_Point(mp."GeometriePunt.X", mp."GeometriePunt.Y") = ST_Point(mw."GeometriePunt.X", mw."GeometriePunt.Y"),
hoedanigheid_type h,
wkr_version wk
WHERE h.code = 'EPSG:28992' 
AND wk.wkrv_id = (
SELECT wkrv_id 
FROM wkr_version 
order by begin_lifespan_version desc limit 1!)
AND NOT EXISTS(
SELECT * FROM public.monitoring_object mo
WHERE
mo.geometry = ST_Transform(CASE WHEN mp.geometrie IS NOT NULL THEN ST_GeomFromText(mp.geometrie,
			CASE WHEN substring(mp."Referentiehorizontaal.code" from 6)::int IS NULL THEN 4326
			ELSE substring(mp."Referentiehorizontaal.code" from 6)::int
			END)
		ELSE ST_SetSRID(ST_Point(mp."GeometriePunt.X", mp."GeometriePunt.Y"),
			CASE WHEN substring(mp."Referentiehorizontaal.code" from 6)::int IS NULL THEN 4326
			ELSE substring(mp."Referentiehorizontaal.code" from 6)::int
			END)
		END, 28992)
AND
mo.name = mp.Omschrijving)