function varargout = nc_cf_time(varargin)
%NC_CF_TIME   readfs all time variables from a netCDF file inot Matlab datenumber
%
%   datenumbers = nc_cf_time(ncfile);
%
% extract time vectors from netCDF file ncfile as Matlab datenumbers, 
% where time is defined according to the CF convention as in:
%
% http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#time-coordinate
% http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/ch04s04.html
%
% When there is only one time variable, an array is returned,
% otherwise a warning is thrown.
%
%See also: NC_CF_NC_CF_STATIONTIMESERIES, NC_CF_GRID, UDUNITS2DATENUM

   if ischar(varargin{1})
      fileinfo = nc_info(varargin{1});
   else
      fileinfo = varargin{1};
   end
   
   %% cycle Dimensions
   % index = [];
   % for idim=1:length(fileinfo.Dimension)
   %    if strcmpi(fileinfo.Dimension(idim).Name,'TIME');
   %    index = [index idim];
   %    end
   % end
   
   %% cycle Datasets
   %  all time datasets must have an associated time Dimension
   index = [];
   name  = {};
   nt    = 0;
   for idim=1:length(fileinfo.Dataset)
      if     strcmpi(fileinfo.Dataset(idim).Name     ,'time') & ...
         any(strcmpi(fileinfo.Dataset(idim).Dimension,'time'));
      nt        = nt+1;
      index(nt) =                   idim;
      name {nt} =  fileinfo.Dataset(idim).Name;
      end
   end
   
   %% get data
   for ivar=1:length(index)
      M(ivar).datenum.units = nc_attget(fileinfo.Filename,name{ivar},'units');
      D(ivar).datenum       = nc_varget(fileinfo.Filename,name{ivar});
      D(ivar).datenum       = udunits2datenum(D.datenum,M.datenum.units);
   end
   
if nargout<2
   if length(index)==1
      varargout = {D(1).datenum};
   else
      warning('multiple time vecots present, please specify furter.')
   end
end

%% EOF