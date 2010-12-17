function Dataset = nc_getvarinfo_tmw ( arg1, arg2 )
% TMW backend for NC_GETVARINFO
%
%   Dataset = nc_getvarinfo_tmw (ncfile,varname)
%   Dataset = nc_getvarinfo_tmw (ncid  ,varid  )
%
%     Dataset:
%         array of metadata structures.  The fields are
%         
%         Name
%         Nctype
%         Unlimited
%         Dimension
%         Attribute
%         Size
%
%See also: nc_info, netcdf

if ischar(arg1) && ischar(arg2)
    % We were given a char filename and a char varname.

    ncfile  = arg1;
    varname = arg2;

    ncid=netcdf.open(ncfile,'NOWRITE');
    try
        varid = netcdf.inqVarID(ncid, varname);
        Dataset = nc_getvarinfo_tmw ( ncid,  varid );
    catch me
        netcdf.close(ncid);
        rethrow(me);
    end
    
    netcdf.close(ncid);

elseif isnumeric ( arg1 ) && isnumeric ( arg2 )
    % We were given a numeric file handle and a numeric id.

    ncid  = arg1;
    varid = arg2;

    %% Variable

    [varname,xtype,dimids,natts] = netcdf.inqVar( ncid,  varid );
    [ndims,nvars,ngatts,unlimdimid] = netcdf.inq(ncid);

    Dataset.Name      = varname;
    Dataset.Nctype    = xtype;
    Dataset.Datatype  = xtype2Datatype(xtype);
    Dataset.Unlimited = 0; % set to 1 if one found
    Dataset.Dimension = {};
    Dataset.Size      = [];
    for dimid=dimids(:)'
       [dimname,length] = netcdf.inqDim(ncid,dimid);
       Dataset.Dimension{end+1} = dimname;
       Dataset.Size(end+1)      = length;
       if any(dimid==unlimdimid)
          Dataset.Unlimited = 1;
       end
     end

    %% Attribute

    for iatt=1:natts
        
       attname = netcdf.inqAttName(ncid,varid,iatt-1); % zero based !
       Dataset.Attribute(iatt).Name     = attname;
       [xtype,attlen]                   = netcdf.inqAtt(ncid,varid,attname);
       Dataset.Attribute(iatt).Nctype   = xtype;
       Dataset.Attribute(iatt).Datatype = xtype2Datatype(xtype);
       value                            = netcdf.getAtt(ncid,varid,attname);
       if isnumeric(value);value = value(:); end % make same size as java version
       Dataset.Attribute(iatt).Value    = value;
    end
    
else
    error ( 'SNCTOOLS:NC_GETVARINFO:tmw:badTypes', ...
            'Must have either both character inputs, or both numeric.' );
end

return

%% subsidiary (used for both variables and attributes)

function Datatype = xtype2Datatype(xtype)

    switch ( xtype )
    case nc_double;Datatype = 'double';
    case nc_float; Datatype = 'single';
    case nc_int;   Datatype = 'int32';
    case nc_short; Datatype = 'int16';
    case nc_char;  Datatype = 'char';
    case nc_byte;  Datatype = 'int8';
   %case nc_??;    Datatype = 'uint8'; % help netcdf.getAtt
    otherwise 
        error ( 'SNCTOOLS:NC_GETVARINFO:tmw:unhandledDatatype', ...
            '%s:  unhandled datatype ''%s''\n', datatype );
    end




