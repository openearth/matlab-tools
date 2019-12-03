Insert INTO dump2.failed_import
(regelnummer, "Dataset.naam", "Aquo.domeintabel", "Import.waarde")
SELECT
row_number() OVER () as regelnummer,
mw."Dataset.naam" as "Dataset.naam",
'public.hoedanigheid_type' as "Aquo.domeintabel",
mw."Referentiehorizontaal.code" as "Import.waarde"
FROM
dump2.meetwaarden mw
LEFT JOIN public.hoedanigheid_type dt ON dt."code" = mw."Referentiehorizontaal.code"
WHERE dt."code" IS NULL
AND mw."Referentiehorizontaal.code" IS NOT NULL;

Insert INTO dump2.failed_import
(regelnummer, "Dataset.naam", "Aquo.domeintabel", "Import.waarde")
SELECT
row_number() OVER () as regelnummer,
mw."Dataset.naam" as "Dataset.naam",
'public.Compartiment_type' as "Aquo.domeintabel",
mw."MonsterCompartiment.code" as "Import.waarde"
FROM
dump2.meetwaarden mw
LEFT JOIN public.Compartiment_type dt ON dt."code" = mw."MonsterCompartiment.code"
WHERE dt."code" IS NULL
AND mw."MonsterCompartiment.code" IS NOT NULL;

Insert INTO dump2.failed_import
(regelnummer, "Dataset.naam", "Aquo.domeintabel", "Import.waarde")
SELECT
row_number() OVER () as regelnummer,
mw."Dataset.naam" as "Dataset.naam",
'domains.orgaan' as "Aquo.domeintabel",
mw."Orgaan.code" as "Import.waarde"
FROM
dump2.meetwaarden mw
LEFT JOIN domains.orgaan dt ON dt."code" = mw."Orgaan.code"
WHERE dt."code" IS NULL
AND mw."Orgaan.code" IS NOT NULL;

Insert INTO dump2.failed_import
(regelnummer, "Dataset.naam", "Aquo.domeintabel", "Import.waarde")
SELECT
row_number() OVER () as regelnummer,
mw."Dataset.naam" as "Dataset.naam",
'public.taxa_group' as "Aquo.domeintabel",
mw."Organisme.naam" as "Import.waarde"
FROM
dump2.meetwaarden mw
LEFT JOIN public.taxa_group dt ON dt."name" = mw."Organisme.naam"
WHERE dt."name" IS NULL
AND mw."Organisme.naam" IS NOT NULL;

Insert INTO dump2.failed_import
(regelnummer, "Dataset.naam", "Aquo.domeintabel", "Import.waarde")
SELECT
row_number() OVER () as regelnummer,
mw."Dataset.naam" as "Dataset.naam",
'public.hoedanigheid_type' as "Aquo.domeintabel",
mw."Referentievlak.code" as "Import.waarde"
FROM
dump2.meetwaarden mw
LEFT JOIN public.hoedanigheid_type dt ON dt."code" = mw."Referentievlak.code"
WHERE dt."code" IS NULL
AND mw."Referentievlak.code" IS NOT NULL;

Insert INTO dump2.failed_import
(regelnummer, "Dataset.naam", "Aquo.domeintabel", "Import.waarde")
SELECT
row_number() OVER () as regelnummer,
mw."Dataset.naam" as "Dataset.naam",
'domains.monsterbewerkingsmethode' as "Aquo.domeintabel",
mw."Monsterbewerkingsmethode.code" as "Import.waarde"
FROM
dump2.meetwaarden mw
LEFT JOIN domains.monsterbewerkingsmethode dt ON dt."code" = mw."Monsterbewerkingsmethode.code"
WHERE dt."code" IS NULL
AND mw."Monsterbewerkingsmethode.code" IS NOT NULL;

Insert INTO dump2.failed_import
(regelnummer, "Dataset.naam", "Aquo.domeintabel", "Import.waarde")
SELECT
row_number() OVER () as regelnummer,
mw."Dataset.naam" as "Dataset.naam",
'domains.bemonsteringsmethode' as "Aquo.domeintabel",
mw."Bemonsteringsmethode.code" as "Import.waarde"
FROM
dump2.meetwaarden mw
LEFT JOIN domains.bemonsteringsmethode dt ON dt."code" = mw."Bemonsteringsmethode.code"
WHERE dt."code" IS NULL
AND mw."Bemonsteringsmethode.code" IS NOT NULL;

