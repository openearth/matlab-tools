par_lon = {'longitude','lon','longitude_cen','x','X'};

lon = [];
ii = 1;

while isempty(lon)
    try
        if ii <= length(par_lon)
            lon = nc_varget(ncfile,par_lon{ii});
        else
            lon = nan;
            return;
        end
    catch
        ii = ii + 1;
    end
end