-- SELECT * FROM public.observed_property_type
-- DELETE FROM public.observed_property_type

INSERT INTO public.observed_property_type
(observed_property_type_class, result_type, quantity_id, object_group_id, substance_group_id, taxa_group_id, indicator_id, hoedanigheid_id)
SELECT DISTINCT
-- h.hdh_id as hoedanigheid_id, -- Op basis van meegegeven hoedanigheid.code in dump.meetwaarden
o.observed_property_type_class_type, -- Type opt_class ook een GOKJE
o.result_type_type, -- Type resultaat (enumeratie) bepaalt hoe het resultaat vastgelegd moet worden (measure, analysis, classified, description) GOKJE
g.grh_id, -- Op basis van meegegeven grootheid.code in dump.meetwaarden
og.ojg_id as object_group_id,
s.ssg_id as substance_group_id,
tg.txg_id as taxa_group_id,
tp.typ_id as indicator_id,
hdh.hdh_id as hoedanigheid_id
FROM dump.meetwaarden2 mw
LEFT JOIN grootheid_type g ON g.code = mw."Grootheid.code"
LEFT JOIN public.parameter_aquo_ds_20160105 p ON p.code = mw."Parameter.code"
LEFT JOIN public.substance_group s ON s.name = p.omschrijving
LEFT JOIN public.object_group og ON og.name = p.omschrijving
LEFT JOIN public.taxa_group tg ON tg.name = mw."Biotaxon.naam"
LEFT JOIN public.typering_type tp ON tp.code = mw."Typering.code"
LEFT JOIN public.hoedanigheid_type hdh ON hdh.code = mw."Hoedanigheid.code",
public.opt_class_result_type_type o
WHERE o.result_type_type = 'MeasureResult' --> Dit is de GOK
AND o.observed_property_type_class_type = 'PhysicalObservation' --> Dit is de GOK
