SET SCHEMA 'mep-nsw_pvis';
CREATE SEQUENCE location_idlocation_seq;

CREATE TABLE location (
                idlocation INTEGER DEFAULT nextval('location_idlocation_seq'::regclass) NOT NULL ,
                locationdescription VARCHAR(255),
                published BOOLEAN,
                CONSTRAINT location_pkey PRIMARY KEY (idlocation)
);


ALTER SEQUENCE location_idlocation_seq OWNED BY location.idlocation;

CREATE SEQUENCE parameter_idparameter_seq;

CREATE TABLE parameter (
                idparameter INTEGER DEFAULT nextval('parameter_idparameter_seq'::regclass) NOT NULL ,
                parameterdescription VARCHAR(255) NOT NULL,
                CONSTRAINT pk_parameter PRIMARY KEY (idparameter)
);
COMMENT ON TABLE parameter IS 'This is the parameter database. The database consists of a serial key (idparameter), a field with a general description (in case of species names, this is the scientific name), foreign key and a table name. The combination tablename and foreign key form a unique combination and will be used as a constraint.';
COMMENT ON COLUMN parameter.parameterdescription IS 'description derived from the referencetable (i.e. species, chemical characteristic, sediment characteristic)';



CREATE SEQUENCE taxon_idtaxon_seq;

CREATE TABLE taxon (
                idtaxon INTEGER DEFAULT nextval('taxon_idtaxon_seq'::regclass) NOT NULL ,
                CONSTRAINT pk_taxon PRIMARY KEY (idtaxon)
);
COMMENT ON TABLE taxon IS 'This is the taxon database.';

ALTER SEQUENCE taxon_idtaxon_seq OWNED BY taxon.idtaxon;


CREATE INDEX indx_paramdesc
 ON parameter USING BTREE
 ( parameterdescription );

CREATE INDEX indx_paramid
 ON parameter USING BTREE
 ( idparameter );

ALTER SEQUENCE parameter_idparameter_seq OWNED BY parameter.idparameter;

CREATE SEQUENCE property_idproperty_seq;

CREATE TABLE property (
                idproperty INTEGER DEFAULT nextval('property_idproperty_seq'::regclass) NOT NULL,
                propertydescription TEXT NOT NULL,
                propertyreference TEXT,
                propertycode VARCHAR(12),
                CONSTRAINT pk_property PRIMARY KEY (idproperty)
);
COMMENT ON TABLE property IS 'AQUO: Hoedanigheid';
COMMENT ON COLUMN property.propertyreference IS 'optional reference to documentation on the property';
COMMENT ON COLUMN property.propertycode IS 'AQUO: AQUO code voor hoedanigheid.';

CREATE INDEX indx_idproperty
 ON property USING BTREE
 ( idproperty );

ALTER SEQUENCE property_idproperty_seq OWNED BY property.idproperty;

CREATE TABLE parameter_physical (
		code VARCHAR(50),
                parameteralias VARCHAR(50),
                referencelink VARCHAR(255)
) INHERITS (parameter);


CREATE SEQUENCE group_idgroup_seq;

CREATE TABLE "group" (
                idgroup INTEGER DEFAULT nextval('group_idgroup_seq'::regclass) NOT NULL,
                groupdescription TEXT NOT NULL,
                CONSTRAINT pkgroup PRIMARY KEY (idgroup)
);
COMMENT ON TABLE "group" IS 'Group description (lut)';
COMMENT ON COLUMN "group".idgroup IS 'Group identifier';
COMMENT ON COLUMN "group".groupdescription IS 'full description of the group';


ALTER SEQUENCE group_idgroup_seq OWNED BY "group".idgroup;

CREATE SEQUENCE compartment_idcompartment_seq;

CREATE TABLE compartment (
                idcompartment INTEGER DEFAULT nextval('compartment_idcompartment_seq'::regclass) NOT NULL,
                compartmentcode VARCHAR(12) NOT NULL,
                compartmentnumber VARCHAR(12) NOT NULL,
                compartmentdescription VARCHAR(60) NOT NULL,
                compartmentlink text,
                idgroup INTEGER,
                CONSTRAINT pk_compartment PRIMARY KEY (idcompartment)
);
COMMENT ON TABLE compartment IS 'description of the compartment from which the sample has been taken, can any part of the environment as well as tissue of an organisme';
COMMENT ON COLUMN compartment.idgroup IS 'Group identifier';


ALTER SEQUENCE compartment_idcompartment_seq OWNED BY compartment.idcompartment;

CREATE SEQUENCE measurementmethod_idmeasurementmethod_seq;

