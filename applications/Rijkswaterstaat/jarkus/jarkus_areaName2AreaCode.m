function areacode = jarkus_areaName2AreaCode(areaname)
%JARKUS_AREANAME2AREACODE  returns jarkus area code of selected jarkus area name

url = jarkus_url;
areanames = nc_varget(url, 'areaname');
areacodes = nc_varget(url, 'areacode');
if size(areaname,1) == 1
    ids = strcmp(areaname,cellstr(areanames));
    areacode = areacodes(find(ids > 0, 1, 'first'));
else
    [dum idcell] = ismember(areaname,cellstr(areanames));
    areacode = areacodes(idcell(idcell>0));
end

