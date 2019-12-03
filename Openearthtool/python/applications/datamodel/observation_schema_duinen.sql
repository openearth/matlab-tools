CREATE SCHEMA "mep-duinen";
SET search_path = "mep-duinen", pg_catalog, public;
CREATE SEQUENCE location_idlocation_seq;

CREATE TABLE location (
                idlocation INTEGER DEFAULT nextval('location_idlocation_seq'::regclass) NOT NULL ,
                locationdescription VARCHAR(255),
                published BOOLEAN,
                CONSTRAINT location_pkey PRIMARY KEY (idlocation)
);


ALTER SEQUENCE location_idlocation_seq OWNED BY location.idlocation;





CREATE TABLE location_line (
                thegeometry GEOMETRY NOT NULL,
                wktline TEXT NOT NULL
) INHERITS(location);
COMMENT ON COLUMN location_line.thegeometry IS 'Geometry deferred fom wkt (and srid).';
COMMENT ON COLUMN location_line.wktline IS 'WKT representation of a line (incl. SRID).';



CREATE TABLE location_poly (
                thegeometry GEOMETRY NOT NULL,
                wktpoly TEXT NOT NULL
) INHERITS (location);
COMMENT ON COLUMN location_poly.wktpoly IS 'WKT representation of the original/source polygon data (incl. SRID)';



CREATE SEQUENCE metadata_id_seq;

CREATE TABLE metadata (
                id INTEGER NOT NULL DEFAULT nextval('metadata_id_seq'),
                dataset_person TEXT,
                dataset_party TEXT,
                dataset_phone TEXT,
                dataset_address TEXT,
                dataset_city TEXT,
                dataset_pobx TEXT,
                dataset_country TEXT,
                dataset_mail TEXT,
                resp_person TEXT,
                resp_party TEXT,
                resp_phone TEXT,
                resp_address TEXT,
                resp_city TEXT,
                resp_pobx TEXT,
                resp_country TEXT,
                resp_mail TEXT,
                title TEXT,
                purpose TEXT,
                abstract TEXT,
                url TEXT,
                qry_spatialextent TEXT,
                qry_keywords TEXT,
                vocabular TEXT,
                qry_timeextent TEXT,
                uidentifier TEXT,
                geom_table TEXT,
                geom_column TEXT,
                CONSTRAINT metadata_pk PRIMARY KEY (id)
);


ALTER SEQUENCE metadata_id_seq OWNED BY metadata.id;

CREATE TABLE location_point (
                thegeometry GEOMETRY NOT NULL,
                wkt_point TEXT NOT NULL
) INHERITS (location);
COMMENT ON COLUMN location_point.wkt_point IS 'WKT representation of the original/source point data (incl SRID).';



CREATE SEQUENCE observation_idobservation_seq;

CREATE TABLE observation (
                idobservation   INTEGER DEFAULT nextval('observation_idobservation_seq'::regclass) NOT NULL,
                startdatetime   TIMESTAMP NOT NULL,
                utcoffset       VARCHAR(10) DEFAULT '+01:00ST' NOT NULL,
                depth           REAL NOT NULL,
                thresholdsymbol VARCHAR(1) NOT NULL,
                idlocation      INTEGER NOT NULL,
                idcompartment   INTEGER NOT NULL,
                idproperty      INTEGER NOT NULL,
                idunit          INTEGER NOT NULL,
                idparameter     INTEGER NOT NULL,
                idsampledevice  INTEGER NOT NULL,
                enddatetime     TIMESTAMP,
                numvalue        REAL,
                alfanumvalue    VARCHAR(50),
                processingjobid INTEGER,
                remark          VARCHAR(255),
                blstatus        BOOLEAN DEFAULT false,
                idstation       VARCHAR(75),
                idorgan         INTEGER,
                idquality       INTEGER,
                idsamplemethod  INTEGER,
                idmeasurementmethod INTEGER,
		idvaluetype	INTEGER,
                idtaxon         INTEGER,
		idfish		BIGINT,
		idparentfish	BIGINT,
                CONSTRAINT pk_observation PRIMARY KEY (idobservation)
);
COMMENT ON COLUMN observation.startdatetime IS 'Observation start date and time. What is de default time when no time is specified?';
COMMENT ON COLUMN observation.enddatetime IS 'Observation end date and time.';
COMMENT ON COLUMN observation.utcoffset IS 'Time zone offset (startdatetime and enddatetime) relative to UTC, with specification of Day Light Saving Time (DST) or Standard Time (ST).
Format: [+|-]hh:mm[ST|DST]';
COMMENT ON COLUMN observation.depth IS 'Depth on a observation location.
(location, date, depth, parameter...)=AK?';
COMMENT ON COLUMN observation.numvalue IS 'Numeric observation value.
When not specified, there should be a alfanum value indication.';
COMMENT ON COLUMN observation.alfanumvalue IS 'AlfaNumeric observation value.
When not specified, there should be a numeric value specified.';
COMMENT ON COLUMN observation.processingjobid IS 'Reference to lineage (meta) data on how data was upload into the database.';
COMMENT ON COLUMN observation.thresholdsymbol IS '"<" if value below reporting threshold.
">" if value above reporting threshold.';
COMMENT ON COLUMN observation.idproperty IS 'FK to property (AQUO hoedanigheid), default NVT';
COMMENT ON COLUMN observation.idvaluetype IS 'FK to valuetype (AQUO waardebepalingsmethode), default NVT';

