%NC_NANTEST  This shows how NaNs behave in snctools
%
% Values indentical to _Fillvalue are returned as NaN.
% NaNs in the data are returned as NaN, so there is no nead to specify 
% NaN as _Fillvalue
%
%See also: nan, scntools

% TO DO: check also for C interface in addition to java interface
% TO DO: check also for native 2009a matlab interface in addition to java interface
% TO DO: move to scntools

try
   rmpath('Y:\app\matlab\toolbox\wl_mexnc\')
end   

%% Initialize
%------------------

   OPT.dump          = 1;

%% 0 Read raw data
%------------------

   D.datenum = now + [0 1 2 3];
   D.data    = [nan 0 1 2];
   
%% 1a Create file
%------------------

   outputfile    = [pwd,filesep,'nc_nantest.nc'];
   
   nc_create_empty (outputfile)

%% 2 Create dimensions
%------------------

   nc_add_dimension(outputfile, 'time'     , length(D.datenum))

%% 3 Create variables
%------------------
   clear nc

      ifld = 1;
   nc(ifld).Name         = 'var0';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'time'};
   nc(ifld).Attribute(1) = struct('Name', '_FillValue'     ,'Value', -1);

      ifld = ifld + 1;
   nc(ifld).Name         = 'var1';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'time'};
   nc(ifld).Attribute(1) = struct('Name', '_FillValue'     ,'Value', nan);

      ifld = ifld + 1;
   nc(ifld).Name         = 'var2';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'time'};
   nc(ifld).Attribute(1) = struct('Name', '_FillValue'     ,'Value', 0);

      ifld = ifld + 1;
   nc(ifld).Name         = 'var3';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'time'};
   nc(ifld).Attribute(1) = struct('Name', '_FillValue'     ,'Value', 1);

      ifld = ifld + 1;
   nc(ifld).Name         = 'var4';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'time'};
   nc(ifld).Attribute(1) = struct('Name', '_FillValue'     ,'Value', 2);

%% 4 Create attibutes
%------------------

   for ifld=1:length(nc)
      nc_addvar(outputfile, nc(ifld));   
   end

%% 5 Fill variables
%------------------

   nc_varput(outputfile, 'var0', D.data); % NaN is returned as NaN: behaves same as var1
   nc_varput(outputfile, 'var1', D.data); % NaN is returned as NaN: behaves same as var0
   nc_varput(outputfile, 'var2', D.data); % NaN an 0 are returned as NaN 
   nc_varput(outputfile, 'var3', D.data); % NaN an 1 are returned as NaN
   nc_varput(outputfile, 'var4', D.data); % NaN an 2 are returned as NaN

%% 6 Check
%------------------

   if OPT.dump
   nc_dump(outputfile);
   end
   
   DMP = nc_getall(outputfile);
   
   ['initial data',num2str([])                ,' data: ', num2str(D.data)]
   disp('------------------------------------------')
   ['FillValue:  ',num2str(DMP.var0.FillValue),' data: ', num2str(DMP.var0.data')]
   ['FillValue:  ',num2str(DMP.var1.FillValue),' data: ', num2str(DMP.var1.data')]
   ['FillValue:  ',num2str(DMP.var2.FillValue),' data: ', num2str(DMP.var2.data')]
   ['FillValue:  ',num2str(DMP.var3.FillValue),' data: ', num2str(DMP.var3.data')]
   ['FillValue:  ',num2str(DMP.var4.FillValue),' data: ', num2str(DMP.var4.data')]
   
%% EOF