Insert INTO dump2.failed_import
(regelnummer, "Dataset.naam", "Aquo.domeintabel", "Import.waarde")
SELECT
row_number() OVER () as regelnummer,
mw."Dataset.naam" as "Dataset.naam",
'public.hoedanigheid_type' as "Aquo.domeintabel",
mw."Monstercriterium.code" as "Import.waarde"
FROM
dump2.meetwaarden mw
LEFT JOIN public.hoedanigheid_type dt ON dt."code" = mw."Monstercriterium.code"
WHERE dt."code" IS NULL
AND mw."Monstercriterium.code" IS NOT NULL;

Insert INTO dump2.failed_import
(regelnummer, "Dataset.naam", "Aquo.domeintabel", "Import.waarde")
SELECT
row_number() OVER () as regelnummer,
mw."Dataset.naam" as "Dataset.naam",
'domains.veldapparaat' as "Aquo.domeintabel",
mw."Meetapparaat.omschrijving" as "Import.waarde"
FROM
dump2.meetwaarden mw
LEFT JOIN domains.veldapparaat dt ON dt."description" = mw."Meetapparaat.omschrijving"
WHERE dt."description" IS NULL
AND mw."Meetapparaat.omschrijving" IS NOT NULL;

Insert INTO dump2.failed_import
(regelnummer, "Dataset.naam", "Aquo.domeintabel", "Import.waarde")
SELECT
row_number() OVER () as regelnummer,
mw."Dataset.naam" as "Dataset.naam",
'public.typering_type' as "Aquo.domeintabel",
mw."Typering.code" as "Import.waarde"
FROM
dump2.meetwaarden mw
LEFT JOIN public.typering_type dt ON dt."code" = mw."Typering.code"
WHERE dt."code" IS NULL
AND mw."Typering.code" IS NOT NULL;

Insert INTO dump2.failed_import
(regelnummer, "Dataset.naam", "Aquo.domeintabel", "Import.waarde")
SELECT
row_number() OVER () as regelnummer,
mw."Dataset.naam" as "Dataset.naam",
'public.grootheid_type' as "Aquo.domeintabel",
mw."Grootheid.code" as "Import.waarde"
FROM
dump2.meetwaarden mw
LEFT JOIN public.grootheid_type dt ON dt."code" = mw."Grootheid.code"
WHERE dt."code" IS NULL
AND mw."Grootheid.code" IS NOT NULL;

Insert INTO dump2.failed_import
(regelnummer, "Dataset.naam", "Aquo.domeintabel", "Import.waarde")
SELECT
row_number() OVER () as regelnummer,
mw."Dataset.naam" as "Dataset.naam",
'public.parameter_aquo_ds_20160105' as "Aquo.domeintabel",
mw."Parameter.code" as "Import.waarde"
FROM
dump2.meetwaarden mw
LEFT JOIN public.parameter_aquo_ds_20160105 dt ON dt."code" = mw."Parameter.code"
WHERE dt."code" IS NULL
AND mw."Parameter.code" IS NOT NULL;

Insert INTO dump2.failed_import
(regelnummer, "Dataset.naam", "Aquo.domeintabel", "Import.waarde")
SELECT
row_number() OVER () as regelnummer,
mw."Dataset.naam" as "Dataset.naam",
'public.parameter_aquo_ds_20160105' as "Aquo.domeintabel",
mw."Parameter.omschrijving" as "Import.waarde"
FROM
dump2.meetwaarden mw
LEFT JOIN public.parameter_aquo_ds_20160105 dt ON dt."omschrijving" = mw."Parameter.omschrijving"
WHERE dt."omschrijving" IS NULL
AND mw."Parameter.omschrijving" IS NOT NULL;

Insert INTO dump2.failed_import
(regelnummer, "Dataset.naam", "Aquo.domeintabel", "Import.waarde")
SELECT
row_number() OVER () as regelnummer,
mw."Dataset.naam" as "Dataset.naam",
'public.eenheid_type' as "Aquo.domeintabel",
mw."Eenheid.code" as "Import.waarde"
FROM
dump2.meetwaarden mw
LEFT JOIN public.eenheid_type dt ON dt."code" = mw."Eenheid.code"
WHERE dt."code" IS NULL
AND mw."Eenheid.code" IS NOT NULL;

