function nc_multibeam_putDataInNCfile(OPT,ncfile,time,Z)
%NC_MULTIBEAM_PUTDATAINNCFILE
%
%   nc_multibeam_putdatainncfile(OPT,ncfile,time,Z)
%
% adds variable to a netcdf file (incl time) using matlabs native (2008b+) netcdf
%
%See also: nc_multibeam

dimSizeX = (OPT.mapsizex/OPT.gridsizex)+1;
dimSizeY = (OPT.mapsizey/OPT.gridsizex)+1;

%% Open NC file
NCid = netcdf.open(ncfile, 'NC_WRITE');

%% get current timesteps in nc file
varid = netcdf.inqVarID(NCid,'time');
time0 = netcdf.getVar(NCid,varid);

%% add time if it is not already in nc file
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
    % Z0(Z0>1e35) = nan; Should not be necessary to manually set high values to nan
    Znotnan  = ~isnan(Z);
    Z0notnan = ~isnan(Z0);
    notnan   = Znotnan&~Z0notnan);
    % check if data will be overwritten
    if any(notnan) % values are not nan in both existing and new data
        [~,filename] = fileparts(ncfile);
         if isequal(Z0(notnan) - Z(notnan))
            % this is ok
            fprintf(1,'in %s, data is overwritten by identical values from a different source \n',filename)
        else 
            % this is (most likely) not ok   
            fprintf(2,'in %s, data is overwritten by different values from a different source \n',filename)
        end
    end
    Z0(Znotnan) = Z(Znotnan);
    Z = Z0;
end

%% Write z data
netcdf.putVar(NCid,varid,[0 0 jj],[dimSizeX dimSizeY 1],Z);

%% Close NC file
netcdf.close(NCid)
end

