function areacode = jarkus_areaName2AreaCode(areaname)
%JARKUS_AREANAME2AREACODE  returns jarkus area code of selected jarkus area name

url = jarkus_url;
id = nc_varget(url,'id');
areanames = nc_varget(url, 'areaname');
areacodes = nc_varget(url, 'areacode');
ids = strcmp(areaname,cellstr(areanames));
areacode = areacodes(find(ids > 0, 1, 'first'));
