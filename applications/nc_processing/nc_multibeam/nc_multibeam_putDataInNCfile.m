function nc_multibeam_putDataInNCfile(OPT,ncfile,kk,time,Z)

dimSizeX = (OPT.mapsizex/OPT.gridsize)+1;
dimSizeY = (OPT.mapsizey/OPT.gridsize)+1;

%% Open NC file
OPT.WBmsg{2}  = 'Closing NC File';
waitbar(OPT.WBdone,OPT.wb,OPT.WBmsg);

NCid = netcdf.open(ncfile, 'NC_WRITE');

%% add time
varid = netcdf.inqVarID(NCid,'time');
time0 = netcdf.getVar(NCid,varid);

%% add time
if any(time0 == time(kk))
    jj = find(time0 == time(kk),1)-1;
else
    jj = length(time0);
    netcdf.putVar(NCid,varid,jj,1,time(kk)); %#ok<*FNDSB>
end

varid = netcdf.inqVarID(NCid,'z');
if jj ~= length(time0) % then existing nc file already has data
    %% read Z data
    OPT.WBmsg{2}  = 'Reading Z data from NC File';
    waitbar(OPT.WBdone,OPT.wb,OPT.WBmsg);
    
    Z0 = netcdf.getVar(NCid,varid,[0 0 1],[dimSizeY dimSizeX 1]);
    Z0(Z0>1e35) = nan;
    
    %% Merge Z data
    OPT.WBmsg{2}  = 'Merging Z data';
    waitbar(OPT.WBdone,OPT.wb,OPT.WBmsg);
    
    % check if data will be overwritten
    if ~all(isnan(Z0(~isnan(Z))))
        warning('data will be overwritten') %#ok<*WNTAG>
    end
    
    Z0(~isnan(Z)) = Z(~isnan(Z));
    Z = Z0;
end
%% Write z data
OPT.WBmsg{2}  = 'Writing Z data to NC File';
waitbar(OPT.WBdone,OPT.wb,OPT.WBmsg);

netcdf.putVar(NCid,varid,[0 0 jj],[dimSizeX dimSizeY 1],Z);

%% Close NC file
OPT.WBmsg{2}  = 'Closing NC File';
waitbar(OPT.WBdone,OPT.wb,OPT.WBmsg);

netcdf.close(NCid)
end

