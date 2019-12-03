-- Voor een overzicht
select count(*) as "Number of rows", "Dataset.naam", "Aquo.domeintabel", "Import.waarde" FROM dump2.failed_import
-- WHERE "Dataset.naam" = 'SpisulaBiota' -- Voor check per dataset
GROUP BY "Dataset.naam", "Aquo.domeintabel", "Import.waarde"
ORDER BY "Dataset.naam"

-- Om te tellen
select COUNT(*) FROM dump2.failed_import

-- Om te verwijderen
DELETE FROM dump2.failed_import