Insert INTO dump2.failed_import
(regelnummer, "Dataset.naam", "Aquo.domeintabel", "Import.waarde")
SELECT
row_number() OVER () as regelnummer,
mw."Dataset.naam" as "Dataset.naam",
'public.hoedanigheid_type' as "Aquo.domeintabel",
mw."Hoedanigheid.code" as "Import.waarde"
FROM
dump2.meetwaarden mw
LEFT JOIN public.hoedanigheid_type dt ON dt."code" = mw."Hoedanigheid.code"
WHERE dt."code" IS NULL
AND mw."Hoedanigheid.code" IS NOT NULL;

Insert INTO dump2.failed_import
(regelnummer, "Dataset.naam", "Aquo.domeintabel", "Import.waarde")
SELECT
row_number() OVER () as regelnummer,
mw."Dataset.naam" as "Dataset.naam",
'public.waarde_bewerkings_methode_type' as "Aquo.domeintabel",
mw."Waardebewerkingsmethode.code" as "Import.waarde"
FROM
dump2.meetwaarden mw
LEFT JOIN public.waarde_bewerkings_methode_type dt ON dt."code" = mw."Waardebewerkingsmethode.code"
WHERE dt."code" IS NULL
AND mw."Waardebewerkingsmethode.code" IS NOT NULL;

Insert INTO dump2.failed_import
(regelnummer, "Dataset.naam", "Aquo.domeintabel", "Import.waarde")
SELECT
row_number() OVER () as regelnummer,
mw."Dataset.naam" as "Dataset.naam",
'public.waarde_bepalings_methode_type' as "Aquo.domeintabel",
mw."Waardebepalingsmethode.code" as "Import.waarde"
FROM
dump2.meetwaarden mw
LEFT JOIN public.waarde_bepalings_methode_type dt ON dt."code" = mw."Waardebepalingsmethode.code"
WHERE dt."code" IS NULL
AND mw."Waardebepalingsmethode.code" IS NOT NULL;

Insert INTO dump2.failed_import
(regelnummer, "Dataset.naam", "Aquo.domeintabel", "Import.waarde")
SELECT
row_number() OVER () as regelnummer,
mw."Dataset.naam" as "Dataset.naam",
'public.waarde_bepalings_methode_type' as "Aquo.domeintabel",
mw."Waardepalingsmethode.codespace" as "Import.waarde"
FROM
dump2.meetwaarden mw
LEFT JOIN public.waarde_bepalings_methode_type dt ON dt."codespace" = mw."Waardepalingsmethode.codespace"
WHERE dt."codespace" IS NULL
AND mw."Waardepalingsmethode.codespace" IS NOT NULL;

Insert INTO dump2.failed_import
(regelnummer, "Dataset.naam", "Aquo.domeintabel", "Import.waarde")
SELECT
row_number() OVER () as regelnummer,
mw."Dataset.naam" as "Dataset.naam",
'domains.waardebepalingstechniek' as "Aquo.domeintabel",
mw."Waardebepalingstechniek.code" as "Import.waarde"
FROM
dump2.meetwaarden mw
LEFT JOIN domains.waardebepalingstechniek dt ON dt."code" = mw."Waardebepalingstechniek.code"
WHERE dt."code" IS NULL
AND mw."Waardebepalingstechniek.code" IS NOT NULL;

Insert INTO dump2.failed_import
(regelnummer, "Dataset.naam", "Aquo.domeintabel", "Import.waarde")
SELECT
row_number() OVER () as regelnummer,
mw."Dataset.naam" as "Dataset.naam",
'public.bepaling_grens_type' as "Aquo.domeintabel",
mw."limietsymbool" as "Import.waarde"
FROM
dump2.meetwaarden mw
LEFT JOIN public.bepaling_grens_type dt ON dt."code" = mw."limietsymbool"
WHERE dt."code" IS NULL
AND mw."limietsymbool" IS NOT NULL;

Insert INTO dump2.failed_import
(regelnummer, "Dataset.naam", "Aquo.domeintabel", "Import.waarde")
SELECT
row_number() OVER () as regelnummer,
mw."Dataset.naam" as "Dataset.naam",
'public.kwaliteitsoordeel_type' as "Aquo.domeintabel",
mw."Kwaliteitsoordeel.code" as "Import.waarde"
FROM
dump2.meetwaarden mw
LEFT JOIN public.kwaliteitsoordeel_type dt ON dt."code" = mw."Kwaliteitsoordeel.code"
WHERE dt."code" IS NULL
AND mw."Kwaliteitsoordeel.code" IS NOT NULL;

