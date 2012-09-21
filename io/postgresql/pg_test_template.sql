-- Simple datamodel for use in pg_test.m
-- pg_test_template.sql
-- Replace "/" with required table name
-- % $Id: pg_quote.m 7264 2012-09-21 11:27:43Z boer_g $
-- % $Date: 2012-09-21 13:27:43 +0200 (vr, 21 sep 2012) $
-- % $Author: boer_g $
-- % $Revision: 7264 $
-- % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/postgresql/pg_quote.m $
-- % $Keywords: $
CREATE TABLE "?" () WITH (OIDS=FALSE);
ALTER  TABLE "?" OWNER TO postgres;
ALTER  TABLE "?" ADD   COLUMN "ObservationID" integer;
ALTER  TABLE "?" ALTER COLUMN "ObservationID" SET NOT NULL;
CREATE SEQUENCE "?_ObservationID_seq" INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 6 CACHE 1;
ALTER TABLE "?_ObservationID_seq" OWNER TO postgres;
ALTER TABLE "?" ALTER COLUMN "ObservationID" SET DEFAULT nextval('"?_ObservationID_seq"'::regclass);
ALTER TABLE "?" ADD CONSTRAINT "?_pkey" PRIMARY KEY("ObservationID" );
ALTER TABLE "?" ADD COLUMN "Value" real;
