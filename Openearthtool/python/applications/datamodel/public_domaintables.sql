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

CREATE SEQUENCE valuetype_idvaluetype_seq;

CREATE TABLE valuetype (
                idvaluetype INTEGER DEFAULT nextval('valuetype_idvaluetype_seq'::regclass) NOT NULL,
                valuetypecode VARCHAR(5) NOT NULL,
                valuetypedescription TEXT NOT NULL,
                idgroup INTEGER,
                CONSTRAINT pk_idvaluetype PRIMARY KEY (idvaluetype)
);
COMMENT ON TABLE valuetype IS 'TypeWaardebewerkingmethodeType';
COMMENT ON COLUMN valuetype.idgroup IS 'Group identifier';


ALTER SEQUENCE valuetype_idvaluetype_seq OWNED BY valuetype.idvaluetype;


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
                donarname VARCHAR(255),
		source VARCHAR(50)
) INHERITS (taxon);
COMMENT ON COLUMN taxon_worms.source IS 'Geeft de bron aan van de data, geleverde data van vliz is niet compleet.';

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


ALTER SEQUENCE organ_idorgan_seq OWNED BY organ.idorgan;

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

ALTER TABLE property ADD CONSTRAINT fk_property
FOREIGN KEY (idproperty)
REFERENCES property (idproperty)
ON DELETE CASCADE
ON UPDATE CASCADE
NOT DEFERRABLE;

ALTER TABLE property ADD CONSTRAINT uk_property
UNIQUE(propertycode);

ALTER TABLE organ ADD CONSTRAINT uk_organ
UNIQUE(organcode);

ALTER TABLE valuetype ADD CONSTRAINT uk_valuetype
UNIQUE(valuetypecode);

ALTER TABLE organ ADD CONSTRAINT fk_group
FOREIGN KEY (idgroup)
REFERENCES "group" (idgroup)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE valuetype ADD CONSTRAINT fk_group
FOREIGN KEY (idgroup)
REFERENCES "group" (idgroup)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

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

ALTER TABLE compartment ADD CONSTRAINT fk_group
FOREIGN KEY (idgroup)
REFERENCES "group" (idgroup)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE compartment ADD CONSTRAINT uk_compartment
UNIQUE(compartmentcode);

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

