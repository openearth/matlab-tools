% Python netcdf4 1.0 'NETCDF4' file doe snot work in matlab R2011a
%
%See also: fix_creation_order_issue

ncversions = {'NETCDF3_64BIT'
              'NETCDF3_CLASSIC'
              'NETCDF4_CLASSIC'
              'NETCDF4'
              'NETCDF4_CLASSIC_fixed_for_matlab_R2011a'}
              
copyfile('NETCDF4_CLASSIC.nc','NETCDF4_CLASSIC_fixed_for_matlab_R2011a.nc')

% remove '_Netcdf4Dimid'
fix_creation_order_issue('NETCDF4_CLASSIC_fixed_for_matlab_R2011a.nc');
              
for inc=1:length(ncversions)

  ncversion = ncversions{inc};

  % netCDF-java backend (*_java.cdl)
  setpref('SNCTOOLS','USE_NETCDF_JAVA',1);
  
  fid = fopen([ncversion,'_java.cdl'],'w');
  try
    tmp=javaclasspath;
    fprintf(fid,'// Created with Matlab: %s \r\n',version('-release'));
    fprintf(fid,'// with javaclasspath: \r\n');
    for i=1:length(tmp)
    fprintf(fid,'// *  %s \r\n',filenameext(tmp{i}));
    end
    nc_dump([ncversion,'.nc'],fid);
    I = ncinfo([ncversion,'.nc']);disp(I.Format)
  catch
    fprintf(fid,'%s \r\n','// error ');
  end
  fclose(fid);

  % netCDF-c-based native mathworks backend (*_tmw.cdl)
  setpref('SNCTOOLS','USE_NETCDF_JAVA',0);
  
  fid = fopen([ncversion,'_tmw.cdl'],'w');
  try
    fprintf(fid,'// Created with Matlab: %s \r\n',version('-release'));
    nc_dump([ncversion,'.nc'],fid);
  catch
    fprintf(fid,'%s \r\n','// error ');
  end
  fclose(fid);

end