ALTER SEQUENCE observation_idobservation_seq OWNED BY observation.idobservation;

CREATE INDEX indx_obsdate
 ON observation USING BTREE
 ( startdatetime );

CREATE INDEX indx_obslocid
 ON observation USING BTREE
 ( idlocation );

CREATE SEQUENCE extattribute_idextattribute_seq;

CREATE TABLE extattribute (
                idextattribute INTEGER NOT NULL DEFAULT nextval('extattribute_idextattribute_seq'),
                idobservation INTEGER DEFAULT nextval('observation_idobservation_seq'::regclass) NOT NULL,
                attributename VARCHAR(50) NOT NULL,
                numvalue REAL,
                alfanumvalue VARCHAR(50),
                CONSTRAINT extattribute_pk PRIMARY KEY (idextattribute, idobservation)
);
COMMENT ON TABLE extattribute IS 'Table for dynamic creation of ad hoc extra Observation attributes.';
COMMENT ON COLUMN extattribute.numvalue IS 'Numeric observation value for extra attribute.
When not specified, there should be a alfanum value indication.';
COMMENT ON COLUMN extattribute.alfanumvalue IS 'AlfaNumeric observation value.
When not specified, there should be a numeric value specified.';


ALTER SEQUENCE extattribute_idextattribute_seq OWNED BY extattribute.idextattribute;



-- FK constraints and inheritance is not working...
--ALTER TABLE observation ADD CONSTRAINT fk_location
--FOREIGN KEY (idlocation)
--REFERENCES location (idlocation)
--ON DELETE NO ACTION
--ON UPDATE NO ACTION
--NOT DEFERRABLE;

-- FK constraints and inheritance is not working...
--ALTER TABLE observation ADD CONSTRAINT fk_taxon
--FOREIGN KEY (idtaxon)
--REFERENCES taxon (idtaxon)
--ON DELETE NO ACTION
--ON UPDATE NO ACTION
--NOT DEFERRABLE;

ALTER TABLE observation ADD CONSTRAINT fk_property
FOREIGN KEY (idproperty)
REFERENCES public.property (idproperty)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;



ALTER TABLE observation ADD CONSTRAINT fk_compartment
FOREIGN KEY (idcompartment)
REFERENCES public.compartment (idcompartment)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE observation ADD CONSTRAINT fk_measurementmethod
FOREIGN KEY (idmeasurementmethod)
REFERENCES public.measurementmethod (idmeasurementmethod)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE observation ADD CONSTRAINT fk_valuetype
FOREIGN KEY (idvaluetype)
REFERENCES public.valuetype (idvaluetype)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE observation ADD CONSTRAINT fk_samplemethod
FOREIGN KEY (idsamplemethod)
REFERENCES public.samplemethod (idsamplemethod)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE observation ADD CONSTRAINT fk_quality
FOREIGN KEY (idquality)
REFERENCES public.quality (idquality)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE observation ADD CONSTRAINT fk_unit
FOREIGN KEY (idunit)
REFERENCES public.unit (idunit)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