CREATE TABLE measurementmethod (
                idmeasurementmethod INTEGER DEFAULT nextval('measurementmethod_idmeasurementmethod_seq'::regclass) NOT NULL,
                measurementmethodtype TEXT NOT NULL,
                measurementmethoddescription TEXT NOT NULL,
                measurementmethodlink TEXT,
                idgroup INTEGER,
                CONSTRAINT pk_measurementmethod PRIMARY KEY (idmeasurementmethod)
);
COMMENT ON TABLE measurementmethod IS 'TypeWaardebepalingsmethodeType';
COMMENT ON COLUMN measurementmethod.measurementmethodlink IS 'optional link to full description of measurement type';
COMMENT ON COLUMN measurementmethod.idgroup IS 'Group identifier';


ALTER SEQUENCE measurementmethod_idmeasurementmethod_seq OWNED BY measurementmethod.idmeasurementmethod;

CREATE TABLE location_line (
                thegeometry GEOMETRY NOT NULL,
                wktline TEXT NOT NULL
) INHERITS(location);
COMMENT ON COLUMN location_line.thegeometry IS 'Geometry deferred fom wkt (and srid).';
COMMENT ON COLUMN location_line.wktline IS 'WKT representation of a line (incl. SRID).';


CREATE SEQUENCE samplemethod_idsamplemethod_seq;

CREATE TABLE samplemethod (
                idsamplemethod INTEGER DEFAULT nextval('samplemethod_idsamplemethod_seq'::regclass) NOT NULL,
                samplemethodtype TEXT,
                samplemethoddescription TEXT NOT NULL,
                samplemethodlink TEXT,
                idgroup INTEGER,
                samplemethodreference TEXT,
                samplemethodcode VARCHAR(12) NOT NULL,
                CONSTRAINT pk_samplemethod PRIMARY KEY (idsamplemethod)
);
COMMENT ON COLUMN samplemethod.samplemethodlink IS 'optional link to sample method description';
COMMENT ON COLUMN samplemethod.idgroup IS 'Group identifier';


ALTER SEQUENCE samplemethod_idsamplemethod_seq OWNED BY samplemethod.idsamplemethod;

CREATE TABLE location_poly (
                thegeometry GEOMETRY NOT NULL,
                wktpoly TEXT NOT NULL
) INHERITS (location);
COMMENT ON COLUMN location_poly.wktpoly IS 'WKT representation of the original/source polygon data (incl. SRID)';


CREATE TABLE parameter_chemical (
		code VARCHAR(12) NOT NULL,
		casnumber VARCHAR(25),
		sikbid integer,
                referencelink text
) INHERITS (parameter);
COMMENT ON TABLE parameter_chemical IS 'chemical parameters according to AQUO';


CREATE TABLE parameter_pesi (
                pesiid INTEGER,
                guid VARCHAR(255),
                referencelink VARCHAR(255),
                scientificname VARCHAR(255),
                authority VARCHAR(255),
                status VARCHAR(255),
                kingdom VARCHAR(255),
                phylum VARCHAR(255),
                class VARCHAR(255),
                "order" VARCHAR(255),
                family VARCHAR(255),
                genus VARCHAR(255),
                subgenus VARCHAR(255),
                species VARCHAR(255),
                subspecies VARCHAR(255),
                citation TEXT
) INHERITS (parameter);


CREATE SEQUENCE quality_idquality_seq;

CREATE TABLE quality (
                idquality INTEGER DEFAULT nextval('quality_idquality_seq'::regclass) NOT NULL,
                qualitycode VARCHAR(12) NOT NULL,
                qualitydescription VARCHAR(60) NOT NULL,
                qualitylink text,
                idgroup INTEGER,
                CONSTRAINT pk_quality PRIMARY KEY (idquality)
);
COMMENT ON TABLE quality IS 'Quality judgement';
COMMENT ON COLUMN quality.idgroup IS 'Group identifier';


ALTER SEQUENCE quality_idquality_seq OWNED BY quality.idquality;

CREATE TABLE taxon_worms (
                aphiaid INTEGER NOT NULL,
                scientificname VARCHAR(255),
                authority VARCHAR(255),
                status VARCHAR(255),
                aphiaid_accepted INTEGER,
                kingdom VARCHAR(255),
                phylum VARCHAR(255),
                class VARCHAR(255),
                "order" VARCHAR(255),
                family VARCHAR(255),
                genus VARCHAR(255),
                subgenus VARCHAR(255),
                species VARCHAR(255),
                subspecies VARCHAR(255),
                alt_id INTEGER,
                alt_code VARCHAR(50),
                standard VARCHAR(50),
                referencelink VARCHAR(255),
                localname VARCHAR(255),
                iddonar VARCHAR(50),
                donarname VARCHAR(255)
) INHERITS (taxon);


CREATE SEQUENCE unit_idunit_seq;

