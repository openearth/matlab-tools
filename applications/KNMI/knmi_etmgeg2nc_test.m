function nan=knmi_etmgeg2nc_test
%KNMI_ETMGEG2NC_TEST   viual test for knmi_etmgeg2nc
%
%See also: KNMI_ETMGEG2NC

  locbase = 'F:\checkouts\';

   OPT.directory_nc                           = [locbase,'\OpenEarthRawData\KNMI\etmgeg\processed\'];

fname     = [OPT.directory_nc,'\etmgeg_391.nc'];
fname     = [OPT.directory_nc,'\etmgeg_210.nc'];

D         = nc2struct(fname)
D.datenum = nc_cf_time(fname);

fldnames = fieldnames(D);

for ifld = 1:length(fldnames)
   fldname = fldnames{ifld};
   
   if isnumeric(D.(fldname)) & ...
         length(D.(fldname)) > 1 & ...
          ~strcmpi(fldname,'time') & ...
          ~strcmpi(fldname,'datenum')
   
   plot(D.datenum,D.(fldname));
   datetick('x')
   title({[char(D.station_name),': ',num2str(D.station_id)],...
          mktex(fldname)})
   grid on
   text(0,1,[' values [1 2 end-1 end]: ',num2str(D.(fldname)([1 2 (end-1) end]))],'units','normalized','verticalalignment','top')
   pausedisp
   
   end
   
end
