-- --------------------------------------------------------
-- Host:                         localhost
-- Server versie:                PostgreSQL 9.6.6, compiled by Visual C++ build 1800, 64-bit
-- Server OS:                    
-- HeidiSQL Versie:              9.5.0.5225
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES  */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Structuur van  tabel public.cdi wordt geschreven
CREATE TABLE IF NOT EXISTS "cdi" (
	"id" INTEGER NOT NULL DEFAULT nextval('cdi_id_seq'::regclass) ,
	"geom" GEOMETRY(POINT,4326) NULL DEFAULT NULL ,
	"istimeseries" BOOLEAN NULL DEFAULT NULL ,
	"cdi" CHARACTER VARYING NULL DEFAULT NULL ,
	"local_cdi_id" CHARACTER VARYING NULL DEFAULT NULL ,
	"edmo_code_id" INTEGER NOT NULL ,
	"odvfile_id" INTEGER NOT NULL ,
	"x" DOUBLE PRECISION DEFAULT NULL ,
	"y" DOUBLE PRECISION DEFAULT NULL 
);

-- Data exporteren was gedeselecteerd
-- Structuur van  tabel public.edmo wordt geschreven
CREATE TABLE IF NOT EXISTS "edmo" (
	"id" INTEGER NOT NULL DEFAULT nextval('edmo_id_seq1'::regclass) ,
	"code" INTEGER NULL DEFAULT NULL ,
	"name" CHARACTER VARYING NULL DEFAULT NULL ,
	"odvfile_id" INTEGER NOT NULL 
);

-- Data exporteren was gedeselecteerd
-- Structuur van  tabel public.l20 wordt geschreven
CREATE TABLE IF NOT EXISTS "l20" (
	"id" INTEGER NOT NULL ,
	"identifier" CHARACTER VARYING(1) NULL DEFAULT NULL ,
	"preflabel" CHARACTER VARYING NULL DEFAULT NULL ,
	"altlabel" CHARACTER VARYING NULL DEFAULT NULL ,
	"definition" CHARACTER VARYING NULL DEFAULT NULL 
);

-- Data exporteren was gedeselecteerd
-- Structuur van  tabel public.observation wordt geschreven
CREATE TABLE IF NOT EXISTS "observation" (
	"id" INTEGER NOT NULL DEFAULT nextval('observation_id_seq1'::regclass) ,
	"value" DOUBLE PRECISION DEFAULT NULL ,
	"datetime" TIMESTAMP WITHOUT TIME ZONE NULL DEFAULT NULL ,
	"depth" DOUBLE PRECISION DEFAULT NULL ,
	"parameter_id" INTEGER NOT NULL ,
	"p06_id" INTEGER NOT NULL ,
	"flag_id" INTEGER NOT NULL ,
	"cdi_id" INTEGER NOT NULL ,
	"odvfile_id" INTEGER NOT NULL ,
	"z" DOUBLE PRECISION DEFAULT NULL ,
	"z_id" INTEGER NOT NULL ,
	"z_id_org" INTEGER NULL DEFAULT NULL 
);

-- Data exporteren was gedeselecteerd
-- Structuur van  tabel public.odvfile wordt geschreven
CREATE TABLE IF NOT EXISTS "odvfile" (
	"id" INTEGER NOT NULL ,
	"name" CHARACTER VARYING(64) NULL DEFAULT NULL ,
	"lastmodified" TIMESTAMP WITH TIME ZONE NULL DEFAULT NULL ,
	"size" INTEGER NULL DEFAULT NULL ,
	"sha256hash" BYTEA NULL DEFAULT NULL 
);

-- Data exporteren was gedeselecteerd
-- Structuur van  tabel public.p06 wordt geschreven
CREATE TABLE IF NOT EXISTS "p06" (
	"id" INTEGER NOT NULL ,
	"identifier" CHARACTER VARYING NULL DEFAULT NULL ,
	"preflabel" CHARACTER VARYING NULL DEFAULT NULL ,
	"altlabel" CHARACTER VARYING NULL DEFAULT NULL ,
	"definition" CHARACTER VARYING NULL DEFAULT NULL 
);

-- Data exporteren was gedeselecteerd
-- Structuur van  tabel public.p35_used wordt geschreven
CREATE TABLE IF NOT EXISTS "p35_used" (
	"p35_id" CHARACTER VARYING NULL DEFAULT NULL ,
	"p35" CHARACTER VARYING NULL DEFAULT NULL ,
	"p36_id" INTEGER NULL DEFAULT NULL ,
	"preflabel" CHARACTER VARYING NULL DEFAULT NULL ,
	"geom" GEOMETRY NULL DEFAULT NULL ,
	"zidentifier" CHARACTER VARYING NULL DEFAULT NULL 
);

-- Data exporteren was gedeselecteerd
-- Structuur van  tabel public.p36 wordt geschreven
CREATE TABLE IF NOT EXISTS "p36" (
	"id" INTEGER NOT NULL ,
	"identifier" CHARACTER VARYING NULL DEFAULT NULL ,
	"preflabel" CHARACTER VARYING NULL DEFAULT NULL ,
	"altlabel" CHARACTER VARYING NULL DEFAULT NULL ,
	"definition" CHARACTER VARYING NULL DEFAULT NULL 
);

