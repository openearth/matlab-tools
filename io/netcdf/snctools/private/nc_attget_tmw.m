function values = nc_attget_tmw(ncfile,varname,attrname)

ncid=netcdf.open(ncfile,'NOWRITE');

% Assume that the location is in the root group until we know
% otherwise.  
gid = ncid;


% If the library is > 4 and the format is unrestricted netcdf-4, then we
% may need to drill down thru the groups.
lv = netcdf.inqLibVers;
if lv(1) == '4'
    fmt = netcdf.inqFormat(ncid);
    if strcmp(fmt,'FORMAT_NETCDF4') && (numel(strfind(varname,'/')) > 0)
        varpath = regexp(varname,'/','split');
        for k = 2:numel(varpath)-1
            gid = netcdf.inqNcid(gid,varpath{k});
        end
        
        % Is it a group or a variable?
        try
            gid_last = netcdf.inqNcid(gid,varpath{end});
            % It's a group.
            loc_id = gid_last;
            varid = -1;
        catch me
            loc_id = gid;
            varid = netcdf.inqVarID(loc_id,varpath{end});
        end
        values = netcdf.getAtt(loc_id,varid,attrname);
        netcdf.close(ncid);
            
        return
    end
end



% Backwards compat mode.
try

    switch class(varname)
    case { 'double' }
        varid = varname;

    case 'char'
        varid = figure_out_varid_tmw ( ncid, varname );

    otherwise
        error('SNCTOOLS:NC_ATTGET:badType', ...
            'Must specify either a variable name or NC_GLOBAL' );

    end

    values = netcdf.getAtt(ncid,varid,attrname);
	netcdf.close(ncid);
	return

catch me
	netcdf.close(ncid);
    rethrow(me);
end
return













%--------------------------------------------------------------------------
function varid = figure_out_varid_tmw ( ncid, varname )
% Did the user do something really stupid like say 'global' when they meant
% NC_GLOBAL?
if isempty(varname)
    varid = nc_global;
    return;
end

if ( strcmpi(varname,'global') )
    try 
        varid = netcdf.inqVarID(ncid,varname);
        return
    catch %#ok<CTCH>
        %
        % Ok, the user meant NC_GLOBAL
        warning ( 'SNCTOOLS:nc_attget:doNotUseGlobalString', ...
                  ['Please consider using the m-file NC_GLOBAL.M ' ...
                   'instead of the string ''%s''.'], varname );
        varid = nc_global;
        return;
    end
else
    varid = netcdf.inqVarID(ncid,varname);
end