CREATE TABLE unit (
                idunit INTEGER DEFAULT nextval('unit_idunit_seq'::regclass) NOT NULL,
                unitcode VARCHAR(12) NOT NULL,
                unitdescription VARCHAR(255) NOT NULL,
                unitconversionfactor REAL,
                unitalias VARCHAR(255),
                unitlink VARCHAR(255),
                unitdimension VARCHAR(12),
                idgroup INTEGER,
                groep VARCHAR(60),
                CONSTRAINT pk_unit PRIMARY KEY (idunit)
);
COMMENT ON COLUMN unit.unitconversionfactor IS 'Unit conversion factor.';
COMMENT ON COLUMN unit.idgroup IS 'Group identifier';


ALTER SEQUENCE unit_idunit_seq OWNED BY unit.idunit;


CREATE SEQUENCE spatialreferencedevice_idsrdevice_seq;

CREATE TABLE spatialreferencedevice (
                idsrdevice INTEGER DEFAULT nextval('spatialreferencedevice_idsrdevice_seq'::regclass) NOT NULL,
                srdevicecode SMALLINT NOT NULL,
                srdevicedescription TEXT NOT NULL,
                srdevicelink TEXT,
                CONSTRAINT pk_srdevice PRIMARY KEY (idsrdevice)
);
COMMENT ON COLUMN spatialreferencedevice.srdevicelink IS 'optional link to online source for description';


ALTER SEQUENCE spatialreferencedevice_idsrdevice_seq OWNED BY spatialreferencedevice.idsrdevice;

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


CREATE SEQUENCE sampledevice_idsampledevice_seq;

CREATE TABLE sampledevice (
                idsampledevice INTEGER DEFAULT nextval('sampledevice_idsampledevice_seq'::regclass) NOT NULL,
                sampledevicedescription TEXT,
                sampledevicelink TEXT,
                idgroup INTEGER,
                sampledevicecode INTEGER NOT NULL,
                CONSTRAINT pk_sampledevice PRIMARY KEY (idsampledevice)
);
COMMENT ON COLUMN sampledevice.sampledevicelink IS 'optional link to full description of the device';
COMMENT ON COLUMN sampledevice.idgroup IS 'Group identifier';


ALTER SEQUENCE sampledevice_idsampledevice_seq OWNED BY sampledevice.idsampledevice;

CREATE SEQUENCE organ_idorgan_seq;

CREATE TABLE organ (
                idorgan INTEGER DEFAULT nextval('organ_idorgan_seq'::regclass) NOT NULL,
                organcode VARCHAR(12) NOT NULL,
                organdescription VARCHAR(60) NOT NULL,
                organlink text,
                idgroup INTEGER,
                CONSTRAINT pk_organ PRIMARY KEY (idorgan)
);
COMMENT ON COLUMN organ.idgroup IS 'Group identifier';


ALTER SEQUENCE organ_idorgan_seq OWNED BY organ.idorgan;

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
                idtaxon         INTEGER,
                
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

CREATE TABLE parameter_sediment (

) INHERITS (parameter);

CREATE TABLE parameter_ecology(
    code VARCHAR(20)
) INHERITS (parameter);

CREATE TABLE parameter_quantity(
    code VARCHAR(20)
) INHERITS (parameter);

CREATE TABLE parameter_type(
    code VARCHAR(20)
) INHERITS (parameter);

CREATE TABLE parameter_object(
    code VARCHAR(20)
) INHERITS (parameter);

CREATE TABLE parameter_laboratory(
    code VARCHAR(20)
) INHERITS (parameter);

CREATE TABLE parameter_wave(
    code VARCHAR(20)
) INHERITS (parameter);

CREATE TABLE parameter_undef(
    code VARCHAR(20)
) INHERITS (parameter);

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
REFERENCES property (idproperty)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE property ADD CONSTRAINT fk_property
FOREIGN KEY (idproperty)
REFERENCES property (idproperty)
ON DELETE CASCADE
ON UPDATE CASCADE
NOT DEFERRABLE;

ALTER TABLE property ADD CONSTRAINT uk_property
UNIQUE(propertycode);

ALTER TABLE organ ADD CONSTRAINT fk_group
FOREIGN KEY (idgroup)
REFERENCES "group" (idgroup)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE organ ADD CONSTRAINT uk_organ
UNIQUE(organcode);

ALTER TABLE quality ADD CONSTRAINT fk_group
FOREIGN KEY (idgroup)
REFERENCES "group" (idgroup)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE sampledevice ADD CONSTRAINT fk_group
FOREIGN KEY (idgroup)
REFERENCES "group" (idgroup)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE samplemethod ADD CONSTRAINT fk_group
FOREIGN KEY (idgroup)
REFERENCES "group" (idgroup)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE unit ADD CONSTRAINT fk_group
FOREIGN KEY (idgroup)
REFERENCES "group" (idgroup)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE measurementmethod ADD CONSTRAINT fk_group
FOREIGN KEY (idgroup)
REFERENCES "group" (idgroup)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE measurementmethod ADD CONSTRAINT uk_measurementmethod
UNIQUE(measurementmethodtype);

