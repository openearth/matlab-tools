-- View: public.[VIEW_NAME]

-- DROP VIEW public.[VIEW_NAME];

CREATE OR REPLACE VIEW public.[VIEW_NAME] AS 
 SELECT object_group.ojg_id AS "ObjectGroup_ID",
    mo.inspire_id_local_id AS "Meetpunt.identificatie",
    mo.name AS "Meetpunt.omschrijving",
    mo.geometry_etrs89 AS "Meetpunt.Geometrie",
    st_x(st_centroid(mo.geometry_etrs89)) AS "Meetpunt.GeometryPunt.x",
    st_y(st_centroid(mo.geometry_etrs89)) AS "Meetpunt.GeometryPunt.y",
    'EPSG:'::text || st_srid(mo.geometry_etrs89) AS "ReferentieHorizontaal.code",
    mo.mno_id AS "Monster.identificatie",
    ct.code AS "Compartiment.code",
    va.code AS "Bemonsteringsmethode.code",
    va.description AS "Veldapparaat.omschrijving",
    typering_type.code AS "Typering.code",
    typering_type.omschrijving AS "Typering.omschrijving",
    grootheid_type.code AS "Grootheid.code",
    grootheid_type.omschrijving AS "Grootheid.omschrijving",
        CASE
            WHEN chemische_stof_type.code IS NULL THEN object_type.code
            ELSE chemische_stof_type.code
        END AS "Parameter.code",
        CASE
            WHEN chemische_stof_type.naam IS NULL THEN object_type.omschrijving
            ELSE chemische_stof_type.naam
        END AS "Parameter.omschrijving",
    chemische_stof_type.cas_nr AS "Chemischestof.casnr",
        CASE
            WHEN txg.name IS NULL THEN observed_property_type.remarks::character varying
            ELSE txg.name
        END AS "Taxon.naam",
    object_type.code AS "Object.code",
    object_type.omschrijving AS "Object.omschrijving",
    eenheid_type.code AS "Eenheid.code",
    eenheid_type.omschrijving AS "Eenheid.omschrijving",
    hoedanigheid_type.code AS "Hoedanigheid.code",
    hoedanigheid_type.omschrijving AS "Hoedanigheid.omschrijving",
    to_char(observation.phenomenon_time_begin, 'YYYY-MM-DD'::text) AS "Begindatum",
    to_char(observation.phenomenon_time_begin, 'HH24:MI:SS'::text) AS "Begintijd",
    to_char(observation.phenomenon_time_end, 'YYYY-MM-DD'::text) AS "Einddatum",
    to_char(observation.phenomenon_time_end, 'HH24:MI:SS'::text) AS "Eindtijd",
    bepaling_grens_type.omschrijving AS "Limietsymbool",
    observation.start_depth AS "Startdiepte",
    observation.end_depth AS "Einddiepte",
    observation.numeric_value AS "Numeriekewaarde",
    observation.description AS "Alfanumeriekewaarde",
    observation.remarks AS "Opmerking",
    mo.mno_id AS "Meetpunt.DB_ID",
    date_part('year'::text, observation.phenomenon_time_begin) AS "Rapportagejaar",
    observation.last_change_time,
    mo.wkrv_id AS "Versie",
    osc.name AS "Dataset.Naam"
	 , ht_levs.omschrijving as Levensstadium
	 , ht_len.omschrijving as Lengteklasse
	 , ht_ges.omschrijving as Geslacht
	 , ht_ver.omschrijving as Verschijningsvorm
	 , ht_levv.omschrijving as Levensvorm
	 , ht_ged.omschrijving as Gedrag
   FROM observation 
     JOIN observed_property_type ON observation.observed_property_type = observed_property_type.opt_id
     JOIN monitoring_object mo ON mo.mno_id = observation.mno_id
     LEFT JOIN grootheid_type ON observed_property_type.quantity_id = grootheid_type.grh_id
     LEFT JOIN object_group ON object_group.ojg_id = observed_property_type.object_group_id
     LEFT JOIN object_group_element ON object_group.ojg_id = object_group_element.ojg_id
     LEFT JOIN object_type ON object_group_element.obj_id = object_type.obj_id
     LEFT JOIN typering_type ON typering_type.typ_id = observed_property_type.indicator_id
     LEFT JOIN substance_group_element ON observed_property_type.substance_group_id = substance_group_element.ssge_id
     LEFT JOIN chemische_stof_type ON chemische_stof_type.chs_id = substance_group_element.chs_id
     JOIN eenheid_type ON observation.numeric_value_uom_id = eenheid_type.eenh_id
     LEFT JOIN bepaling_grens_type ON observation.limit_symbol_id = bepaling_grens_type.bpg_id
     LEFT JOIN taxa_group txg ON txg.txg_id = observed_property_type.taxa_group_id
     LEFT JOIN taxa_group_element txe ON txe.txg_id = txg.txg_id
     LEFT JOIN taxon_type txn ON txn.txn_id = txe.txg_id
     LEFT JOIN hoedanigheid_type ON hoedanigheid_type.hdh_id = observed_property_type.hoedanigheid_id
     LEFT JOIN sample sa ON sa.smpl_id = mo.mno_id
     LEFT JOIN sampling_proces sp ON sp.smp_id = sa.smp_id
     LEFT JOIN domains.veldapparaat va ON va.var_id = sp.var_id
     LEFT JOIN monitored_compartiment mc ON mc.mno_id = mo.mno_id
     LEFT JOIN compartiment_type ct ON ct.cptm_id = mc.cptm_id
     LEFT JOIN public.observing_capability_observation oco ON oco.obs_id = observation.obs_id
     LEFT JOIN public.observing_capability osc ON osc.osc_id = oco.osc_id
	  LEFT JOIN public.bio_observation bio on bio.obs_id=observation.obs_id
	  LEFT JOIN public.hoedanigheid_type ht_levs ON ht_levs.hdh_id = bio.levensstadium_id
	  LEFT JOIN public.hoedanigheid_type ht_len ON ht_len.hdh_id = bio.lengte_klasse_id
	  LEFT JOIN public.hoedanigheid_type ht_ges ON ht_ges.hdh_id = bio.geslacht_id
	  LEFT JOIN public.hoedanigheid_type ht_ver ON ht_ver.hdh_id = bio.verschijningsvorm_id
	  LEFT JOIN public.hoedanigheid_type ht_levv ON ht_levv.hdh_id = bio.levensvorm_id
	  LEFT JOIN public.hoedanigheid_type ht_ged ON ht_ged.hdh_id = bio.gedrag_id
;