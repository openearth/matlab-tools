drop table "public".BiologischKenmerk;

CREATE TABLE if not exists "public".BiologischKenmerk
(
  ID BIGINT primary key
, Code VARCHAR(30)
, Omschrijving VARCHAR(60)
, Groep VARCHAR(17)
, D_BEGIN date
, D_EIND date
, D_STATUS VARCHAR(1)
)
;CREATE INDEX if not exists idx_BiologischKenmerk_lookup ON "public".BiologischKenmerk(Code)
;