ALTER TABLE compartment ADD CONSTRAINT fk_group
FOREIGN KEY (idgroup)
REFERENCES "group" (idgroup)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE compartment ADD CONSTRAINT uk_compartment
UNIQUE(compartmentcode);

ALTER TABLE observation ADD CONSTRAINT fk_compartment
FOREIGN KEY (idcompartment)
REFERENCES compartment (idcompartment)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE observation ADD CONSTRAINT fk_measurementmethod
FOREIGN KEY (idmeasurementmethod)
REFERENCES measurementmethod (idmeasurementmethod)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE observation ADD CONSTRAINT fk_samplemethod
FOREIGN KEY (idsamplemethod)
REFERENCES samplemethod (idsamplemethod)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE observation ADD CONSTRAINT fk_quality
FOREIGN KEY (idquality)
REFERENCES quality (idquality)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE observation ADD CONSTRAINT fk_unit
FOREIGN KEY (idunit)
REFERENCES unit (idunit)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

-- FK constraints and inheritance is not working...
--ALTER TABLE observation ADD CONSTRAINT fk_parameter
--FOREIGN KEY (idparameter)
--REFERENCES parameter (idparameter)
--ON DELETE NO ACTION
--ON UPDATE NO ACTION
--NOT DEFERRABLE;

ALTER TABLE observation ADD CONSTRAINT fk_sampledevice
FOREIGN KEY (idsampledevice)
REFERENCES sampledevice (idsampledevice)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE observation ADD CONSTRAINT fk_organ
FOREIGN KEY (idorgan)
REFERENCES organ (idorgan)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE extattribute ADD CONSTRAINT observation_extattribute_fk
FOREIGN KEY (idobservation)
REFERENCES observation (idobservation)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE parameter_chemical ADD CONSTRAINT uk_parameter_chemcial UNIQUE(code);
ALTER TABLE parameter_ecology ADD CONSTRAINT uk_parameter_ecology UNIQUE(code);
ALTER TABLE parameter_laboratory ADD CONSTRAINT uk_parameter_laboratory UNIQUE(code);
ALTER TABLE parameter_object ADD  CONSTRAINT uk_parameter_object UNIQUE(code);
--ALTER TABLE parameter_pesi ADD  CONSTRAINT UNIQUE(?);
ALTER TABLE parameter_physical ADD  CONSTRAINT uk_parameter_physical UNIQUE(code);
ALTER TABLE parameter_quantity ADD  CONSTRAINT uk_parameter_quantity UNIQUE(code);
--ALTER TABLE parameter_sediment ADD  CONSTRAINT uk_parameter_sediment UNIQUE(?);
ALTER TABLE parameter_type ADD  CONSTRAINT uk_parameter_type UNIQUE(code);
ALTER TABLE parameter_undef ADD  CONSTRAINT uk_parameter_undef UNIQUE(code);
ALTER TABLE parameter_wave ADD  CONSTRAINT uk_parameter_wave UNIQUE(code);



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
	,'Niet geimplementeerd' AS "referentievlak.code"
	,'Niet geimplementeerd' AS "monsterbewerkingsmethode.code"
	,sm.samplemethodcode AS "bemonsteringsmethode.code"
	,sd.sampledevicedescription AS "Veldapparaat.omschrijving"
	,o.startdatetime AS "monsternemingsdatum"
	,o.utcoffset AS "UTCoffset"
FROM observation o
JOIN location_point l ON o.idlocation=l.idlocation
JOIN compartment c ON c.idcompartment=o.idcompartment
LEFT JOIN organ g ON g.idorgan=o.idorgan
LEFT JOIN taxon_worms t ON t.idtaxon=o.idtaxon
LEFT JOIN samplemethod sm ON sm.idsamplemethod=o.idsamplemethod
LEFT JOIN sampledevice sd ON sd.idsampledevice=o.idsampledevice
);


CREATE VIEW meting AS (
SELECT
	 o.idobservation AS "Monster.identificatie"
	,o.idobservation AS "Meetpunt.identificatie"
	,p.parameterdescription AS "Parameter.omschrijving"
	,t.scientificname AS "Biotaxon.naam"
	,u.unitcode AS "Eenheid.code"
	,h.propertycode AS "Hoedanigheid.code"
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
JOIN unit u ON u.idunit=o.idunit
JOIN parameter p ON p.idparameter=o.idparameter
JOIN property h ON h.idproperty=o.idproperty
JOIN location_point l on l.idlocation=o.idlocation
LEFT JOIN taxon_worms t ON t.idtaxon=o.idtaxon
LEFT OUTER JOIN quality q ON q.idquality=o.idquality
LEFT OUTER JOIN samplemethod m ON m.idsamplemethod=o.idsamplemethod
);