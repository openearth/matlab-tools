-- SELECT * FROM public.monitoring_object
-- DELETE FROM public.monitoring_object

INSERT  INTO public.monitoring_object
(wkrv_id, inspire_id_local_id, inspire_id_namespace_id, primary_geodetic_reference_id, monitoring_object_type,
name, additional_description, geometry, last_change_time, geometry_etrs89, begin_lifespan_version, end_lifespan_version,
primary_geo_column, reason_change)

SELECT DISTINCT
wk.wkrv_id,
'0001', --> Gokje
4, --> Gokje
h.hdh_id, --> Op basis van huidige CRS
'Sample', --> Gokje
mw."Meetobject.lokaalID",
'Test dataset',
ST_SetSRID(ST_Point(64000, 430000), 28992),
NOW(),
st_transform(ST_SetSRID(ST_Point(64000, 430000), 28992) ,4258),
wk.begin_lifespan_version,
wk.end_lifespan_version,
'geometry',
'First insert'
FROM dump.meetwaarden2 mw,
hoedanigheid_type h,
wkr_version wk
WHERE h.code = 'EPSG:28992' 
AND wk.wkrv_id = (
SELECT wkrv_id 
FROM wkr_version 
order by begin_lifespan_version desc limit 1!)