-- Data exporteren was gedeselecteerd
-- Structuur van  tabel public.p36_colorvalues wordt geschreven
CREATE TABLE IF NOT EXISTS "p36_colorvalues" (
	"min" DOUBLE PRECISION DEFAULT NULL ,
	"max" DOUBLE PRECISION DEFAULT NULL ,
	"id" INTEGER NULL DEFAULT NULL 
);

-- Data exporteren was gedeselecteerd
-- Structuur van  tabel public.parameter wordt geschreven
CREATE TABLE IF NOT EXISTS "parameter" (
	"id" INTEGER NOT NULL ,
	"identifier" CHARACTER VARYING NULL DEFAULT NULL ,
	"preflabel" CHARACTER VARYING NULL DEFAULT NULL ,
	"altlabel" CHARACTER VARYING NULL DEFAULT NULL ,
	"definition" CHARACTER VARYING NULL DEFAULT NULL ,
	"origin" CHARACTER VARYING NULL DEFAULT NULL ,
	"p36_id" INTEGER NULL DEFAULT NULL ,
	"p35" TEXT NULL DEFAULT NULL 
);

-- Data exporteren was gedeselecteerd
-- Structuur van  tabel public.parameter_copy wordt geschreven
CREATE TABLE IF NOT EXISTS "parameter_copy" (
	"id" INTEGER NULL DEFAULT NULL ,
	"identifier" CHARACTER VARYING NULL DEFAULT NULL ,
	"preflabel" CHARACTER VARYING NULL DEFAULT NULL ,
	"altlabel" CHARACTER VARYING NULL DEFAULT NULL ,
	"definition" CHARACTER VARYING NULL DEFAULT NULL ,
	"origin" CHARACTER VARYING NULL DEFAULT NULL ,
	"p36_id" INTEGER NULL DEFAULT NULL 
);

-- Data exporteren was gedeselecteerd
-- Structuur van  tabel public.regions wordt geschreven
CREATE TABLE IF NOT EXISTS "regions" (
	"id" INTEGER NULL DEFAULT NULL ,
	"name" CHARACTER VARYING(64) NULL DEFAULT NULL ,
	"region" TEXT NULL DEFAULT NULL 
);

-- Data exporteren was gedeselecteerd
-- Structuur van  tabel public.spatial_ref_sys wordt geschreven
CREATE TABLE IF NOT EXISTS "spatial_ref_sys" (
	"srid" INTEGER NOT NULL ,
	"auth_name" CHARACTER VARYING(256) NULL DEFAULT NULL ,
	"auth_srid" INTEGER NULL DEFAULT NULL ,
	"srtext" CHARACTER VARYING(2048) NULL DEFAULT NULL ,
	"proj4text" CHARACTER VARYING(2048) NULL DEFAULT NULL ,
	PRIMARY KEY ("srid")
);

-- Data exporteren was gedeselecteerd
-- Structuur van  tabel public.z wordt geschreven
CREATE TABLE IF NOT EXISTS "z" (
	"id" INTEGER NOT NULL ,
	"identifier" CHARACTER VARYING NULL DEFAULT NULL ,
	"p06_unit" CHARACTER VARYING NULL DEFAULT NULL ,
	"preflabel" CHARACTER VARYING NULL DEFAULT NULL ,
	"altlabel" CHARACTER VARYING NULL DEFAULT NULL ,
	"definition" CHARACTER VARYING NULL DEFAULT NULL ,
	"p06_id" INTEGER NOT NULL ,
	"parameterid" INTEGER NULL DEFAULT NULL 
);

-- Data exporteren was gedeselecteerd
-- Structuur van  tabel public.z_copy wordt geschreven
CREATE TABLE IF NOT EXISTS "z_copy" (
	"id" INTEGER NULL DEFAULT NULL ,
	"identifier" CHARACTER VARYING NULL DEFAULT NULL ,
	"p06_unit" CHARACTER VARYING NULL DEFAULT NULL ,
	"preflabel" CHARACTER VARYING NULL DEFAULT NULL ,
	"altlabel" CHARACTER VARYING NULL DEFAULT NULL ,
	"definition" CHARACTER VARYING NULL DEFAULT NULL ,
	"p06_id" INTEGER NULL DEFAULT NULL 
);

-------------------------------
CREATE TABLE if not exists "public".p35xml
(
  xml_row_number BIGINT
, xml_data_type_description VARCHAR(25)
, xml_element_id BIGINT
, xml_parent_element_id BIGINT
, xml_element_level BIGINT
, xml_path VARCHAR(1024)
, xml_parent_path VARCHAR(1024)
, xml_data_name VARCHAR(1024)
, xml_data_value VARCHAR(1024)
);

create table if not exists "public".observationset (
	odvfile_id int
	, cdi_id int
	, datetime timestamp
	, p01codes varchar
);

create table if not exists "public".observationset_parameter (
	odvfile_id int
	, cdi_id int
	, datetime timestamp
	, parameter_id int
	, p01list varchar[]
);

