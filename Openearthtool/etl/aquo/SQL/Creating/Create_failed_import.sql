-- Table: dump2.failed_import

-- DROP TABLE dump2.failed_import;

CREATE TABLE dump2.failed_import
(
  regelnummer character varying(10),
  "Dataset.naam" character varying(255),
  "Aquo.domeintabel" character varying(100),
  "Import.waarde" character varying(255)
)
WITH (
  OIDS=FALSE
);

