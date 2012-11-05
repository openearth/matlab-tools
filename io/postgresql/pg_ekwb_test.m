function OK = pg_ekwb_test
%PG_EKWB_TEST test for pg_ekwb
%
%See also: pg_ekwb

OK = [];

%% http://en.wikipedia.org/wiki/Well-known_text
[t,s,x,y  ]=pg_ewkb('000000000140000000000000004010000000000000'                );OK(end+1) = (t==1) & (isempty(s)) & (x==2) & (y==4); % http://en.wikipedia.org/wiki/Well-known_text

%% http://postgis.refractions.net/docs/using_postgis_dbmanagement.html#EWKB_EWKT
[t,s,x,y  ]=pg_ewkb('01010000200400000000000000000000000000000000000000'        );OK(end+1) = (t==1) & (s==4      ) & (x==0) & (y==0);

%% http://jaspa.upv.es/jaspa/v0.2.0/manual/html/ST_GeomFromEWKB.html
[t,s,x,y  ]=pg_ewkb('010100000000000000000014400000000000001440'                );OK(end+1) = (t==1) & (isempty(s)) & (x==5) & (y==5);
[t,s,x,y  ]=pg_ewkb('0101000020e664000000000000000014400000000000001440'        );OK(end+1) = (t==1) & (s==25830  ) & (x==5) & (y==5);

%% https://docs.djangoproject.com/en/dev/ref/contrib/gis/geos/
[t,s,x,y  ]=pg_ewkb('0101000000000000000000F03F000000000000F03F'                );OK(end+1) = (t==1) & (isempty(s)) & (x==1) & (y==1);
[t,s,x,y  ]=pg_ewkb('00000000013FF00000000000003FF0000000000000'                );OK(end+1) = (t==1) & (isempty(s)) & (x==1) & (y==1);
[t,s,x,y  ]=pg_ewkb('0101000020E6100000000000000000F03F000000000000F03F'        );OK(end+1) = (t==1) & (s==4326   ) & (x==1) & (y==1);
[t,s,x,y,z]=pg_ewkb('0101000080000000000000F03F000000000000F03F000000000000F03F');OK(end+1) = (t==1) & (isempty(s)) & (x==1) & (y==1) & (z==1);

%% http://svn.osgeo.org/postgis/trunk/regress/wkb_expected
%  http://svn.osgeo.org/postgis/trunk/regress/wkb.sql

OK = all(OK);