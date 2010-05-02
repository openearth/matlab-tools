function OPT = grid_orth_getTimeInfoInPolygon(OPT)

maps = grid_orth_identifyWhichMapsAreInPolygon(OPT, OPT.polygon);

varinfo_t = nc_varfind(maps{1},'attributename', 'standard_name', 'attributevalue', 'time');
OPT.inputtimes     = [];
for i = 1:length(maps)
    OPT.inputtimes = unique([OPT.inputtimes; nc_cf_time(maps{i}, varinfo_t)]);
end
        