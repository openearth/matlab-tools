DELETE FROM dump.meetwaarden;

DELETE FROM dump.meetpunten;

-- Filled in tables
DELETE FROM public.observing_capability_observation;

DELETE FROM public.observing_capability_sample;

DELETE FROM public.observing_capability;

DELETE FROM public.monitored_compartiment;

DELETE FROM public.bio_observation;

DELETE FROM public.sample;

DELETE FROM public.sampling_proces;

DELETE FROM public.observation;

DELETE FROM public.observed_property_type;

DELETE FROM public.monitoring_object;

-- Domain tables
DELETE FROM public.opt_class_result_type_type;

DELETE FROM public.bepaling_grens_type;

DELETE FROM public.wkr_version;

DELETE FROM public.chemische_stof_type;

DELETE FROM public.typering_type;

DELETE FROM public.grootheid_type;

DELETE FROM public.object_group_element;

DELETE FROM public.object_group;

DELETE FROM public.object_type;

DELETE FROM public.substance_group_element;

DELETE FROM public.substance_group;

DELETE FROM public.parameter_aquo_ds_20160105;

DELETE FROM public.eenheid_type;

DELETE FROM public.taxa_group;

DELETE FROM public.hoedanigheid_type;

DELETE FROM public.compartiment_type;

DELETE FROM public.waarde_bewerkings_methode_type;

DELETE FROM public.kwaliteitsoordeel_type;

DELETE FROM public.waarde_bepalings_methode_type;

DELETE FROM domains.veldapparaat;

DELETE FROM domains.monsterbewerkingsmethode;

DELETE FROM domains.waardebepalingstechniek;

DELETE FROM domains.orgaan;

DELETE FROM domains.bemonsteringsmethode;
-- 2;"2012-10-15 00:00:00";"2021-12-31 00:00:00";"2017-04-11 15:29:53.621"