-- FK constraints and inheritance is not working...
--ALTER TABLE observation ADD CONSTRAINT fk_parameter
--FOREIGN KEY (idparameter)
--REFERENCES public.parameter (idparameter)
--ON DELETE NO ACTION
--ON UPDATE NO ACTION
--NOT DEFERRABLE;

ALTER TABLE observation ADD CONSTRAINT fk_sampledevice
FOREIGN KEY (idsampledevice)
REFERENCES public.sampledevice (idsampledevice)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE observation ADD CONSTRAINT fk_organ
FOREIGN KEY (idorgan)
REFERENCES public.organ (idorgan)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE extattribute ADD CONSTRAINT observation_extattribute_fk
FOREIGN KEY (idobservation)
REFERENCES observation (idobservation)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

-- The VIEWS:
CREATE VIEW meetobject AS (
	SELECT idlocation as "Meetpunt.Identificatie"
	       ,locationdescription AS "Meetpuntomschrijving"
	       ,thegeometry AS "Geometrie"
	       ,ST_SRID(thegeometry) AS "EPSGcode"
	FROM location_point
	WHERE idlocation in (
	  SELECT DISTINCT idlocation
	  FROM observation
	)
);

CREATE VIEW monster AS (
SELECT
	 idobservation AS "Identificatie"
	,l.idlocation AS "Meetpunt.identificatie"
	,l.thegeometry AS "Geometrie"
	,c.compartmentcode AS "compartiment.code"
	,g.organcode AS "orgaan.code"
	,t.scientificname AS "Biotaxon.naam"
	,depth as "begindiepte_m"
	,'Niet geimplementeerd'::varchar(20) AS "referentievlak.code"
	,'Niet geimplementeerd'::varchar(20) AS "monsterbewerkingsmethode.code"
	,sm.samplemethodcode AS "bemonsteringsmethode.code"
	,sd.sampledevicedescription AS "Veldapparaat.omschrijving"
	,o.startdatetime AS "monsternemingsdatum"
	,o.utcoffset AS "UTCoffset"
FROM observation o
JOIN location_point l ON o.idlocation=l.idlocation
JOIN public.compartment c ON c.idcompartment=o.idcompartment
LEFT JOIN public.organ g ON g.idorgan=o.idorgan
LEFT JOIN public.taxon_worms t ON t.idtaxon=o.idtaxon
LEFT JOIN public.samplemethod sm ON sm.idsamplemethod=o.idsamplemethod
LEFT JOIN public.sampledevice sd ON sd.idsampledevice=o.idsampledevice
);


CREATE VIEW meting AS (
SELECT
	 o.idobservation AS "Monster.identificatie"
	,o.idobservation AS "Meetpunt.identificatie"
	,p.parameterdescription AS "Parameter.omschrijving"
	,t.scientificname AS "Biotaxon.naam"
	,u.unitcode AS "Eenheid.code"
	,h.propertycode AS "Hoedanigheid.code"
	,v.valuetypecode AS "Waardebewerkingsmethode.code"
--	, AS "Waardebewerkingsmethode.code"
--	, AS "Waardebepalingsmethode.omschrijving"
	,m.samplemethodcode AS "Bemonsteringsmethode.code"
	,o.startdatetime AS "Begindatum"
	,o.utcoffset AS "Tijd_UTCoffset"
	,o.thresholdsymbol AS "Limietsymbool"
	,o.numvalue AS "Numeriekewaarde"
	,q.qualitycode AS "Kwaliteitsoordeel.code"
	,l.thegeometry as "Geometrie"
FROM observation o
JOIN public.unit u ON u.idunit=o.idunit
JOIN public.parameter p ON p.idparameter=o.idparameter
JOIN public.property h ON h.idproperty=o.idproperty
JOIN location_point l on l.idlocation=o.idlocation
LEFT JOIN public.taxon_worms t ON t.idtaxon=o.idtaxon
LEFT OUTER JOIN public.quality q ON q.idquality=o.idquality
LEFT OUTER JOIN public.samplemethod m ON m.idsamplemethod=o.idsamplemethod
LEFT OUTER JOIN public.valuetype v ON v.idvaluetype=o.idvaluetype
);
