function nc_multibeam_putDataInNCfile(OPT,ncfile,time,Z)

dimSizeX = (OPT.mapsizex/OPT.gridsizex)+1;
dimSizeY = (OPT.mapsizey/OPT.gridsizex)+1;

%% Open NC file
NCid = netcdf.open(ncfile, 'NC_WRITE');

%% add time
varid = netcdf.inqVarID(NCid,'time');
time0 = netcdf.getVar(NCid,varid);

%% add time
if any(time0 == time)
    jj = find(time0 == time,1)-1;
else
    jj = length(time0);
    netcdf.putVar(NCid,varid,jj,1,time); %#ok<*FNDSB>
end

varid = netcdf.inqVarID(NCid,'z');

%% Merge Z data with existing data if it exists
if jj ~= length(time0) % then existing nc file already has data
    % read Z data
    Z0 = netcdf.getVar(NCid,varid,[0 0 jj],[dimSizeX dimSizeY 1]);
    Z0(Z0>1e35) = nan;
    
    % check if data will be overwritten
    if ~all(isnan(Z0(~isnan(Z))))
        if max(Z0(~isnan(Z0)&~isnan(Z)) - Z(~isnan(Z0)&~isnan(Z)))>0
            warning('data will be overwritten') %#ok<*WNTAG>
        else
            disp('in an nc, data will be overwritten by identical values from a different source')
        end
    end
    Z0(~isnan(Z)) = Z(~isnan(Z));
    Z = Z0;
end

%% Write z data
netcdf.putVar(NCid,varid,[0 0 jj],[dimSizeX dimSizeY 1],Z);

%% Close NC file
netcdf.close(NCid)
end

