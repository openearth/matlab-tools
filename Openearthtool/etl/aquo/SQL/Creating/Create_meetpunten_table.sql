-- Table: dump2.meetpunten

-- DROP TABLE dump2.meetpunten;

CREATE TABLE dump2.meetpunten
(
  identificatie character varying(36) NOT NULL,
  namespace character varying(6),
  versie character varying(30),
  omschrijving character varying(36),
  "GeometriePunt.X" double precision NOT NULL,
  "GeometriePunt.Y" double precision NOT NULL,
  "Plaatsbepaling.code" character varying(10),
  "Plaatsbepaling.codespace" character varying(30),
  "MeetobjectSoort.code" character varying(10),
  gerelateerdmeetobject character varying(30),
  "GerelateerdMeetobjectRol.id" integer,
  geometrie character varying(10000),
  "Referentiehorizontaal.code" character varying(30),
  CONSTRAINT pk_location PRIMARY KEY (omschrijving, "GeometriePunt.X", "GeometriePunt.Y")
)
WITH (
  OIDS=FALSE
);